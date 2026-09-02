from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def sidecar_path(ase_path: Path) -> Path:
    return ase_path.with_suffix(".json")


def read_sidecar(ase_path: Path) -> dict[str, Any]:
    p = sidecar_path(ase_path)
    if not p.exists():
        return {}
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return data if isinstance(data, dict) else {}


def write_sidecar(ase_path: Path, data: dict[str, Any]) -> Path:
    p = sidecar_path(ase_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    merged = read_sidecar(ase_path)
    merged.update(data)
    p.write_text(json.dumps(merged, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return p


def merge_tags(ase_path: Path, tags: list[dict[str, Any]]) -> None:
    data = read_sidecar(ase_path)
    data["tags"] = tags
    write_sidecar(ase_path, data)
