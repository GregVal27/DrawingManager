from __future__ import annotations

import pathfix  # noqa: F401 — drop repo root so official mcp SDK wins

from fastmcp import FastMCP

from live_relay import start_live_relay
from tools import register

mcp = FastMCP("drawing-manager")
register(mcp)

try:
    start_live_relay()
except OSError:
    pass


if __name__ == "__main__":
    mcp.run()
