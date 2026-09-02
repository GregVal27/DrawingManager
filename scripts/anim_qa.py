"""Onion-like inter-frame QA. Thin wrapper around pixel_qa --anim.

Usage:
  .\\.venv\\Scripts\\python.exe scripts\\anim_qa.py preview\\idle.gif
  .\\.venv\\Scripts\\python.exe scripts\\anim_qa.py f2.png f3.png f4.png f5.png
"""

from __future__ import annotations

import sys
from pathlib import Path

# Same folder as pixel_qa.py
_ROOT = Path(__file__).resolve().parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

import pixel_qa  # noqa: E402


def main(argv: list[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)
    if not args:
        print(__doc__, file=sys.stderr)
        return 2
    return pixel_qa.main(["--anim", *args])


if __name__ == "__main__":
    sys.exit(main())
