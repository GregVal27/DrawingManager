-- Side-on undead: skull in a hooded cloak, warhammer raised overhead.
-- Pass 1 only: sticks on skeleton, masses on volume. A64-friendly hex.

local SK = "skeleton"
local VOL = "volume"
local STICK = "#b14863"
local BONE = "#9cabb1"
local BONE_A = "#9cabb1c8"
local CLOAK = "#313a91"
local CLOAK_A = "#313a91b4"
local HOOD = "#4c3435"
local HOOD_A = "#4c3435c8"
local HAMMER = "#808078"
local HAMMER_A = "#808078c8"
local VOID = "#000000"

local function put(layer, x, y, w, h, color)
  if w <= 0 or h <= 0 then
    return
  end
  DM.use(layer, 1)
  DM.draw_rect(x, y, w, h, color, true)
end

local function ln(layer, x1, y1, x2, y2, color)
  DM.use(layer, 1)
  DM.draw_line(x1, y1, x2, y2, color)
end

local function ov(layer, cx, cy, rx, ry, color)
  DM.use(layer, 1)
  DM.draw_ellipse(cx, cy, rx, ry, color, true)
end

function pose_cloak_skeleton()
  -- Cloak / hood mass (back)
  ov(VOL, 28, 18, 12, 10, HOOD_A)
  ov(VOL, 22, 28, 11, 16, CLOAK_A)
  put(VOL, 12, 24, 16, 28, CLOAK_A)
  put(VOL, 14, 50, 18, 8, CLOAK_A)
  put(VOL, 10, 54, 8, 6, CLOAK_A)

  -- Bone masses
  ov(VOL, 38, 16, 8, 7, BONE_A)
  put(VOL, 34, 21, 9, 4, BONE_A)
  put(VOL, 32, 24, 12, 14, BONE_A)
  put(VOL, 31, 37, 12, 6, BONE_A)
  put(VOL, 30, 42, 5, 16, BONE_A)
  put(VOL, 40, 42, 5, 16, BONE_A)
  put(VOL, 26, 56, 9, 4, BONE_A)
  put(VOL, 38, 56, 10, 4, BONE_A)

  -- Raised arms + hammer mass
  put(VOL, 36, 20, 5, 10, BONE_A)
  put(VOL, 40, 8, 5, 16, BONE_A)
  put(VOL, 30, 1, 20, 7, HAMMER_A)
  put(VOL, 38, 7, 4, 14, HAMMER_A)

  -- Eye sockets punched in the skull mass
  put(VOL, 40, 13, 3, 3, VOID)
  put(VOL, 36, 13, 2, 2, VOID)

  -- Sticks: skull
  ov(SK, 38, 15, 6, 5, STICK)
  put(SK, 35, 19, 7, 3, STICK)
  put(SK, 40, 13, 3, 2, VOID)
  put(SK, 36, 13, 2, 2, VOID)

  -- Spine + ribs
  ln(SK, 37, 22, 37, 38, STICK)
  ln(SK, 37, 25, 44, 27, STICK)
  ln(SK, 37, 28, 45, 31, STICK)
  ln(SK, 37, 32, 43, 34, STICK)
  ln(SK, 37, 25, 31, 27, STICK)
  ln(SK, 37, 29, 30, 31, STICK)

  -- Pelvis
  put(SK, 32, 37, 11, 3, STICK)
  ln(SK, 33, 39, 31, 42, STICK)
  ln(SK, 42, 39, 44, 42, STICK)

  -- Back leg
  ln(SK, 33, 42, 28, 50, STICK)
  ln(SK, 28, 50, 27, 58, STICK)
  put(SK, 24, 57, 8, 3, STICK)

  -- Front leg (leading)
  ln(SK, 42, 42, 45, 50, STICK)
  ln(SK, 45, 50, 43, 58, STICK)
  put(SK, 40, 57, 9, 3, STICK)

  -- Back arm (cloak side, up toward the haft)
  ln(SK, 34, 26, 32, 16, STICK)
  ln(SK, 32, 16, 36, 10, STICK)

  -- Front arm raised, gripping the hammer
  ln(SK, 40, 26, 44, 16, STICK)
  ln(SK, 44, 16, 41, 8, STICK)

  -- Warhammer: long haft, wide head overhead
  put(SK, 31, 1, 18, 6, STICK)
  put(SK, 33, 2, 14, 4, STICK)
  ln(SK, 40, 7, 40, 20, STICK)
  ln(SK, 41, 7, 41, 18, STICK)

  pcall(function()
    local layer = DM.find_layer(VOL)
    layer.opacity = 170
  end)
  DM.result(DM.info())
end

-- A64 local palettes (pass 2): 2–3 tones per material, shadow cooler, highlight warmer.
-- Reuses BONE / CLOAK / HOOD / VOID from pass 1.
local CLOAK_H = "#8385cf"
local CLOAK_S = "#000000"
local HOOD_H = "#92562b"
local BONE_H = "#ede6c8"
local BONE_S = "#485454"
local METAL_H = "#ede6c8"
local METAL = "#808078"
local METAL_S = "#485454"
local WOOD_H = "#cd9373"
local WOOD = "#92562b"
local WOOD_S = "#4c3435"
local FOLD = "#7655a2"

local FRAME = 1
local buf = {}

local function use(layer)
  DM.use(layer, FRAME)
end

local function dot(x, y, c)
  buf[#buf + 1] = { x = x, y = y, color = c }
end

local function span(y, x1, x2, c)
  if x2 < x1 then
    return
  end
  for x = x1, x2 do
    dot(x, y, c)
  end
end

local function flush(layer)
  use(layer)
  if #buf > 0 then
    DM.draw_pixels(buf)
  end
  buf = {}
end

local function stroke(layer, x1, y1, x2, y2, c)
  use(layer)
  DM.draw_line_px(x1, y1, x2, y2, c)
end

local function punch_rect(layer, x, y, w, h, color)
  use(layer)
  DM.punch(x, y, w, h, color)
end

local function clear_paint()
  for _, name in ipairs({ "line", "color", "shade", "fx" }) do
    pcall(function()
      DM.clear_cel(name, FRAME)
    end)
  end
end

-- Pass 2: form inventory, 1px clusters, sel-out. Does not trace volume.
-- Forms: hood rim+cavity, skull (vault, sockets, zygoma, jaw, teeth),
-- ribs as gaps, 1px spine, pelvic wings, thigh/shin/foot, near/far arms,
-- hammer (face, peen, eye, haft, wrap), cloak folds + jagged hem,
-- holes: cloak vs spine, hammer vs skull, between legs.
function paint_cloak_skeleton()
  clear_paint()

  -- Far arm (occluded, shorter, darker) — 2px, raised to the haft above the skull.
  stroke("color", 34, 24, 32, 16, BONE_S)
  stroke("color", 35, 24, 33, 16, BONE_S)
  stroke("color", 32, 16, 36, 10, BONE_S)
  stroke("color", 33, 16, 37, 10, BONE_S)
  span(9, 36, 37, BONE_S)
  span(10, 36, 37, BONE_S)

  -- Hood exterior (cloak cloth wrapping the head) + drape into the cloak.
  -- Light sel-out lives on the top-left outer edge (CLOAK_H).
  span(7, 25, 32, CLOAK_H)
  span(8, 23, 34, CLOAK_H)
  span(9, 21, 36, CLOAK)
  span(9, 21, 24, CLOAK_H)
  span(10, 20, 38, CLOAK)
  span(10, 20, 23, CLOAK_H)
  span(11, 19, 35, CLOAK)
  span(11, 19, 22, CLOAK_H)
  span(12, 18, 33, CLOAK)
  span(12, 18, 21, CLOAK_H)
  span(13, 17, 32, CLOAK)
  span(13, 17, 20, CLOAK_H)
  span(14, 16, 31, CLOAK)
  span(14, 16, 19, CLOAK_H)
  span(15, 16, 30, CLOAK)
  span(16, 16, 29, CLOAK)
  span(17, 16, 29, CLOAK)
  span(18, 17, 30, CLOAK)

  -- Cloak body: inner (right) edge stops short of the spine — negative space.
  span(19, 15, 30, CLOAK)
  span(20, 14, 31, CLOAK)
  span(21, 14, 31, CLOAK)
  span(22, 13, 30, CLOAK)
  span(23, 13, 30, CLOAK)
  span(24, 12, 29, CLOAK)
  span(25, 12, 29, CLOAK)
  span(26, 11, 28, CLOAK)
  span(27, 11, 28, CLOAK)
  span(28, 11, 27, CLOAK)
  span(29, 10, 27, CLOAK)
  span(30, 10, 26, CLOAK)
  span(31, 10, 26, CLOAK)
  span(32, 10, 25, CLOAK)
  span(33, 10, 25, CLOAK)
  span(34, 10, 24, CLOAK)
  span(35, 11, 24, CLOAK)
  span(36, 11, 24, CLOAK)
  span(37, 11, 23, CLOAK)
  span(38, 12, 23, CLOAK)
  span(39, 12, 23, CLOAK)
  span(40, 12, 22, CLOAK)
  span(41, 13, 22, CLOAK)
  span(42, 13, 23, CLOAK)
  span(43, 12, 23, CLOAK)
  span(44, 12, 22, CLOAK)
  span(45, 11, 22, CLOAK)
  span(46, 11, 21, CLOAK)
  span(47, 10, 21, CLOAK)
  span(48, 10, 20, CLOAK)
  span(49, 10, 20, CLOAK)
  span(50, 9, 21, CLOAK)
  span(51, 9, 20, CLOAK)
  span(52, 9, 19, CLOAK)
  span(53, 8, 20, CLOAK)
  span(54, 8, 18, CLOAK)
  span(55, 8, 19, CLOAK)
  -- Jagged hem (connected teeth, not a rectangle).
  span(56, 7, 12, CLOAK)
  span(56, 14, 19, CLOAK)
  span(57, 7, 11, CLOAK)
  span(57, 15, 22, CLOAK)
  span(58, 8, 10, CLOAK)
  span(58, 16, 18, CLOAK)
  span(58, 20, 23, CLOAK)
  span(59, 9, 10, CLOAK)
  span(59, 21, 23, CLOAK)
  span(60, 22, 24, CLOAK)
  -- Lit outer left remaining after the top hood
  span(19, 15, 17, CLOAK_H)
  span(20, 14, 16, CLOAK_H)
  span(24, 12, 13, CLOAK_H)
  span(29, 10, 11, CLOAK_H)

  -- Hood cavity (lining) between rim and skull — depth, not a filled oval.
  -- Skull starts at y=12; cavity stays left of x=35 so the face is free.
  span(10, 31, 36, HOOD)
  span(11, 30, 36, HOOD)
  span(12, 29, 34, VOID)
  span(13, 28, 34, VOID)
  span(14, 28, 34, VOID)
  span(15, 28, 34, VOID)
  span(16, 28, 34, VOID)
  span(17, 29, 34, VOID)
  span(18, 30, 35, HOOD)
  span(19, 31, 36, HOOD)
  span(20, 32, 36, HOOD)
  -- Hood rim (opening): warm catch on top, brown on the underside. Not over the vault.
  span(8, 30, 36, HOOD_H)
  span(9, 31, 38, HOOD_H)
  span(10, 36, 40, HOOD_H)
  span(11, 36, 40, HOOD)

  -- Skull below the grip: vault, zygoma bulge (near/right), jaw.
  span(12, 37, 45, BONE_H)
  span(13, 35, 47, BONE)
  span(13, 35, 41, BONE_H)
  span(14, 35, 48, BONE)
  span(14, 35, 38, BONE_H)
  span(15, 35, 48, BONE)
  span(16, 35, 48, BONE)
  span(17, 35, 49, BONE) -- zygoma
  span(18, 36, 48, BONE)
  span(19, 36, 46, BONE)
  span(20, 37, 45, BONE)
  span(21, 37, 44, BONE)
  span(22, 38, 43, BONE)
  span(23, 39, 42, BONE_S)
  span(19, 44, 46, BONE_S)
  span(20, 43, 45, BONE_S)
  span(21, 42, 44, BONE_S)
  span(22, 41, 43, BONE_S)

  -- 1px spine + clavicle hints
  for y = 23, 36 do
    dot(38, y, BONE)
  end
  span(23, 36, 41, BONE)
  span(24, 35, 36, BONE_S)
  span(24, 39, 42, BONE)

  -- Pelvic wings (not a bar): far wing, sacrum, near wing, hole between.
  span(37, 33, 36, BONE_S)
  span(37, 38, 39, BONE)
  span(37, 41, 45, BONE)
  span(38, 32, 36, BONE_S)
  span(38, 38, 38, BONE)
  span(38, 41, 46, BONE)
  span(39, 32, 35, BONE_S)
  span(39, 42, 45, BONE)
  span(40, 33, 35, BONE_S)
  span(40, 42, 44, BONE)
  span(41, 34, 34, BONE_S)
  span(41, 43, 43, BONE)
  span(38, 45, 46, BONE_S)
  span(39, 44, 45, BONE_S)

  -- Far leg: thigh 3px tapering to shin 2px, foot wedge. Darker / shorter.
  span(42, 33, 35, BONE_S)
  span(43, 32, 34, BONE_S)
  span(44, 32, 34, BONE_S)
  span(45, 31, 33, BONE_S)
  span(46, 31, 33, BONE_S)
  span(47, 30, 32, BONE_S)
  span(48, 30, 32, BONE_S)
  span(49, 30, 31, BONE_S) -- knee break
  span(50, 29, 30, BONE_S)
  span(51, 28, 29, BONE_S)
  span(52, 28, 29, BONE_S)
  span(53, 28, 29, BONE_S)
  span(54, 27, 28, BONE_S)
  span(55, 27, 28, BONE_S)
  span(56, 27, 28, BONE_S)
  span(57, 27, 28, BONE_S)
  span(58, 24, 29, BONE_S)
  span(59, 23, 29, BONE)
  span(59, 27, 29, BONE_S)
  span(60, 24, 28, BONE_S)

  -- Near leg: slightly lower and righter; gap vs far leg.
  span(42, 41, 43, BONE)
  span(43, 42, 44, BONE)
  span(44, 42, 44, BONE)
  span(45, 42, 44, BONE)
  span(46, 43, 45, BONE)
  span(47, 43, 45, BONE)
  span(48, 43, 45, BONE)
  span(49, 43, 44, BONE) -- knee
  span(50, 44, 45, BONE)
  span(51, 44, 45, BONE)
  span(52, 43, 44, BONE)
  span(53, 43, 44, BONE)
  span(54, 43, 44, BONE)
  span(55, 43, 44, BONE)
  span(56, 42, 43, BONE)
  span(57, 42, 43, BONE)
  span(58, 42, 43, BONE)
  span(59, 40, 47, BONE)
  span(60, 39, 47, BONE)
  span(61, 40, 46, BONE)
  -- Form shadow on the near leg (connected cluster, bottom-right of the volume).
  span(44, 44, 44, BONE_S)
  span(45, 44, 44, BONE_S)
  span(46, 45, 45, BONE_S)
  span(47, 45, 45, BONE_S)
  span(50, 45, 45, BONE_S)
  span(51, 45, 45, BONE_S)
  span(53, 44, 44, BONE_S)
  span(54, 44, 44, BONE_S)
  span(60, 45, 47, BONE_S)
  span(61, 44, 46, BONE_S)
  span(42, 41, 42, BONE_H)
  span(43, 42, 43, BONE_H)
  span(59, 40, 42, BONE_H)

  -- Hammer: smaller peen (left), larger face (right), cheeks, eye, short haft, wrap.
  -- Peen (detached at the crown so the two lobes read)
  span(2, 31, 35, METAL)
  span(3, 30, 36, METAL)
  span(4, 30, 36, METAL)
  span(5, 31, 36, METAL)
  span(3, 30, 31, METAL_S)
  span(4, 30, 31, METAL_S)
  -- Cheeks around the eye (eye punched after flush)
  span(3, 36, 38, METAL)
  span(3, 42, 43, METAL)
  span(4, 36, 38, METAL)
  span(4, 42, 43, METAL)
  span(5, 36, 38, METAL)
  span(5, 42, 43, METAL)
  -- Face (hero mass, facing right)
  span(1, 45, 52, METAL_H)
  span(2, 44, 53, METAL)
  span(2, 44, 48, METAL_H)
  span(3, 43, 53, METAL)
  span(4, 43, 53, METAL)
  span(5, 43, 52, METAL)
  span(6, 44, 51, METAL)
  span(7, 46, 50, METAL_S)
  span(3, 52, 53, METAL_S)
  span(4, 52, 53, METAL_S)
  span(5, 51, 52, METAL_S)
  -- Haft only down to the grip — do not pierce the skull. Gap vs vault at y=12.
  for y = 6, 11 do
    dot(39, y, WOOD)
    dot(40, y, WOOD_S)
  end
  -- Leather wrap: WOOD cluster with a connected shadow/highlight, not hood-brown fill.
  span(8, 38, 41, WOOD)
  span(9, 38, 41, WOOD)
  span(10, 38, 41, WOOD)
  span(11, 38, 41, WOOD)
  span(8, 41, 41, WOOD_S)
  span(9, 41, 41, WOOD_S)
  span(10, 41, 41, WOOD_S)
  span(9, 38, 39, WOOD_H)

  -- Near hand on the wrap (arm stroke after flush, to the right of the face).
  span(9, 41, 43, BONE)
  span(10, 41, 43, BONE)
  span(11, 41, 42, BONE)

  flush("color")

  -- Near arm (2px): lower + righter. Elbow out past the skull; forearm stays
  -- in the hammer/skull gap instead of crossing the sockets.
  stroke("color", 46, 24, 51, 13, BONE)
  stroke("color", 47, 24, 52, 13, BONE)
  stroke("color", 51, 13, 43, 9, BONE)
  stroke("color", 52, 13, 44, 9, BONE)

  -- Holes: sockets, nose, hammer eye. Ribs are strokes (gaps by omission).
  punch_rect("color", 36, 15, 2, 3, nil) -- far socket
  punch_rect("color", 43, 15, 3, 4, nil) -- near socket (deeper)
  punch_rect("color", 41, 17, 1, 2, nil) -- nasal cavity
  punch_rect("color", 39, 3, 3, 3, nil) -- hammer eye (through the head)
  -- Eye lips stay metal so they join the head cluster (not 1px shade orphans).
  use("color")
  DM.draw_pixels({
    { x = 38, y = 3, color = METAL },
    { x = 38, y = 4, color = METAL },
    { x = 42, y = 3, color = METAL },
    { x = 42, y = 4, color = METAL },
  })

  -- Ribs as 1px arcs with empty intercostal space (not bars on a rectangle).
  stroke("color", 39, 24, 45, 26, BONE)
  stroke("color", 39, 27, 46, 29, BONE)
  stroke("color", 39, 30, 45, 32, BONE)
  stroke("color", 39, 33, 44, 35, BONE)
  stroke("color", 37, 25, 33, 27, BONE_S)
  stroke("color", 37, 28, 32, 30, BONE_S)
  stroke("color", 37, 31, 33, 33, BONE_S)
  stroke("color", 37, 34, 34, 35, BONE_S)

  -- Shade: folds, cavity extra, bone breaks, metal underside. Not pillow rings.
  -- Cloak folds (2–3 vertical drapes, wavy).
  span(22, 16, 16, CLOAK_S)
  span(23, 16, 17, CLOAK_S)
  span(24, 17, 17, CLOAK_S)
  span(25, 16, 17, CLOAK_S)
  span(26, 16, 16, CLOAK_S)
  span(27, 15, 16, CLOAK_S)
  span(28, 15, 16, CLOAK_S)
  span(29, 15, 15, CLOAK_S)
  span(30, 14, 15, CLOAK_S)
  span(31, 14, 15, CLOAK_S)
  span(32, 14, 14, CLOAK_S)
  span(33, 13, 14, CLOAK_S)
  span(34, 13, 14, CLOAK_S)
  span(35, 14, 14, CLOAK_S)
  span(36, 13, 14, CLOAK_S)
  span(37, 13, 13, CLOAK_S)
  span(38, 14, 14, CLOAK_S)
  span(39, 14, 14, CLOAK_S)
  span(40, 13, 14, CLOAK_S)
  span(41, 14, 14, CLOAK_S)
  span(42, 15, 15, CLOAK_S)
  span(43, 14, 15, CLOAK_S)
  span(44, 14, 14, CLOAK_S)
  span(45, 13, 14, CLOAK_S)
  span(46, 13, 13, CLOAK_S)
  span(47, 12, 13, CLOAK_S)
  span(48, 12, 12, CLOAK_S)
  span(49, 12, 13, CLOAK_S)
  span(50, 11, 12, CLOAK_S)
  span(51, 11, 12, CLOAK_S)
  span(52, 11, 11, CLOAK_S)
  span(53, 10, 11, CLOAK_S)
  span(54, 10, 11, CLOAK_S)
  span(55, 10, 10, CLOAK_S)
  -- Second fold
  span(24, 21, 21, CLOAK_S)
  span(25, 21, 22, CLOAK_S)
  span(26, 21, 21, CLOAK_S)
  span(27, 20, 21, CLOAK_S)
  span(28, 20, 21, CLOAK_S)
  span(29, 20, 20, CLOAK_S)
  span(30, 19, 20, CLOAK_S)
  span(31, 19, 20, CLOAK_S)
  span(32, 19, 19, CLOAK_S)
  span(33, 18, 19, CLOAK_S)
  span(34, 18, 19, CLOAK_S)
  span(35, 18, 18, CLOAK_S)
  span(36, 18, 19, CLOAK_S)
  span(37, 18, 18, CLOAK_S)
  span(38, 17, 18, CLOAK_S)
  span(39, 17, 18, CLOAK_S)
  span(40, 17, 17, CLOAK_S)
  span(41, 16, 17, CLOAK_S)
  span(42, 17, 17, CLOAK_S)
  span(43, 17, 18, CLOAK_S)
  span(44, 16, 17, CLOAK_S)
  span(45, 16, 16, CLOAK_S)
  span(46, 15, 16, CLOAK_S)
  span(47, 15, 16, CLOAK_S)
  span(48, 15, 15, CLOAK_S)
  -- Third fold (near the body, shorter)
  span(28, 25, 25, CLOAK_S)
  span(29, 25, 25, CLOAK_S)
  span(30, 24, 25, CLOAK_S)
  span(31, 24, 24, CLOAK_S)
  span(32, 23, 24, CLOAK_S)
  span(33, 23, 23, CLOAK_S)
  span(34, 22, 23, CLOAK_S)
  span(35, 22, 22, CLOAK_S)
  span(36, 22, 22, CLOAK_S)
  span(37, 21, 22, CLOAK_S)
  span(38, 21, 21, CLOAK_S)
  span(39, 21, 21, CLOAK_S)
  -- Inner cloak edge (shadow side toward the spine gap) — keep 8-connected.
  span(22, 29, 30, CLOAK_S)
  span(23, 30, 30, CLOAK_S)
  span(26, 27, 28, CLOAK_S)
  span(27, 27, 28, CLOAK_S)
  span(28, 27, 27, CLOAK_S)
  span(32, 24, 25, CLOAK_S)
  span(36, 23, 24, CLOAK_S)
  span(40, 22, 22, CLOAK_S)
  span(41, 22, 22, CLOAK_S)
  -- Hem shadow
  span(57, 7, 8, CLOAK_S)
  span(58, 8, 9, CLOAK_S)
  span(58, 22, 23, CLOAK_S)
  span(59, 22, 23, CLOAK_S)
  span(60, 23, 24, CLOAK_S)
  -- Short inner lines: zygoma, hammer poll (not a wrap around the body).
  span(18, 43, 47, BONE_S)
  flush("shade")

  -- FX: top-left highlights, teeth as one 3px cluster, wrap catch, fold ridge.
  span(12, 38, 42, BONE_H)
  span(13, 36, 40, BONE_H)
  -- Teeth: one connected cluster on the jaw, not three orphans.
  span(22, 39, 41, BONE_H)
  -- Hammer face spec
  span(1, 45, 49, METAL_H)
  span(2, 44, 46, METAL_H)
  -- Cloak / hood ridge
  span(8, 24, 28, CLOAK_H)
  span(9, 22, 24, CLOAK_H)
  -- One fold catch (connected 4px, unique hue)
  dot(21, 22, FOLD)
  dot(21, 23, FOLD)
  dot(22, 23, FOLD)
  dot(21, 24, FOLD)
  -- Wrap catch joins the leather cluster
  span(9, 38, 39, WOOD_H)
  flush("fx")

  pcall(function()
    DM.set_layer_visible("skeleton", false)
  end)
  pcall(function()
    DM.set_layer_visible("volume", false)
  end)
  DM.result(DM.info())
end
