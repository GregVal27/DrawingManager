# DrawingManager agent notes

User-facing how-to and request form: [`docs/USAGE.md`](docs/USAGE.md), [`docs/REQUEST_FORM.md`](docs/REQUEST_FORM.md).

Draw through the DrawingManager MCP server. Canonical plan: [`docs/PLAN.md`](docs/PLAN.md). Save sources in `work/` (`characters/`, `nature/`, `interiors/`, `tilesets/`, `locations/`). After edits, preview. Do not treat `preview/` as the deliverable.

Style is **side-on**. Pixel craft: [`docs/PIXEL_CRAFT.md`](docs/PIXEL_CRAFT.md). Side-on refs: [`docs/refs/sideon.md`](docs/refs/sideon.md). Saint11 cards: [`docs/refs/saint11/README.md`](docs/refs/saint11/README.md). Default palette is EDG32. Before drawing: canvas size + palette (bundle / `.gpl` / hex / palette from a `.aseprite`). Paint with 1px lines, clusters, sel-out; do not use `U()`/`S()` or `outline_from_volume` as the finished outline. No copyrighted game assets in `work/`.

Creatures are two-pass: `create_creature` → `pose_skeleton` → wait for «ок» → `paint_creature`. Layers: `skeleton` / `volume` / `line` / `color` / `shade` / `fx` (complex: groups `skeleton` / `volume` / `paint`). Default tags: idle, walk, run, attack, jump, fall, hurt, die (counts overridable). Custom: `add_action(name, frames, description)`.

Product default backend is **live**. If `status.live_connected` is false, ask the user to Connect, then `set_backend("live")`.
