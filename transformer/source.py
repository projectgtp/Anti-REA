#!/usr/bin/env python3
"""Anti-REA v1.0 — source-mode transform (L02, stdlib only).

Generalises the v0.1 Bridge transformer to ANY Kotlin/Java source
file: every string literal whose value is a configured exact needle
(or matches a configured pattern) is replaced by a
ReaRuntime.decrypt("blob", "part1", "part2") call, and a REA-IR entry
is emitted. The runtime (com.appcore.runtime.ReaRuntime) must be on
the app's classpath — for APK builds that is the injected smali; for
source builds add runtime/*.kt to the sources.

Rules (honest, narrow):
- Only double-quoted literals on a single line are replaced. Raw
  strings (Kotlin triple-quote), string templates, annotations, and
  multi-line literals are SKIPPED and recorded — never rewritten
  blindly, because a wrong rewrite breaks the build.
- The file must already import (or be given) com.appcore.runtime;
  the transformer inserts the import after the package line when the
  file is Kotlin/Java and the import is absent.
- A literal inside a comment is left alone (comment text is not a
  value). Detection is line-based and conservative: lines whose
  trimmed text starts with //, *, or /* are skipped.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from config import derive_needles  # noqa: E402
from crypto import encrypt_payload  # noqa: E402

STR_RE = re.compile(r'"((?:[^"\\\n]|\\.)*)"')
IMPORT_KT = "import com.appcore.runtime.ReaRuntime"
IMPORT_JAVA = "import com.appcore.runtime.ReaRuntime;"


def _unescape(s):
    out, i = [], 0
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s):
            n = s[i + 1]
            mapping = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\",
                       "'": "'", "$": "$"}
            if n in mapping:
                out.append(mapping[n])
                i += 2
            elif n == "u" and i + 5 < len(s):
                try:
                    out.append(chr(int(s[i + 2:i + 6], 16)))
                except ValueError:
                    out.append(s[i:i + 6])
                i += 6
            else:
                out.append(n)
                i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def transform_source_text(text, needles, patterns, payloads):
    """Return (new_text, replaced_count, skipped_list). payloads maps
    needle -> crypto dict. Needles not yet in payloads are encrypted
    here and added to payloads. `needles` is expanded through
    derive_needles() first (bare host, www., scheme/port/
    trailing-slash/encoded forms), and URL/host needles also match
    case-insensitively — hosts are case-insensitive, and the payload
    encrypts the literal as written, so the runtime value is
    byte-identical (see smali._ci_matchable)."""
    from smali import _ci_matchable
    needles = derive_needles(list(needles or []))
    needles_set = set(needles)
    lines = text.splitlines()
    out, replaced, skipped = [], 0, []
    for lineno, line in enumerate(lines, 1):
        stripped = line.strip()
        if (stripped.startswith("//") or stripped.startswith("*")
                or stripped.startswith("/*") or '"""' in line):
            if '"""' in line:
                skipped.append((lineno, "raw-string line"))
            out.append(line)
            continue

        def repl(m):
            nonlocal replaced
            raw = m.group(1)
            value = _unescape(raw)
            hit = None
            if value in needles_set:
                hit = value
            else:
                # Case variant of a URL/host needle.
                low = value.lower()
                for needle in needles_set:
                    if (_ci_matchable(needle)
                            and needle.lower() == low):
                        hit = value
                        break
                if hit is None:
                    for pat in patterns:
                        try:
                            if re.fullmatch(pat, value):
                                hit = value
                                break
                        except re.error:
                            pass
            if hit is None:
                # Embedded needle: "…for example https://…" — split the
                # literal into concatenation: "prefix" + decrypt() + "suffix".
                from smali import _split_segments as _ss
                segs = _ss(value, needles, patterns)
                if segs:
                    parts = []
                    for kind, text in segs:
                        if kind == "lit":
                            esc = (text.replace("\\", "\\\\")
                                   .replace('"', '\\"')
                                   .replace("\n", "\\n")
                                   .replace("\t", "\\t"))
                            parts.append('"%s"' % esc)
                        else:
                            if text not in payloads:
                                payloads[text] = encrypt_payload(text)
                            p = payloads[text]
                            parts.append(
                                'ReaRuntime.decrypt("%s", "%s", "%s")'
                                % (p["blob_b64"], p["key_part1_b64"],
                                   p["key_part2_b64"]))
                    replaced += 1
                    return " + ".join(parts)
                return m.group(0)
            if hit not in payloads:
                payloads[hit] = encrypt_payload(hit)
            p = payloads[hit]
            replaced += 1
            return ('ReaRuntime.decrypt("%s", "%s", "%s")'
                    % (p["blob_b64"], p["key_part1_b64"], p["key_part2_b64"]))

        out.append(STR_RE.sub(repl, line))
    new_text = "\n".join(out) + ("\n" if text.endswith("\n") else "")
    if replaced and IMPORT_KT not in new_text:
        is_java = "public class" in new_text or "import java." in new_text
        imp = IMPORT_JAVA if is_java else IMPORT_KT
        lines2 = new_text.splitlines()
        for i, ln in enumerate(lines2):
            if ln.startswith("package "):
                lines2.insert(i + 1, imp)
                break
        else:
            lines2.insert(0, imp)
        new_text = "\n".join(lines2) + "\n"
    return new_text, replaced, skipped


def transform_source_file(path, needles, patterns, payloads):
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    new_text, replaced, skipped = transform_source_text(
        text, needles, patterns, payloads)
    if replaced:
        Path(path).write_text(new_text, encoding="utf-8")
    return replaced, skipped
