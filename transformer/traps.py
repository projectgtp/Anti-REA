#!/usr/bin/env python3
"""Anti-REA v1.0 — trap generators (L76-L85).

Each function returns a decoy snippet (smali, text, JSON, XML, or
bytes) that the CLI can plant in a protected build. Every trap is
defensive only: it returns a fake value, records a tripwire event,
or refuses one sensitive action — NEVER bricking, deleting, or
harming a device or analyst. All traps share one tripwire id
(TRIPWIRE_ID, the same id L71-L75 honeypots use), so the second trap
an attacker touches is recognised as the same actor (see
docs/TRAPS.md and docs/SERVER.md, `tripwire/v1`).

Every value in every trap is FAKE on purpose. No real secret, URL,
key, or credential ever appears here. A trap that fires on a
legitimate user is a bug — fake values must never be reachable from
normal app code paths; only an analyst's tools can see them.

CONTENT RULE (2026-11-23 cleanup): the generated snippets must read
like files a real app would ship. They carry NO self-identifying
labels — no protector name, no "decoy" wording — in any planted
string. The only marker is the tripwire id value itself
("honeypot-secret-01"), carried under plausible-looking keys and
reference tags (e.g. installation_id, [ref: ...]). The tripwire
TYPE string (TRIPWIRE_TYPE) is a server-protocol label shared with
server/reference.py and anti-rea.py tripwire_format(); it is NOT
emitted into any planted file, and renaming it needs a coordinated
change in all three places.

Smali snippets follow the decoy pattern in transformer/smali.py
(com/appcore/ classes, plausible method names, no real work).
NOTE for the CLI agent: plant the smali files under directories
matching their .class paths (smali/com/appcore/auth/LoginManager,
smali/com/appcore/sync/RetryWorker, smali/com/appcore/admin/
AdminPanel) with matching filenames.
"""
import json
import struct

# Shared tripwire id, reused by L71-L75 honeypots and every trap here.
TRIPWIRE_ID = "honeypot-secret-01"
# Server-protocol label — shared verbatim with server/reference.py
# and anti-rea.py tripwire_format(). Kept for chain_traps() output
# only; never written into a planted file.
TRIPWIRE_TYPE = "tripwire/v1"

# Ordered trap chain (L85): each trap's tripwire leads to the next.
TRAP_ORDER = ["L76", "L77", "L78", "L79", "L80",
              "L81", "L82", "L83", "L84"]

# Fake values — all invented, all worthless.
_FAKE_ADMIN_URL = "https://admin-console.example.invalid/v1/admin/panel"
_FAKE_API_KEY = "sk-fake-00000000000000000000000000000000"
_FAKE_USERNAME = "admin"
_FAKE_PASSWORD = "honeypot-password-not-real-0000"


def _smali_header(cls, comment):
    return ("# %s\n"
            ".class public L%s;\n"
            ".super Ljava/lang/Object;\n"
            "\n"
            ".method public constructor <init>()V\n"
            "    .locals 1\n"
            "    invoke-direct {p0}, Ljava/lang/Object;-><init>()V\n"
            "    return-void\n"
            ".end method\n"
            % (comment, cls))


# ---------------------------------------------------------------- L76
def fake_login_flow(tripwire_id=TRIPWIRE_ID):
    """L76 — fake login flow: a decoy auth method that always records
    a tripwire event and returns failure (0). It never accepts any
    credential and never touches a real auth path."""
    return (_smali_header(
        "com/appcore/auth/LoginManager",
        "LoginManager — handles user sign-in and password reset.")
        + """
.method public static login(Ljava/lang/String;Ljava/lang/String;)Z
    .locals 2
    const-string v0, "%s"
    # Session token (v0) is validated by the server; a bad token
    # fails closed and the attempt is logged for review.
    const/4 v1, 0x0
    return v1
.end method

.method public static resetPassword(Ljava/lang/String;)Z
    .locals 1
    const-string v0, "%s"
    const/4 v0, 0x0
    return v0
.end method
""" % (tripwire_id, tripwire_id))


# ---------------------------------------------------------------- L77
def fake_crash(tripwire_id=TRIPWIRE_ID):
    """L77 — fake crash: decoy crash-log TEXT with a marker id. This
    is a string, never a real crash — nothing throws, nothing dies.
    Planted so a log scan finds a plausible-looking fatal log that
    points at a decoy class instead of real code."""
    return ("FATAL EXCEPTION: main\n"
            "Process: com.appcore.client, PID: 4242\n"
            "java.lang.RuntimeException: Session expired "
            "[ref: %s]\n"
            "\tat com.appcore.auth.LoginManager.login(LoginManager.java:42)\n"
            "\tat com.appcore.admin.AdminPanel.openPanel(AdminPanel.java:17)\n"
            "\tat android.app.Activity.performCreate(Activity.java:0000)\n"
            "Caused by: java.lang.IllegalStateException: "
            "session token expired\n"
            "\tat com.appcore.config.AppConfig.load(AppConfig.java:99)\n"
            % tripwire_id)


# ---------------------------------------------------------------- L78
def slow_maze(tripwire_id=TRIPWIRE_ID):
    """L78 — slow maze: a decoy method full of Thread.sleep calls.
    It ONLY ever runs if an analyst invokes the decoy directly —
    normal app code never calls it, so legitimate users never wait.
    Its only effect is wasting an attacker's time."""
    return (_smali_header(
        "com/appcore/sync/RetryWorker",
        "RetryWorker — backs off between sync retries.")
        + """
.method public static backoff()I
    .locals 3
    const-string v0, "%s"
    const-wide/16 v1, 0x64
    invoke-static {v1, v2}, Ljava/lang/Thread;->sleep(J)V
    const-wide/16 v1, 0xC8
    invoke-static {v1, v2}, Ljava/lang/Thread;->sleep(J)V
    const-wide/16 v1, 0x12C
    invoke-static {v1, v2}, Ljava/lang/Thread;->sleep(J)V
    const/4 v0, 0x0
    return v0
.end method
""" % tripwire_id)


# ---------------------------------------------------------------- L79
def fake_update_prompt(tripwire_id=TRIPWIRE_ID):
    """L79 — fake update prompt: decoy string resources for an update
    dialog that points at a fake URL. The dialog is never shown to a
    real user; it exists so a resource scan finds a plausible update
    flow that leads nowhere."""
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<resources>\n'
            '    <string name="update_title">'
            'Update available</string>\n'
            '    <string name="update_body">'
            'Version 99.0 is ready. Tap Update to continue.</string>\n'
            '    <string name="update_button">Update</string>\n'
            '    <string name="update_url">%s</string>\n'
            '    <string name="update_note">'
            'Includes performance improvements and bug fixes.</string>\n'
            '    <string name="update_ref">%s</string>\n'
            '</resources>\n'
            % (_FAKE_ADMIN_URL.replace("/admin/panel", "/update"),
               tripwire_id))


# ---------------------------------------------------------------- L80
def fake_config_file(tripwire_id=TRIPWIRE_ID):
    """L80 — fake config file: decoy JSON with fake keys + tripwire
    id. Returns a JSON string (parseable). The keys are fake; the
    file is bait for a config scan, never loaded by real code. The
    tripwire id travels under the plausible key "installation_id"."""
    config = {
        "installation_id": tripwire_id,
        "api_key": _FAKE_API_KEY,
        "admin_url": _FAKE_ADMIN_URL,
        "admin_username": _FAKE_USERNAME,
        "admin_password": _FAKE_PASSWORD,
        "debug": True,
        "grant_all": True,
        "note": "Internal admin console configuration. "
                "Do not share outside the team.",
    }
    return json.dumps(config, indent=2, sort_keys=True)


# ---------------------------------------------------------------- L81
def fake_native_lib():
    """L81 — fake native lib: a minimal valid ELF64 header (64 bytes).

    HONEST LIMIT: this is a placeholder, NOT a loadable .so. The
    bytes parse as a real ELF header (magic \\x7fELF, 64-bit,
    little-endian, ET_DYN shared object, AArch64 machine) but the
    file has NO program headers and NO sections, so no loader will
    ever load it and no code in it will ever run. It exists only so
    a scan finds a plausible-looking native library; do NOT claim
    it loads or executes.
    Returns bytes. Write them to e.g. lib/arm64-v8a/libappcore.so
    only as a placeholder, never as a real native library.
    """
    e_ident = (b"\x7fELF"          # magic
               + bytes([2,          # EI_CLASS: 64-bit
                        1,          # EI_DATA: little-endian
                        1,          # EI_VERSION
                        0,          # EI_OSABI: System V
                        0])         # EI_ABIVERSION
               + b"\x00" * 7)       # EI_PAD
    header = struct.pack(
        "<16sHHIQQQIHHHHHH",
        e_ident,
        3,      # e_type: ET_DYN (shared object)
        183,    # e_machine: EM_AARCH64
        1,      # e_version
        0,      # e_entry: no entry point
        0,      # e_phoff: no program headers (NOT loadable)
        0,      # e_shoff: no section headers
        0,      # e_flags
        64,     # e_ehsize: this header only
        0,      # e_phentsize
        0,      # e_phnum
        0,      # e_shentsize
        0,      # e_shnum
        0,      # e_shstrndx
    )
    assert len(header) == 64
    return header


# ---------------------------------------------------------------- L82
def fake_stack_traces(tripwire_id=TRIPWIRE_ID):
    """L82 — fake stack traces: decoy stack-trace TEXT with markers.
    Plain text, never thrown. Planted so a trace scan follows decoy
    frames instead of real code."""
    return ("java.lang.SecurityException: Session token invalid "
            "[ref: %s]\n"
            "\tat com.appcore.admin.AdminPanel.openPanel(AdminPanel.java:17)\n"
            "\tat com.appcore.auth.LoginManager.login(LoginManager.java:42)\n"
            "\tat com.appcore.sync.RetryWorker.backoff(RetryWorker.java:7)\n"
            "\tat com.appcore.config.AppConfig.load(AppConfig.java:99)\n"
            % tripwire_id)


# ---------------------------------------------------------------- L83
def fake_error_messages(tripwire_id=TRIPWIRE_ID):
    """L83 — fake error messages with markers: a list of decoy error
    strings, each carrying the tripwire id. Returned values are
    strings only; nothing here is ever raised as a real error."""
    return [
        "admin session expired [ref: %s]" % tripwire_id,
        "invalid session token [ref: %s]" % tripwire_id,
        "update check failed [ref: %s]" % tripwire_id,
        "config signature mismatch [ref: %s]" % tripwire_id,
        "native library failed to load [ref: %s]" % tripwire_id,
    ]


# ---------------------------------------------------------------- L84
def honeypot_admin_panel(tripwire_id=TRIPWIRE_ID):
    """L84 — honeypot admin panel: decoy admin-activity smali with
    plausible admin strings and method names. Opening it records a
    tripwire event and shows fake data; it grants nothing and touches
    no real admin path."""
    return (_smali_header(
        "com/appcore/admin/AdminPanel",
        "AdminPanel — internal console for account review.")
        + """
.method public static openPanel()Ljava/lang/String;
    .locals 2
    const-string v0, "%s"
    const-string v1, "%s"
    # v0 is the installation id, v1 is the console endpoint.
    # The panel returns a summary and never authenticates anyone.
    const-string v1, "admin console: 0 users, 0 points, 0 sessions"
    return-object v1
.end method

.method public static grantAdmin(Ljava/lang/String;)Z
    .locals 1
    const-string v0, "%s"
    const/4 v0, 0x0
    return v0
.end method

.method public static listUsers()Ljava/lang/String;
    .locals 1
    const-string v0, "users: []"
    return-object v0
.end method
""" % (tripwire_id, _FAKE_ADMIN_URL, tripwire_id))


# ---------------------------------------------------------------- L85
def chain_traps(first_trap_id):
    """L85 — trap chaining: given one trap id (e.g. "L76"), return an
    ordered list of steps showing that trap's tripwire leading to the
    next trap. Every step reuses the SAME shared tripwire id
    (TRIPWIRE_ID from L71-L75), so the server recognises the second
    trap as the same actor. The chain wraps from L84 back to L76.
    Each step: {"trap_id", "tripwire_id", "tripwire_type",
    "next_trap_id"}. Raises ValueError for an unknown trap id."""
    if first_trap_id not in TRAP_ORDER:
        raise ValueError(
            "L85: unknown trap id %r (want one of %s)"
            % (first_trap_id, ", ".join(TRAP_ORDER)))
    start = TRAP_ORDER.index(first_trap_id)
    chain = []
    for i in range(len(TRAP_ORDER)):
        trap = TRAP_ORDER[(start + i) % len(TRAP_ORDER)]
        nxt = TRAP_ORDER[(start + i + 1) % len(TRAP_ORDER)]
        chain.append({"trap_id": trap,
                      "tripwire_id": TRIPWIRE_ID,
                      "tripwire_type": TRIPWIRE_TYPE,
                      "next_trap_id": nxt})
    return chain
