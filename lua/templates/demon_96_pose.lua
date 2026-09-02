-- Pass 1: beast demon, 96x96. Sticks + volume. Not a humanoid.
-- pose_demon_96() = still frame 1. pose_demon_96_at(F, o) = any frame.
-- Idle: skeleton may bob; paint hybrid is copy still + part shift/rotate + brush.

local F = 1
local STICK = "#ff0044"
local HIDE = "#9e2835c8"
local HIDE2 = "#743f39c8"
local HUMP = "#e43b44c0"
local BONE = "#ead4aac8"
local HORN = "#c28569c8"
local DARK = "#3f2832c8"
local VOID = "transparent"

local function has(name)
  local ok = pcall(function()
    DM.find_layer(name)
  end)
  return ok
end

local function ensure(name, parent)
  if not has(name) then
    DM.add_layer(name, parent)
  end
end

local function clr(name)
  pcall(function()
    DM.clear_cel(name, F)
  end)
end

local function use(layer)
  DM.use(layer, F)
end

local function put(layer, x, y, w, h, c)
  if w <= 0 or h <= 0 then
    return
  end
  use(layer)
  DM.draw_rect(x, y, w, h, c, true)
end

local function ov(layer, cx, cy, rx, ry, c)
  use(layer)
  DM.draw_ellipse(cx, cy, rx, ry, c, true)
end

local function ln(layer, x1, y1, x2, y2, c)
  use(layer)
  DM.draw_line(x1, y1, x2, y2, c)
end

local function poly(layer, pts, c)
  use(layer)
  DM.draw_polyline(pts, c, false)
end

local function hole(layer, x, y, w, h)
  use(layer)
  DM.punch(x, y, w, h, VOID)
end

local function ensure_parts()
  ensure("sk_hump", "skeleton")
  ensure("sk_horn", "skeleton")
  ensure("sk_tail", "skeleton")
  ensure("vol_hump", "volume")
  ensure("vol_horn", "volume")
  ensure("vol_tail", "volume")
end

local function clear_pose_cels()
  for _, n in ipairs({
    "sk_spine",
    "sk_head",
    "sk_arm_f",
    "sk_arm_b",
    "sk_leg_f",
    "sk_leg_b",
    "sk_hump",
    "sk_horn",
    "sk_tail",
    "vol_spine",
    "vol_head",
    "vol_arm_f",
    "vol_arm_b",
    "vol_leg_f",
    "vol_leg_b",
    "vol_hump",
    "vol_horn",
    "vol_tail",
  }) do
    clr(n)
  end
end

function pose_demon_96_at(frame, o)
  F = frame
  o = o or {}
  local bx = o.bx or 0
  local by = o.by or 0
  local tbx = o.tail_bx or bx
  local tby = o.tail_by or by
  local jby = o.jaw_by or by
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

  local function X(x)
    return x + bx
  end
  local function Y(y)
    return y + by
  end
  local function TX(x)
    return x + tbx
  end
  local function TY(y)
    return y + tby
  end
  local function JY(y)
    return y + jby + hdy
  end
  local function HX(x)
    return x + bx + hx
  end
  local function HDX(x)
    return x + bx + hdx
  end
  local function HDY(y)
    return y + by + hdy
  end
  local function NLX(x)
    return x + bx + nlx
  end
  local function NLY(y)
    return y + by + nly
  end
  local function NFX(x)
    return x + nlx
  end
  local function NFY(y)
    if plant_n then
      return y + nly
    end
    return y + by + nly
  end
  local function FLX(x)
    return x + bx + flx
  end
  local function FLY(y)
    return y + by + fly
  end
  local function FFX(x)
    return x + flx
  end
  local function FFY(y)
    if plant_f then
      return y + fly
    end
    return y + by + fly
  end
  local function NAX(x)
    return x + bx + nax
  end
  local function NAY(y)
    return y + by + nay
  end
  local function FAX(x)
    return x + bx + fax
  end
  local function FAY(y)
    return y + by + fay
  end

  ensure_parts()
  clear_pose_cels()

  pcall(function()
    DM.find_layer("vol_hump").stackIndex = 1
  end)
  pcall(function()
    DM.find_layer("vol_tail").stackIndex = 2
  end)

  -- VOLUME back to front ------------------------------------------------
  -- Tail (lagged)
  ov("vol_tail", TX(34), TY(64), 6, 4, HIDE2)
  ov("vol_tail", TX(24), TY(72), 5, 4, HIDE2)
  put("vol_tail", TX(14), TY(76), 12, 5, HIDE2)
  ov("vol_tail", TX(10), TY(82), 4, 3, DARK)
  put("vol_tail", TX(8), TY(80), 6, 5, DARK)

  -- Far goat
  ov("vol_leg_b", FLX(40), FLY(60), 7, 5, HIDE2)
  put("vol_leg_b", FLX(34), FLY(62), 8, 10, HIDE2)
  put("vol_leg_b", FFX(28), FFY(70), 7, 6, HIDE2)
  put("vol_leg_b", FFX(26), FFY(76), 5, 12, DARK)
  put("vol_leg_b", FFX(22), FFY(86), 8, 5, BONE)
  ov("vol_leg_b", FFX(24), FFY(89), 4, 2, HORN)

  -- Far arm
  ov("vol_arm_b", FAX(42), FAY(50), 4, 3, HIDE2)
  put("vol_arm_b", FAX(36), FAY(52), 5, 8, HIDE2)
  put("vol_arm_b", FAX(32), FAY(58), 4, 8, DARK)
  ov("vol_arm_b", FAX(31), FAY(66), 3, 3, HIDE2)

  -- HUMP
  ov("vol_hump", HX(38), Y(32), 16, 10, HUMP)
  put("vol_hump", HX(26), Y(28), 24, 16, HUMP)
  ov("vol_hump", HX(32), Y(26), 12, 8, HUMP)
  ov("vol_hump", HX(46), Y(38), 10, 8, HIDE)
  put("vol_hump", HX(30), Y(36), 18, 10, HIDE)
  hole("vol_hump", HX(48), Y(18), 10, 10)
  hole("vol_hump", HX(54), Y(22), 8, 8)

  -- Torso / belly
  ov("vol_spine", X(48), Y(50), 12, 10, HIDE)
  put("vol_spine", X(40), Y(46), 18, 14, HIDE)
  ov("vol_spine", X(52), Y(58), 9, 7, HIDE2)
  hole("vol_spine", X(44), Y(62), 6, 6)

  -- Head: skull+muzzle; hanging jaw lagged
  ov("vol_head", HDX(64), HDY(44), 8, 7, HIDE)
  put("vol_head", HDX(66), HDY(44), 16, 8, HIDE)
  ov("vol_head", HDX(78), HDY(48), 8, 5, HIDE)
  ov("vol_head", HDX(74), JY(56), 8, 5, HIDE2)
  put("vol_head", HDX(68), JY(52), 14, 7, HIDE2)
  put("vol_head", HDX(60), HDY(38), 12, 5, DARK)
  hole("vol_head", HDX(70), HDY(50), 10, 5)
  hole("vol_head", HDX(76), HDY(52), 6, 4)

  -- Horns from skull
  put("vol_horn", HDX(52), HDY(6), 4, 22, BONE)
  put("vol_horn", HDX(50), HDY(4), 3, 8, HORN)
  put("vol_horn", HDX(54), HDY(20), 5, 14, HORN)
  put("vol_horn", HDX(66), HDY(8), 3, 22, BONE)
  put("vol_horn", HDX(67), HDY(6), 3, 8, HORN)
  put("vol_horn", HDX(64), HDY(22), 5, 14, HORN)
  hole("vol_horn", HDX(54), HDY(18), 8, 10)
  hole("vol_hump", HX(50), Y(18), 12, 10)

  -- Near goat
  ov("vol_leg_f", NLX(56), NLY(60), 8, 6, HIDE)
  put("vol_leg_f", NLX(58), NLY(64), 9, 12, HIDE)
  put("vol_leg_f", NFX(62), NFY(74), 7, 6, HIDE)
  put("vol_leg_f", NFX(64), NFY(80), 6, 12, HIDE2)
  put("vol_leg_f", NFX(60), NFY(90), 14, 5, BONE)
  ov("vol_leg_f", NFX(64), NFY(93), 5, 2, HORN)
  hole("vol_leg_f", NFX(50), NFY(76), 8, 12)

  -- Near arm
  ov("vol_arm_f", NAX(58), NAY(50), 5, 4, HIDE)
  put("vol_arm_f", NAX(62), NAY(54), 6, 12, HIDE)
  put("vol_arm_f", NAX(66), NAY(64), 5, 10, HIDE2)
  ov("vol_arm_f", NAX(70), NAY(74), 4, 3, HIDE)

  -- STICKS --------------------------------------------------------------
  ln("sk_spine", X(48), Y(58), X(38), Y(42), STICK)
  ln("sk_spine", X(38), Y(42), X(36), Y(26), STICK)
  ln("sk_spine", X(36), Y(26), X(52), Y(38), STICK)
  ln("sk_spine", X(52), Y(38), X(64), Y(44), STICK)
  put("sk_spine", X(44), Y(54), 10, 3, STICK)

  ln("sk_hump", HX(32), Y(28), HX(50), Y(34), STICK)
  ln("sk_hump", HX(30), Y(34), HX(48), Y(40), STICK)

  ov("sk_head", HDX(64), HDY(44), 6, 5, STICK)
  ln("sk_head", HDX(68), HDY(46), HDX(82), HDY(50), STICK)
  ln("sk_head", HDX(68), HDY(48), HDX(80), HDY(54), STICK)
  ln("sk_head", HDX(66), JY(52), HDX(78), JY(58), STICK)
  put("sk_head", HDX(74), JY(54), 6, 3, STICK)

  ln("sk_horn", HDX(56), HDY(36), HDX(46), HDY(8), STICK)
  ln("sk_horn", HDX(57), HDY(36), HDX(48), HDY(6), STICK)
  ln("sk_horn", HDX(66), HDY(38), HDX(68), HDY(10), STICK)
  put("sk_horn", HDX(45), HDY(4), 3, 4, STICK)
  put("sk_horn", HDX(67), HDY(8), 3, 3, STICK)

  ln("sk_arm_f", NAX(56), NAY(50), NAX(66), NAY(62), STICK)
  ln("sk_arm_f", NAX(66), NAY(62), NAX(72), NAY(74), STICK)
  put("sk_arm_f", NAX(70), NAY(72), 4, 3, STICK)

  ln("sk_arm_b", FAX(44), FAY(50), FAX(36), FAY(58), STICK)
  ln("sk_arm_b", FAX(36), FAY(58), FAX(32), FAY(66), STICK)
  put("sk_arm_b", FAX(30), FAY(64), 4, 3, STICK)

  ln("sk_leg_f", NLX(54), NLY(58), NLX(64), NLY(72), STICK)
  ln("sk_leg_f", NLX(64), NLY(72), NFX(68), NFY(80), STICK)
  ln("sk_leg_f", NFX(68), NFY(80), NFX(66), NFY(92), STICK)
  put("sk_leg_f", NFX(60), NFY(91), 12, 3, STICK)

  ln("sk_leg_b", FLX(44), FLY(58), FFX(32), FFY(70), STICK)
  ln("sk_leg_b", FFX(32), FFY(70), FFX(26), FFY(78), STICK)
  ln("sk_leg_b", FFX(26), FFY(78), FFX(24), FFY(88), STICK)
  put("sk_leg_b", FFX(22), FFY(86), 8, 3, STICK)

  poly("sk_tail", {
    { x = TX(42), y = TY(60) },
    { x = TX(28), y = TY(68) },
    { x = TX(18), y = TY(76) },
    { x = TX(10), y = TY(82) },
    { x = TX(6), y = TY(84) },
  }, STICK)

  for _, n in ipairs({
    "vol_hump",
    "vol_spine",
    "vol_head",
    "vol_arm_f",
    "vol_arm_b",
    "vol_leg_f",
    "vol_leg_b",
    "vol_horn",
    "vol_tail",
  }) do
    pcall(function()
      DM.find_layer(n).opacity = 180
    end)
  end
end

function pose_demon_96()
  pose_demon_96_at(1, {})
  DM.result({ ok = true, pose = "demon_96_still" })
end

local function vis(name, v)
  pcall(function()
    DM.find_layer(name).isVisible = v
  end)
end

function pose_demon_96_idle()
  -- still = frame 1. idle tag = frames 2-5. Volume/sticks may bob;
  -- paint later redraws clusters (phase), not a shifted still.
  local keys = {
    { by = 0, tail_by = 0, jaw_by = 0 },
    { by = -1, tail_by = 0, jaw_by = 0 },
    { by = 0, tail_by = -1, jaw_by = -1 },
    { by = 1, tail_by = 0, jaw_by = 0 },
  }
  for i, key in ipairs(keys) do
    pose_demon_96_at(1 + i, key)
  end
  -- pose check: show sticks+volume, hide paint (still paint cels stay)
  for _, n in ipairs({ "paint", "line", "color", "shade", "fx", "_tmp" }) do
    vis(n, false)
  end
  vis("skeleton", true)
  vis("volume", true)
  for _, n in ipairs({
    "sk_spine",
    "sk_head",
    "sk_arm_f",
    "sk_arm_b",
    "sk_leg_f",
    "sk_leg_b",
    "sk_hump",
    "sk_horn",
    "sk_tail",
    "vol_spine",
    "vol_head",
    "vol_arm_f",
    "vol_arm_b",
    "vol_leg_f",
    "vol_leg_b",
    "vol_hump",
    "vol_horn",
    "vol_tail",
  }) do
    vis(n, true)
  end
  DM.result({ ok = true, pose = "demon_96_idle", frames = { 2, 3, 4, 5 } })
end
