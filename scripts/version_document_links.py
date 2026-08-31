#!/usr/bin/env python3
"""Add a cache-busting version to public CV and JMP links."""

from __future__ import annotations

import re
import sys
from pathlib import Path


DOCUMENTS = (
    "riccardo-di-cato-cv.pdf",
    "DiCatoJMP.pdf",
)


def main() -> int:
    if len(sys.argv) != 2 or not re.fullmatch(r"[A-Za-z0-9._-]+", sys.argv[1]):
        print("usage: version_document_links.py VERSION", file=sys.stderr)
        return 2

    version = sys.argv[1]
    pattern = re.compile(
        rf"({'|'.join(re.escape(name) for name in DOCUMENTS)})(?:\?v=[A-Za-z0-9._-]+)?"
    )

    changed = 0
    for path in Path(".").rglob("*.html"):
        if ".git" in path.parts:
            continue
        original = path.read_text(encoding="utf-8")
        updated = pattern.sub(rf"\1?v={version}", original)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            changed += 1

    print(f"Versioned document links in {changed} HTML files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
