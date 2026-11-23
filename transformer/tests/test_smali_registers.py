#!/usr/bin/env python3
"""Anti-REA v1.0 — regression tests for the high-register fixup
(transformer/smali.py: _fixup_high_regs / _plan_fix).

Regression: L55 chunking bumped `.locals` by 4, which pushed a
parameter register above v15 in methods with high `.locals`, and
the fixup only knew how to rewrite plain invokes and moves — any
other nibble-limited instruction (22c iget/iput field ops, 22t
branches, 12x unary ops, const/4) made `protect` abort with
"unfixable high parameter register". The first failure was
ArrayDeque.retainAll/removeAll (`.locals 11` -> 15, p1 at v16):
`iput p1, p0, ...->size:I`. The full L55 sweep failed 12 files
(iput, iget-object, if-gt/if-lt, neg-long, const/4, plus two
invokes needing 5 temp slots with only 4 available).

21c CORRECTION (2026-11-23): sget/sput are format 21c — ONE 8-bit
register + 16-bit field ref — NOT 22c, so `sget-object v18` in
Bridge SessionActivity.refresh() (.locals 25) is legal and must
pass through the fixup UNCHANGED. An earlier version of both this
checker and the fixup wrongly classed sget/sput as 22c: the fixup
pointlessly rewrote valid `sget-object p3` (testapp
EncodeOutputStream) and aborted the Bridge 2.14.0 protect on the
legal `sget-object v18`. The tests below pin the correction:
high-register sget/sput stay byte-identical, while a real 22c
high-param iput is still fixed.

22s CORRECTION (2026-11-23): `*-lit16` ops are format 22s — TWO
4-bit registers + a 16-bit literal — NOT 8-bit, despite the
fixup's old table (and this checker's old table) listing them as
8-bit. smali proves it: `and-int/lit16 p14, p13, 0x80` with
.locals 3 fails assembly ("Invalid register: v17"), and the
Bridge 2.14.0 rebuild died on exactly that line
(AdminAttentionItem.copy$default). The 22b `*-lit8` ops ARE 8-bit
(smali accepts them at v17). The tests below pin the correction:
a high-param lit16 is rewritten through temps, a low-reg lit16
is left alone.

Run from the v1.0 directory:
    python3 -m unittest transformer.tests.test_smali_registers -v
or:
    python3 transformer/tests/test_smali_registers.py
Stdlib only. Each test feeds a small smali method with a high
parameter register through the suspect pass(es) and asserts the
output is still register-valid — every nibble-limited instruction
resolves to v0-v15 given the method's `.locals` count — and that
the transform actually applied (not silently skipped). These tests
FAIL on the old code (chunk_string_literals raises RuntimeError)
and pass on the fixed code. Temp files go under /home/hatch/tmp
and are removed afterwards.
"""
import re
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import smali as sm

TMP_BASE = "/home/hatch/tmp"

# --- a miniature Dalvik register-validity checker (independent of
# the fixup's own tables: it encodes the format limits directly) ---
_FOUR_BIT_OPS = {
    "move", "move-wide", "move-object",
    "array-length",
    "neg-int", "neg-long", "neg-float", "neg-double",
    "not-int", "not-long",
    "int-to-long", "int-to-float", "int-to-double",
    "long-to-int", "long-to-float", "long-to-double",
    "float-to-int", "float-to-long", "float-to-double",
    "double-to-int", "double-to-long", "double-to-float",
    "int-to-byte", "int-to-char", "int-to-short",
    "const/4",
    # 22s literal-short ops: 4-bit, NOT 8-bit (the 16-bit literal
    # occupies the rest of the code unit) — smali-proven 2026-11-23:
    # `and-int/lit16 p14, p13, 0x80` with .locals 3 fails assembly
    # ("Invalid register: v17"). An earlier version of this checker
    # (and the fixup) wrongly treated them as 8-bit. The 22b
    # *-lit8 ops stay 8-bit and are NOT listed here.
    "add-int/lit16", "rsub-int", "mul-int/lit16", "div-int/lit16",
    "rem-int/lit16", "and-int/lit16", "or-int/lit16",
    "xor-int/lit16",
}
_FOUR_BIT_2ADDR = {
    "add-int", "sub-int", "mul-int", "div-int", "rem-int",
    "and-int", "or-int", "xor-int", "shl-int", "shr-int", "ushr-int",
    "add-long", "sub-long", "mul-long", "div-long", "rem-long",
    "and-long", "or-long", "xor-long", "shl-long", "shr-long",
    "ushr-long",
    "add-float", "sub-float", "mul-float", "div-float", "rem-float",
    "add-double", "sub-double", "mul-double", "div-double",
    "rem-double",
}
# 22c field ops are iget/iput ONLY (two 4-bit registers). sget/sput
# are 21c (one 8-bit register) and must NOT be listed here — an
# earlier version of this checker classed them as 4-bit, which made
# a legal `sget-object v18` look like a violation.
_FIELD_RE = re.compile(
    r"^(iget|iput)(?:-wide|-object|-boolean|-byte|-char|-short)?$")
_BRANCH2_RE = re.compile(r"^if-(?:eq|ne|lt|ge|gt|le)$")
_REG_RE = re.compile(r"\b([vp])(\d+)\b")


def check_registers_valid(text):
    """Return a list of (lineno, line) for instructions whose
    registers violate the Dalvik format limits: 4-bit ops (12x,
    22c iget/iput, 22s *-lit16, 22t, 35c plain invoke,
    filled-new-array, const/4) must use v0-v15; every other
    register reference (8-bit ops, including 21c sget/sput with
    one 8-bit register and 22b *-lit8) must use v0-v255. /16 and
    /range forms are 16-bit and exempt.
    String literals are stripped before scanning so a literal such
    as "p9" is never mistaken for a register."""
    errors = []
    locals_n = None
    for lineno, raw in enumerate(text.splitlines(), 1):
        line = raw.split('"', 1)[0]
        m = re.match(r"\s*\.locals\s+(\d+)", line)
        if m:
            locals_n = int(m.group(1))
            continue
        if re.match(r"\s*\.method\s+", line):
            locals_n = None
            continue
        if re.match(r"\s*\.registers\s+\d+", line):
            locals_n = None  # transforms skip .registers methods
            continue
        if locals_n is None:
            continue
        om = re.match(r"^\s*([a-z][\w/-]*)", line)
        if not om:
            continue
        op = om.group(1)
        if "/16" in op or "/range" in op or "/jumbo" in op:
            continue
        regs = [(k, int(n)) for k, n in _REG_RE.findall(line)]

        def absidx(k, n):
            return locals_n + n if k == "p" else n

        if (op in _FOUR_BIT_OPS or _FIELD_RE.match(op)
                or _BRANCH2_RE.match(op)
                or op in ("instance-of", "new-array")
                or (op.startswith("invoke-"))
                or op == "filled-new-array"
                or (op.endswith("/2addr")
                    and op[:-len("/2addr")] in _FOUR_BIT_2ADDR)):
            for k, n in regs:
                if absidx(k, n) > 15:
                    errors.append((lineno, raw.strip()))
        else:
            for k, n in regs:
                if absidx(k, n) > 255:
                    errors.append((lineno, raw.strip()))
    return errors


def assert_valid(testcase, text):
    errs = check_registers_valid(text)
    testcase.assertEqual(
        errs, [], "register-validity violations: %s" % (errs,))


LONG_LITERAL = "a-long-literal-string-for-chunking"


def _smali_file(tmpdir, name, body):
    p = Path(tmpdir) / name
    p.write_text(body, encoding="utf-8")
    return p


class TestChunkHighParamRegisters(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory(dir=TMP_BASE)
        self.tmp = Path(self._tmp.name)

    def tearDown(self):
        self._tmp.cleanup()

    def _chunk(self, path):
        stats = {}
        sm.chunk_string_literals(path, stats=stats)
        return path.read_text(encoding="utf-8"), stats

    def test_iput_high_param_retainall(self):
        # The original failure: ArrayDeque.retainAll, .locals 11 -> 15,
        # p1 at v16 in `iput p1, p0, ...->size:I` (22c, 4-bit).
        src = """
.class public Lkotlin/collections/ArrayDeque;
.super Ljava/lang/Object;

.method public retainAll(Ljava/util/Collection;)Z
    .locals 11
    const-string v0, "%s"
    invoke-static {v0}, Lkotlin/collections/ArrayDeque;->useString(Ljava/lang/String;)V
    iput p1, p0, Lkotlin/collections/ArrayDeque;->size:I
    const/4 v0, 0x1
    return v0
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "ArrayDeque.smali", src)
        text, stats = self._chunk(p)  # old code raises RuntimeError here
        self.assertIn("StringBuilder", text,
                      "chunking must have applied, not been skipped")
        self.assertEqual(stats.get("strings_chunked"), 1)
        assert_valid(self, text)
        self.assertIn("iput v", text)
        self.assertIn("move/16", text)

    def test_sget_object_high_dest(self):
        # 21c, NOT 22c: sget-object takes ONE 8-bit register, so a
        # high parameter is legal and must pass through UNCHANGED.
        # (FilesKt__UtilsKt, Base64, PathTreeWalk shapes.) An earlier
        # version of this test asserted the opposite — that the
        # fixup rewrote it through a temp — which was the bug: the
        # old fixup pointlessly rewrote valid `sget-object p3` in
        # the testapp (EncodeOutputStream) and aborted the Bridge
        # protect on the legal `sget-object v18`.
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public static foo(Ljava/lang/String;)Ljava/lang/String;
    .locals 12
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    sget-object p0, Ljava/io/File;->separator:Ljava/lang/String;
    return-object p0
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "Sget.smali", src)
        text, stats = self._chunk(p)
        assert_valid(self, text)
        self.assertIn(
            "sget-object p0, Ljava/io/File;->separator:Ljava/lang/String;",
            text, "21c sget-object must pass through unchanged")
        self.assertNotIn("move-object/16 p0", text,
                         "no temp copy may be emitted for a 21c op")
        self.assertEqual(stats.get("field_fixed", 0), 0)

    def test_sget_object_v18_and_sget_v20_unchanged(self):
        # The Bridge 2.14.0 failure, verbatim shape:
        # SessionActivity.refresh(), .locals 25, with the original
        # `sget-object v18, ...UiRows;->INSTANCE:...` (clean-decode
        # line 1038) plus a `sget v20`. Both are 21c (8-bit) and
        # legal at v18/v20, so the fixup must leave both lines
        # byte-identical. FAILS on the old code: _plan_operands
        # raised "unfixable high v-register in a 4-bit op" on v18.
        src = """
.class public Lcom/bridge/mvp/SessionActivity;
.super Ljava/lang/Object;

.method private final refresh()V
    .locals 25
    const-string v0, "%s"
    invoke-static {v0}, Lcom/bridge/mvp/SessionActivity;->useString(Ljava/lang/String;)V
    sget-object v18, Lcom/bridge/mvp/UiRows;->INSTANCE:Lcom/bridge/mvp/UiRows;
    sget v20, Lcom/bridge/mvp/UiRows;->COUNT:I
    return-void
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "SessionActivity.smali", src)
        text, stats = self._chunk(p)  # old code raises RuntimeError here
        assert_valid(self, text)
        self.assertIn(
            "sget-object v18, Lcom/bridge/mvp/UiRows;->INSTANCE:"
            "Lcom/bridge/mvp/UiRows;", text)
        self.assertIn(
            "sget v20, Lcom/bridge/mvp/UiRows;->COUNT:I", text)
        self.assertEqual(stats.get("field_fixed", 0), 0,
                         "no 22c field fixup may fire for 21c ops")
        m = re.search(r"\.locals\s+(\d+)", text)
        self.assertEqual(int(m.group(1)), 29,
                         "chunk bump only: 25 -> 29, no fixup growth")

    def test_iput_high_param_still_fixed(self):
        # 22c CONTROL: a real nibble-limited field op must still be
        # fixed. iput is 22c (two 4-bit registers), unlike sget/sput
        # above — p1 lands at v17 after the chunk bump (.locals
        # 12 -> 16), so it must be rewritten through a temp.
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public setSize(I)V
    .locals 12
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    iput p1, p0, Lx;->size:I
    return-void
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "IputControl.smali", src)
        text, stats = self._chunk(p)
        assert_valid(self, text)
        self.assertIn("iput v", text)
        self.assertIn("move/16", text)
        self.assertNotIn("iput p1, p0", text)
        self.assertGreaterEqual(stats.get("field_fixed", 0), 1)

    def test_rsub_int_lit8_and_const_method_handle_unchanged(self):
        # SECOND table error of the same class, found only once the
        # 21c blocker was fixed (Bridge 2.14.0 protect then died
        # here instead): `rsub-int/lit8` is format 22b — registers
        # 8-bit — but SAFE_8BIT_OPS listed the DEAD name
        # "rsub-int/lit16" and missed "rsub-int/lit8", so the
        # safety net raised "unfixable high parameter register in
        # 'rsub-int/lit8'" on wireguard Curve25519.eval
        # (`rsub-int/lit8 p3, p3, 0x1a`). The 22s rsub is BARE
        # "rsub-int" (dexlib2 Opcode enum; baksmali emits
        # `rsub-int v5, v4, 0x2000`). const-method-handle/type are
        # 21c (8-bit) and were missing too — no occurrence in Bridge
        # or the testapp yet, pinned here before one can abort a
        # protect. All three must pass through UNCHANGED. FAILS on
        # the old code (RuntimeError from the safety net).
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public static calc(IIII)I
    .locals 12
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    rsub-int/lit8 p3, p3, 0x1a
    return p3
.end method

.method public static useHandle(Ljava/lang/invoke/MethodHandle;)V
    .locals 12
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    const-method-handle p0, invoke-static@Lx;->target()V
    const-method-type p0, ()V
    return-void
.end method
""" % (LONG_LITERAL, LONG_LITERAL)
        p = _smali_file(self.tmp, "Rsub.smali", src)
        text, stats = self._chunk(p)  # old code raises RuntimeError here
        assert_valid(self, text)
        self.assertIn("rsub-int/lit8 p3, p3, 0x1a", text)
        self.assertIn("const-method-handle p0, invoke-static@Lx;->target()V",
                      text)
        self.assertIn("const-method-type p0, ()V", text)

    def test_lit16_high_param_fixed(self):
        # 22s CONTROL (Bridge shape): AdminAttentionItem.copy$default
        # (.locals 3 after the bumps) died in the apktool rebuild on
        # `and-int/lit16 p14, p13, 0x80` — p14 is v17, and 22s
        # registers are 4-bit. The fixup must rewrite it through
        # temps. FAILS on the old code: the old fixup listed lit16
        # as 8-bit, returned None, and the checker (also fixed here)
        # would have called the result valid.
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public static mask(IIIIIIIIIIIIIIII)I
    .locals 2
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    and-int/lit16 p14, p13, 0x80
    return p14
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "Lit16.smali", src)
        text, stats = self._chunk(p)
        assert_valid(self, text)
        self.assertRegex(text, r"and-int/lit16 v\d+, v\d+, 0x80")
        self.assertIn("move/16", text)
        self.assertNotIn("and-int/lit16 p14", text)
        self.assertGreaterEqual(stats.get("lit16_fixed", 0), 1)

    def test_lit16_low_reg_unchanged(self):
        # 22s below the limit stays untouched: .locals 11 -> 15
        # after the bump, p0 is v15 — legal for a 4-bit op, so no
        # rewrite. (The Bridge original had .locals 0, p14 = v14.)
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public static mask(I)I
    .locals 11
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    and-int/lit16 p0, p0, 0x80
    return p0
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "Lit16Low.smali", src)
        text, stats = self._chunk(p)
        assert_valid(self, text)
        self.assertIn("and-int/lit16 p0, p0, 0x80", text)
        self.assertEqual(stats.get("lit16_fixed", 0), 0)

    def test_iget_object_high_object_reg(self):
        # 22c with a high OBJECT register: iget-object v2, p0
        # (ParameterizedTypeImpl.getTypeName shape).
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public getType()Ljava/lang/Object;
    .locals 12
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    iget-object v2, p0, Lx;->field:Ljava/lang/Object;
    return-object v2
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "Iget.smali", src)
        text, _stats = self._chunk(p)
        assert_valid(self, text)
        self.assertIn("iget-object v2, v", text)

    def test_if_lt_high_param(self):
        # 22t with a high second operand: if-lt v0, p0 (Duration,
        # DecodeInputStream shapes).
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public static check(I)Z
    .locals 12
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    if-lt v0, p0, :cond_0
    const/4 v0, 0x1
    return v0
    :cond_0
    const/4 v0, 0x0
    return v0
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "IfLt.smali", src)
        text, _stats = self._chunk(p)
        assert_valid(self, text)
        self.assertRegex(text, r"if-lt v0, v\d+, :cond_0")

    def test_neg_long_high_param(self):
        # 12x unary on a wide pair: neg-long p4, p4
        # (UProgressionUtilKt shape). p4 is the low half of the
        # third long parameter of a static (JJJJ)J method.
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public static neg(JJJJ)J
    .locals 12
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    neg-long p4, p4
    return-wide p4
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "NegLong.smali", src)
        text, _stats = self._chunk(p)
        assert_valid(self, text)
        self.assertIn("move-wide/16", text)
        self.assertRegex(text, r"neg-long v\d+, v\d+")

    def test_const4_high_param(self):
        # 11n: const/4 p3, 0x0 (HexExtensionsKt shape) becomes const/16.
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public static foo(IIII)V
    .locals 12
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    const/4 p3, 0x0
    return-void
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "Const4.smali", src)
        text, _stats = self._chunk(p)
        assert_valid(self, text)
        self.assertIn("const/16 p3, 0x0", text)
        self.assertNotIn("const/4 p3", text)

    def test_invoke_needs_five_slots_grows_locals(self):
        # A 5-register invoke with only 4 bump slots (HexExtensionsKt /
        # Uuid$Companion shape): the fixup grows .locals instead of
        # raising "invoke needs 5 temp slots, only 4 available".
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public static caller([BI[I[CI)V
    .locals 11
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    invoke-static {p0, p1, p4, v0, v1}, Lx;->format([BI[I[CI)I
    return-void
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "Invoke5.smali", src)
        text, stats = self._chunk(p)
        assert_valid(self, text)
        self.assertIn("invoke-static/range", text)
        m = re.search(r"\.locals\s+(\d+)", text)
        self.assertEqual(int(m.group(1)), 16,
                         "locals must grow 11 -> 16 to fit 5 temp slots")
        self.assertEqual(stats.get("locals_grown"), 1)

    def test_low_method_left_alone(self):
        # Guard against over-rewriting: a method whose parameters stay
        # at or below v15 after the bump keeps its original iput.
        src = """
.class public Lx;
.super Ljava/lang/Object;

.method public add(Ljava/lang/Object;)V
    .locals 2
    const-string v0, "%s"
    invoke-static {v0}, Lx;->useString(Ljava/lang/String;)V
    iput p1, p0, Lx;->size:I
    return-void
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "Low.smali", src)
        text, _stats = self._chunk(p)
        assert_valid(self, text)
        self.assertIn("iput p1, p0, Lx;->size:I", text)


class TestFullPipelineHighParamRegisters(unittest.TestCase):
    """The real pipeline order: chunk (L55) -> opaque (L58) ->
    flatten (L11). Cumulative bumps push the same parameter further
    (retainAll: 11 -> 15 -> 17 -> 18), so the fixup must keep
    working at every stage, including flatten's 1-slot bump."""

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory(dir=TMP_BASE)
        self.tmp = Path(self._tmp.name)

    def tearDown(self):
        self._tmp.cleanup()

    def test_retainall_through_chunk_opaque_flatten(self):
        src = """
.class public Lkotlin/collections/ArrayDeque;
.super Ljava/lang/Object;

.method public retainAll(Ljava/util/Collection;)Z
    .locals 11
    const-string v0, "%s"
    invoke-static {v0}, Lkotlin/collections/ArrayDeque;->useString(Ljava/lang/String;)V
    iput p1, p0, Lkotlin/collections/ArrayDeque;->size:I
    const/4 v0, 0x1
    return v0
.end method
""" % LONG_LITERAL
        p = _smali_file(self.tmp, "ArrayDeque.smali", src)
        stats = {}
        sm.chunk_string_literals(p, stats=stats)
        assert_valid(self, p.read_text(encoding="utf-8"))
        sm.insert_opaque_predicates(p, seed=1234, stats=stats)
        assert_valid(self, p.read_text(encoding="utf-8"))
        sm.flatten_smali_file(p, seed=1234, stats=stats)
        text = p.read_text(encoding="utf-8")
        assert_valid(self, text)
        self.assertIn("rea_dispatch", text, "method must be flattened")
        self.assertGreaterEqual(stats.get("methods_flattened", 0), 1)
        # The iput survives, rewritten through a temp at every stage.
        self.assertIn("iput v", text)
        self.assertNotIn("iput p1, p0", text)


if __name__ == "__main__":
    unittest.main(verbosity=2)
