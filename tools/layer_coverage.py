#!/usr/bin/env python3
"""Anti-REA v1.0 — L93 layer coverage report (per-build evidence).

Reads layers/REGISTRY.md (read-only — this tool never writes it) and
scans the evidence files for mentions of each layer id, then emits a
JSON report:

    python3 tools/layer_coverage.py [--out coverage.json]
    python3 tools/layer_coverage.py --out -   # print to stdout

Evidence files (all under the v1.0 root, skipped silently if absent):
  VERIFICATION-REPORT-v1.0.md, TOOL-COVERAGE.md,
  TOOL-SWEEP-REPORT.md, GAMEGUARDIAN-FIX-REPORT.md,
  SELF-PROTECT-REPORT.md, tests/attack-*.json,
  tests/frida-smoke-*.json, tests/testapp-rea-ir/*.json

For each layer the report records:
  status       from the registry (IMPLEMENTED / PARTIAL / PLANNED)
  code_exists  whether the file named in the registry "Where" column
               exists in the tree (only when it names a single path)
  evidence     evidence files whose text mentions the layer id
               (word-boundary match, so L01 does not match L010)

Summary counts: total layers, counts by status, implemented layers
with at least one evidence file, implemented layers with NO evidence
file (these are the honest gap: claimed but unevidenced — the
coordinator must either find the evidence or move the layer back).

Exit code is always 0 when the report is written; a gap is reported
in the JSON, never hidden by failing the command. Python stdlib only.
"""
import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

EVIDENCE_FILES = [
    "VERIFICATION-REPORT-v1.0.md",
    "TOOL-COVERAGE.md",
    "TOOL-SWEEP-REPORT.md",
    "GAMEGUARDIAN-FIX-REPORT.md",
    "SELF-PROTECT-REPORT.md",
]

EVIDENCE_GLOBS = [
    "tests/attack-*.json",
    "tests/frida-smoke-*.json",
    "tests/testapp-rea-ir/*.json",
    "tests/bridge-rea-ir/*.json",
]


def parse_registry():
    """Same table parse as anti-rea.py (REGISTRY.md is the source)."""
    layers = []
    text = (ROOT / "layers" / "REGISTRY.md").read_text(encoding="utf-8")
    for line in text.splitlines():
        line = line.strip()
        if not line.startswith("| L"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 4 or not re.fullmatch(r"L\d+", cells[0]):
            continue
        layers.append({"id": cells[0], "name": cells[1],
                       "counters": cells[2], "status": cells[3],
                       "where": cells[4] if len(cells) > 4 else ""})
    return layers


def collect_evidence_files():
    files = []
    for rel in EVIDENCE_FILES:
        p = ROOT / rel
        if p.is_file():
            files.append(p)
    for pattern in EVIDENCE_GLOBS:
        files.extend(sorted(ROOT.glob(pattern)))
    return files


def code_exists(where):
    """True/False when the Where column names one existing path,
    None when it names no single file (e.g. '—' or a description)."""
    where = (where or "").strip()
    if not where or where in ("—", "-"):
        return None
    # First token that looks like a repo path.
    for token in re.split(r"[,\s]+", where):
        token = token.strip()
        if token and (token.endswith((".py", ".kt", ".md", ".sh", ".json"))
                      or "/" in token):
            return (ROOT / token).is_file()
    return None


def build_report():
    layers = parse_registry()
    evidence_files = collect_evidence_files()
    texts = {}
    for p in evidence_files:
        try:
            texts[str(p.relative_to(ROOT))] = p.read_text(
                encoding="utf-8", errors="replace")
        except OSError:
            continue
    rows = []
    for layer in layers:
        lid = layer["id"]
        pattern = re.compile(r"\b%s\b" % re.escape(lid))
        evidence = sorted(
            rel for rel, text in texts.items() if pattern.search(text))
        rows.append({**layer,
                     "code_exists": code_exists(layer["where"]),
                     "evidence_files": evidence})
    counts = {}
    for layer in layers:
        counts[layer["status"]] = counts.get(layer["status"], 0) + 1
    impl = [r for r in rows if r["status"] == "IMPLEMENTED"]
    impl_with = [r["id"] for r in impl if r["evidence_files"]]
    impl_without = [r["id"] for r in impl if not r["evidence_files"]]
    return {
        "tool": "anti-rea layer_coverage (L93)",
        "generated_utc": datetime.now(timezone.utc).isoformat(),
        "total_layers": len(rows),
        "counts_by_status": counts,
        "implemented_total": len(impl),
        "implemented_with_evidence": len(impl_with),
        "implemented_without_evidence": impl_without,
        "evidence_files_scanned": sorted(texts),
        "layers": rows,
    }


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", default="coverage.json",
                    help="output JSON path, or - for stdout")
    args = ap.parse_args(argv)
    report = build_report()
    text = json.dumps(report, indent=2)
    if args.out == "-":
        print(text)
    else:
        Path(args.out).write_text(text, encoding="utf-8")
        print("coverage: total=%d %s implemented=%d with_evidence=%d "
              "without_evidence=%d -> %s"
              % (report["total_layers"], report["counts_by_status"],
                 report["implemented_total"],
                 report["implemented_with_evidence"],
                 len(report["implemented_without_evidence"]), args.out))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
