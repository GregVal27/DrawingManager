-- Side-on props: nature + interiors. paint_prop(kind, motion).
-- Layers: optional skeleton, volume, line, color, shade, fx. Tag loop.

local INK = "#181425"
local BARK = "#6b4424"
local BARK_S = "#3f2818"
local LEAF = "#3d7a44"
local LEAF_L = "#5ca85a"
local LEAF_S = "#245230"
local BUSH = "#4a8f3a"
local GRASS = "#6bb24a"
local GRASS_S = "#2f5c28"
local WATER = "#3a7ea8"
local WATER_L = "#6eb4d4"
local WATER_S = "#245a7a"
local ROCK = "#7a7e86"
local ROCK_S = "#4a4e56"
local ROCK_L = "#c0c4cc"
local CLOUD = "#e8eef4"
local CLOUD_S = "#b8c4d4"
local FIRE = "#e43b44"
local FIRE_L = "#ead4aa"
local WOOD = "#8a5a32"
local WOOD_D = "#5c3a22"
local CLOTH = "#e43b44"
local SMOKE = "#7a7e86"

local function sway(frame, frames, amp)
  amp = amp or 1
  local t = (frame - 1) / math.max(1, frames)
  return math.floor(math.sin(t * math.pi * 2) * amp + 0.5)
end

local function put(layer, frame, x, y, w, h, color)
  if w <= 0 or h <= 0 then
    return
  end
  DM.use(layer, frame)
  DM.draw_rect(x, y, w, h, color, true)
end

local function oval(layer, frame, cx, cy, rx, ry, color)
  DM.use(layer, frame)
  DM.draw_ellipse(cx, cy, rx, ry, color, true)
end

local function paint_tree(frame, frames, dx)
  local s = DM.sprite()
  local ground = s.height - 1
  local trunk_w = math.max(3, math.floor(s.width * 0.12))
  local trunk_h = math.max(10, math.floor(s.height * 0.42))
  local tx = math.floor(s.width / 2) - math.floor(trunk_w / 2)
  local ty = ground - trunk_h
  put("volume", frame, tx - 1, ty, trunk_w + 2, trunk_h + 1, INK)
  put("color", frame, tx, ty, trunk_w, trunk_h, BARK)
  put("shade", frame, tx, ty, math.max(1, math.floor(trunk_w / 3)), trunk_h, BARK_S)
  local cx = math.floor(s.width / 2) + dx
  local cy = math.floor(s.height * 0.38)
  local rx = math.max(8, math.floor(s.width * 0.32))
  local ry = math.max(8, math.floor(s.height * 0.28))
  oval("volume", frame, cx, cy, rx + 1, ry + 1, INK)
  oval("color", frame, cx, cy, rx, ry, LEAF)
  oval("color", frame, cx - math.floor(rx * 0.35), cy - math.floor(ry * 0.2), math.floor(rx * 0.55), math.floor(ry * 0.55), LEAF_L)
  oval("shade", frame, cx + math.floor(rx * 0.15), cy + math.floor(ry * 0.2), math.floor(rx * 0.55), math.floor(ry * 0.5), LEAF_S)
end

local function paint_bush(frame, frames, dx)
  local s = DM.sprite()
  local ground = s.height - 2
  local cx = math.floor(s.width / 2) + dx
  local cy = ground - math.floor(s.height * 0.28)
  local rx = math.max(8, math.floor(s.width * 0.38))
  local ry = math.max(6, math.floor(s.height * 0.32))
  oval("volume", frame, cx, cy, rx + 1, ry + 1, INK)
  oval("color", frame, cx, cy, rx, ry, BUSH)
  oval("shade", frame, cx + 3, cy + 3, math.floor(rx * 0.45), math.floor(ry * 0.4), LEAF_S)
end

local function paint_grass(frame, frames, dx)
  local s = DM.sprite()
  local base = s.height - 2
  put("color", frame, 4, base - 1, s.width - 8, 2, GRASS_S)
  local blades = { { 6, 10 }, { 10, 14 }, { 14, 9 }, { 18, 13 }, { 22, 11 } }
  for _, b in ipairs(blades) do
    local x = math.floor(b[1] * s.width / 32) + dx
    local h = math.floor(b[2] * s.height / 32)
    put("color", frame, x, base - h, 1, h, GRASS)
    put("shade", frame, x + 1, base - h + 2, 1, math.max(1, h - 2), GRASS_S)
  end
end

local function paint_water(frame, frames, dx)
  local s = DM.sprite()
  put("color", frame, 0, math.floor(s.height * 0.35), s.width, s.height, WATER)
  put("shade", frame, 0, math.floor(s.height * 0.7), s.width, s.height, WATER_S)
  put("fx", frame, 2 + dx, math.floor(s.height * 0.45), s.width - 8, 1, WATER_L)
end

local function paint_rock(frame)
  local s = DM.sprite()
  local cx = math.floor(s.width / 2)
  local cy = s.height - math.floor(s.height * 0.38)
  local rx = math.max(6, math.floor(s.width * 0.34))
  local ry = math.max(5, math.floor(s.height * 0.28))
  oval("volume", frame, cx, cy, rx + 1, ry + 1, INK)
  oval("color", frame, cx, cy, rx, ry, ROCK)
  oval("shade", frame, cx + 2, cy + 2, math.floor(rx * 0.55), math.floor(ry * 0.55), ROCK_S)
end

local function paint_cloud(frame, frames, dx)
  local s = DM.sprite()
  local cy = math.floor(s.height * 0.45)
  local cx = math.floor(s.width / 2) + dx
  oval("color", frame, cx, cy, math.floor(s.width * 0.28), math.floor(s.height * 0.28), CLOUD)
  oval("shade", frame, cx, cy + math.floor(s.height * 0.12), math.floor(s.width * 0.22), math.floor(s.height * 0.1), CLOUD_S)
end

local function paint_fire(frame, frames)
  local s = DM.sprite()
  local t = (frame - 1) / math.max(1, frames)
  local h = math.floor(s.height * (0.45 + 0.2 * math.abs(math.sin(t * math.pi * 2))))
  local cx = math.floor(s.width / 2)
  local base = s.height - 2
  put("color", frame, cx - 4, base - 4, 8, 4, WOOD)
  oval("color", frame, cx, base - h, 5, math.floor(h * 0.6), FIRE)
  oval("fx", frame, cx, base - h - 2, 3, math.floor(h * 0.4), FIRE_L)
end

local function paint_flag(frame, frames, dx)
  local s = DM.sprite()
  local pole_x = 6
  put("color", frame, pole_x, 2, 2, s.height - 4, WOOD_D)
  local top = 4
  put("color", frame, pole_x + 2, top + dx, s.width - 12, 10, CLOTH)
  put("shade", frame, pole_x + 2, top + 6 + dx, s.width - 14, 3, "#9e2835")
end

local function paint_torch(frame, frames)
  local s = DM.sprite()
  local cx = math.floor(s.width / 2)
  put("color", frame, cx - 1, math.floor(s.height * 0.35), 3, math.floor(s.height * 0.6), WOOD)
  oval("fx", frame, cx, math.floor(s.height * 0.28) - (frame % 2), 4, 5, FIRE)
  oval("fx", frame, cx, math.floor(s.height * 0.22) - (frame % 2), 2, 3, FIRE_L)
end

local function paint_smoke(frame, frames, dx)
  local s = DM.sprite()
  local base = s.height - 4
  oval("color", frame, 10 + dx, base - 6, 6, 5, SMOKE)
  oval("color", frame, 14 + dx, base - 14, 7, 6, SMOKE)
  oval("color", frame, 12 + dx, base - 22, 5, 4, CLOUD_S)
end

local function paint_wall(frame)
  local s = DM.sprite()
  put("color", frame, 0, 0, s.width, s.height, "#c4a574")
  put("shade", frame, 0, 0, 3, s.height, WOOD_D)
  for y = 8, s.height - 1, 8 do
    put("shade", frame, 0, y, s.width, 1, WOOD)
  end
end

local function paint_floor(frame)
  local s = DM.sprite()
  put("color", frame, 0, 0, s.width, s.height, WOOD)
  put("shade", frame, 0, s.height - 4, s.width, 4, WOOD_D)
end

local function paint_door(frame)
  local s = DM.sprite()
  put("volume", frame, 4, 2, s.width - 8, s.height - 4, INK)
  put("color", frame, 5, 3, s.width - 10, s.height - 6, WOOD)
  put("fx", frame, s.width - 12, math.floor(s.height / 2), 2, 2, "#ead4aa")
end

local function paint_window(frame)
  local s = DM.sprite()
  put("color", frame, 2, 2, s.width - 4, s.height - 4, "#6ea0c8")
  put("shade", frame, 2, 2, s.width - 4, 2, WOOD_D)
  put("shade", frame, math.floor(s.width / 2), 2, 2, s.height - 4, WOOD)
end

local function paint_table(frame)
  local s = DM.sprite()
  local top = math.floor(s.height * 0.45)
  put("volume", frame, 1, top - 1, s.width - 2, 6, INK)
  put("color", frame, 2, top, s.width - 4, 4, WOOD)
  put("shade", frame, 2, top + 3, s.width - 4, 1, WOOD_D)
  put("volume", frame, 5, top, 5, s.height - top - 1, INK)
  put("color", frame, 6, top, 3, s.height - top - 2, WOOD_D)
  put("volume", frame, s.width - 10, top, 5, s.height - top - 1, INK)
  put("color", frame, s.width - 9, top, 3, s.height - top - 2, WOOD_D)
end

local function paint_chair(frame)
  local s = DM.sprite()
  local back_h = math.floor(s.height * 0.6)
  local seat_y = math.floor(s.height * 0.55)
  put("volume", frame, 3, math.floor(s.height * 0.35) - 1, 5, back_h + 2, INK)
  put("color", frame, 4, math.floor(s.height * 0.35), 3, back_h, WOOD)
  put("volume", frame, 3, seat_y - 1, s.width - 8, 5, INK)
  put("color", frame, 4, seat_y, s.width - 10, 3, WOOD)
end

local function paint_chest(frame)
  local s = DM.sprite()
  put("volume", frame, 2, math.floor(s.height * 0.4), s.width - 4, math.floor(s.height * 0.5), INK)
  put("color", frame, 3, math.floor(s.height * 0.42), s.width - 6, math.floor(s.height * 0.46), WOOD)
  put("fx", frame, math.floor(s.width / 2) - 1, math.floor(s.height * 0.6), 3, 3, "#ead4aa")
end

local function paint_bed(frame)
  local s = DM.sprite()
  put("color", frame, 2, math.floor(s.height * 0.55), s.width - 4, math.floor(s.height * 0.35), WOOD)
  put("color", frame, 4, math.floor(s.height * 0.48), s.width - 10, 8, "#c5dff0")
end

local function paint_banner(frame, frames, dx)
  local s = DM.sprite()
  put("color", frame, 4, 2, s.width - 8, 3, WOOD_D)
  put("color", frame, 6 + dx, 5, s.width - 14, s.height - 10, CLOTH)
end

local PAINTERS = {
  tree = paint_tree,
  bush = paint_bush,
  grass = paint_grass,
  water = paint_water,
  rock = paint_rock,
  cloud = paint_cloud,
  fire = paint_fire,
  flag = paint_flag,
  torch = paint_torch,
  smoke = paint_smoke,
  wall = paint_wall,
  floor = paint_floor,
  door = paint_door,
  window = paint_window,
  table = paint_table,
  chair = paint_chair,
  chest = paint_chest,
  bed = paint_bed,
  banner = paint_banner,
}

function paint_prop(kind, motion)
  kind = kind or "tree"
  motion = motion or "shift"
  local fn = PAINTERS[kind]
  if not fn then
    DM.fail("unknown prop kind: " .. tostring(kind))
  end
  local s = DM.sprite()
  local frames = #s.frames
  local live = {
    fire = true, flag = true, torch = true, smoke = true,
    grass = true, cloud = true, water = true, tree = true, bush = true, banner = true,
  }
  if motion == "shift" then
    fn(1, frames, 0)
    local names = {}
    for _, name in ipairs({ "volume", "line", "color", "shade", "fx", "skeleton" }) do
      local ok = pcall(function() DM.find_layer(name) end)
      if ok then
        names[#names + 1] = name
      end
    end
    for f = 2, frames do
      DM.copy_cels(1, f, names)
      local dx = sway(f, frames, 1)
      pcall(function()
        DM.shift_cel("color", f, dx, 0)
      end)
      pcall(function()
        DM.shift_cel("fx", f, dx, 0)
      end)
    end
  elseif motion == "copy" then
    fn(1, frames, 0)
    local names = {}
    for _, name in ipairs({ "volume", "line", "color", "shade", "fx" }) do
      local ok = pcall(function() DM.find_layer(name) end)
      if ok then
        names[#names + 1] = name
      end
    end
    for f = 2, frames do
      DM.copy_cels(f - 1, f, names)
      local dx = sway(f, frames, 1)
      pcall(function()
        DM.shift_cel("color", f, dx, (kind == "fire" or kind == "smoke") and -1 or 0)
      end)
    end
  else
    -- redraw
    for f = 1, frames do
      fn(f, frames, sway(f, frames, 1))
    end
  end
  if not live[kind] and frames > 1 and motion == "shift" then
    -- static interiors: keep copies identical
  end
  DM.result(DM.info())
end
