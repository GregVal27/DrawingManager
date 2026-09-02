-- Side-on humanoid painter for DrawingManager.
-- Requires DM and an open character template (16 frames: idle/walk/attack).
-- paint_humanoid(facing) — facing is "right" (default) or "left".

local INK = "#181425"
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

local function put(layer, frame, x, y, w, h, color)
  DM.use(layer, frame)
  if w <= 0 or h <= 0 then
    return
  end
  DM.draw_rect(fx(x, w), y, w, h, color, true)
end

local function pixel(layer, frame, x, y, color)
  DM.use(layer, frame)
  DM.draw_pixels({ { x = fx(x, 1), y = y, color = color } })
end

local function draw_pose(frame, pose, hd)
  local bob = S(pose.bob)
  local lean = S(pose.lean)
  if FACING == "left" then
    lean = -lean
  end
  local hx = S(12) + lean
  local hy = S(5) + bob

  put("silhouette", frame, hx - S(1), hy, S(9), S(9), INK)
  put("silhouette", frame, S(11) + lean, S(13) + bob, S(9), S(10), INK)
  put("silhouette", frame, S(12) + lean + S(pose.rleg), S(22) + bob - S(pose.rlift), S(4), S(8) + S(pose.rlift), INK)
  put("silhouette", frame, S(15) + lean + S(pose.lleg), S(22) + bob - S(pose.llift), S(4), S(8) + S(pose.llift), INK)
  put("silhouette", frame, S(10) + lean + S(pose.larm), S(14) + bob + S(pose.larm_y), S(3), S(8), INK)
  put("silhouette", frame, S(18) + lean + S(pose.rarm), S(14) + bob + S(pose.rarm_y), S(3), S(8), INK)

  put("color", frame, hx, hy, S(8), S(8), SKIN)
  put("color", frame, hx, hy, S(8), S(3), HAIR)
  put("color", frame, hx, hy + S(1), S(2), S(4), HAIR)
  put("shade", frame, hx, hy + S(2), S(2), S(5), SKIN_S)
  put("shade", frame, hx, hy + S(2), S(8), S(1), HAIR_S)
  pixel("color", frame, hx + S(5), hy + S(4), WHITE)
  pixel("color", frame, hx + S(6), hy + S(4), EYE)
  if pose.blink then
    put("color", frame, hx + S(5), hy + S(4), S(2), S(1), SKIN)
  end

  put("color", frame, S(11) + lean, S(13) + bob, S(9), S(9), SHIRT)
  put("shade", frame, S(11) + lean, S(13) + bob, S(3), S(9), SHIRT_S)

  put("color", frame, S(12) + lean, S(21) + bob, S(8), S(3), PANTS)

  local rx = S(16) + lean + S(pose.rleg)
  local ry = S(23) + bob - S(pose.rlift)
  local lx = S(12) + lean + S(pose.lleg)
  local ly = S(23) + bob - S(pose.llift)
  put("color", frame, rx, ry, S(3), S(6) + S(pose.rlift), PANTS)
  put("color", frame, lx, ly, S(3), S(6) + S(pose.llift), PANTS)
  put("shade", frame, lx, ly, S(1), S(6) + S(pose.llift), PANTS_S)
  put("color", frame, rx, ry + S(6) + S(pose.rlift), S(4), S(2), BOOT)
  put("color", frame, lx, ly + S(6) + S(pose.llift), S(4), S(2), BOOT)

  local ax = S(19) + lean + S(pose.rarm)
  local ay = S(14) + bob + S(pose.rarm_y)
  local bx = S(10) + lean + S(pose.larm)
  local by = S(14) + bob + S(pose.larm_y)
  put("color", frame, ax, ay, S(2), S(7), SKIN)
  put("color", frame, bx, by, S(2), S(7), SKIN)
  put("shade", frame, bx, by, S(1), S(7), SKIN_S)

  if pose.sword then
    local sw = S(pose.sword_w or 10)
    local sh = S(pose.sword_h or 2)
    local sx = ax + S(pose.sword_x or 2)
    local sy = ay + S(pose.sword_y or 1)
    put("silhouette", frame, sx - S(1), sy - S(1), sw + S(2), sh + S(2), INK)
    put("fx", frame, sx, sy, sw, sh, STEEL)
    put("fx", frame, sx, sy, S(2), sh, STEEL_S)
  end

  if hd then
    put("shade", frame, S(12) + lean, S(20) + bob, S(7), S(1), SHIRT_S)
    put("color", frame, hx + S(1), hy + S(1), S(2), S(1), WHITE)
    pixel("color", frame, hx + S(6), hy + S(3), WHITE)
    put("shade", frame, rx, ry, S(1), S(5), PANTS_S)
  end
end

local idle = {
  { bob = 0, lean = 0, rleg = 1, lleg = -1, rarm = 0, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0, blink = false },
  { bob = -1, lean = 0, rleg = 1, lleg = -1, rarm = 0, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0, blink = false },
  { bob = 0, lean = 0, rleg = 1, lleg = -1, rarm = 0, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0, blink = true },
  { bob = 0, lean = 0, rleg = 1, lleg = -1, rarm = 0, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0, blink = false },
}

local walk = {
  { bob = 1, lean = 1, rleg = 3, lleg = -3, rarm = -2, larm = 2, rlift = 0, llift = 0, rarm_y = 1, larm_y = -1, blink = false },
  { bob = 2, lean = 1, rleg = 2, lleg = -2, rarm = -1, larm = 1, rlift = 0, llift = 0, rarm_y = 1, larm_y = 0, blink = false },
  { bob = 0, lean = 0, rleg = 0, lleg = 0, rarm = 0, larm = 0, rlift = 0, llift = 3, rarm_y = 0, larm_y = 0, blink = false },
  { bob = -1, lean = 0, rleg = -2, lleg = 3, rarm = 1, larm = -1, rlift = 2, llift = 0, rarm_y = -1, larm_y = 1, blink = false },
  { bob = 1, lean = 1, rleg = -3, lleg = 3, rarm = 2, larm = -2, rlift = 0, llift = 0, rarm_y = -1, larm_y = 1, blink = false },
  { bob = 2, lean = 1, rleg = -2, lleg = 2, rarm = 1, larm = -1, rlift = 0, llift = 0, rarm_y = 0, larm_y = 1, blink = false },
  { bob = 0, lean = 0, rleg = 0, lleg = 0, rarm = 0, larm = 0, rlift = 3, llift = 0, rarm_y = 0, larm_y = 0, blink = false },
  { bob = -1, lean = 0, rleg = 3, lleg = -2, rarm = -1, larm = 1, rlift = 0, llift = 2, rarm_y = 1, larm_y = -1, blink = false },
}

local attack = {
  { bob = 0, lean = -1, rleg = 2, lleg = -1, rarm = -2, larm = 1, rlift = 0, llift = 0, rarm_y = -1, larm_y = 1, blink = false, sword = true, sword_x = 1, sword_y = 2, sword_w = 8, sword_h = 2 },
  { bob = 1, lean = 2, rleg = 3, lleg = -2, rarm = 6, larm = -1, rlift = 0, llift = 1, rarm_y = -2, larm_y = 1, blink = false, sword = true, sword_x = 2, sword_y = 0, sword_w = 12, sword_h = 2 },
  { bob = 0, lean = 2, rleg = 3, lleg = -2, rarm = 5, larm = -1, rlift = 0, llift = 0, rarm_y = -1, larm_y = 1, blink = false, sword = true, sword_x = 2, sword_y = 1, sword_w = 11, sword_h = 2 },
  { bob = 0, lean = 0, rleg = 1, lleg = -1, rarm = 1, larm = 0, rlift = 0, llift = 0, rarm_y = 0, larm_y = 0, blink = false, sword = true, sword_x = 2, sword_y = 2, sword_w = 8, sword_h = 2 },
}

local function outline_from_silhouette()
  local s = DM.sprite()
  for f = 1, #s.frames do
    DM.use("line", f)
    DM.canvas()
    DM.use("silhouette", f)
    local sil = DM.canvas()
    DM.use("line", f)
    local line = DM.canvas()
    local w, h = s.width, s.height
    for y = 0, h - 1 do
      for x = 0, w - 1 do
        local pc = Color(sil:getPixel(x, y))
        if pc.alpha > 0 then
          local function empty(nx, ny)
            if nx < 0 or ny < 0 or nx >= w or ny >= h then
              return true
            end
            return Color(sil:getPixel(nx, ny)).alpha == 0
          end
          if empty(x - 1, y) or empty(x + 1, y) or empty(x, y - 1) or empty(x, y + 1) then
            line:putPixel(x, y, DM.color(INK))
          end
        end
      end
    end
  end
end

function paint_humanoid(facing)
  FACING = (facing == "left") and "left" or "right"
  local hd = U() >= 3
  for i, pose in ipairs(idle) do
    draw_pose(i, pose, hd)
  end
  for i, pose in ipairs(walk) do
    draw_pose(4 + i, pose, hd)
  end
  local nframes = #DM.sprite().frames
  if nframes >= 16 then
    for i, pose in ipairs(attack) do
      draw_pose(12 + i, pose, hd)
    end
  end
  outline_from_silhouette()
  pcall(function()
    DM.hide_layer("silhouette")
  end)
  DM.result(DM.info())
end
