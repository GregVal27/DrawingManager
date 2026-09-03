-- Goblin 128 pass 2 still. A64. 1px clusters, sel-out, light top-left.
-- Sausage limbs + ovals. No U()/S(). No outline_from_volume. Frame 1 only.

local SKIN_H = "#ede6c8"
local SKIN_L = "#9ccc47"
local SKIN = "#509450"
local SKIN_T = "#808078"
local SKIN_S = "#485454"
local SKIN_D = "#4c3435"
local SKIN_B = "#7655a2"
local RAG = "#8385cf"
local RAG_S = "#7655a2"
local RAG_D = "#313a91"
local LEA_H = "#cd9373"
local LEA = "#92562b"
local LEA_S = "#4c3435"
local STL_H = "#ede6c8"
local STL_C = "#8fbfd5"
local STL = "#9cabb1"
local STL_M = "#808078"
local STL_S = "#485454"
local WOOD_H = "#cd9373"
local WOOD = "#92562b"
local WOOD_S = "#4c3435"
local GUM = "#b14863"
local INK = "#4c3435"
local VOID = "#000000"

local FRAME = 1
local buf = {}

local function use(layer)
  DM.use(layer, FRAME)
end

local function dot(x, y, c)
  if x < 0 or y < 0 or x > 127 or y > 127 then
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

local function oval(cx, cy, rx, ry, c)
  use("color")
  DM.draw_ellipse(cx, cy, rx, ry, c, true)
end

local function box(x, y, w, h, c)
  if w < 1 or h < 1 then
    return
  end
  use("color")
  DM.draw_rect(x, y, w, h, c, true)
end

local function hole(x, y, w, h)
  if w < 1 or h < 1 then
    return
  end
  use("color")
  DM.punch(x, y, w, h)
end

local function hide(name)
  pcall(function()
    DM.find_layer(name).isVisible = false
  end)
end

local function sausage(x1, y1, x2, y2, rx, ry, c)
  local n = math.max(6, math.max(math.abs(x2 - x1), math.abs(y2 - y1)))
  for i = 0, n do
    local t = i / n
    local x = math.floor(x1 + (x2 - x1) * t + 0.5)
    local y = math.floor(y1 + (y2 - y1) * t + 0.5)
    oval(x, y, rx, ry, c)
  end
end

local function paint_color()
  -- Far leg (cooler, shorter)
  sausage(42, 96, 36, 116, 5, 6, SKIN_S)
  oval(36, 118, 8, 3, SKIN_D)
  box(30, 119, 16, 4, LEA_S)
  span(119, 31, 38, SKIN_S)
  span(120, 32, 44, LEA_S)
  span(121, 33, 43, LEA_S)
  span(122, 34, 42, LEA_S)

  -- Far arm
  sausage(50, 58, 40, 72, 4, 5, SKIN_S)

  -- Shield (accent disk)
  oval(32, 76, 17, 16, WOOD)
  oval(27, 70, 9, 8, WOOD_H)
  oval(37, 84, 8, 7, WOOD_S)
  oval(34, 76, 5, 5, STL_M)
  oval(33, 74, 3, 3, STL)
  span(69, 24, 30, WOOD_H)
  span(73, 22, 26, WOOD)
  span(81, 36, 42, WOOD)
  span(85, 30, 38, WOOD_S)
  span(77, 26, 32, LEA)

  -- Hunched torso
  oval(54, 68, 15, 13, SKIN)
  oval(50, 82, 13, 12, SKIN)
  span(62, 46, 58, SKIN_L)
  span(63, 45, 56, SKIN_L)
  span(64, 44, 54, SKIN_L)
  span(65, 46, 52, SKIN)
  span(76, 56, 62, SKIN)
  span(82, 52, 60, SKIN_S)
  span(86, 46, 56, SKIN_S)
  span(84, 44, 50, SKIN_B)

  -- Belt + two rag folds
  span(87, 44, 64, LEA)
  span(88, 43, 65, LEA)
  span(89, 44, 64, LEA_S)
  span(88, 54, 58, LEA_H)
  span(90, 46, 51, RAG)
  span(91, 45, 52, RAG)
  span(92, 45, 50, RAG_S)
  span(93, 46, 49, RAG_D)
  span(94, 47, 50, RAG_S)
  span(90, 55, 62, RAG)
  span(91, 56, 63, RAG_S)
  span(92, 57, 62, RAG_D)
  span(93, 56, 60, RAG_S)
  span(94, 55, 58, RAG_D)

  -- Near leg
  sausage(62, 94, 70, 116, 6, 7, SKIN)
  span(96, 60, 66, SKIN_L)
  span(97, 61, 67, SKIN_L)
  oval(70, 118, 9, 3, SKIN_S)
  oval(68, 120, 9, 3, LEA)
  span(119, 60, 70, SKIN)
  span(120, 61, 76, LEA)
  span(121, 62, 75, LEA_S)
  span(122, 63, 74, LEA_S)
  span(120, 70, 72, LEA_H)

  -- Far ear
  oval(48, 26, 8, 11, SKIN)
  span(18, 44, 52, SKIN_L)
  span(19, 43, 53, SKIN_L)
  span(20, 44, 54, SKIN)
  oval(49, 30, 3, 4, SKIN_S)

  -- Near ear
  oval(84, 22, 7, 10, SKIN)
  span(16, 80, 88, SKIN_L)
  span(17, 82, 90, SKIN_L)
  span(18, 84, 91, SKIN_H)
  oval(85, 26, 3, 4, SKIN_S)

  -- Skull
  oval(68, 40, 16, 15, SKIN)
  span(29, 58, 74, SKIN_L)
  span(30, 56, 76, SKIN_L)
  span(31, 55, 78, SKIN)
  span(48, 70, 84, SKIN_S)
  span(49, 72, 86, SKIN_S)
  -- brow
  span(34, 70, 84, SKIN_D)
  span(35, 71, 85, SKIN_S)

  -- Nose
  sausage(82, 46, 102, 52, 5, 4, SKIN)
  oval(104, 51, 6, 5, SKIN)
  span(45, 86, 100, SKIN_L)
  span(46, 88, 102, SKIN)
  span(49, 94, 108, SKIN_S)
  span(50, 96, 108, SKIN_D)
  span(50, 102, 104, SKIN_D)
  span(47, 92, 94, SKIN_D)

  -- Jaw / mouth
  oval(74, 56, 9, 7, SKIN)
  span(55, 70, 84, SKIN)
  span(56, 72, 86, GUM)
  span(57, 73, 85, GUM)
  span(58, 74, 84, SKIN_D)
  span(55, 78, 80, SKIN_H)
  span(56, 81, 83, SKIN_H)

  -- Near arm + hand
  sausage(62, 58, 78, 86, 5, 5, SKIN)
  span(57, 60, 66, SKIN_L)
  span(58, 61, 67, SKIN_L)
  oval(80, 88, 6, 6, SKIN)
  span(86, 78, 84, SKIN_L)
  span(89, 77, 83, SKIN)
  span(90, 78, 84, SKIN_S)
  span(87, 82, 84, SKIN_H)

  -- Sword: wrap, short blade
  box(78, 84, 7, 8, LEA)
  span(84, 78, 83, LEA_H)
  span(90, 79, 84, LEA_S)
  span(86, 85, 90, STL_M)
  span(87, 86, 94, STL)
  span(88, 88, 98, STL)
  span(89, 90, 100, STL)
  span(90, 92, 103, STL_M)
  span(91, 94, 106, STL_M)
  span(92, 96, 108, STL_S)
  span(93, 98, 110, STL_S)
  span(94, 100, 112, STL_S)
  span(95, 102, 113, STL_M)
  span(96, 104, 114, STL)
  span(97, 106, 114, STL)
  span(98, 108, 113, STL_M)
  span(99, 110, 112, STL_S)
  span(87, 86, 89, STL_C)
  span(88, 88, 92, STL_C)
  span(89, 90, 93, STL_C)
  span(96, 104, 108, STL_C)
  span(97, 106, 110, STL_H)
  -- claws
  span(122, 42, 44, SKIN_D)
  span(122, 74, 76, SKIN_D)

  flush("color")

  -- Gaps after mass is down (silhouette lock)
  hole(50, 108, 12, 12)
  hole(76, 36, 6, 5)
  hole(48, 28, 3, 4)
  hole(85, 23, 3, 4)
  hole(90, 34, 10, 7)

  -- Eye in socket
  span(36, 76, 80, VOID)
  span(37, 76, 81, VOID)
  span(38, 77, 80, VOID)
  span(37, 77, 77, SKIN_H)
  flush("color")
end

local function paint_shade()
  span(49, 78, 88, SKIN_S)
  span(50, 92, 104, SKIN_D)
  span(72, 56, 62, SKIN_S)
  span(83, 52, 58, SKIN_T)
  span(116, 66, 74, SKIN_S)
  span(117, 68, 76, SKIN_D)
  span(84, 36, 44, WOOD_S)
  span(88, 32, 40, WOOD_S)
  span(72, 46, 50, SKIN_B)
  span(91, 80, 84, SKIN_D)
  span(98, 108, 114, STL_S)
  span(30, 48, 52, SKIN_D)
  flush("shade")
end

local function paint_line()
  use("line")
  DM.draw_ellipse(32, 76, 17, 16, STL_S, false)
  span(54, 108, 108, INK)
  span(53, 106, 107, INK)
  span(42, 84, 84, INK)
  span(62, 66, 66, INK)
  span(92, 44, 44, INK)
  span(100, 30, 30, WOOD_S)
  span(108, 40, 40, WOOD_S)
  span(24, 52, 52, SKIN_S)
  span(18, 86, 86, SKIN_S)
  span(35, 74, 78, INK)
  span(45, 90, 94, SKIN_D)
  span(87, 48, 56, LEA_S)
  span(76, 28, 32, WOOD_S)
  span(34, 80, 82, SKIN_D)
  flush("line")
end

local function paint_fx()
  dot(77, 37, SKIN_H)
  dot(78, 36, STL_C)
  dot(80, 55, SKIN_H)
  dot(82, 55, SKIN_H)
  dot(33, 73, STL_H)
  dot(34, 73, STL_H)
  dot(91, 89, STL_H)
  dot(92, 89, STL_H)
  dot(103, 97, STL_H)
  dot(86, 17, SKIN_H)
  flush("fx")
end

function paint_goblin_128()
  for _, name in ipairs({ "line", "color", "shade", "fx" }) do
    pcall(function()
      DM.clear_cel(name, FRAME)
    end)
  end
  for _, name in ipairs({
    "skeleton", "sk_spine", "sk_head", "sk_arm_f", "sk_arm_b", "sk_leg_f", "sk_leg_b",
    "sk_sword", "sk_shield",
    "volume", "vol_spine", "vol_head", "vol_arm_f", "vol_arm_b", "vol_leg_f", "vol_leg_b",
    "vol_sword", "vol_shield", "_tmp",
  }) do
    hide(name)
  end
  paint_color()
  paint_shade()
  paint_line()
  paint_fx()
  DM.result({ ok = true, pass = "paint_goblin_128", frame = FRAME })
end
