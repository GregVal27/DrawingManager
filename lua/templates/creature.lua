-- Two-pass side-on creature: pose_humanoid_skeleton then paint_creature.
-- Pass 1 (volume) may stay chunky via U()/S(). Pass 2 is 1px form inventory + selout;
-- it does not trace volume or call outline_from_volume.

local INK = "#181425"
local BONE = "#e43b44"
local VOL = "#3a4466"
local SKIN = "#e8b796"
local SKIN_S = "#c28569"
local SHIRT = "#e43b44"
local SHIRT_S = "#9e2835"
local PANTS = "#3a4466"
local PANTS_S = "#262b44"
local HAIR = "#ead4aa"
local HAIR_S = "#b86e50"
local BOOT = "#3f2832"
local WHITE = "#ffffff"
local EYE = "#181425"
local STEEL = "#8a8f99"
local STEEL_S = "#4a4e56"

local FACING = "right"

local function U()
  return math.max(1, math.floor(math.min(DM.sprite().width, DM.sprite().height) / 32))
end

local function S(n)
  return math.floor(n * U() + (n >= 0 and 0.0001 or -0.0001))
end

local function fx(x, w)
  w = w or 1
  if FACING == "left" then
    return DM.sprite().width - (x + w)
  end
  return x
end

local function has_layer(name)
  local ok = pcall(function()
    DM.find_layer(name)
  end)
  return ok
end

local function skel(part)
  local n = "sk_" .. part
  if has_layer(n) then
    return n
  end
  return "skeleton"
end

local function vol(part)
  local n = "vol_" .. part
  if has_layer(n) then
    return n
  end
  return "volume"
end

local function put(layer, frame, x, y, w, h, color)
  if w <= 0 or h <= 0 then
    return
  end
  DM.use(layer, frame)
  DM.draw_rect(fx(x, w), y, w, h, color, true)
end

local function line(layer, frame, x1, y1, x2, y2, color)
  DM.use(layer, frame)
  DM.draw_line(fx(x1, 1), y1, fx(x2, 1), y2, color)
end

local function linepx(layer, frame, x1, y1, x2, y2, color)
  DM.use(layer, frame)
  DM.draw_line_px(fx(x1, 1), y1, fx(x2, 1), y2, color)
end

local function pixel(layer, frame, x, y, color)
  DM.use(layer, frame)
  DM.draw_pixels({ { x = fx(x, 1), y = y, color = color } })
end

local function punch(layer, frame, x, y, w, h, color)
  if w <= 0 or h <= 0 then
    return
  end
  DM.use(layer, frame)
  DM.punch(fx(x, w), y, w, h, color)
end

local function oval(layer, frame, cx, cy, rx, ry, color)
  DM.use(layer, frame)
  local ox = cx
  if FACING == "left" then
    ox = DM.sprite().width - 1 - cx
  end
  DM.draw_ellipse(ox, cy, rx, ry, color, true)
end

local function tag_range(name)
  local s = DM.sprite()
  if not name or name == "" then
    return 1, #s.frames
  end
  for _, tag in ipairs(s.tags) do
    if tag.name == name then
      return tag.fromFrame.frameNumber, tag.toFrame.frameNumber
    end
  end
  return 1, #s.frames
end

local idle = {
  { bob = 0, lean = 0, rleg = 1, lleg = -1, rarm = 0, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0 },
  { bob = -1, lean = 0, rleg = 1, lleg = -1, rarm = 0, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0 },
  { bob = 0, lean = 0, rleg = 1, lleg = -1, rarm = 0, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0, blink = true },
  { bob = 0, lean = 0, rleg = 1, lleg = -1, rarm = 0, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0 },
}

local walk = {
  { bob = 1, lean = 1, rleg = 3, lleg = -3, rarm = -2, larm = 2, rlift = 0, llift = 0, rarm_y = 1, larm_y = -1 },
  { bob = 2, lean = 1, rleg = 2, lleg = -2, rarm = -1, larm = 1, rlift = 0, llift = 0, rarm_y = 1, larm_y = 0 },
  { bob = 0, lean = 0, rleg = 0, lleg = 0, rarm = 0, larm = 0, rlift = 0, llift = 3, rarm_y = 0, larm_y = 0 },
  { bob = -1, lean = 0, rleg = -2, lleg = 3, rarm = 1, larm = -1, rlift = 2, llift = 0, rarm_y = -1, larm_y = 1 },
  { bob = 1, lean = 1, rleg = -3, lleg = 3, rarm = 2, larm = -2, rlift = 0, llift = 0, rarm_y = -1, larm_y = 1 },
  { bob = 2, lean = 1, rleg = -2, lleg = 2, rarm = 1, larm = -1, rlift = 0, llift = 0, rarm_y = 0, larm_y = 1 },
  { bob = 0, lean = 0, rleg = 0, lleg = 0, rarm = 0, larm = 0, rlift = 3, llift = 0, rarm_y = 0, larm_y = 0 },
  { bob = -1, lean = 0, rleg = 3, lleg = -2, rarm = -1, larm = 1, rlift = 0, llift = 2, rarm_y = 1, larm_y = -1 },
}

local run = {
  { bob = 2, lean = 2, rleg = 4, lleg = -4, rarm = -3, larm = 3, rlift = 0, llift = 1, rarm_y = 2, larm_y = -2 },
  { bob = 1, lean = 2, rleg = 2, lleg = -2, rarm = -2, larm = 2, rlift = 1, llift = 0, rarm_y = 1, larm_y = -1 },
  { bob = 2, lean = 1, rleg = -4, lleg = 4, rarm = 3, larm = -3, rlift = 1, llift = 0, rarm_y = -2, larm_y = 2 },
  { bob = 1, lean = 1, rleg = -2, lleg = 2, rarm = 2, larm = -2, rlift = 0, llift = 1, rarm_y = -1, larm_y = 1 },
}

local attack = {
  { bob = 0, lean = -1, rleg = 2, lleg = -1, rarm = -2, larm = 1, rlift = 0, llift = 0, rarm_y = -1, larm_y = 1, sword = true, sword_x = 1, sword_y = 2, sword_w = 8 },
  { bob = 1, lean = 2, rleg = 3, lleg = -2, rarm = 6, larm = -1, rlift = 0, llift = 1, rarm_y = -2, larm_y = 1, sword = true, sword_x = 2, sword_y = 0, sword_w = 12 },
  { bob = 0, lean = 2, rleg = 3, lleg = -2, rarm = 5, larm = -1, rlift = 0, llift = 0, rarm_y = -1, larm_y = 1, sword = true, sword_x = 2, sword_y = 1, sword_w = 11 },
  { bob = 0, lean = 0, rleg = 1, lleg = -1, rarm = 1, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0, sword = true, sword_x = 2, sword_y = 2, sword_w = 8 },
}

local jump = {
  { bob = -2, lean = 0, rleg = 0, lleg = 0, rarm = -1, larm = -1, rlift = 2, llift = 2, rarm_y = -2, larm_y = -2 },
  { bob = -4, lean = 1, rleg = 1, lleg = -1, rarm = 1, larm = 1, rlift = 3, llift = 3, rarm_y = -3, larm_y = -1 },
  { bob = -3, lean = 0, rleg = 2, lleg = -1, rarm = 0, larm = 0, rlift = 1, llift = 2, rarm_y = -1, larm_y = 0 },
}

local fall = {
  { bob = 1, lean = 0, rleg = 1, lleg = -1, rarm = 2, larm = -2, rlift = 0, llift = 0, rarm_y = -2, larm_y = -2 },
  { bob = 3, lean = 0, rleg = 2, lleg = -2, rarm = 3, larm = -3, rlift = 0, llift = 0, rarm_y = -3, larm_y = -2 },
}

local hurt = {
  { bob = 0, lean = -2, rleg = 1, lleg = 0, rarm = -1, larm = 1, rlift = 0, llift = 0, rarm_y = 1, larm_y = 1 },
  { bob = 1, lean = -3, rleg = 0, lleg = 1, rarm = -2, larm = 2, rlift = 0, llift = 0, rarm_y = 2, larm_y = 0 },
}

local die = {
  { bob = 1, lean = -2, rleg = 2, lleg = 0, rarm = -1, larm = 2, rlift = 0, llift = 0, rarm_y = 2, larm_y = 1 },
  { bob = 4, lean = -4, rleg = 3, lleg = 1, rarm = -2, larm = 3, rlift = 0, llift = 0, rarm_y = 3, larm_y = 2 },
  { bob = 8, lean = -6, rleg = 4, lleg = 2, rarm = -3, larm = 4, rlift = 0, llift = 0, rarm_y = 4, larm_y = 3 },
}

local TAG_POSES = {
  idle = idle,
  walk = walk,
  run = run,
  attack = attack,
  jump = jump,
  fall = fall,
  hurt = hurt,
  die = die,
}

local function pose_at(list, i, n)
  if #list == 0 then
    return idle[1]
  end
  if n <= 1 then
    return list[1]
  end
  local t = (i - 1) / math.max(1, n - 1)
  local idx = 1 + math.floor(t * (#list - 1) + 0.5)
  if idx < 1 then idx = 1 end
  if idx > #list then idx = #list end
  return list[idx]
end

local function pose_for_tag(tag_name, i, n)
  return pose_at(TAG_POSES[tag_name] or idle, i, n)
end

local function draw_skeleton_pose(frame, pose, description, i, n)
  local bob = S(pose.bob)
  local lean = S(pose.lean)
  if FACING == "left" then
    lean = -lean
  end
  local hx = S(16) + lean
  local hy = S(8) + bob
  local tx = S(16) + lean
  local ty = S(16) + bob
  line(skel("spine"), frame, tx, hy + S(4), tx, ty + S(8), BONE)
  put(skel("head"), frame, hx - S(2), hy, S(5), S(5), BONE)
  line(skel("arm_f"), frame, tx + S(2), ty, tx + S(6) + S(pose.rarm), ty + S(6) + S(pose.rarm_y), BONE)
  line(skel("arm_b"), frame, tx - S(2), ty, tx - S(6) + S(pose.larm), ty + S(6) + S(pose.larm_y), BONE)
  line(skel("leg_f"), frame, tx + S(1), ty + S(8), tx + S(2) + S(pose.rleg), ty + S(16) - S(pose.rlift), BONE)
  line(skel("leg_b"), frame, tx - S(1), ty + S(8), tx - S(2) + S(pose.lleg), ty + S(16) - S(pose.llift), BONE)

  put(vol("head"), frame, hx - S(3), hy - S(1), S(8), S(8), VOL)
  put(vol("spine"), frame, tx - S(4), ty, S(9), S(10), VOL)
  put(vol("leg_f"), frame, tx + S(1) + S(pose.rleg), ty + S(8) - S(pose.rlift), S(4), S(8) + S(pose.rlift), VOL)
  put(vol("leg_b"), frame, tx - S(4) + S(pose.lleg), ty + S(8) - S(pose.llift), S(4), S(8) + S(pose.llift), VOL)
  put(vol("arm_f"), frame, tx + S(4) + S(pose.rarm), ty + S(pose.rarm_y), S(3), S(7), VOL)
  put(vol("arm_b"), frame, tx - S(6) + S(pose.larm), ty + S(pose.larm_y), S(3), S(7), VOL)

  local desc = (description or ""):lower()
  if desc:find("шарик") or desc:find("balloon") or desc:find("шар") then
    local t = 0
    if n and n > 1 then
      t = (i - 1) / (n - 1)
    end
    local r = S(3) + math.floor(S(8) * t)
    if desc:find("лопа") or desc:find("pop") or t > 0.75 then
      oval(skel("head"), frame, hx, hy, r, r, "#ead4aa")
      if t > 0.85 then
        line(skel("head"), frame, hx - r, hy, hx + r, hy, INK)
        line(skel("head"), frame, hx, hy - r, hx, hy + r, INK)
      end
    else
      oval(vol("head"), frame, hx, hy - S(2), r, r, "#e43b44")
    end
  end
end

-- Pass 2 draft: 1px brush, form inventory. P() places landmarks only;
-- limb thickness stays 2/3px. Per-brief paint should replace this via run_lua.
local function draw_paint_pose(frame, pose)
  local s = DM.sprite()
  local k = math.min(s.width, s.height) / 64
  local function P(n)
    n = n or 0
    return math.floor(n * k + (n >= 0 and 0.0001 or -0.0001))
  end
  local arm_w = 2
  local leg_w = 3
  local foot_h = 2
  local thigh_h = P(10)
  local shin_h = P(10)
  local bob = P(pose.bob or 0)
  local lean = P(pose.lean or 0)
  if FACING == "left" then
    lean = -lean
  end
  local rleg = P(pose.rleg or 0)
  local lleg = P(pose.lleg or 0)
  local rlift = P(pose.rlift or 0)
  local llift = P(pose.llift or 0)
  local rarm = P(pose.rarm or 0)
  local larm = P(pose.larm or 0)
  local rarm_y = P(pose.rarm_y or 0)
  local larm_y = P(pose.larm_y or 0)

  local hx = P(36) + lean
  local hy = P(12) + bob
  local tx = P(34) + lean
  local ty = P(24) + bob
  local hip_x = P(33) + lean
  local hip_y = P(38) + bob

  -- Far arm (behind torso): 1px strokes, 2px form
  local bx = P(28) + lean + larm
  local by = P(20) + bob + larm_y
  local bhand_x = bx - P(1)
  local bhand_y = by + P(11)
  for i = 0, arm_w - 1 do
    linepx("color", frame, bx + i, by, bhand_x + i, bhand_y, SKIN_S)
  end
  put("shade", frame, bhand_x, bhand_y - 1, arm_w, 3, SKIN_S)

  -- Far leg (3px thigh, 2px shin, gap vs near leg)
  local lx = hip_x - P(3) + lleg
  local ly = hip_y - llift
  local l_thigh = thigh_h + llift
  put("color", frame, lx, ly, leg_w, l_thigh, PANTS_S)
  put("color", frame, lx + 1, ly + l_thigh, 2, shin_h, PANTS_S)
  put("color", frame, lx - 1, ly + l_thigh + shin_h, 5, foot_h, BOOT)

  -- Torso clusters (chest, waist) — not a shirt square
  oval("color", frame, tx, ty, math.max(4, P(6)), math.max(5, P(7)), SHIRT)
  oval("color", frame, hip_x + 1, hip_y - P(2), math.max(3, P(5)), math.max(4, P(6)), SHIRT)
  put("color", frame, hip_x - P(1), hip_y - P(1), P(8), P(4), PANTS)
  put("shade", frame, tx + P(2), ty + P(2), P(3), P(8), SHIRT_S)
  linepx("color", frame, hip_x, hip_y, hip_x + P(6), hip_y, PANTS_S)

  -- Neck + head (skull oval, hair cluster, ear)
  put("color", frame, hx - 1, hy + P(5), 2, P(3), SKIN)
  oval("color", frame, hx, hy, math.max(4, P(5)), math.max(5, P(6)), SKIN)
  oval("color", frame, hx - P(2), hy - P(5), math.max(3, P(5)), math.max(2, P(3)), HAIR)
  put("color", frame, hx - P(5), hy - P(3), P(3), P(5), HAIR)
  pixel("color", frame, hx - P(5), hy, SKIN)
  put("shade", frame, hx + 1, hy + P(2), P(3), P(4), SKIN_S)
  pixel("color", frame, hx - P(2), hy + 1, HAIR_S)

  local eye_x = hx + P(2)
  local eye_y = hy - 1
  if pose.blink then
    put("color", frame, eye_x, eye_y, 2, 1, SKIN)
  else
    punch("color", frame, eye_x, eye_y, 2, 2)
    pixel("color", frame, eye_x, eye_y, WHITE)
    pixel("color", frame, eye_x + 1, eye_y + 1, EYE)
  end

  -- Near leg (gap vs far leg)
  local rx = hip_x + P(3) + rleg
  local ry = hip_y - rlift
  local r_thigh = thigh_h + rlift
  put("color", frame, rx, ry, leg_w, r_thigh, PANTS)
  put("color", frame, rx + 1, ry + r_thigh, 2, shin_h, PANTS)
  put("shade", frame, rx + 2, ry + P(6), 1, P(8), PANTS_S)
  put("color", frame, rx, ry + r_thigh + shin_h, 5, foot_h, BOOT)

  -- Near arm
  local ax = P(40) + lean + rarm
  local ay = P(20) + bob + rarm_y
  local ahand_x = ax + P(1)
  local ahand_y = ay + P(11)
  for i = 0, arm_w - 1 do
    linepx("color", frame, ax + i, ay, ahand_x + i, ahand_y, SKIN)
  end
  put("color", frame, ahand_x, ahand_y - 1, arm_w, 3, SKIN)

  if pose.sword then
    local sx = ahand_x + (pose.sword_x or 2)
    local sy = ahand_y + (pose.sword_y or 0)
    local sw = math.max(8, P(pose.sword_w or 10))
    linepx("fx", frame, sx, sy, sx + sw, sy, STEEL)
    linepx("fx", frame, sx + 1, sy + 1, sx + sw - 1, sy + 1, STEEL)
    put("fx", frame, sx, sy - 1, 2, 3, STEEL_S)
  end
end

function pose_humanoid_skeleton(facing, tag, description)
  FACING = (facing == "left") and "left" or "right"
  local from_f, to_f = tag_range(tag)
  local n = to_f - from_f + 1
  local tag_name = tag or "idle"
  for f = from_f, to_f do
    local i = f - from_f + 1
    draw_skeleton_pose(f, pose_for_tag(tag_name, i, n), description, i, n)
  end
  DM.result(DM.info())
end

function paint_creature(facing, tag)
  FACING = (facing == "left") and "left" or "right"
  local from_f, to_f = tag_range(tag)
  local n = to_f - from_f + 1
  local tag_name = tag or "idle"
  for f = from_f, to_f do
    pcall(function()
      DM.clear_cel("line", f)
    end)
    pcall(function()
      DM.clear_cel("color", f)
    end)
    pcall(function()
      DM.clear_cel("shade", f)
    end)
    pcall(function()
      DM.clear_cel("fx", f)
    end)
    local i = f - from_f + 1
    draw_paint_pose(f, pose_for_tag(tag_name, i, n))
    DM.use("color", f)
    DM.selout(INK)
  end
  pcall(function()
    DM.set_layer_visible("skeleton", false)
  end)
  pcall(function()
    for _, name in ipairs({ "sk_spine", "sk_head", "sk_arm_f", "sk_arm_b", "sk_leg_f", "sk_leg_b" }) do
      if has_layer(name) then
        DM.set_layer_visible(name, false)
      end
    end
  end)
  pcall(function()
    DM.set_layer_visible("volume", false)
  end)
  pcall(function()
    for _, name in ipairs({ "vol_spine", "vol_head", "vol_arm_f", "vol_arm_b", "vol_leg_f", "vol_leg_b" }) do
      if has_layer(name) then
        DM.set_layer_visible(name, false)
      end
    end
  end)
  DM.result(DM.info())
end
