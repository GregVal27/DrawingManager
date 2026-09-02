-- Demon 96 pass 2. EDG32. Beast, not human. 1px clusters, sel-out.
-- Accent: hump + horns. Hide burgundy, keratin horns/hooves, wear chips.
-- Still: paint_demon_96 (clear + clusters). Idle hybrid: copy still +
-- shift_rect/rotate_pixels + paint_idle_hybrid_brush (not blink-only phase).
-- Other tags still use paint_demon_96_at (clear + redraw) after «ок».

local HIDE_H = "#e43b44"
local HIDE_W = "#be4a2f"
local HIDE = "#a22633"
local HIDE_M = "#733e39"
local HIDE_S = "#3e2731"
local HIDE_T = "#68386c"
local HIDE_B = "#b55088"
local HORN_H = "#ead4aa"
local HORN_W = "#d77643"
local HORN = "#c28569"
local HORN_S = "#733e39"
local HORN_D = "#3e2731"
local INK = "#181425"
local CRACK = "#262b44"
local COOL = "#5a6988"
local DUST = "#8b9bb4"
local MAW = "#f6757a"
local EYE_SPEC = "#c0cbdc"

local FRAME = 1
local buf = {}
local ox = 0
local oy = 0

local function seto(px, py)
  ox = px or 0
  oy = py or 0
end

local function use(layer)
  DM.use(layer, FRAME)
end

local function dot(x, y, c)
  x = x + ox
  y = y + oy
  if x < 0 or y < 0 or x > 95 or y > 95 then
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

local function hide(name)
  pcall(function()
    DM.find_layer(name).isVisible = false
  end)
end

local function paint_color(o)
  o = o or {}
  local bx = o.bx or 0
  local by = o.by or 0
  local tbx = o.tail_bx or bx
  local tby = o.tail_by or by
  local jby = o.jaw_by or 0
  local hx = o.hx or 0
  local hdx = o.hdx or 0
  local hdy = o.hdy or 0
  local nlx = o.nlx or 0
  local nly = o.nly or 0
  local flx = o.flx or 0
  local fly = o.fly or 0
  local nax = o.nax or 0
  local nay = o.nay or 0
  local fax = o.fax or 0
  local fay = o.fay or 0
  local plant_n = o.plant_n
  local plant_f = o.plant_f
  if plant_n == nil then
    plant_n = true
  end
  if plant_f == nil then
    plant_f = true
  end
  local nleg_y = plant_n and nly or (by + nly)
  local fleg_y = plant_f and fly or (by + fly)

  -- Tail back-down, taper, darker. Gap vs far cannon.
  seto(tbx, tby)
  span(58, 36, 42, HIDE_M)
  span(59, 32, 40, HIDE_M)
  span(60, 28, 38, HIDE_S)
  span(61, 26, 36, HIDE_S)
  span(62, 24, 34, HIDE_S)
  span(63, 22, 32, HIDE_S)
  span(64, 20, 30, HIDE_S)
  span(65, 18, 28, HIDE_S)
  span(66, 16, 26, HIDE_S)
  span(67, 14, 24, HIDE_S)
  span(68, 12, 22, HIDE_S)
  span(69, 10, 20, HIDE_S)
  span(70, 9, 18, HIDE_S)
  span(71, 8, 16, HIDE_S)
  span(72, 8, 15, HIDE_S)
  span(73, 7, 14, HIDE_S)
  span(74, 7, 13, CRACK)
  span(75, 6, 12, HIDE_S)
  span(76, 6, 11, HIDE_S)
  span(77, 6, 10, HIDE_S)
  span(78, 6, 10, HIDE_S)
  span(79, 7, 10, HIDE_S)
  span(80, 7, 9, CRACK)
  span(81, 7, 9, HIDE_S)
  span(58, 36, 38, HIDE)
  span(62, 24, 26, HIDE_M)

  -- Far arm 3px, short, dark
  seto(bx + fax, by + fay)
  span(50, 42, 45, HIDE_S)
  span(51, 40, 44, HIDE_S)
  span(52, 38, 43, HIDE_S)
  span(53, 37, 41, HIDE_S)
  span(54, 36, 40, HIDE_S)
  span(55, 35, 38, HIDE_S)
  span(56, 34, 37, HIDE_S)
  span(57, 33, 36, HIDE_S)
  span(58, 32, 35, HIDE_S)
  span(59, 32, 34, HIDE_S)
  span(60, 31, 34, HIDE_S)
  span(61, 31, 33, HIDE_S)
  span(62, 30, 33, HIDE_S)
  span(63, 30, 32, HIDE_S)
  span(64, 30, 32, HIDE_S)
  span(65, 30, 32, HIDE_S)
  span(66, 30, 32, CRACK)
  span(58, 32, 34, COOL)
  span(59, 32, 33, COOL)

  -- Far goat: thigh follows hip; cannon/hoof planted or lifted
  seto(bx + flx, by + fly)
  span(58, 36, 42, HIDE_S)
  span(59, 35, 41, HIDE_S)
  span(60, 34, 40, HIDE_S)
  span(61, 33, 39, HIDE_S)
  span(62, 32, 38, HIDE_S)
  span(63, 31, 37, HIDE_S)
  span(64, 30, 36, HIDE_S)
  span(65, 29, 35, HIDE_S)
  span(66, 28, 34, HIDE_S)
  span(67, 27, 33, HIDE_S)
  span(68, 26, 32, HIDE_S)
  span(69, 26, 31, HIDE_S)
  seto(flx, fleg_y)
  span(70, 25, 30, HIDE_S)
  span(71, 25, 29, HIDE_S)
  span(72, 24, 28, HIDE_S)
  span(73, 24, 27, HIDE_S)
  span(74, 24, 27, HIDE_S)
  span(75, 23, 26, HIDE_S)
  span(76, 23, 26, HIDE_S)
  span(77, 23, 25, HIDE_S)
  span(78, 23, 25, HIDE_S)
  span(79, 22, 25, HIDE_S)
  span(80, 22, 24, HIDE_S)
  span(81, 22, 24, HIDE_S)
  span(82, 22, 24, HIDE_S)
  span(83, 22, 24, HIDE_S)
  span(84, 22, 24, HIDE_S)
  span(85, 22, 24, HIDE_S)
  -- far hoof, no sole outline
  seto(flx, fleg_y)
  span(86, 20, 28, HORN_S)
  span(87, 19, 29, HORN)
  span(88, 19, 28, HORN)
  span(89, 20, 27, HORN_S)
  span(87, 19, 21, HORN_H)
  span(87, 23, 24, HORN_S)
  span(88, 23, 24, INK)

  -- HUMP ridge (accent): arch, lit top-left. Right edge stops short of rear horn.
  seto(bx + hx, by)
  span(20, 32, 46, HIDE)
  span(20, 32, 38, HIDE_H)
  span(21, 28, 49, HIDE)
  span(21, 28, 36, HIDE_H)
  span(22, 26, 50, HIDE)
  span(22, 26, 34, HIDE_H)
  span(23, 24, 51, HIDE)
  span(23, 24, 32, HIDE_H)
  span(24, 24, 51, HIDE)
  span(24, 24, 30, HIDE_H)
  span(25, 24, 52, HIDE)
  span(25, 24, 29, HIDE_H)
  span(26, 25, 52, HIDE)
  span(26, 25, 29, HIDE_H)
  span(27, 25, 53, HIDE)
  span(28, 26, 53, HIDE)
  span(29, 26, 53, HIDE)
  span(30, 27, 52, HIDE)
  span(31, 28, 52, HIDE)
  span(32, 28, 51, HIDE)
  span(33, 29, 50, HIDE)
  span(34, 30, 50, HIDE)
  span(35, 31, 49, HIDE)
  span(36, 32, 48, HIDE)
  -- terminator wedge bottom-right (not horizontal belts)
  span(26, 50, 52, HIDE_M)
  span(27, 50, 53, HIDE_M)
  span(28, 49, 53, HIDE_S)
  span(29, 48, 53, HIDE_S)
  span(30, 47, 52, HIDE_S)
  span(31, 49, 52, HIDE_M)
  span(34, 46, 50, HIDE_S)
  span(35, 45, 49, HIDE_S)
  -- two fold clusters
  span(27, 40, 43, HIDE_M)
  span(31, 38, 41, HIDE_M)
  -- rare stone cracks (short, not a grid)
  span(26, 40, 41, CRACK)
  span(27, 41, 41, CRACK)
  span(28, 41, 42, INK)
  span(32, 36, 36, CRACK)
  span(33, 36, 37, INK)
  span(29, 44, 44, CRACK)
  -- bounce under ridge (not a belt)
  span(35, 32, 36, HIDE_B)
  span(36, 33, 38, HIDE_T)
  span(34, 31, 33, HIDE_T)
  span(22, 34, 38, HIDE_W)
  span(23, 32, 36, HIDE_W)

  -- Torso / belly under hump
  seto(bx, by)
  span(37, 34, 58, HIDE)
  span(38, 36, 60, HIDE)
  span(39, 38, 62, HIDE)
  span(40, 40, 62, HIDE)
  span(41, 40, 62, HIDE)
  span(42, 41, 62, HIDE)
  span(43, 42, 61, HIDE)
  span(44, 42, 60, HIDE)
  span(45, 43, 60, HIDE)
  span(46, 44, 59, HIDE)
  span(47, 44, 58, HIDE)
  span(48, 45, 58, HIDE)
  span(49, 46, 57, HIDE)
  span(50, 46, 56, HIDE)
  span(51, 47, 56, HIDE)
  span(52, 48, 56, HIDE)
  span(53, 48, 62, HIDE_M)
  span(54, 48, 60, HIDE)
  span(55, 49, 58, HIDE)
  span(54, 49, 55, HIDE_S)
  -- belly terminator (wedge, not belts)
  span(43, 58, 61, HIDE_M)
  span(44, 57, 60, HIDE_S)
  span(48, 54, 58, HIDE_S)
  span(49, 53, 57, HIDE_S)
  span(37, 34, 38, HIDE_H)

  -- HEAD: brow, skull, muzzle right, hanging jaw, OPEN maw (hole)
  seto(bx + hdx, by + hdy)
  -- brow ridge
  span(38, 58, 72, HIDE_S)
  span(39, 57, 73, HIDE_M)
  span(39, 57, 62, HIDE)
  -- skull
  span(40, 58, 74, HIDE)
  span(41, 59, 74, HIDE)
  span(42, 60, 74, HIDE)
  span(43, 60, 75, HIDE)
  span(44, 61, 76, HIDE)
  span(40, 58, 64, HIDE_H)
  span(41, 59, 63, HIDE_H)
  -- muzzle (no human nose/lips)
  span(45, 68, 82, HIDE)
  span(46, 70, 84, HIDE)
  span(47, 72, 85, HIDE)
  span(48, 73, 86, HIDE)
  span(45, 68, 72, HIDE_H)
  span(46, 70, 73, HIDE_W)
  span(47, 82, 85, HIDE_M)
  span(48, 83, 86, HIDE_S)
  -- maw cavity (dark hole, not a transparent bite)
  span(49, 76, 79, INK)
  span(50, 74, 84, INK)
  span(51, 74, 83, INK)
  span(49, 74, 75, HORN_H)
  span(49, 80, 81, HORN)
  dot(77, 50, MAW)
  dot(78, 51, MAW)
  -- hanging jaw under the cavity
  seto(bx + hdx, by + hdy + jby)
  span(50, 68, 73, HIDE_M)
  span(51, 68, 73, HIDE_M)
  span(52, 70, 84, HIDE_S)
  span(53, 70, 83, HIDE_S)
  span(54, 71, 82, HIDE_S)
  span(55, 72, 80, HIDE_S)
  span(56, 73, 78, CRACK)
  span(52, 69, 71, HIDE_M)
  dot(76, 52, HORN)
  -- eye socket under brow (deep, not cute)
  seto(bx + hdx, by + hdy)
  span(41, 66, 68, INK)
  span(42, 66, 68, INK)
  dot(67, 41, EYE_SPEC)

  -- Horns (accent): back-curve, taper, gap between, gap vs hump
  seto(bx + hdx, by + hdy)
  -- rear (far) horn: tip back-up, darker
  span(4, 45, 46, HORN_H)
  span(5, 44, 47, HORN_H)
  span(6, 44, 48, HORN)
  span(7, 44, 48, HORN)
  span(8, 45, 49, HORN)
  span(9, 45, 49, HORN)
  span(10, 46, 50, HORN_W)
  span(11, 46, 50, HORN)
  span(12, 47, 51, HORN)
  span(13, 47, 51, HORN)
  span(14, 48, 52, HORN)
  span(15, 48, 52, HORN)
  span(16, 49, 53, HORN)
  span(17, 49, 53, HORN)
  span(18, 50, 54, HORN)
  span(19, 50, 54, HORN)
  span(20, 51, 55, HORN)
  span(21, 52, 56, HORN)
  span(22, 53, 57, HORN)
  span(23, 53, 57, HORN)
  span(24, 54, 58, HORN)
  span(25, 54, 58, HORN)
  span(26, 55, 58, HORN)
  span(27, 55, 59, HORN)
  span(28, 55, 59, HORN)
  span(29, 56, 59, HORN)
  span(30, 56, 60, HORN)
  span(31, 56, 60, HORN)
  span(32, 56, 60, HORN)
  span(33, 56, 61, HORN)
  span(34, 57, 61, HORN)
  span(35, 57, 61, HORN)
  span(36, 57, 61, HORN)
  span(8, 48, 49, HORN_S)
  span(16, 52, 53, HORN_S)
  span(24, 57, 58, HORN_S)
  span(32, 59, 60, HORN_S)
  span(5, 44, 45, HORN_H)
  span(12, 47, 48, HORN_H)
  -- keratin chip (cluster cut, not a grid)
  span(7, 44, 46, HORN_D)
  span(8, 44, 45, CRACK)
  span(9, 45, 46, HORN_S)
  -- forward (near) horn: taller, slight forward hook at tip
  span(5, 71, 72, HORN_H)
  span(6, 70, 73, HORN_H)
  span(7, 70, 73, HORN)
  span(8, 69, 73, HORN)
  span(9, 69, 73, HORN)
  span(10, 68, 73, HORN)
  span(11, 68, 73, HORN)
  span(12, 68, 73, HORN)
  span(13, 67, 73, HORN)
  span(14, 67, 72, HORN)
  span(15, 67, 72, HORN)
  span(16, 66, 72, HORN)
  span(17, 66, 72, HORN)
  span(18, 66, 72, HORN)
  span(19, 65, 71, HORN)
  span(20, 65, 71, HORN)
  span(21, 65, 71, HORN)
  span(22, 65, 71, HORN)
  span(23, 64, 71, HORN)
  span(24, 64, 70, HORN)
  span(25, 64, 70, HORN)
  span(26, 64, 70, HORN)
  span(27, 64, 70, HORN)
  span(28, 64, 70, HORN)
  span(29, 64, 70, HORN)
  span(30, 64, 70, HORN)
  span(31, 64, 70, HORN)
  span(32, 64, 70, HORN)
  span(33, 64, 70, HORN)
  span(34, 63, 70, HORN)
  span(35, 63, 70, HORN)
  span(36, 63, 70, HORN)
  span(37, 64, 70, HORN)
  span(10, 72, 73, HORN_S)
  span(18, 71, 72, HORN_S)
  span(26, 69, 70, HORN_S)
  span(6, 70, 71, HORN_H)
  span(14, 67, 68, HORN_H)

  -- Near goat (weight): thigh 5px, hock kink, cannon 3px
  seto(bx + nlx, by + nly)
  span(56, 52, 60, HIDE)
  span(57, 53, 61, HIDE)
  span(58, 54, 62, HIDE)
  span(59, 55, 63, HIDE)
  span(60, 56, 64, HIDE)
  span(61, 57, 65, HIDE)
  span(62, 58, 66, HIDE)
  span(63, 59, 67, HIDE)
  span(64, 60, 67, HIDE)
  span(65, 61, 67, HIDE)
  span(66, 62, 67, HIDE)
  span(67, 62, 68, HIDE)
  span(68, 63, 68, HIDE)
  span(69, 63, 69, HIDE)
  span(70, 64, 69, HIDE)
  span(71, 62, 70, HIDE)
  span(72, 61, 70, HIDE)
  span(73, 62, 70, HIDE)
  span(74, 63, 70, HIDE)
  span(75, 65, 69, HIDE)
  span(76, 65, 68, HIDE)
  span(72, 61, 63, HIDE_M)
  span(73, 62, 64, HIDE_S)
  seto(nlx, nleg_y)
  span(77, 65, 68, HIDE_M)
  span(78, 65, 68, HIDE_M)
  span(79, 65, 67, HIDE_M)
  span(80, 65, 67, HIDE_M)
  span(81, 65, 67, HIDE_M)
  span(82, 65, 67, HIDE_S)
  span(83, 65, 67, HIDE_S)
  span(84, 65, 67, HIDE_S)
  span(85, 65, 67, HIDE_S)
  span(86, 65, 67, HIDE_S)
  span(87, 65, 67, HIDE_S)
  span(88, 65, 67, HIDE_S)
  span(89, 64, 67, HIDE_S)
  span(90, 63, 68, HIDE_S)
  span(58, 54, 56, HIDE_H)
  span(62, 58, 59, HIDE_H)
  span(70, 64, 64, HIDE_M)
  -- planted cloven hoof (no sole outline)
  seto(nlx, nleg_y)
  span(91, 60, 74, HORN)
  span(92, 59, 75, HORN)
  span(93, 60, 74, HORN_S)
  span(94, 62, 72, HORN_S)
  span(91, 60, 64, HORN_H)
  span(92, 59, 62, HORN_H)
  span(91, 66, 67, HORN_S)
  span(92, 66, 68, HORN_S)
  span(93, 66, 67, INK)
  span(93, 62, 64, DUST)
  span(94, 63, 65, HORN_D)

  -- Near arm 3px, lower and righter
  seto(bx + nax, by + nay)
  span(49, 56, 59, HIDE)
  span(50, 57, 60, HIDE)
  span(51, 58, 61, HIDE)
  span(52, 59, 62, HIDE)
  span(53, 60, 63, HIDE)
  span(54, 61, 64, HIDE)
  span(55, 62, 65, HIDE)
  span(56, 63, 66, HIDE)
  span(57, 64, 67, HIDE)
  span(58, 65, 68, HIDE)
  span(59, 66, 69, HIDE)
  span(60, 67, 70, HIDE)
  span(61, 68, 71, HIDE)
  span(62, 69, 72, HIDE)
  span(63, 70, 73, HIDE)
  span(64, 70, 73, HIDE)
  span(65, 71, 74, HIDE)
  span(66, 71, 74, HIDE)
  span(67, 72, 75, HIDE)
  span(68, 72, 75, HIDE)
  span(69, 72, 75, HIDE)
  span(70, 72, 75, HIDE)
  span(71, 72, 74, HIDE_M)
  span(72, 72, 74, HIDE_S)
  span(73, 72, 74, HIDE_S)
  span(74, 72, 74, HIDE_S)
  if o.claw then
    span(73, 75, 78, HIDE_S)
    span(74, 75, 80, HIDE_S)
    span(75, 77, 81, HIDE_M)
    dot(81, 75, HORN_H)
    dot(80, 76, HORN)
  end
  span(49, 56, 57, HIDE_H)
  span(54, 61, 62, HIDE_H)
  span(60, 67, 68, HIDE_H)

  paint_redraw_phase(o)
  flush("color")
end

-- Legacy still-edge twinkles for paint_demon_96_at. Idle hybrid does not use this.
function paint_redraw_phase(o)
  local ph = o.phase or 0
  if ph == 0 then
    return
  end
  local bx = o.bx or 0
  local by = o.by or 0
  local hx = o.hx or 0
  local hdx = o.hdx or 0
  local hdy = o.hdy or 0
  local tbx = o.tail_bx or bx
  local tby = o.tail_by or by
  if ph == 1 then
    -- rest: bounce + open lid (still-like, but drawn on this cel)
    seto(bx + hx, by)
    span(35, 32, 36, HIDE_B)
    seto(bx + hdx, by + hdy)
    dot(67, 41, EYE_SPEC)
  elseif ph == 2 then
    -- inhale: new highlight cluster on crest, chest, catch in eye
    seto(bx + hx, by)
    span(19, 30, 38, HIDE_H)
    span(20, 28, 34, HIDE_H)
    span(21, 26, 32, HIDE_H)
    span(37, 34, 40, HIDE)
    seto(bx, by)
    span(38, 36, 42, HIDE_H)
    seto(bx + hdx, by + hdy)
    dot(67, 41, HORN_H)
    dot(68, 41, EYE_SPEC)
  elseif ph == 3 then
    -- lag: eyelid, jaw mass redraw, tail tip curl (not blit)
    seto(bx + hdx, by + hdy)
    span(40, 66, 69, HIDE_S)
    span(41, 66, 68, HIDE_M)
    dot(67, 42, INK)
    seto(bx + hdx, by + hdy + (o.jaw_by or 0))
    span(51, 68, 74, HIDE)
    span(52, 69, 82, HIDE_M)
    span(56, 73, 76, HIDE_S)
    seto(tbx, tby)
    span(80, 6, 10, HIDE_M)
    span(81, 5, 9, HIDE_S)
    span(82, 5, 8, CRACK)
  elseif ph == 4 then
    -- exhale: wider terminator, dust in fold, maw slightly closed
    seto(bx + hx, by)
    span(27, 48, 53, HIDE_T)
    span(28, 47, 53, HIDE_S)
    span(31, 38, 42, DUST)
    span(32, 36, 38, CRACK)
    seto(bx + hdx, by + hdy)
    span(49, 76, 79, HIDE_M)
    span(50, 75, 80, INK)
    dot(76, 50, MAW)
  end
end

local function paint_shade(o)
  o = o or {}
  seto(o.bx or 0, o.by or 0)
  span(42, 58, 62, HIDE_S)
  span(47, 82, 86, HIDE_S)
  span(54, 76, 82, CRACK)
  span(38, 56, 60, HIDE_S)
  span(78, 23, 24, CRACK)
  span(84, 66, 67, CRACK)
  flush("shade")
end

local function paint_line(o)
  o = o or {}
  seto(o.bx or 0, o.by or 0)
  -- hump right/bottom (matches trimmed ridge)
  span(25, 52, 52, HIDE_S)
  span(30, 52, 52, HIDE_S)
  span(35, 49, 49, HIDE_S)
  -- skull / jaw
  span(43, 75, 75, HIDE_S)
  span(48, 86, 86, HIDE_S)
  span(55, 80, 80, CRACK)
  -- rear horn right
  span(8, 49, 49, HORN_S)
  span(16, 53, 53, HORN_S)
  span(24, 58, 58, HORN_S)
  -- forward horn right
  span(10, 73, 73, HORN_S)
  span(20, 71, 71, HORN_S)
  span(30, 70, 70, HORN_S)
  -- hanging arm
  span(58, 35, 35, HIDE_S)
  span(64, 32, 32, CRACK)
  span(70, 75, 75, HIDE_S)
  -- goat cannons (not soles)
  span(80, 25, 25, CRACK)
  span(84, 67, 67, HIDE_S)
  -- short inner suggests
  span(39, 64, 68, CRACK)
  span(27, 33, 35, HIDE_M)
  span(46, 72, 74, HIDE_M)
  flush("line")
end

local function paint_fx(o)
  o = o or {}
  local bx = o.bx or 0
  local by = o.by or 0
  local hdx = o.hdx or 0
  local hdy = o.hdy or 0
  seto(bx + hdx, by + hdy)
  -- tiny keratin catch, not metal
  dot(45, 5, HORN_H)
  dot(46, 5, HORN_H)
  dot(71, 6, HORN_H)
  dot(77, 50, MAW)
  -- one hide catch on hump top-left
  seto(bx + (o.hx or 0), by)
  dot(27, 22, HIDE_H)
  dot(28, 21, HIDE_H)
  if (o.phase or 0) == 2 then
    dot(26, 21, HORN_H)
  end
  if o.smear then
    seto(bx + (o.nax or 0), by + (o.nay or 0))
    span(68, 76, 84, HORN_H)
    span(70, 78, 86, HORN)
    span(72, 80, 85, HIDE_H)
    dot(86, 70, HORN_H)
  end
  flush("fx")
end

-- 1px seams after hybrid idle transforms. Does not clear the cel.
function paint_idle_hybrid_brush(frame, o)
  FRAME = frame
  o = o or {}
  local by = o.body_dy or 0
  local hx = o.hump_extra or 0
  local cx = o.chest_extra or 0
  local jy = o.jaw_dy or 0
  buf = {}
  seto(0, 0)

  -- Planted hooves (far y>=86, near y>=91): restamp so they do not drift.
  span(86, 20, 28, HORN_S)
  span(87, 19, 29, HORN)
  span(88, 19, 28, HORN)
  span(89, 20, 27, HORN_S)
  span(87, 19, 21, HORN_H)
  span(87, 23, 24, HORN_S)
  span(88, 23, 24, INK)
  span(91, 60, 74, HORN)
  span(92, 59, 75, HORN)
  span(93, 60, 74, HORN_S)
  span(94, 62, 72, HORN_S)
  span(91, 60, 64, HORN_H)
  span(92, 59, 62, HORN_H)
  span(91, 66, 67, HORN_S)
  span(92, 66, 68, HORN_S)
  span(93, 66, 67, INK)
  span(93, 62, 64, DUST)
  span(94, 63, 65, HORN_D)

  -- Far hock: cannon ends at 85+body_dy; hoof stays at 86.
  local far_join = 85 + by
  if far_join < 85 then
    for yy = far_join + 1, 85 do
      span(yy, 22, 24, HIDE_S)
    end
  end
  span(85, 22, 24, HIDE_S)
  span(84, 22, 24, HIDE_S)

  -- Near hock: cannon 86–90 moved by body_dy; hoof at 91.
  local near_join = 90 + by
  if near_join < 90 then
    for yy = math.max(near_join + 1, 86), 90 do
      span(yy, 65, 67, HIDE_S)
    end
  end
  span(90, 64, 67, HIDE_S)
  span(89, 65, 67, HIDE_S)
  span(88, 65, 67, HIDE_M)

  -- Neck / shoulder: hump ridge meets skull (after body + hump extra).
  local ny = 36 + by + hx
  span(ny, 50, 58, HIDE)
  span(ny + 1, 52, 60, HIDE_M)
  span(35 + by + hx, 48, 54, HIDE)
  span(38 + by + cx, 48, 56, HIDE)
  span(40 + by + cx, 44, 52, HIDE_M)

  -- Jaw seam under muzzle after lag.
  local jbase = 50 + by + jy
  span(jbase, 70, 76, HIDE_M)
  span(jbase + 1, 71, 78, HIDE_S)

  if o.lid then
    local ey = 41 + by
    span(ey - 1, 66, 69, HIDE_S)
    span(ey, 66, 68, HIDE_M)
    dot(67, ey + 1, INK)
  else
    dot(67, 41 + by, EYE_SPEC)
  end
  flush("color")

  buf = {}
  seto(0, 0)
  span(20 + by + hx, 51, 51, HIDE_S)
  span(25 + by + hx, 52, 52, HIDE_S)
  span(35 + by, 49, 49, HIDE_S)
  span(43 + by, 75, 75, HIDE_S)
  span(55 + by + jy, 80, 80, CRACK)
  flush("line")

  buf = {}
  seto(0, 0)
  if o.spec then
    dot(67, 41 + by, EYE_SPEC)
    dot(26, 21 + by + hx, HORN_H)
    dot(27, 22 + by + hx, HIDE_H)
    dot(28, 21 + by + hx, HIDE_H)
  else
    dot(27, 22 + by + hx, HIDE_H)
    dot(28, 21 + by + hx, HIDE_H)
  end
  flush("fx")
end

function paint_demon_96_at(frame, o)
  FRAME = frame
  o = o or {}
  seto(0, 0)
  for _, name in ipairs({ "line", "color", "shade", "fx" }) do
    pcall(function()
      DM.clear_cel(name, FRAME)
    end)
  end
  paint_color(o)
  paint_shade(o)
  paint_line(o)
  paint_fx(o)
end

function paint_demon_96()
  -- still only; animation uses paint_demon_96_at
  FRAME = 1
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
    "sk_hump",
    "sk_horn",
    "sk_tail",
    "volume",
    "vol_spine",
    "vol_head",
    "vol_arm_f",
    "vol_arm_b",
    "vol_leg_f",
    "vol_leg_b",
    "vol_hump",
    "vol_horn",
    "vol_tail",
    "_tmp",
  }) do
    hide(name)
  end
  seto(0, 0)
  paint_color({})
  paint_shade({})
  paint_line({})
  paint_fx({})
  DM.result({ ok = true, pass = "paint_demon_96" })
end
