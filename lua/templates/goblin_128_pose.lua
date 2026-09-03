-- Pass 1 still: hunched goblin, short sword, round shield. 128x128, facing right.
-- No U()/S(). Frame 1 only. Wait for user «ок» before paint.

local F = 1
local BONE = "#e43b44"
local VOL = "#3a4466"
local VOLB = "#262b44"
local VOLN = "#4a5580"
local SHIELD = "#5c6b8a"
local STEEL = "#8b9bb4"

local function use(layer)
  DM.use(layer, F)
end

local function rect(layer, x, y, w, h, c)
  if w < 1 or h < 1 then
    return
  end
  use(layer)
  DM.draw_rect(x, y, w, h, c, true)
end

local function oval(layer, cx, cy, rx, ry, c)
  use(layer)
  DM.draw_ellipse(cx, cy, rx, ry, c, true)
end

local function stick(layer, x1, y1, x2, y2, c)
  use(layer)
  DM.draw_line(x1, y1, x2, y2, c)
end

local function hole(layer, x, y, w, h)
  if w < 1 or h < 1 then
    return
  end
  use(layer)
  DM.punch(x, y, w, h)
end

local function ensure_layer(name, parent)
  local ok = pcall(function()
    DM.find_layer(name)
  end)
  if not ok then
    DM.add_layer(name, parent)
  end
end

local function clear_pass1()
  local names = {
    "sk_spine", "sk_head", "sk_arm_f", "sk_arm_b", "sk_leg_f", "sk_leg_b",
    "sk_sword", "sk_shield",
    "vol_spine", "vol_head", "vol_arm_f", "vol_arm_b", "vol_leg_f", "vol_leg_b",
    "vol_sword", "vol_shield",
  }
  for _, name in ipairs(names) do
    pcall(function()
      DM.clear_cel(name, F)
    end)
  end
end

function pose_goblin_128_still()
  ensure_layer("sk_sword", "skeleton")
  ensure_layer("sk_shield", "skeleton")
  ensure_layer("vol_shield", "volume")
  ensure_layer("vol_sword", "volume")
  clear_pass1()

  -- Sticks
  stick("sk_spine", 56, 50, 50, 94, BONE)
  stick("sk_head", 64, 34, 80, 46, BONE)
  stick("sk_head", 80, 46, 100, 52, BONE)
  stick("sk_arm_b", 52, 58, 34, 74, BONE)
  stick("sk_arm_f", 60, 62, 82, 90, BONE)
  stick("sk_leg_b", 46, 94, 36, 121, BONE)
  stick("sk_leg_f", 56, 96, 74, 121, BONE)
  stick("sk_sword", 84, 86, 112, 104, BONE)
  use("sk_shield")
  DM.draw_ellipse(32, 76, 16, 16, BONE, false)

  -- Far leg: back, shorter, plant y=121
  oval("vol_leg_b", 40, 102, 6, 11, VOLB)
  rect("vol_leg_b", 34, 110, 10, 11, VOLB)
  rect("vol_leg_b", 30, 119, 16, 4, VOLB)

  -- Far arm + shield sticking LEFT of body (silhouette disk)
  rect("vol_arm_b", 44, 56, 8, 18, VOLB)
  oval("vol_shield", 32, 76, 17, 16, SHIELD)
  oval("vol_shield", 34, 76, 5, 5, STEEL)

  -- Hunched torso / belly. Gap vs legs and shield.
  oval("vol_spine", 52, 68, 14, 13, VOL)
  oval("vol_spine", 50, 84, 13, 11, VOL)
  rect("vol_spine", 44, 74, 16, 18, VOL)
  hole("vol_spine", 58, 90, 10, 12)
  hole("vol_spine", 36, 66, 8, 14)

  -- Head: big skull, ear fans, long nose, jaw. Eye hole.
  oval("vol_head", 68, 40, 16, 15, VOLN)
  rect("vol_head", 42, 20, 14, 22, VOLN)
  oval("vol_head", 46, 22, 8, 8, VOLN)
  rect("vol_head", 78, 16, 12, 20, VOLN)
  oval("vol_head", 86, 20, 7, 7, VOLN)
  rect("vol_head", 80, 44, 20, 10, VOLN)
  oval("vol_head", 100, 50, 8, 6, VOLN)
  oval("vol_head", 74, 56, 9, 7, VOLN)
  hole("vol_head", 76, 36, 6, 5)
  hole("vol_head", 90, 34, 12, 8)

  -- Near leg forward/right, gap vs far
  oval("vol_leg_f", 66, 104, 7, 11, VOLN)
  rect("vol_leg_f", 62, 112, 11, 9, VOLN)
  rect("vol_leg_f", 60, 119, 18, 5, VOLN)
  hole("vol_leg_f", 48, 108, 14, 12)

  -- Near arm + short sword angled down-forward, clear of snout
  rect("vol_arm_f", 60, 58, 8, 16, VOLN)
  rect("vol_arm_f", 68, 72, 9, 14, VOLN)
  oval("vol_arm_f", 80, 88, 6, 6, VOLN)
  rect("vol_sword", 78, 84, 7, 8, STEEL)
  rect("vol_sword", 86, 88, 8, 6, STEEL)
  rect("vol_sword", 92, 92, 10, 6, STEEL)
  rect("vol_sword", 100, 96, 10, 5, STEEL)
  oval("vol_sword", 112, 104, 5, 4, STEEL)
  hole("vol_sword", 88, 78, 16, 8)
  hole("vol_head", 96, 40, 8, 6)

  DM.result({
    ok = true,
    pose = "goblin_128_still",
    frame = F,
    awaiting = "user_ok_then_paint_creature",
  })
end
