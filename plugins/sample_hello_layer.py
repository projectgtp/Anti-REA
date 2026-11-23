"""Sample marketplace plugin (L100).

A minimal community layer: stamps a marker file into the decoded APK
dir so a later check can prove the plugin ran. It protects nothing
by itself — it exists to prove the loader contract (LAYER_ID +
apply() + test()) works end to end.

Community layer ids are X-prefixed and never collide with registry
L01..L103 slots. Review any plugin before installing it: plugins run
with the CLI's privileges.
"""

LAYER_ID = "X-HELLO-01"
DESCRIPTION = "Sample plugin: stamps antirea/plugins/X-HELLO-01.txt"


def apply(apk_dir, config):
    """Write the marker into the decoded APK dir."""
    import os
    target = os.path.join(str(apk_dir), "assets", "antirea",
                          "plugins", "X-HELLO-01.txt")
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, "w", encoding="utf-8") as f:
        f.write("Anti-REA marketplace sample plugin X-HELLO-01\n")
    return target


def test():
    """Self-test: apply() to a temp dir writes the marker file."""
    import os
    import tempfile
    base = "/home/hatch/tmp"
    os.makedirs(base, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="antirea-plugin-test-",
                                     dir=base) as d:
        out = apply(d, {})
        with open(out, encoding="utf-8") as f:
            return "X-HELLO-01" in f.read()
