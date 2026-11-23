# Anti-REA layer marketplace — plugins/ (L100, local)

Drop a community layer plugin (a `.py` module) in this directory and
run `python3 tools/layer_marketplace.py list` / `test`.

A plugin must expose:

```python
LAYER_ID = "X-YOUR-ID"   # X-prefixed; never L01..L103 (registry slots)
DESCRIPTION = "one line"
def apply(apk_dir, config): ...   # transform the decoded APK dir
def test(): ...                   # -> True on pass
```

**Trust warning:** plugins run with the CLI's privileges. Only
install plugins from sources you trust, and read them first.

Ships with: `sample_hello_layer.py` (X-HELLO-01) — stamps a marker
file, protects nothing by itself, proves the loader works.
