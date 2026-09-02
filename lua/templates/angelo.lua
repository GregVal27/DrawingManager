-- Angelo pass 2: monk with bent staff. A64, 1px clusters, sel-out.
-- Does not trace volume. Arms 2px, legs 3px. Light top-left.

local SKIN_H = "#ede6c8"
local SKIN = "#cd9373"
local SKIN_S = "#92562b"
local CLOTH_H = "#ede6c8"
local CLOTH = "#ede6c8"
local CLOTH_M = "#cd9373"
local CLOTH_S = "#9cabb1"
local FOLD = "#8385cf"
local SASH = "#8385cf"
local SASH_S = "#7655a2"
local WOOD_H = "#cd9373"
local WOOD = "#92562b"
local WOOD_S = "#4c3435"
local GOLD_H = "#ede6c8"
local GOLD = "#bbc840"
local GOLD_S = "#808078"
local HAIR = "#4c3435"
local BOOT = "#4c3435"
local BOOT_H = "#92562b"
local LINE = "#485454"
local LINE_W = "#4c3435"
local EYE = "#4c3435"

local FRAME = 1
local buf = {}

local function use(layer)
  DM.use(layer, FRAME)
end

local function dot(x, y, c)
  if x < 0 or y < 0 or x > 63 or y > 63 then
    return
  end
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

local function hide(name)
  pcall(function()
    DM.find_layer(name).isVisible = false
  end)
end

local function shaft_x(y)
  if y <= 10 then
    return 48
  elseif y <= 14 then
    return 47
  elseif y <= 18 then
    return 46
  elseif y <= 22 then
    return 47
  elseif y <= 26 then
    return 48
  elseif y <= 31 then
    return 49
  elseif y <= 40 then
    return 50
  elseif y <= 44 then
    return 49
  elseif y <= 48 then
    return 48
  elseif y <= 52 then
    return 47
  elseif y <= 56 then
    return 46
  else
    return 47
  end
end

local function paint_color()
  -- Staff streamer (from gold, wind left) — separate piece
  span(2, 34, 42, SASH)
  span(3, 26, 40, SASH)
  span(3, 26, 30, SASH_S)
  span(4, 18, 34, SASH)
  span(4, 18, 24, SASH_S)
  span(5, 12, 26, SASH)
  span(5, 12, 18, SASH_S)
  span(6, 8, 20, SASH)
  span(6, 8, 14, FOLD)
  span(7, 6, 16, SASH_S)
  span(8, 5, 13, SASH_S)
  span(9, 5, 11, FOLD)
  span(10, 6, 10, FOLD)
  span(4, 38, 42, CLOTH_H)
  span(5, 22, 26, CLOTH_H)

  -- Second ribbon from the collar, stays right of the face
  span(8, 40, 46, SASH)
  span(9, 41, 47, SASH)
  span(10, 42, 47, SASH_S)
  span(8, 40, 42, CLOTH_H)

  -- Far hanging arm (2px, darker, shorter)
  span(21, 22, 24, CLOTH_S)
  span(22, 21, 23, CLOTH_S)
  span(23, 20, 22, CLOTH_S)
  span(24, 19, 21, CLOTH_S)
  span(25, 18, 20, SKIN_S)
  span(26, 18, 19, SKIN_S)
  span(27, 17, 18, SKIN_S)
  span(28, 17, 18, SKIN_S)
  span(29, 16, 17, SKIN_S)
  span(30, 16, 17, SKIN_S)
  span(31, 16, 17, SKIN_S)
  span(32, 15, 16, SKIN_S)
  span(33, 15, 16, SKIN_S)
  span(34, 15, 16, SKIN_S)
  span(35, 15, 16, SKIN_S)
  span(36, 15, 16, SKIN_S)
  span(37, 15, 16, SKIN_S)
  span(38, 15, 16, SKIN_S)
  span(39, 15, 16, SKIN_S)
  span(40, 15, 16, SKIN_S)
  span(41, 14, 16, SKIN_S)
  span(42, 14, 16, SKIN_S)
  span(43, 14, 15, SKIN_S)
  span(22, 21, 21, CLOTH_H)

  -- Far leg (3px thigh -> 2px shin, darker, shorter)
  span(43, 24, 26, CLOTH_S)
  span(44, 23, 25, CLOTH_S)
  span(45, 23, 25, CLOTH_S)
  span(46, 22, 24, SKIN_S)
  span(47, 22, 24, SKIN_S)
  span(48, 22, 23, SKIN_S)
  span(49, 21, 23, SKIN_S)
  span(50, 21, 22, SKIN_S)
  span(51, 20, 22, SKIN_S)
  span(52, 20, 21, SKIN_S)
  span(53, 20, 21, SKIN_S)
  span(54, 19, 21, SKIN_S)
  span(55, 19, 20, SKIN_S)
  span(56, 19, 20, SKIN_S)
  span(57, 18, 20, SKIN_S)
  span(58, 18, 20, SKIN_S)
  span(59, 17, 22, BOOT)
  span(60, 17, 21, BOOT)

  -- Sash from waist, wind left (gap vs torso)
  span(32, 12, 24, SASH)
  span(33, 7, 23, SASH)
  span(33, 7, 12, SASH_S)
  span(34, 5, 20, SASH)
  span(34, 5, 10, FOLD)
  span(35, 4, 16, SASH_S)
  span(36, 5, 14, SASH_S)
  span(37, 6, 12, FOLD)
  span(38, 7, 11, FOLD)
  span(32, 20, 24, CLOTH_H)
  span(33, 18, 22, CLOTH_H)

  -- Robe body: cream linen, waist tuck, skirt flare left, slit on right
  span(18, 26, 36, CLOTH)
  span(18, 26, 30, CLOTH_H)
  span(19, 25, 37, CLOTH)
  span(19, 25, 29, CLOTH_H)
  span(20, 24, 38, CLOTH)
  span(20, 24, 28, CLOTH_H)
  span(21, 25, 38, CLOTH)
  span(21, 25, 28, CLOTH_H)
  span(22, 25, 37, CLOTH)
  span(23, 25, 37, CLOTH)
  span(24, 26, 37, CLOTH)
  span(25, 26, 36, CLOTH)
  span(26, 26, 36, CLOTH)
  span(27, 26, 36, CLOTH)
  span(28, 27, 36, CLOTH)
  span(29, 27, 35, CLOTH)
  span(30, 26, 35, CLOTH)
  span(31, 26, 35, CLOTH)
  span(32, 26, 36, CLOTH)
  span(33, 25, 36, CLOTH)
  span(34, 25, 35, CLOTH)
  span(35, 25, 35, CLOTH)
  span(36, 25, 35, CLOTH)
  span(37, 24, 35, CLOTH)
  span(38, 24, 34, CLOTH)
  span(39, 23, 34, CLOTH)
  span(40, 23, 33, CLOTH)
  span(41, 22, 32, CLOTH)
  span(42, 21, 31, CLOTH)
  span(43, 20, 30, CLOTH)
  span(44, 20, 29, CLOTH)
  span(45, 19, 28, CLOTH)
  span(46, 18, 27, CLOTH)
  span(47, 18, 26, CLOTH)
  span(48, 17, 25, CLOTH)
  span(49, 16, 24, CLOTH)
  -- dusty-rose fold planes (bedding), not a blue fill
  span(23, 33, 37, CLOTH_M)
  span(24, 34, 37, CLOTH_S)
  span(28, 32, 36, CLOTH_M)
  span(29, 33, 35, CLOTH_S)
  -- hem teeth
  span(50, 14, 19, CLOTH)
  span(50, 22, 24, CLOTH)
  span(51, 12, 18, CLOTH)
  span(51, 21, 23, CLOTH)
  span(52, 10, 16, CLOTH)
  span(52, 20, 22, CLOTH_S)
  span(53, 9, 14, CLOTH_S)
  span(53, 19, 21, CLOTH)
  span(54, 8, 12, CLOTH_S)
  span(54, 18, 20, CLOTH)
  span(55, 8, 11, FOLD)
  span(55, 17, 19, CLOTH_S)
  span(56, 9, 10, FOLD)
  span(56, 16, 18, CLOTH_S)
  span(57, 16, 17, FOLD)
  -- lit left of robe
  span(22, 25, 26, CLOTH_H)
  span(26, 26, 27, CLOTH_H)
  span(33, 25, 26, CLOTH_H)
  span(40, 23, 24, CLOTH_H)
  span(46, 18, 19, CLOTH_H)
  span(30, 33, 35, FOLD)
  span(34, 33, 35, CLOTH_S)
  span(35, 32, 35, FOLD)
  span(39, 31, 34, CLOTH_S)
  span(42, 28, 31, CLOTH_M)
  span(44, 26, 29, FOLD)

  -- Rope belt
  span(36, 26, 32, WOOD)

  -- Head: vault, ear, face right, crown wrap, short hair back
  span(6, 27, 32, HAIR)
  span(7, 26, 33, HAIR)
  span(7, 28, 32, CLOTH_M)
  span(8, 25, 34, HAIR)
  span(8, 27, 33, CLOTH)
  span(8, 27, 30, CLOTH_H)
  span(9, 25, 27, HAIR)
  span(9, 28, 35, SKIN)
  span(9, 28, 31, SKIN_H)
  span(10, 25, 26, HAIR)
  span(10, 27, 36, SKIN)
  span(10, 27, 31, SKIN_H)
  span(11, 25, 26, HAIR)
  span(11, 26, 26, SKIN)
  span(11, 27, 36, SKIN)
  span(11, 27, 30, SKIN_H)
  span(12, 26, 37, SKIN)
  span(12, 26, 30, SKIN_H)
  span(13, 26, 38, SKIN)
  span(13, 37, 38, SKIN_S)
  span(14, 27, 37, SKIN)
  span(14, 36, 37, SKIN_S)
  span(15, 28, 36, SKIN)
  span(15, 35, 36, SKIN_S)
  span(16, 29, 34, SKIN)
  span(17, 30, 32, SKIN)
  span(18, 30, 32, SKIN)
  -- ear
  span(11, 25, 25, SKIN_S)
  span(12, 25, 25, SKIN)
  -- eye
  span(11, 34, 35, SKIN_H)
  dot(34, 12, EYE)
  dot(35, 12, SKIN_H)
  -- nose / mouth suggest
  dot(38, 13, SKIN_S)
  span(15, 32, 33, SKIN_S)

  -- Near leg (3px, lower + right, gap vs far)
  span(43, 35, 37, CLOTH)
  span(44, 36, 38, CLOTH)
  span(45, 36, 38, SKIN)
  span(46, 36, 38, SKIN)
  span(47, 37, 39, SKIN)
  span(48, 37, 39, SKIN)
  span(49, 37, 39, SKIN)
  span(50, 38, 39, SKIN)
  span(51, 38, 39, SKIN)
  span(52, 38, 39, SKIN)
  span(53, 38, 39, SKIN)
  span(54, 38, 39, SKIN)
  span(55, 37, 39, SKIN)
  span(56, 37, 39, SKIN)
  span(57, 37, 39, SKIN)
  span(58, 37, 39, SKIN)
  span(59, 36, 41, BOOT)
  span(60, 36, 41, BOOT)
  span(61, 37, 42, BOOT)
  span(45, 36, 36, SKIN_H)
  span(47, 37, 37, SKIN_H)
  span(59, 36, 37, BOOT_H)

  -- Bent wooden staff (2px, S-bow, knobs). Dark pixel IS the sel-out.
  for y = 9, 61 do
    local x = shaft_x(y)
    local left = WOOD_H
    local right = WOOD_S
    if y < 22 then
      right = WOOD
    elseif y >= 50 then
      left = WOOD
    end
    dot(x, y, left)
    dot(x + 1, y, right)
  end
  -- knobs / grown wood, always attached to the shaft
  dot(45, 16, WOOD)
  dot(45, 17, WOOD_H)
  dot(51, 30, WOOD)
  dot(52, 35, WOOD_S)
  dot(51, 36, WOOD)
  dot(48, 57, WOOD)
  -- gold collar just under the orb
  span(8, 47, 50, GOLD)
  span(9, 46, 49, GOLD_S)

  -- Gold head (irregular orb, hard gleam top-left)
  span(1, 47, 49, GOLD)
  span(2, 45, 51, GOLD)
  span(2, 45, 48, GOLD_H)
  span(3, 44, 52, GOLD)
  span(3, 44, 47, GOLD_H)
  span(4, 43, 53, GOLD)
  span(4, 43, 46, GOLD_H)
  span(4, 51, 53, GOLD_S)
  span(5, 43, 53, GOLD)
  span(5, 43, 45, GOLD_H)
  span(5, 50, 53, GOLD_S)
  span(6, 44, 52, GOLD)
  span(6, 49, 52, GOLD_S)
  span(7, 45, 51, GOLD)
  span(7, 49, 51, GOLD_S)
  span(8, 46, 50, GOLD_S)
  -- not a perfect disc: skip a couple edge pixels
  -- (drawn solid then we just leave y=1 narrow)

  -- Near arm (2px) to the grip; covers shaft at the hand
  span(21, 36, 37, CLOTH)
  span(22, 37, 38, CLOTH)
  span(23, 38, 39, CLOTH)
  span(21, 36, 36, CLOTH_H)
  span(24, 39, 40, SKIN)
  span(25, 40, 41, SKIN)
  span(26, 41, 42, SKIN)
  span(27, 42, 43, SKIN)
  span(28, 43, 44, SKIN)
  span(29, 44, 45, SKIN)
  span(30, 45, 46, SKIN)
  span(31, 46, 47, SKIN)
  span(32, 47, 48, SKIN)
  span(24, 39, 39, SKIN_H)
  span(27, 42, 42, SKIN_H)
  -- hand 2px on the bow of the staff (no outline)
  span(33, 49, 51, SKIN)
  span(34, 49, 51, SKIN)
  span(35, 50, 51, SKIN)
  span(36, 50, 51, SKIN)
  span(37, 50, 51, SKIN_S)
  span(33, 49, 49, SKIN_H)

  flush("color")
end

local function paint_shade()
  -- terminator on head (bottom-right), not a pillow ring
  span(13, 36, 38, SKIN_S)
  span(14, 35, 37, SKIN_S)
  span(15, 34, 36, SKIN_S)
  span(16, 33, 34, SKIN_S)
  -- robe self-shadow right of folds
  span(23, 36, 37, CLOTH_S)
  span(27, 35, 36, CLOTH_M)
  span(31, 34, 35, CLOTH_S)
  span(41, 30, 31, CLOTH_M)
  span(47, 24, 25, CLOTH_S)
  span(34, 14, 16, SASH_S)
  span(24, 20, 21, FOLD)
  span(6, 50, 52, GOLD_S)
  span(7, 50, 51, GOLD_S)
  -- near shin
  span(52, 39, 39, SKIN_S)
  span(56, 39, 39, SKIN_S)
  flush("shade")
end

local function paint_line()
  -- sel-out baked as short rims; skip top-left, soles, grip, staff (dark wood is the rim)
  span(16, 33, 34, LINE_W)
  span(15, 36, 36, LINE_W)
  span(13, 38, 38, LINE_W)
  span(9, 33, 34, LINE)
  span(20, 38, 38, CLOTH_S)
  span(28, 36, 36, CLOTH_S)
  span(43, 30, 30, CLOTH_S)
  span(50, 19, 19, FOLD)
  span(53, 9, 9, FOLD)
  span(36, 16, 16, LINE_W)
  span(42, 14, 14, LINE_W)
  span(50, 21, 21, LINE_W)
  span(54, 39, 39, LINE_W)
  span(7, 51, 52, GOLD_S)
  span(5, 53, 53, GOLD_S)
  -- inner suggests only
  span(8, 27, 29, LINE)
  span(12, 25, 25, LINE_W)
  span(36, 27, 29, WOOD)
  span(30, 29, 29, CLOTH_M)
  flush("line")
end

local function paint_fx()
  -- gold gleam (hard, small)
  dot(45, 3, GOLD_H)
  dot(46, 3, GOLD_H)
  dot(44, 4, GOLD_H)
  dot(45, 4, GOLD_H)
  dot(46, 4, GOLD_H)
  dot(45, 5, GOLD_H)
  -- secondary tick
  dot(47, 2, GOLD_H)
  -- cloth catch on streamer
  dot(39, 3, CLOTH_H)
  dot(23, 5, CLOTH_H)
  dot(21, 32, CLOTH_H)
  flush("fx")
end

function paint_angelo()
  for _, name in ipairs({ "line", "color", "shade", "fx" }) do
    pcall(function()
      DM.clear_cel(name, FRAME)
    end)
  end
  for _, name in ipairs({
    "skeleton",
    "sk_spine",
    "sk_head",
    "sk_arm_f",
    "sk_arm_b",
    "sk_leg_f",
    "sk_leg_b",
    "sk_staff",
    "sk_cloth",
    "volume",
    "vol_spine",
    "vol_head",
    "vol_arm_f",
    "vol_arm_b",
    "vol_leg_f",
    "vol_leg_b",
    "vol_staff",
    "vol_cloth",
    "_tmp",
  }) do
    hide(name)
  end
  paint_color()
  paint_shade()
  paint_line()
  paint_fx()
  DM.result({ ok = true, pass = "paint_angelo" })
end
