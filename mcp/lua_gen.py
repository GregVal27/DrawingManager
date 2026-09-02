from __future__ import annotations

import json
from pathlib import Path


def lua_value(val: object) -> str:
    if val is None:
        return "nil"
    if isinstance(val, bool):
        return "true" if val else "false"
    if isinstance(val, int):
        return str(val)
    if isinstance(val, float):
        return repr(val)
    if isinstance(val, str):
        return json.dumps(val, ensure_ascii=False)
    if isinstance(val, Path):
        return json.dumps(val.as_posix(), ensure_ascii=False)
    if isinstance(val, (list, tuple)):
        return "{" + ",".join(lua_value(x) for x in val) + "}"
    if isinstance(val, dict):
        parts: list[str] = []
        for k, v in val.items():
            key = str(k)
            if key.isidentifier():
                parts.append(f"{key}={lua_value(v)}")
            else:
                parts.append(f"[{lua_value(key)}]={lua_value(v)}")
        return "{" + ",".join(parts) + "}"
    raise TypeError(f"cannot encode {type(val)} as Lua")


def posix(path: str | Path) -> str:
    return Path(path).as_posix()


def wrap_script(
    lib_path: Path,
    body: str,
    title: str = "DM",
    transaction: bool = True,
) -> str:
    lib = posix(lib_path)
    if transaction:
        inner = f"""
  app.transaction({json.dumps(title)}, function()
    {body}
  end)
"""
    else:
        inner = body
    return f"""
collectgarbage()
dofile({json.dumps(lib)})
DM._RESULT = {{ ok = true }}
local ok, err = xpcall(function()
{inner}
end, debug.traceback)
if not ok then
  DM._RESULT = {{ ok = false, error = tostring(err) }}
end
print("DM_RESULT:" .. DM.encode(DM._RESULT or {{ ok = true }}))
"""


def assign_result(expr: str) -> str:
    return f"DM.result({expr})"
