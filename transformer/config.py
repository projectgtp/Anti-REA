#!/usr/bin/env python3
"""Anti-REA v1.0 — minimal YAML-subset config loader (stdlib only).

The config file is YAML, but v1.0 deliberately supports only the small
subset documented in anti-rea.yaml / docs/USAGE.md: top-level mappings,
nested mappings by indentation, lists with "- " items, scalars (plain,
single- or double-quoted), booleans, integers. Anything else raises a
clear error telling the user which line is unsupported — it never
silently misreads a config.

Schema (all keys optional except version):
    version: 1
    app:
      name: "MyApp"                 # label only
      package: "com.example.app"    # optional, checked against the APK
    protect:
      strings:                      # exact literals to hide (smali + source)
        - "https://api.example.com"
      patterns:                     # regexes applied to string literals
        - "https?://[A-Za-z0-9.-]+"
      classes:                      # class name fragments to treat as sensitive
        - "ApiClient"
      files:                        # source files to transform (source mode)
        - "src/main/java/com/example/ApiClient.kt"
    honeypots:
      secrets: ["AKIAIOSFAKEEXAMPLE", "sk-fake-000000000000000000000000"]
      endpoints: ["https://api-decoy.example.invalid/v1/admin"]
    layers:
      enable: ["L01", "L03", ...]   # null/empty = all IMPLEMENTED layers
      disable: ["L14"]              # explicit opt-outs
    runtime:
      provider: true                # inject ReaGuardProvider into manifest
      env_checks: true
    experimental:
      junk_traps: false             # L15 anti-decompile junk traps.
                                    # DEFAULT OFF, never on by default.
                                    # Opt-in only, needs device proof
                                    # (see docs/L15-JUNK-TRAPS.md). This
                                    # flag is SEPARATE from layers.enable:
                                    # "L15" in layers.enable still raises
                                    # because L15 is PLANNED in the
                                    # registry. The flag only arms
                                    # transformer/junk.py apply_* wrappers.
      self_changing_code: true      # L60 runtime code mutation.
                                    # DEFAULT ON, by the user's explicit
                                    # order 2026-11-23 ("Default is on
                                    # man"). Set it to false to turn it
                                    # off. The DANGER warning still
                                    # applies in full — see
                                    # docs/L60-SELF-CHANGING-CODE.md
                                    # before using it on any real app.
                                    # This flag is SEPARATE from
                                    # layers.enable, like junk_traps:
                                    # it only arms the flag-gated
                                    # helpers; it is NOT wired into
                                    # anti-rea.py protect.
    output:
      rea_ir_dir: "rea-ir"
"""
import re


class ConfigError(ValueError):
    pass


def _scalar(text):
    text = text.strip()
    if text in ("true", "True"):
        return True
    if text in ("false", "False"):
        return False
    if text in ("null", "~", ""):
        return None
    if re.fullmatch(r"-?\d+", text):
        return int(text)
    if len(text) >= 2 and text[0] == text[-1] and text[0] in ("'", '"'):
        inner = text[1:-1]
        if text[0] == '"':
            inner = inner.replace('\\"', '"').replace("\\\\", "\\")
        return inner
    if text.startswith("[") and text.endswith("]"):
        inner = text[1:-1].strip()
        if not inner:
            return []
        return [_scalar(p) for p in _split_flow(inner)]
    return text


def _split_flow(text):
    parts, cur, quote = [], "", None
    for ch in text:
        if quote:
            cur += ch
            if ch == quote:
                quote = None
        elif ch in ("'", '"'):
            quote, cur = ch, cur + ch
        elif ch == ",":
            parts.append(cur)
            cur = ""
        else:
            cur += ch
    if cur.strip():
        parts.append(cur)
    return parts


def load_config(path):
    """Parse the YAML subset. Returns a dict. Raises ConfigError."""
    try:
        lines = open(path, encoding="utf-8").read().splitlines()
    except OSError as e:
        raise ConfigError("cannot read config %s: %s" % (path, e))
    root = {}
    stack = [(-1, root)]
    for lineno, raw in enumerate(lines, 1):
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        if "\t" in raw[:indent]:
            raise ConfigError("line %d: tabs are not allowed, use spaces" % lineno)
        text = raw.strip()
        while stack and indent <= stack[-1][0]:
            stack.pop()
        if not stack:
            raise ConfigError("line %d: bad indentation" % lineno)
        parent = stack[-1][1]
        if text.startswith("- "):
            if not isinstance(parent, list):
                raise ConfigError("line %d: list item without a list key" % lineno)
            item = text[2:].strip()
            if ":" in item and not item.startswith(('"', "'")):
                k, _, v = item.partition(":")
                d = {k.strip(): _scalar(v)}
                parent.append(d)
                stack.append((indent, d))
            else:
                parent.append(_scalar(item))
            continue
        if ":" not in text:
            raise ConfigError("line %d: expected 'key: value' (%r)" % (lineno, text))
        key, _, value = text.partition(":")
        key, value = key.strip(), value.strip()
        if not re.fullmatch(r"[A-Za-z0-9_.-]+", key):
            raise ConfigError("line %d: bad key %r" % (lineno, key))
        if isinstance(parent, list):
            raise ConfigError("line %d: mapping key inside a list" % lineno)
        if value == "":
            # Nested block: mapping or list — decide on next non-empty line.
            nxt = None
            for following in lines[lineno:]:
                if following.strip() and not following.lstrip().startswith("#"):
                    nxt = following
                    break
            if nxt is not None and nxt.strip().startswith("- "):
                parent[key] = []
                stack.append((indent, parent[key]))
            else:
                parent[key] = {}
                stack.append((indent, parent[key]))
        else:
            parent[key] = _scalar(value)
    if root.get("version") != 1:
        raise ConfigError("config version must be 1 (got %r)" % (root.get("version"),))
    return root


def protect_lists(cfg):
    p = cfg.get("protect") or {}
    return {
        "strings": list(p.get("strings") or []),
        "patterns": list(p.get("patterns") or []),
        "classes": list(p.get("classes") or []),
        "files": list(p.get("files") or []),
    }


def honeypots(cfg):
    h = cfg.get("honeypots") or {}
    return {
        "secrets": list(h.get("secrets") or []),
        "endpoints": list(h.get("endpoints") or []),
    }


def junk_traps_enabled(cfg):
    """L15 experimental flag. True only if the config sets
    experimental.junk_traps truthy. Default OFF: an absent
    ``experimental`` section, an absent key, or any falsy value means
    OFF. This flag is separate from layers.enable — L15 stays
    PLANNED in the registry, so "L15" in layers.enable still raises
    ConfigError; the flag only arms transformer/junk.py's apply_*
    wrappers, which return their input unchanged while it is off.
    Mirrors junk.is_enabled; both read the same key."""
    if not isinstance(cfg, dict):
        return False
    exp = cfg.get("experimental") or {}
    if not isinstance(exp, dict):
        return False
    return bool(exp.get("junk_traps", False))


def self_changing_code_enabled(cfg):
    """L60 experimental flag. DEFAULT ON, by the user's explicit
    order 2026-11-23 ("Default is on man") — the OPPOSITE default
    from junk_traps, on purpose, and the only flag in this file
    that defaults on. True unless the config explicitly sets
    experimental.self_changing_code to false: an absent
    ``experimental`` section, an absent key, or a non-dict config
    all mean ON. Only an explicit false (or other falsy value
    stored under that key) turns it OFF. The DANGER warning still
    applies in full — see docs/L60-SELF-CHANGING-CODE.md — the
    default changes nothing about when it is safe to use. This
    flag is separate from layers.enable, like junk_traps: it only
    arms flag-gated helpers and is NOT wired into anti-rea.py
    protect."""
    if not isinstance(cfg, dict):
        return True
    exp = cfg.get("experimental") or {}
    if not isinstance(exp, dict):
        return True
    if "self_changing_code" not in exp:
        return True
    return bool(exp.get("self_changing_code", True))


def enabled_layers(cfg, implemented_ids):
    """Return the sorted list of layer ids to run. enable=null means all
    IMPLEMENTED layers; disable removes ids. Unknown ids raise."""
    lay = cfg.get("layers") or {}
    enable = lay.get("enable")
    disable = set(lay.get("disable") or [])
    if enable:
        wanted = set(enable)
    else:
        wanted = set(implemented_ids)
    unknown = (wanted | disable) - set(implemented_ids) - set(
        "L%02d" % i for i in range(1, 101))
    if unknown:
        raise ConfigError("unknown layer ids: %s" % sorted(unknown))
    planned = wanted - set(implemented_ids)
    if planned:
        raise ConfigError(
            "layers %s are PLANNED, not implemented in v1.0 — remove them "
            "from enable (see layers/REGISTRY.md)" % sorted(planned))
    return sorted(wanted - disable)
