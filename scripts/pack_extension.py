from __future__ import annotations

import zipfile
from pathlib import Path


def main() -> Path:
    root = Path(__file__).resolve().parent.parent
    ext = root / "extension"
    out = ext / "drawing-manager.aseprite-extension"
    with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.write(ext / "package.json", "package.json")
        zf.write(ext / "main.lua", "main.lua")
    print(out)
    return out


if __name__ == "__main__":
    main()
