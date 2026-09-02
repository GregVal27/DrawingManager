from pathlib import Path

ROOT = Path("docs/refs/saint11/inventory.yaml")
mapping = {
    "Alignment": "cards/fundamentals.md",
    "Outlines": "cards/shading-light.md",
    "Shading": "cards/shading-light.md",
    "Silhouette": "cards/fundamentals.md",
    "Fundamentals": "cards/fundamentals.md",
    "Fundamentals2": "cards/fundamentals.md",
    "Pipeline": "cards/fundamentals.md",
    "Planning": "cards/fundamentals.md",
    "Modular": "cards/fundamentals.md",
    "1-bit": "cards/fundamentals.md",
    "Walk": "cards/walk-run-jump.md",
    "RunCycleSimple": "cards/walk-run-jump.md",
    "Jump": "cards/walk-run-jump.md",
    "characterIdle": "cards/walk-run-jump.md",
    "Slide": "cards/walk-run-jump.md",
    "WallSlide": "cards/walk-run-jump.md",
    "Wings": "cards/walk-run-jump.md",
    "AttackSheet": "cards/attack-combat.md",
    "Defend": "cards/attack-combat.md",
    "Death": "cards/attack-combat.md",
    "Metal": "cards/materials.md",
    "Wood": "cards/materials.md",
    "Fabric": "cards/materials.md",
    "Ice": "cards/materials.md",
    "Rock": "cards/materials.md",
    "Sand": "cards/materials.md",
    "gems": "cards/materials.md",
    "Tech": "cards/materials.md",
    "Shine": "cards/materials.md",
    "skull": "cards/materials.md",
    "Fire": "cards/vfx-fire-smoke-water.md",
    "Water": "cards/vfx-fire-smoke-water.md",
    "SmokeSheet": "cards/vfx-fire-smoke-water.md",
    "Wind": "cards/vfx-fire-smoke-water.md",
    "Electric": "cards/vfx-fire-smoke-water.md",
    "Explosion": "cards/vfx-fire-smoke-water.md",
    "Tiles": "cards/environment-tiles.md",
    "Clouds": "cards/environment-tiles.md",
    "Vegetation": "cards/environment-tiles.md",
    "Vegetation2": "cards/environment-tiles.md",
    "Vegetation3": "cards/environment-tiles.md",
    "Easings": "cards/animation-theory.md",
    "Squash": "cards/animation-theory.md",
    "Subpixel": "cards/animation-theory.md",
    "loop": "cards/animation-theory.md",
    "MotionBlur": "cards/animation-theory.md",
    "4LegsWalk": "cards/animation-theory.md",
    "IlluminationTechniques": "cards/shading-light.md",
    "Blood": "cards/vfx-extra.md",
    "Goo": "cards/vfx-extra.md",
    "DarkMagic": "cards/vfx-extra.md",
    "LightMagic": "cards/vfx-extra.md",
    "Glitch": "cards/vfx-extra.md",
    "Bullets": "cards/vfx-extra.md",
    "RocketTrail": "cards/vfx-extra.md",
    "Holograms-Ghosts": "cards/vfx-extra.md",
    "Impact": "cards/vfx-extra.md",
    "Breaking": "cards/vfx-extra.md",
    "Top": "cards/topdown-nondefault.md",
    "TopDownWalkCycle": "cards/topdown-nondefault.md",
    "TopDownRun": "cards/topdown-nondefault.md",
    "TopDownAttack": "cards/topdown-nondefault.md",
    "TopDownTricks": "cards/topdown-nondefault.md",
    "Isometric": "cards/topdown-nondefault.md",
    "UI": "cards/ui-9slice.md",
    "Spaceships": "cards/props-weapons.md",
    "FirearmDesign": "cards/props-weapons.md",
    "Swords": "cards/props-weapons.md",
    "Hazards": "cards/props-weapons.md",
    "Parallax": "cards/environment-tiles.md",
    "City": "cards/environment-tiles.md",
    "indoors": "cards/environment-tiles.md",
    "Ruins": "cards/environment-tiles.md",
    "Stars": "cards/environment-tiles.md",
    "Resizing": "cards/animation-theory.md",
    "Portrait": "cards/animation-theory.md",
    "Cuteness": "cards/animation-theory.md",
    "Darkness": "cards/shading-light.md",
    "GD_LevelProgression": "cards/game-design.md",
}
text = ROOT.read_text(encoding="utf-8")
lines = text.splitlines()
out: list[str] = []
cur_id = None
i = 0
while i < len(lines):
    line = lines[i]
    if line.startswith("  - id:"):
        cur_id = line.split(":", 1)[1].strip()
    if cur_id in mapping and line.strip().startswith("status:"):
        out.append("    status: transcribed")
        i += 1
        continue
    if cur_id in mapping and line.strip().startswith("card:"):
        out.append(f"    card: {mapping[cur_id]}")
        i += 1
        continue
    out.append(line)
    i += 1
ROOT.write_text("\n".join(out) + "\n", encoding="utf-8")
print("updated", len(mapping))
