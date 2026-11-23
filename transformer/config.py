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
import ipaddress
import re
from functools import lru_cache
from urllib.parse import quote, urlparse


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


# --- needle auto-derivation (bare-domain fix, 2026-11-23) -----------
#
# TRIGGER: in the Bridge protection the full URL
# "https://mbbridge.onrender.com" was hidden but the bare domain
# "mbbridge.onrender.com" showed once in the protected APK — it was
# never on the hide list, so no pass touched it. A URL in code has
# many spellings that all identify the same endpoint, and every one
# of them leaks the endpoint if it survives. derive_needles()
# enumerates those spellings from each configured string so the
# transformer hides all of them, not just the one spelling the
# developer happened to write in the config.
#
# DERIVATION RULES (per input string; originals always included):
#   * Only strings that look like a URL (scheme://...) or a bare
#     host ([host][:port][/path...]) are derived from. Anything else
#     (secrets, labels, plain words) passes through unchanged.
#   * Bare host: the host alone ("example.com"), and "www.<host>"
#     (skipped for IP literals and localhost, where www. is nonsense).
#   * Host with its port when one is present ("example.com:8443"),
#     the port-stripped form, and the explicit default port for the
#     scheme (https/wss :443, http/ws :80).
#   * Scheme variants: http <-> https, ws, wss — all four schemes
#     over the same host/path — plus protocol-relative ("//host/...")
#     and scheme-less ("host/path") forms.
#   * Trailing-slash variants: with and without a trailing "/" on
#     the path (root "" and "/" are the same pair).
#   * URL-encoded forms of the full URL: the scheme separator
#     alone as "%3A%2F%2F" (path slashes left plain), the separator
#     plus path slashes as "%2F", and the fully-encoded form
#     (quote(safe="")), each in upper- and lower-case hex
#     (%2F vs %2f — hex case is insignificant, both appear in the
#     wild). Only forms that can actually appear inside a string
#     literal are generated — no other escaping is invented.
#   * Hosts are case-insensitive: derived host forms use the
#     lowercased host (urlparse already lowercases it). Paths are
#     case-SENSITIVE and are never lowercased. The original spelling
#     is always kept verbatim, so an originally-mixed-case URL is
#     still hidden exactly as written.
#   * Honeypot values are NEVER derived from: all_needles() feeds
#     only protect.strings into derive_needles(). Honeypots are fake
#     by design — deriving variants of them would plant extra fake
#     endpoints that look real. Regex patterns are left alone too:
#     deriving from a pattern would mean guessing what it matches.
#
# HONEST LIMITS (cannot be derived, by construction):
#   * Subdomains other than www. ("internal.api.example.com") —
#     unbounded, need an explicit config string or a regex pattern.
#   * IP literals for a hostname URL (no DNS is done, and an IP can
#     change) — list the IP explicitly if the app uses it.
#   * URLs assembled at runtime from pieces ("mbbridge" +
#     ".onrender.com", char arrays, Base64, resources) — no static
#     literal contains the endpoint, so no derivation can name it.
#   * Encoded www. forms and userinfo forms are not generated
#     (rare; the plain www. / bare forms cover the realistic cases).

_URL_SCHEMES = ("http", "https", "ws", "wss")
_DEFAULT_PORTS = {"http": 80, "https": 443, "ws": 80, "wss": 443}
_BARE_HOST_RE = re.compile(r"[A-Za-z0-9.\-]+(?::\d+)?(?:/.*)?\Z")


def _lower_hex_variant(s):
    """Lower-case the hex digits of every %XX escape in s."""
    return re.sub(r"%[0-9A-Fa-f]{2}",
                  lambda m: m.group(0).lower(), s)


def _netloc(host, port):
    """host (+ :port) as it appears after "://" — IPv6 hosts need
    brackets, everything else is bare."""
    if ":" in host and not host.startswith("["):
        host = "[%s]" % host
    return "%s:%d" % (host, port) if port else host


def _derive_one(s, out):
    """Add s and every derived variant of s to the set out."""
    out.add(s)
    stripped = s.strip()
    if not stripped or any(c.isspace() for c in stripped):
        return
    host = None
    port = None
    path = ""
    query = ""
    fragment = ""
    if "://" in stripped:
        try:
            parsed = urlparse(stripped)
        except ValueError:
            return
        scheme = (parsed.scheme or "").lower()
        if scheme not in _URL_SCHEMES:
            return
        try:
            host = parsed.hostname
        except ValueError:
            return
        if not host:
            return
        try:
            port = parsed.port
        except ValueError:
            port = None
        path = parsed.path or ""
        query = parsed.query or ""
        fragment = parsed.fragment or ""
    else:
        m = _BARE_HOST_RE.fullmatch(stripped)
        if not m:
            return
        head = stripped.split("/", 1)[0]
        hostport = head.split(":", 1)
        host = hostport[0].lower()
        # A bare host must look like a host, not a dotted label:
        # no trailing dot, no empty labels, and a real-looking TLD
        # (last label alphabetic, >= 2 chars) — otherwise a label
        # such as "tunnel.key." (a secret label, not a host) would
        # sprout fake "http://www.tunnel.key./" variants. Single
        # labels are accepted only as localhost or an IP literal.
        if "." in host:
            labels = host.split(".")
            if (host.endswith(".") or any(not lab for lab in labels)
                    or not re.fullmatch(r"[A-Za-z]{2,}", labels[-1])):
                return
        elif host != "localhost":
            try:
                ipaddress.ip_address(host)
            except ValueError:
                return
        if len(hostport) == 2:
            try:
                port = int(hostport[1])
            except ValueError:
                return
        if "/" in stripped:
            path = "/" + stripped.split("/", 1)[1]
    # Host forms: bare host, plus www. unless IP / localhost /
    # already www. — and, when the host DOES start with www.,
    # the www-stripped bare host as well (a "www." URL must also
    # hide its bare form, or the bare host slips through exactly
    # like the Bridge case). The host is already lowercased
    # (urlparse lowercases it; the bare-host branch lowercases
    # explicitly).
    try:
        is_ip = ipaddress.ip_address(host) is not None
    except ValueError:
        is_ip = False
    host_forms = [host]
    if not is_ip and host != "localhost":
        if host.startswith("www."):
            host_forms.append(host[4:])
        else:
            host_forms.append("www." + host)
    # Port forms: no port, the explicit port, the port-stripped
    # form, and the scheme's default port spelled out.
    port_forms = {None}
    if port:
        port_forms.add(port)
    elif "://" in stripped:
        scheme = urlparse(stripped).scheme.lower()
        port_forms.add(_DEFAULT_PORTS[scheme])
    # Path variants: with and without a trailing slash. The query
    # and fragment (if any) ride along unchanged, after the slash.
    if path in ("", "/"):
        path_variants = ["", "/"]
    elif path.endswith("/"):
        path_variants = [path, path.rstrip("/")]
    else:
        path_variants = [path, path + "/"]
    suffix = ("?" + query if query else "") + \
        ("#" + fragment if fragment else "")
    schemes = _URL_SCHEMES
    for scheme in schemes:
        for hf in host_forms:
            for pf in sorted(port_forms, key=lambda p: (p is not None, p or 0)):
                netloc = _netloc(hf, pf)
                # Bare netloc (host[:port] with no path) — a
                # "host:port" literal is a real spelling even when
                # the configured URL carries a path.
                out.add(netloc)
                for pv in path_variants:
                    out.add("%s://%s%s%s" % (scheme, netloc, pv, suffix))
                    out.add("//%s%s%s" % (netloc, pv, suffix))
                    out.add("%s%s%s" % (netloc, pv, suffix))
    # URL-encoded forms of the full URL (original host, no www.,
    # no default-port spelling — the common encodings of the URL as
    # it was configured, across all four schemes).
    orig_netloc = _netloc(host, port)
    for scheme in schemes:
        for pv in path_variants:
            u = "%s://%s%s%s" % (scheme, orig_netloc, pv, suffix)
            # E0: only the scheme separator encoded (path slashes
            # left plain) — the hand-built / template spelling.
            enc_sep_only = u.replace("://", "%3A%2F%2F")
            enc_partial = enc_sep_only.replace("/", "%2F")
            enc_full = quote(u, safe="")
            for enc in (enc_sep_only, enc_partial, enc_full):
                out.add(enc)
                out.add(_lower_hex_variant(enc))


@lru_cache(maxsize=32)
def _derive_tuple(items):
    out = set()
    for s in items:
        _derive_one(s, out)
    return tuple(sorted(out))


def derive_needles(strings):
    """Expand config strings into the sorted, deduped list of
    literals to hide: every original string plus every derived
    variant (bare host, www., scheme/port/trailing-slash/encoded
    forms — see the rules above). Non-URL strings pass through
    unchanged; honeypot values and regex patterns must never be
    passed in (see all_needles()). Stdlib only (urllib.parse)."""
    if not strings:
        return []
    items = tuple(s for s in strings
                  if isinstance(s, str) and s != "")
    if not items:
        return []
    return list(_derive_tuple(items))


def all_needles(cfg):
    """The full hide list for a loaded config: protect.strings plus
    every derived variant. Honeypot values (fake by design) and
    regex patterns (left alone) are NEVER derived from."""
    if not isinstance(cfg, dict):
        return []
    p = cfg.get("protect") or {}
    return derive_needles(list(p.get("strings") or []))


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
