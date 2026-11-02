#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""文档链接与索引审计。

检查：
- README、AGENTS、docs/**/*.md、scripts/README.md 中的相对 Markdown 链接；
- docs/reference/standards/decisions/archive/guides 的 README 是否覆盖同目录文件；
- scripts/README.md 是否覆盖 scripts/*.py 与 scripts/*.json。

不改文件；报告写入 docs/reports/docs_audit.json。该工具不进入 check_all 维度。
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

from tool_common import REPORT_DIR, ROOT, write_json

INDEX_DIRS = (
    ("docs/reference", "README.md"),
    ("docs/standards", "README.md"),
    ("docs/decisions", "README.md"),
    ("docs/archive", "README.md"),
    ("docs/guides", "README.md"),
)
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")


def tracked_markdown() -> list[Path]:
    result = subprocess.run(
        ["git", "ls-files", "-z", "--", "README.md", "AGENTS.md", "docs", "scripts/README.md"],
        cwd=ROOT,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError("git ls-files 失败，无法枚举文档")
    paths = [ROOT / item.decode("utf-8") for item in result.stdout.split(b"\0") if item]
    return [path for path in paths if path.suffix == ".md" and path.is_file()]


def check_links(files: list[Path]) -> tuple[int, list[dict[str, str]]]:
    checked = 0
    missing: list[dict[str, str]] = []
    for path in files:
        for match in LINK_RE.finditer(path.read_text(encoding="utf-8")):
            raw = match.group(1).strip()
            if raw.startswith(("http://", "https://", "mailto:", "#")):
                continue
            target = raw.split("#", 1)[0].strip()
            if not target or target.startswith("res://"):
                continue
            checked += 1
            if not (path.parent / target).resolve().exists():
                missing.append({"file": str(path.relative_to(ROOT)), "target": raw})
    return checked, missing


def check_index_coverage() -> list[dict[str, str]]:
    missing: list[dict[str, str]] = []
    for directory, index_name in INDEX_DIRS:
        base = ROOT / directory
        index = base / index_name
        if not index.is_file():
            missing.append({"file": directory, "target": f"缺少 {index_name}"})
            continue
        text = index.read_text(encoding="utf-8")
        for path in sorted(base.glob("*.md")):
            if path.name == index_name:
                continue
            if path.name not in text:
                missing.append(
                    {"file": str(index.relative_to(ROOT)), "target": path.name}
                )
    return missing


def check_scripts_coverage() -> list[dict[str, str]]:
    readme = ROOT / "scripts" / "README.md"
    text = readme.read_text(encoding="utf-8")
    missing: list[dict[str, str]] = []
    for path in sorted((ROOT / "scripts").glob("*")):
        if not path.is_file() or path.suffix not in (".py", ".json"):
            continue
        if path.name not in text:
            missing.append({"file": "scripts/README.md", "target": path.name})
    return missing


def main() -> int:
    parser = argparse.ArgumentParser(description="文档链接与索引审计")
    parser.add_argument("--check", action="store_true", help="只检查（默认行为）")
    parser.add_argument("--json", action="store_true", help="输出 JSON 报告")
    args = parser.parse_args()
    del args.check

    try:
        files = tracked_markdown()
        links_checked, missing_links = check_links(files)
        index_missing = check_index_coverage()
        scripts_missing = check_scripts_coverage()
    except (OSError, RuntimeError) as error:
        print(f"[FAIL] 文档审计无法执行: {error}", file=sys.stderr)
        return 2

    report = {
        "ok": not (missing_links or index_missing or scripts_missing),
        "links_checked": links_checked,
        "missing_links": missing_links,
        "index_missing": index_missing,
        "scripts_missing": scripts_missing,
    }
    write_json(REPORT_DIR / "docs_audit.json", report)

    if args.json:
        print_json(report)
    else:
        print(
            f"[docs_audit] links={links_checked} missing_links={len(missing_links)} "
            f"index_missing={len(index_missing)} scripts_missing={len(scripts_missing)}"
        )
        for item in (missing_links + index_missing + scripts_missing)[:20]:
            print(f"  - {item['file']}: {item['target']}")
    return 0 if report["ok"] else 1


def print_json(payload: dict) -> None:
    import json

    print(json.dumps(payload, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    sys.exit(main())
