# DrawingManager agent notes

User-facing how-to and request form: [`docs/USAGE.md`](docs/USAGE.md), [`docs/REQUEST_FORM.md`](docs/REQUEST_FORM.md).

Draw through the DrawingManager MCP server. Canonical plan: [`docs/PLAN.md`](docs/PLAN.md). Save sources in `work/` (`characters/`, `nature/`, `interiors/`, `tilesets/`, `locations/`). After edits, preview. Do not treat `preview/` as the deliverable.

Style is **side-on**. Pixel craft: [`docs/PIXEL_CRAFT.md`](docs/PIXEL_CRAFT.md). Animation craft (open before tags; hybrid compose/shift/rotate/brush): [`docs/ANIM_CRAFT.md`](docs/ANIM_CRAFT.md), [`docs/refs/craft/hybrid-anim.md`](docs/refs/craft/hybrid-anim.md). Ref index: [`docs/refs/README.md`](docs/refs/README.md). Web galleries (Pixnote/Lospec axes, no pins in `work/`): [`docs/refs/web-anim/README.md`](docs/refs/web-anim/README.md). Side-on refs: [`docs/refs/sideon.md`](docs/refs/sideon.md). Saint11 cards: [`docs/refs/saint11/README.md`](docs/refs/saint11/README.md). SLYNYRD paraphrase: [`docs/refs/slynyrd/README.md`](docs/refs/slynyrd/README.md). Default palette is EDG32. Before drawing: canvas size + palette (bundle / `.gpl` / hex / palette from a `.aseprite`). On 96: 4–5 tones per material, ~16–28 colors. Paint with 1px lines, clusters, sel-out; do not use `U()`/`S()` or `outline_from_volume` as the finished outline. Limb-slide = copy+shift the whole sprite and ship without brush. `copy_cels` + `shift_rect` is a valid draft if 1px brush follows. Idle must bob the silhouette. No copyrighted game assets in `work/`.

Creatures are two-pass: `create_creature` → `pose_skeleton` → wait for «ок» → `paint_creature`. Layers: `skeleton` / `volume` / `line` / `color` / `shade` / `fx` (complex: groups `skeleton` / `volume` / `paint`). Default tags: idle, walk, run, attack, jump, fall, hurt, die (counts overridable). Custom: `add_action(name, frames, description)`.

Product default backend is **live**. If `status.live_connected` is false, ask the user to Connect, then `set_backend("live")`.

Closed trial: `work/characters/demon_96` (and `lua/templates/demon_96_*.lua`) — do not reopen, pose, paint, or animate. Wait for a new character brief.
