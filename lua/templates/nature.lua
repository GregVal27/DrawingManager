-- Side-on nature props with a looping 1–2 px sway.
-- Requires DM and an open nature template. Call paint_nature(kind).

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

local KIND = "tree"

local function U()
  return math.max(1, math.floor(math.min(DM.sprite().width, DM.sprite().height) / 32))
end

local function S(n)
  return math.floor(n * U() + (n >= 0 and 0.0001 or -0.0001))
end

local function sway(frame, frames, amp)
  amp = amp or 1
  local t = (frame - 1) / math.max(1, frames)
  return math.floor(math.sin(t * math.pi * 2) * amp + 0.5)
end

local function put(layer, frame, x, y, w, h, color)
  DM.use(layer, frame)
  if w <= 0 or h <= 0 then
    return
  end
  DM.draw_rect(x, y, w, h, color, true)
end

local function oval(layer, frame, cx, cy, rx, ry, color)
  DM.use(layer, frame)
  DM.draw_ellipse(cx, cy, rx, ry, color, true)
end

local function paint_tree(frame, frames)
  local s = DM.sprite()
  local dx = sway(frame, frames, 1)
  local ground = s.height - 1
  local trunk_w = math.max(3, S(4))
  local trunk_h = math.max(10, math.floor(s.height * 0.42))
  local tx = math.floor(s.width / 2) - math.floor(trunk_w / 2)
  local ty = ground - trunk_h
  put("silhouette", frame, tx - 1, ty, trunk_w + 2, trunk_h + 1, INK)
  put("color", frame, tx, ty, trunk_w, trunk_h, BARK)
  put("shade", frame, tx, ty, math.max(1, math.floor(trunk_w / 3)), trunk_h, BARK_S)
  local cx = math.floor(s.width / 2) + dx
  local cy = math.floor(s.height * 0.38)
  local rx = math.max(8, math.floor(s.width * 0.32))
  local ry = math.max(8, math.floor(s.height * 0.28))
  oval("silhouette", frame, cx, cy, rx + 1, ry + 1, INK)
  oval("color", frame, cx, cy, rx, ry, LEAF)
  oval("color", frame, cx - math.floor(rx * 0.35), cy - math.floor(ry * 0.2), math.floor(rx * 0.55), math.floor(ry * 0.55), LEAF_L)
  oval("shade", frame, cx + math.floor(rx * 0.15), cy + math.floor(ry * 0.2), math.floor(rx * 0.55), math.floor(ry * 0.5), LEAF_S)
end

local function paint_bush(frame, frames)
  local s = DM.sprite()
  local dx = sway(frame, frames, 1)
  local ground = s.height - 2
  local cx = math.floor(s.width / 2) + dx
  local cy = ground - math.floor(s.height * 0.28)
  local rx = math.max(8, math.floor(s.width * 0.38))
  local ry = math.max(6, math.floor(s.height * 0.32))
  oval("silhouette", frame, cx, cy, rx + 1, ry + 1, INK)
  oval("color", frame, cx, cy, rx, ry, BUSH)
  oval("color", frame, cx - 4, cy - 2, math.floor(rx * 0.5), math.floor(ry * 0.5), LEAF_L)
  oval("shade", frame, cx + 3, cy + 3, math.floor(rx * 0.45), math.floor(ry * 0.4), LEAF_S)
end

local function paint_grass(frame, frames)
  local s = DM.sprite()
  local dx = sway(frame, frames, 1)
  local base = s.height - 2
  put("silhouette", frame, 4, base - 1, s.width - 8, 2, INK)
  put("color", frame, 4, base - 1, s.width - 8, 2, GRASS_S)
  local blades = {
    { 6, 10 }, { 10, 14 }, { 14, 9 }, { 18, 13 }, { 22, 11 },
  }
  for _, b in ipairs(blades) do
    local x = math.floor(b[1] * s.width / 32) + dx
    local h = math.floor(b[2] * s.height / 32)
    put("silhouette", frame, x, base - h, 2, h, INK)
    put("color", frame, x, base - h, 1, h, GRASS)
    put("shade", frame, x + 1, base - h + 2, 1, math.max(1, h - 2), GRASS_S)
  end
end

local function paint_water(frame, frames)
  local s = DM.sprite()
  local phase = sway(frame, frames, 2)
  put("color", frame, 0, math.floor(s.height * 0.35), s.width, s.height, WATER)
  put("shade", frame, 0, math.floor(s.height * 0.7), s.width, s.height, WATER_S)
  local y1 = math.floor(s.height * 0.45) + math.floor(phase / 2)
  local y2 = math.floor(s.height * 0.58) - math.floor(phase / 2)
  put("fx", frame, 2 + phase, y1, s.width - 8, 1, WATER_L)
  put("fx", frame, 6 - phase, y2, s.width - 12, 1, WATER_L)
end

local function paint_rock(frame, frames)
  local s = DM.sprite()
  local cx = math.floor(s.width / 2)
  local cy = s.height - math.floor(s.height * 0.38)
  local rx = math.max(6, math.floor(s.width * 0.34))
  local ry = math.max(5, math.floor(s.height * 0.28))
  oval("silhouette", frame, cx, cy, rx + 1, ry + 1, INK)
  oval("color", frame, cx, cy, rx, ry, ROCK)
  oval("shade", frame, cx + 2, cy + 2, math.floor(rx * 0.55), math.floor(ry * 0.55), ROCK_S)
  oval("color", frame, cx - 3, cy - 3, math.max(2, math.floor(rx * 0.25)), math.max(2, math.floor(ry * 0.2)), ROCK_L)
end

local function paint_cloud(frame, frames)
  local s = DM.sprite()
  local dx = sway(frame, frames, 1)
  local cy = math.floor(s.height * 0.45)
  local cx = math.floor(s.width / 2) + dx
  oval("color", frame, cx, cy, math.floor(s.width * 0.28), math.floor(s.height * 0.28), CLOUD)
  oval("color", frame, cx - math.floor(s.width * 0.18), cy + 2, math.floor(s.width * 0.2), math.floor(s.height * 0.22), CLOUD)
  oval("color", frame, cx + math.floor(s.width * 0.16), cy + 1, math.floor(s.width * 0.18), math.floor(s.height * 0.2), CLOUD)
  oval("shade", frame, cx, cy + math.floor(s.height * 0.12), math.floor(s.width * 0.22), math.floor(s.height * 0.1), CLOUD_S)
end

local function outline_from_silhouette()
  local s = DM.sprite()
  local sil_layer = nil
  for _, layer in ipairs(s.layers) do
    if layer.name == "silhouette" then
      sil_layer = layer
    end
  end
  if not sil_layer then
    return
  end
  for f = 1, #s.frames do
    DM.use("silhouette", f)
    local ok, sil = pcall(DM.canvas)
    if not ok then
      return
    end
    DM.use("shade", f)
    local shade = DM.canvas()
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
            if Color(shade:getPixel(x, y)).alpha == 0 then
              shade:putPixel(x, y, DM.color(INK))
            end
          end
        end
      end
    end
  end
end

function paint_nature(kind)
  KIND = kind or "tree"
  local s = DM.sprite()
  local frames = #s.frames
  local painters = {
    tree = paint_tree,
    bush = paint_bush,
    grass = paint_grass,
    water = paint_water,
    rock = paint_rock,
    cloud = paint_cloud,
  }
  local fn = painters[KIND]
  if not fn then
    DM.fail("unknown nature kind: " .. tostring(KIND))
  end
  for f = 1, frames do
    fn(f, frames)
  end
  if KIND ~= "water" and KIND ~= "cloud" then
    outline_from_silhouette()
  end
  pcall(function()
    DM.hide_layer("silhouette")
  end)
  DM.result(DM.info())
end
