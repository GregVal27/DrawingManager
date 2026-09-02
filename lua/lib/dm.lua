-- DrawingManager Lua library. Loaded by headless CLI scripts and the live extension.
-- Coordinates are always sprite-space (0,0 = top-left of the canvas).

DM = DM or {}

DM._RESULT = { ok = true }

function DM.encode(val)
  local t = type(val)
  if val == nil then
    return "null"
  elseif t == "boolean" then
    return val and "true" or "false"
  elseif t == "number" then
    if val ~= val or val == math.huge or val == -math.huge then
      return "null"
    end
    return tostring(val)
  elseif t == "string" then
    local s = val
    s = s:gsub("\\", "\\\\")
    s = s:gsub("\"", "\\\"")
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    return "\"" .. s .. "\""
  elseif t == "table" then
    local is_array = true
    local n = 0
    for k, _ in pairs(val) do
      n = n + 1
      if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then
        is_array = false
        break
      end
    end
    if is_array then
      local maxn = 0
      for k, _ in pairs(val) do
        if k > maxn then maxn = k end
      end
      local parts = {}
      for i = 1, maxn do
        parts[i] = DM.encode(val[i])
      end
      return "[" .. table.concat(parts, ",") .. "]"
    else
      local parts = {}
      for k, v in pairs(val) do
        local key = tostring(k)
        parts[#parts + 1] = DM.encode(key) .. ":" .. DM.encode(v)
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
  end
  return "null"
end

function DM.result(tbl)
  DM._RESULT = tbl or { ok = true }
  return DM._RESULT
end

function DM.fail(msg)
  error(msg, 2)
end

function DM.color(c)
  if type(c) == "userdata" then
    return c
  end
  if type(c) == "number" then
    return c
  end
  if type(c) ~= "string" then
    DM.fail("color must be #rrggbb, #rrggbbaa, or a Color")
  end
  local hex = c:gsub("^#", "")
  if #hex ~= 6 and #hex ~= 8 then
    DM.fail("invalid color: " .. c)
  end
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  local a = 255
  if #hex == 8 then
    a = tonumber(hex:sub(7, 8), 16)
  end
  return Color{ r = r, g = g, b = b, a = a }
end

function DM.hex_of(color)
  local c = DM.color(color)
  return string.format("#%02x%02x%02x%02x", c.red, c.green, c.blue, c.alpha)
end

local function color_mode_from(name)
  name = (name or "rgb"):lower()
  if name == "rgb" or name == "rgba" then
    return ColorMode.RGB
  elseif name == "indexed" then
    return ColorMode.INDEXED
  elseif name == "gray" or name == "grayscale" or name == "grey" then
    return ColorMode.GRAY
  end
  DM.fail("unknown color_mode: " .. tostring(name))
end

function DM.sprite()
  local s = app.activeSprite
  if not s then
    DM.fail("no active sprite")
  end
  return s
end

local function path_key(path)
  if not path or path == "" then
    return ""
  end
  local p = tostring(path)
  if app.fs and app.fs.normalizePath then
    p = app.fs.normalizePath(p)
  end
  p = p:gsub("\\", "/"):gsub("/+", "/")
  return p:lower()
end

function DM.find_open(path)
  local want = path_key(path)
  if want == "" then
    return nil
  end
  for _, s in ipairs(app.sprites) do
    if s.filename and s.filename ~= "" and path_key(s.filename) == want then
      return s
    end
  end
  return nil
end

function DM.close_path(path)
  for _ = 1, 32 do
    local s = DM.find_open(path)
    if not s then
      return
    end
    pcall(function()
      if s.filename and s.filename ~= "" then
        s:saveAs(s.filename)
      elseif path and path ~= "" then
        s:saveAs(path)
      end
    end)
    local ok = pcall(function()
      s:close()
    end)
    if not ok then
      return
    end
  end
end

function DM.create(width, height, color_mode, path)
  if path and path ~= "" then
    DM.close_path(path)
  end
  local s = Sprite(width, height, color_mode_from(color_mode))
  app.activeSprite = s
  return s
end

function DM.open(path)
  local existing = DM.find_open(path)
  if existing then
    app.activeSprite = existing
    if app.refresh then
      app.refresh()
    end
    return existing
  end
  local s = app.open(path)
  if not s then
    DM.fail("failed to open: " .. tostring(path))
  end
  app.activeSprite = s
  return s
end

function DM.open_ref(path)
  local existing = DM.find_open(path)
  if existing then
    return existing, false
  end
  local s = app.open(path)
  if not s then
    DM.fail("failed to open: " .. tostring(path))
  end
  return s, true
end

function DM.save(path)
  local s = DM.sprite()
  if path and path ~= "" then
    s:saveAs(path)
  else
    if not s.filename or s.filename == "" then
      DM.fail("sprite has no filename; pass path to save")
    end
    s:saveAs(s.filename)
  end
  return s.filename
end

function DM.iter_layers()
  local out = {}
  local function walk(layers)
    if not layers then
      return
    end
    for _, layer in ipairs(layers) do
      out[#out + 1] = layer
      if layer.isGroup then
        walk(layer.layers)
      end
    end
  end
  walk(DM.sprite().layers)
  return out
end

function DM.find_layer(name)
  local s = DM.sprite()
  if not name or name == "" then
    return app.activeLayer
  end
  for _, layer in ipairs(DM.iter_layers()) do
    if layer.name == name then
      return layer
    end
  end
  DM.fail("layer not found: " .. name)
end

function DM.use(layer_name, frame_number)
  local s = DM.sprite()
  if layer_name and layer_name ~= "" then
    app.activeLayer = DM.find_layer(layer_name)
  end
  if frame_number ~= nil then
    local n = tonumber(frame_number)
    if n < 1 or n > #s.frames then
      DM.fail("frame out of range: " .. tostring(n))
    end
    app.activeFrame = s.frames[n]
  end
end

-- Make the active cel a full-canvas image so drawing uses sprite coordinates.
function DM.canvas()
  local s = DM.sprite()
  local layer = app.activeLayer
  if not layer or not layer.isImage then
    DM.fail("active layer is not an image layer")
  end
  local frame = app.activeFrame
  local cel = layer:cel(frame)
  if not cel then
    cel = s:newCel(layer, frame, Image(s.spec), Point(0, 0))
  end
  if cel.image.width ~= s.width or cel.image.height ~= s.height
      or cel.position.x ~= 0 or cel.position.y ~= 0 then
    local full = Image(s.spec)
    full:clear()
    full:drawImage(cel.image, cel.position)
    cel.image = full
    cel.position = Point(0, 0)
  end
  return cel.image, cel
end

function DM.info()
  local s = DM.sprite()
  local layers = {}
  for i, layer in ipairs(DM.iter_layers()) do
    local kind = "image"
    if layer.isGroup then
      kind = "group"
    elseif layer.isTilemap then
      kind = "tilemap"
    end
    layers[#layers + 1] = {
      index = i,
      name = layer.name,
      visible = layer.isVisible,
      opacity = layer.opacity,
      kind = kind,
    }
  end
  local frames = {}
  for i, frame in ipairs(s.frames) do
    frames[#frames + 1] = {
      number = i,
      duration_ms = math.floor((frame.duration or 0) * 1000 + 0.5),
    }
  end
  local tags = {}
  for _, tag in ipairs(s.tags) do
    tags[#tags + 1] = {
      name = tag.name,
      from = tag.fromFrame.frameNumber,
      to = tag.toFrame.frameNumber,
      aniDir = tostring(tag.aniDir),
    }
  end
  local mode = "rgb"
  if s.colorMode == ColorMode.INDEXED then
    mode = "indexed"
  elseif s.colorMode == ColorMode.GRAY then
    mode = "grayscale"
  end
  return {
    ok = true,
    filename = s.filename or "",
    width = s.width,
    height = s.height,
    color_mode = mode,
    layer_count = #s.layers,
    frame_count = #s.frames,
    layers = layers,
    frames = frames,
    tags = tags,
  }
end

function DM.add_layer(name, parent_name)
  local s = DM.sprite()
  local layer = s:newLayer()
  if name and name ~= "" then
    layer.name = name
  end
  if parent_name and parent_name ~= "" then
    local parent = DM.find_layer(parent_name)
    pcall(function()
      layer.parent = parent
    end)
  end
  app.activeLayer = layer
  return { ok = true, name = layer.name }
end

function DM.add_layer_group(name)
  local s = DM.sprite()
  local group
  local ok = pcall(function()
    group = s:newGroup()
  end)
  if ok and group then
    if name and name ~= "" then
      group.name = name
    end
    app.activeLayer = group
    return { ok = true, name = group.name, kind = "group" }
  end
  return DM.add_layer(name)
end

function DM.set_layer_visible(name, visible)
  local layer = DM.find_layer(name)
  if visible == false or visible == 0 then
    layer.isVisible = false
  else
    layer.isVisible = true
  end
  return { ok = true, name = name, visible = layer.isVisible }
end

function DM.rename_layer(old_name, new_name)
  local layer = DM.find_layer(old_name)
  layer.name = new_name
  return { ok = true, name = new_name }
end

function DM.add_frame()
  local s = DM.sprite()
  local snap = {}
  for _, tag in ipairs(s.tags) do
    snap[#snap + 1] = {
      tag = tag,
      from = tag.fromFrame.frameNumber,
      to = tag.toFrame.frameNumber,
    }
  end
  local frame = s:newEmptyFrame()
  for _, item in ipairs(snap) do
    pcall(function()
      item.tag.fromFrame = s.frames[item.from]
      item.tag.toFrame = s.frames[item.to]
    end)
  end
  app.activeFrame = frame
  return { ok = true, frame = frame.frameNumber, frame_count = #s.frames }
end

function DM.add_frames(count)
  count = tonumber(count) or 0
  local last
  for _ = 1, count do
    last = DM.add_frame()
  end
  return last or { ok = true, frame_count = #DM.sprite().frames }
end

function DM.duplicate_frame(number)
  local s = DM.sprite()
  local src = number and s.frames[tonumber(number)] or app.activeFrame
  local frame = s:newFrame(src)
  app.activeFrame = frame
  return { ok = true, frame = frame.frameNumber, frame_count = #s.frames }
end

function DM.set_frame_duration(number, ms)
  local s = DM.sprite()
  local n = tonumber(number)
  if n < 1 or n > #s.frames then
    DM.fail("frame out of range: " .. tostring(n))
  end
  s.frames[n].duration = (tonumber(ms) or 100) / 1000.0
  return { ok = true, frame = n, duration_ms = math.floor(s.frames[n].duration * 1000 + 0.5) }
end

function DM.set_frame_durations(from_frame, to_frame, ms)
  local s = DM.sprite()
  from_frame = tonumber(from_frame)
  to_frame = tonumber(to_frame)
  for i = from_frame, to_frame do
    DM.set_frame_duration(i, ms)
  end
  return { ok = true, from = from_frame, to = to_frame }
end

function DM.create_tag(name, from_frame, to_frame)
  local s = DM.sprite()
  local tag = s:newTag(tonumber(from_frame), tonumber(to_frame))
  tag.name = name
  return { ok = true, name = tag.name, from = tag.fromFrame.frameNumber, to = tag.toFrame.frameNumber }
end

function DM.draw_pixels(pixels)
  local img = DM.canvas()
  for _, p in ipairs(pixels) do
    img:putPixel(math.floor(p.x), math.floor(p.y), DM.color(p.color))
  end
  return { ok = true, count = #pixels }
end

function DM.draw_line(x1, y1, x2, y2, color)
  local img = DM.canvas()
  local c = DM.color(color)
  x1, y1, x2, y2 = math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2)
  local dx = math.abs(x2 - x1)
  local dy = math.abs(y2 - y1)
  local sx = x1 < x2 and 1 or -1
  local sy = y1 < y2 and 1 or -1
  local err = dx - dy
  while true do
    img:putPixel(x1, y1, c)
    if x1 == x2 and y1 == y2 then
      break
    end
    local e2 = 2 * err
    if e2 > -dy then
      err = err - dy
      x1 = x1 + sx
    end
    if e2 < dx then
      err = err + dx
      y1 = y1 + sy
    end
  end
  return { ok = true }
end

local function bresenham_points(x1, y1, x2, y2)
  local pts = {}
  local dx = math.abs(x2 - x1)
  local dy = math.abs(y2 - y1)
  local sx = x1 < x2 and 1 or -1
  local sy = y1 < y2 and 1 or -1
  local err = dx - dy
  local x, y = x1, y1
  while true do
    pts[#pts + 1] = { x, y }
    if x == x2 and y == y2 then
      break
    end
    local e2 = 2 * err
    if e2 > -dy then
      err = err - dy
      x = x + sx
    end
    if e2 < dx then
      err = err + dx
      y = y + sy
    end
  end
  return pts
end

-- Pixel-perfect 1px stroke: diagonal joins only, no L-corner doubles.
-- Bresenham DM.draw_line stays for non-pixel-perfect uses.
function DM.draw_line_px(x1, y1, x2, y2, color)
  local img = DM.canvas()
  local c = DM.color(color)
  x1, y1, x2, y2 = math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2)
  local pts = bresenham_points(x1, y1, x2, y2)
  local n = #pts
  if n == 0 then
    return { ok = true, pixels = 0 }
  end
  local seen = {}
  local function pk(x, y)
    return x * 4096 + y
  end
  for _, p in ipairs(pts) do
    seen[pk(p[1], p[2])] = true
  end
  local plotted = 0
  for i, p in ipairs(pts) do
    local drop = false
    if i > 1 and i < n then
      local x, y = p[1], p[2]
      local has_h = seen[pk(x + 1, y)] or seen[pk(x - 1, y)]
      local has_v = seen[pk(x, y + 1)] or seen[pk(x, y - 1)]
      if has_h and has_v then
        drop = true
      end
    end
    if not drop then
      img:putPixel(p[1], p[2], c)
      plotted = plotted + 1
    end
  end
  return { ok = true, pixels = plotted }
end

function DM.draw_rect(x, y, w, h, color, filled)
  x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h)
  if filled then
    local img = DM.canvas()
    local c = DM.color(color)
    for yy = y, y + h - 1 do
      for xx = x, x + w - 1 do
        img:putPixel(xx, yy, c)
      end
    end
  else
    DM.draw_line(x, y, x + w - 1, y, color)
    DM.draw_line(x + w - 1, y, x + w - 1, y + h - 1, color)
    DM.draw_line(x + w - 1, y + h - 1, x, y + h - 1, color)
    DM.draw_line(x, y + h - 1, x, y, color)
  end
  return { ok = true }
end

local function plot4(img, cx, cy, x, y, c)
  img:putPixel(cx + x, cy + y, c)
  img:putPixel(cx - x, cy + y, c)
  img:putPixel(cx + x, cy - y, c)
  img:putPixel(cx - x, cy - y, c)
end

function DM.draw_ellipse(cx, cy, rx, ry, color, filled)
  cx, cy = math.floor(cx), math.floor(cy)
  rx, ry = math.max(0, math.floor(rx)), math.max(0, math.floor(ry))
  local img = DM.canvas()
  local c = DM.color(color)
  if rx == 0 and ry == 0 then
    img:putPixel(cx, cy, c)
    return { ok = true }
  end
  if filled then
    for y = -ry, ry do
      local t = 1 - (y * y) / math.max(ry * ry, 1)
      if t < 0 then t = 0 end
      local xspan = math.floor(rx * math.sqrt(t) + 0.5)
      for x = -xspan, xspan do
        img:putPixel(cx + x, cy + y, c)
      end
    end
  else
    local x, y = 0, ry
    local rx2, ry2 = rx * rx, ry * ry
    local two_rx2, two_ry2 = 2 * rx2, 2 * ry2
    local px, py = 0, two_rx2 * y
    local p = ry2 - rx2 * ry + (0.25 * rx2)
    while px < py do
      plot4(img, cx, cy, x, y, c)
      x = x + 1
      px = px + two_ry2
      if p < 0 then
        p = p + ry2 + px
      else
        y = y - 1
        py = py - two_rx2
        p = p + ry2 + px - py
      end
    end
    p = ry2 * (x + 0.5) * (x + 0.5) + rx2 * (y - 1) * (y - 1) - rx2 * ry2
    while y >= 0 do
      plot4(img, cx, cy, x, y, c)
      y = y - 1
      py = py - two_rx2
      if p > 0 then
        p = p + rx2 - py
      else
        x = x + 1
        px = px + two_ry2
        p = p + rx2 - py + px
      end
    end
  end
  return { ok = true }
end

function DM.draw_polyline(points, color, close)
  if not points or #points == 0 then
    return { ok = true, count = 0 }
  end
  for i = 1, #points - 1 do
    local a, b = points[i], points[i + 1]
    DM.draw_line(a.x or a[1], a.y or a[2], b.x or b[1], b.y or b[2], color)
  end
  if close and #points > 2 then
    local a, b = points[#points], points[1]
    DM.draw_line(a.x or a[1], a.y or a[2], b.x or b[1], b.y or b[2], color)
  end
  return { ok = true, count = #points }
end

function DM.fill_area(x, y, color)
  local img = DM.canvas()
  local s = DM.sprite()
  x, y = math.floor(x), math.floor(y)
  if x < 0 or y < 0 or x >= s.width or y >= s.height then
    DM.fail("fill point outside sprite")
  end
  local target = img:getPixel(x, y)
  local fillc = DM.color(color)
  img:putPixel(x, y, fillc)
  local repl = img:getPixel(x, y)
  img:putPixel(x, y, target)
  if target == repl then
    return { ok = true, filled = 0 }
  end
  local w, h = s.width, s.height
  local stack = { { x, y } }
  local filled = 0
  while #stack > 0 do
    local p = table.remove(stack)
    local px, py = p[1], p[2]
    if px >= 0 and py >= 0 and px < w and py < h then
      if img:getPixel(px, py) == target then
        img:putPixel(px, py, fillc)
        filled = filled + 1
        stack[#stack + 1] = { px + 1, py }
        stack[#stack + 1] = { px - 1, py }
        stack[#stack + 1] = { px, py + 1 }
        stack[#stack + 1] = { px, py - 1 }
      end
    end
  end
  return { ok = true, filled = filled }
end

function DM.add_outline(color)
  local img = DM.canvas()
  local s = DM.sprite()
  local w, h = s.width, s.height
  local c = DM.color(color)
  local marks = {}
  local function opaque(px, py)
    if px < 0 or py < 0 or px >= w or py >= h then
      return false
    end
    local pc = Color(img:getPixel(px, py))
    return pc.alpha > 0
  end
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      if not opaque(x, y) then
        if opaque(x - 1, y) or opaque(x + 1, y) or opaque(x, y - 1) or opaque(x, y + 1) then
          marks[#marks + 1] = { x, y }
        end
      end
    end
  end
  for _, p in ipairs(marks) do
    img:putPixel(p[1], p[2], c)
  end
  return { ok = true, pixels = #marks }
end

local function transparent_color()
  return Color{ r = 0, g = 0, b = 0, a = 0 }
end

local function parse_punch_color(c)
  if c == nil or c == false then
    return transparent_color()
  end
  if type(c) == "string" then
    local n = c:lower()
    if n == "" or n == "transparent" or n == "clear" then
      return transparent_color()
    end
  end
  return DM.color(c)
end

local LIGHT_DIRS = {
  ["top-left"] = { -1, -1 },
  ["tl"] = { -1, -1 },
  ["top-right"] = { 1, -1 },
  ["tr"] = { 1, -1 },
  ["bottom-left"] = { -1, 1 },
  ["bl"] = { -1, 1 },
  ["bottom-right"] = { 1, 1 },
  ["br"] = { 1, 1 },
  ["top"] = { 0, -1 },
  ["bottom"] = { 0, 1 },
  ["left"] = { -1, 0 },
  ["right"] = { 1, 0 },
}

-- Selective outline on the active cel: dark rim on the shadow side,
-- body color on the light side. Default light is top-left.
function DM.selout(dark_color, light_dx, light_dy)
  local img = DM.canvas()
  local s = DM.sprite()
  local w, h = s.width, s.height
  local dark = DM.color(dark_color)
  if type(light_dx) == "string" then
    local key = light_dx:lower():gsub("%s+", "-")
    local dir = LIGHT_DIRS[key]
    if not dir then
      DM.fail("unknown light direction: " .. light_dx)
    end
    light_dx, light_dy = dir[1], dir[2]
  end
  light_dx = tonumber(light_dx) or -1
  light_dy = tonumber(light_dy) or -1
  if light_dx == 0 and light_dy == 0 then
    light_dx, light_dy = -1, -1
  end
  local function opaque(px, py)
    if px < 0 or py < 0 or px >= w or py >= h then
      return false
    end
    return Color(img:getPixel(px, py)).alpha > 0
  end
  local dirs = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
  local marks = {}
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      if opaque(x, y) then
        local score, nempty = 0, 0
        local body = img:getPixel(x, y)
        for _, d in ipairs(dirs) do
          if not opaque(x + d[1], y + d[2]) then
            nempty = nempty + 1
            score = score + d[1] * light_dx + d[2] * light_dy
            local ix, iy = x - d[1], y - d[2]
            if opaque(ix, iy) then
              body = img:getPixel(ix, iy)
            end
          end
        end
        if nempty > 0 then
          if score > 0 then
            marks[#marks + 1] = { x, y, body }
          else
            marks[#marks + 1] = { x, y, dark }
          end
        end
      end
    end
  end
  for _, m in ipairs(marks) do
    img:putPixel(m[1], m[2], m[3])
  end
  return { ok = true, pixels = #marks, light_dx = light_dx, light_dy = light_dy }
end

-- Cut a hole in a cluster. Rect: DM.punch(x, y, w, h[, color]).
-- Flood at a seed: DM.punch(x, y) or DM.punch(x, y, color).
-- Nil/false/"transparent" color clears to alpha 0.
function DM.punch(x, y, w, h, color)
  local img = DM.canvas()
  local s = DM.sprite()
  local sw, sh = s.width, s.height
  x, y = math.floor(x), math.floor(y)
  local flood_color = nil
  local is_flood = false
  if w == nil or type(w) == "string" or type(w) == "boolean" then
    is_flood = true
    flood_color = w
  elseif type(w) == "userdata" then
    is_flood = true
    flood_color = w
  end
  if is_flood then
    if x < 0 or y < 0 or x >= sw or y >= sh then
      DM.fail("punch point outside sprite")
    end
    local fillc = parse_punch_color(flood_color)
    local target = img:getPixel(x, y)
    img:putPixel(x, y, fillc)
    local repl = img:getPixel(x, y)
    img:putPixel(x, y, target)
    if target == repl then
      return { ok = true, filled = 0, mode = "flood" }
    end
    local stack = { { x, y } }
    local filled = 0
    while #stack > 0 do
      local p = table.remove(stack)
      local px, py = p[1], p[2]
      if px >= 0 and py >= 0 and px < sw and py < sh then
        if img:getPixel(px, py) == target then
          img:putPixel(px, py, fillc)
          filled = filled + 1
          stack[#stack + 1] = { px + 1, py }
          stack[#stack + 1] = { px - 1, py }
          stack[#stack + 1] = { px, py + 1 }
          stack[#stack + 1] = { px, py - 1 }
        end
      end
    end
    return { ok = true, filled = filled, mode = "flood" }
  end
  w, h = math.floor(w), math.floor(h)
  local fillc = parse_punch_color(color)
  local n = 0
  for yy = y, y + h - 1 do
    for xx = x, x + w - 1 do
      if xx >= 0 and yy >= 0 and xx < sw and yy < sh then
        img:putPixel(xx, yy, fillc)
        n = n + 1
      end
    end
  end
  return { ok = true, pixels = n, mode = "rect" }
end

local function stair_run(opaque, x, y, dx, dy, w, h)
  local n = 1
  local px, py = x - dx, y - dy
  while px >= 0 and py >= 0 and px < w and py < h and opaque(px, py) do
    n = n + 1
    px = px - dx
    py = py - dy
  end
  return n
end

-- 1px midtone on long stair corners. Off when min(canvas) <= 64 unless force.
function DM.aa_stair(mid_color, min_run, force)
  if type(min_run) == "boolean" then
    force = min_run
    min_run = nil
  end
  local s = DM.sprite()
  local w, h = s.width, s.height
  if not force and math.min(w, h) <= 64 then
    return { ok = true, pixels = 0, skipped = true }
  end
  min_run = tonumber(min_run) or 4
  if min_run < 2 then
    min_run = 2
  end
  local img = DM.canvas()
  local mid = DM.color(mid_color)
  local function opaque(px, py)
    if px < 0 or py < 0 or px >= w or py >= h then
      return false
    end
    return Color(img:getPixel(px, py)).alpha > 0
  end
  -- {run_dx, run_dy, empty_dx, empty_dy, step_dx, step_dy}
  local cases = {
    { 1, 0, 1, 0, 1, 1 },
    { 1, 0, 1, 0, 1, -1 },
    { -1, 0, -1, 0, -1, 1 },
    { -1, 0, -1, 0, -1, -1 },
    { 0, 1, 0, 1, 1, 1 },
    { 0, 1, 0, 1, -1, 1 },
    { 0, -1, 0, -1, 1, -1 },
    { 0, -1, 0, -1, -1, -1 },
  }
  local marks = {}
  local seen = {}
  local function pk(x, y)
    return x * 4096 + y
  end
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      if opaque(x, y) then
        for _, c in ipairs(cases) do
          local rdx, rdy, ex, ey, sx, sy = c[1], c[2], c[3], c[4], c[5], c[6]
          if not opaque(x + ex, y + ey) and opaque(x + sx, y + sy) then
            if stair_run(opaque, x, y, rdx, rdy, w, h) >= min_run then
              local k = pk(x, y)
              if not seen[k] then
                seen[k] = true
                marks[#marks + 1] = { x, y }
              end
            end
          end
        end
      end
    end
  end
  for _, p in ipairs(marks) do
    img:putPixel(p[1], p[2], mid)
  end
  return { ok = true, pixels = #marks, skipped = false, min_run = min_run }
end

function DM.set_palette(colors)
  local s = DM.sprite()
  local pal = Palette(#colors)
  for i, hex in ipairs(colors) do
    pal:setColor(i - 1, DM.color(hex))
  end
  s:setPalette(pal)
  return { ok = true, size = #colors }
end

function DM.apply_palette_file(path)
  local pal = Palette{ fromFile = path }
  if not pal then
    DM.fail("failed to load palette: " .. tostring(path))
  end
  DM.sprite():setPalette(pal)
  return { ok = true, size = #pal, path = path }
end

local function rgb_to_hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local maxc, minc = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (maxc + minc) / 2
  if maxc ~= minc then
    local d = maxc - minc
    s = l > 0.5 and d / (2 - maxc - minc) or d / (maxc + minc)
    if maxc == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif maxc == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, l
end

local function hue2rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1 / 6 then return p + (q - p) * 6 * t end
  if t < 1 / 2 then return q end
  if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
  return p
end

local function hsl_to_rgb(h, s, l)
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  end
  return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
end

function DM.generate_ramp(base_color, steps)
  steps = tonumber(steps) or 5
  if steps < 2 then
    steps = 2
  end
  local c = DM.color(base_color)
  local h, s, l = rgb_to_hsl(c.red, c.green, c.blue)
  local s_pal = DM.sprite().palettes[1]
  local start_index = #s_pal
  s_pal:resize(start_index + steps)
  local hexes = {}
  for i = 0, steps - 1 do
    local t = i / (steps - 1)
    local ll = 0.12 + t * 0.76
    local hh = h + (0.5 - t) * 0.06
    if hh < 0 then hh = hh + 1 end
    if hh > 1 then hh = hh - 1 end
    local ss = s * (0.75 + 0.25 * (1 - math.abs(t - 0.45) * 2))
    if ss > 1 then ss = 1 end
    local r, g, b = hsl_to_rgb(hh, ss, ll)
    local col = Color{ r = r, g = g, b = b, a = 255 }
    s_pal:setColor(start_index + i, col)
    hexes[#hexes + 1] = string.format("#%02x%02x%02x", r, g, b)
  end
  return { ok = true, colors = hexes, start_index = start_index }
end

local function ramp_colors(hex, steps)
  local c = DM.color(hex)
  local h, s, _ = rgb_to_hsl(c.red, c.green, c.blue)
  local out = {}
  for i = 0, steps - 1 do
    local t = steps == 1 and 0.5 or (i / (steps - 1))
    local ll = 0.10 + t * 0.78
    local hh = h + (0.5 - t) * 0.05
    if hh < 0 then hh = hh + 1 end
    if hh > 1 then hh = hh - 1 end
    local ss = math.min(1, s * (0.7 + 0.3 * (1 - math.abs(t - 0.4))))
    local r, g, b = hsl_to_rgb(hh, ss, ll)
    out[#out + 1] = string.format("#%02x%02x%02x", r, g, b)
  end
  return out
end

function DM.create_palette(count, seed)
  count = math.max(8, math.min(256, tonumber(count) or 32))
  seed = seed and seed ~= "" and seed or "#6b8f3a"
  local families = {
    seed,
    "#5c4030", -- earth
    "#3d7a44", -- foliage
    "#6ea0c8", -- sky
    "#d2a07a", -- skin/bone
    "#8a8f99", -- metal
    "#c45c4a", -- accent
  }
  local per = math.max(2, math.floor(count / #families))
  local hexes = { "#000000" }
  for _, fam in ipairs(families) do
    if #hexes >= count then
      break
    end
    local need = math.min(per, count - #hexes)
    local ramp = ramp_colors(fam, need)
    for _, h in ipairs(ramp) do
      hexes[#hexes + 1] = h
      if #hexes >= count then
        break
      end
    end
  end
  while #hexes < count do
    hexes[#hexes + 1] = "#808080"
  end
  DM.set_palette(hexes)
  return { ok = true, size = #hexes, colors = hexes }
end

function DM.hide_layer(name)
  local layer = DM.find_layer(name)
  layer.isVisible = false
  return { ok = true, name = name }
end

function DM.extract_palette()
  local pal = DM.sprite().palettes[1]
  local hexes = {}
  for i = 0, #pal - 1 do
    local c = pal:getColor(i)
    hexes[#hexes + 1] = string.format("#%02x%02x%02x", c.red, c.green, c.blue)
  end
  return { ok = true, size = #hexes, colors = hexes }
end

function DM.copy_palette_from(src_path)
  local dest = DM.sprite()
  local src, owned = DM.open_ref(src_path)
  dest:setPalette(src.palettes[1])
  local hexes = {}
  local pal = src.palettes[1]
  for i = 0, #pal - 1 do
    local c = pal:getColor(i)
    hexes[#hexes + 1] = string.format("#%02x%02x%02x", c.red, c.green, c.blue)
  end
  if owned then
    src:close()
  end
  app.activeSprite = dest
  return { ok = true, size = #hexes, colors = hexes }
end

function DM.copy_cels(from_frame, to_frame, layer_names)
  local s = DM.sprite()
  from_frame = tonumber(from_frame)
  to_frame = tonumber(to_frame)
  local layers = {}
  if layer_names and #layer_names > 0 then
    for _, name in ipairs(layer_names) do
      layers[#layers + 1] = DM.find_layer(name)
    end
  else
    layers = DM.iter_layers()
  end
  for _, layer in ipairs(layers) do
    if layer.isImage then
      local src = layer:cel(from_frame)
      if src then
        local img = Image(src.image)
        local existing = layer:cel(to_frame)
        if existing then
          existing.image = img
          existing.position = Point(src.position.x, src.position.y)
        else
          s:newCel(layer, to_frame, img, src.position)
        end
      end
    end
  end
  return { ok = true, from = from_frame, to = to_frame }
end

function DM.shift_cel(layer_name, frame, dx, dy)
  DM.use(layer_name, frame)
  local img, cel = DM.canvas()
  local moved = Image(img.spec)
  moved:clear()
  moved:drawImage(img, Point(tonumber(dx) or 0, tonumber(dy) or 0))
  cel.image = moved
  cel.position = Point(0, 0)
  return { ok = true, layer = layer_name, frame = frame, dx = dx, dy = dy }
end

-- Cut pixels in a sprite-space rect and paste at +dx,+dy. Clip to canvas.
-- Whole-layer nudge remains shift_cel.
function DM.shift_rect(layer_name, frame, x, y, w, h, dx, dy)
  DM.use(layer_name, frame)
  local img = DM.canvas()
  local s = DM.sprite()
  local sw, sh = s.width, s.height
  x = math.floor(tonumber(x) or 0)
  y = math.floor(tonumber(y) or 0)
  w = math.floor(tonumber(w) or 0)
  h = math.floor(tonumber(h) or 0)
  dx = math.floor(tonumber(dx) or 0)
  dy = math.floor(tonumber(dy) or 0)
  if w <= 0 or h <= 0 or (dx == 0 and dy == 0) then
    return { ok = true, layer = layer_name, frame = frame, dx = dx, dy = dy, moved = 0 }
  end
  local x1 = math.max(0, x)
  local y1 = math.max(0, y)
  local x2 = math.min(sw, x + w)
  local y2 = math.min(sh, y + h)
  if x1 >= x2 or y1 >= y2 then
    return { ok = true, layer = layer_name, frame = frame, dx = dx, dy = dy, moved = 0 }
  end
  local saved = {}
  for py = y1, y2 - 1 do
    for px = x1, x2 - 1 do
      saved[#saved + 1] = { px, py, img:getPixel(px, py) }
    end
  end
  local clear = transparent_color()
  for py = y1, y2 - 1 do
    for px = x1, x2 - 1 do
      img:putPixel(px, py, clear)
    end
  end
  local moved = 0
  for i = 1, #saved do
    local rec = saved[i]
    local nx, ny = rec[1] + dx, rec[2] + dy
    if nx >= 0 and ny >= 0 and nx < sw and ny < sh then
      img:putPixel(nx, ny, rec[3])
      moved = moved + 1
    end
  end
  return { ok = true, layer = layer_name, frame = frame, dx = dx, dy = dy, moved = moved }
end

local function nn_round(v)
  if v >= 0 then
    return math.floor(v + 0.5)
  end
  return math.ceil(v - 0.5)
end

-- Nearest-neighbor rotate of opaque pixels inside a disk. Inverse mapping.
-- Does not bilinear-filter and does not rotate the whole canvas.
function DM.rotate_pixels(layer_name, frame, cx, cy, angle_deg, radius)
  DM.use(layer_name, frame)
  local img = DM.canvas()
  local s = DM.sprite()
  local sw, sh = s.width, s.height
  cx = tonumber(cx) or 0
  cy = tonumber(cy) or 0
  local deg = tonumber(angle_deg) or 0
  radius = tonumber(radius) or 0
  if radius <= 0 or deg == 0 then
    return { ok = true, layer = layer_name, frame = frame, angle = deg, radius = radius, rotated = 0 }
  end
  local ang = math.rad(deg)
  local cos_a = math.cos(ang)
  local sin_a = math.sin(ang)
  local r2 = radius * radius
  local xmin = math.max(0, math.floor(cx - radius))
  local ymin = math.max(0, math.floor(cy - radius))
  local xmax = math.min(sw - 1, math.ceil(cx + radius))
  local ymax = math.min(sh - 1, math.ceil(cy + radius))
  local src = {}
  for py = ymin, ymax do
    local row = {}
    for px = xmin, xmax do
      row[px] = img:getPixel(px, py)
    end
    src[py] = row
  end
  local clear = transparent_color()
  for py = ymin, ymax do
    for px = xmin, xmax do
      local ddx = px - cx
      local ddy = py - cy
      if ddx * ddx + ddy * ddy <= r2 then
        if Color(src[py][px]).alpha > 0 then
          img:putPixel(px, py, clear)
        end
      end
    end
  end
  local rotated = 0
  for py = ymin, ymax do
    for px = xmin, xmax do
      local ddx = px - cx
      local ddy = py - cy
      if ddx * ddx + ddy * ddy <= r2 then
        local sx = nn_round(cx + ddx * cos_a + ddy * sin_a)
        local sy = nn_round(cy - ddx * sin_a + ddy * cos_a)
        if sx >= xmin and sy >= ymin and sx <= xmax and sy <= ymax then
          local sdx = sx - cx
          local sdy = sy - cy
          if sdx * sdx + sdy * sdy <= r2 then
            local pix = src[sy][sx]
            if Color(pix).alpha > 0 then
              img:putPixel(px, py, pix)
              rotated = rotated + 1
            end
          end
        end
      end
    end
  end
  return {
    ok = true,
    layer = layer_name,
    frame = frame,
    angle = deg,
    radius = radius,
    rotated = rotated,
  }
end

function DM.clear_cel(layer_name, frame)
  DM.use(layer_name, frame)
  local img = DM.canvas()
  img:clear()
  return { ok = true, layer = layer_name, frame = frame }
end

function DM.apply_tags(tag_list)
  local s = DM.sprite()
  local total = 0
  for _, spec in ipairs(tag_list) do
    total = total + math.max(1, tonumber(spec.frames) or 1)
  end
  while #s.frames < total do
    s:newEmptyFrame()
  end
  local cursor = 1
  for _, spec in ipairs(tag_list) do
    local n = math.max(1, tonumber(spec.frames) or 1)
    local ms = tonumber(spec.ms) or 100
    local last = cursor + n - 1
    DM.set_frame_durations(cursor, last, ms)
    local exists = false
    for _, tag in ipairs(s.tags) do
      if tag.name == spec.name then
        exists = true
        pcall(function()
          tag.fromFrame = s.frames[cursor]
          tag.toFrame = s.frames[last]
        end)
      end
    end
    if not exists then
      DM.create_tag(spec.name, cursor, last)
    end
    cursor = last + 1
  end
  return { ok = true, frame_count = #s.frames }
end

function DM.create_creature_template(width, height, complex, tag_list)
  local s = DM.sprite()
  complex = complex == true
  if complex then
    if #s.layers >= 1 then
      s.layers[1].name = "_tmp"
    end
    DM.add_layer_group("skeleton")
    for _, name in ipairs({ "sk_spine", "sk_head", "sk_arm_f", "sk_arm_b", "sk_leg_f", "sk_leg_b" }) do
      DM.add_layer(name, "skeleton")
    end
    DM.add_layer_group("volume")
    for _, name in ipairs({ "vol_spine", "vol_head", "vol_arm_f", "vol_arm_b", "vol_leg_f", "vol_leg_b" }) do
      DM.add_layer(name, "volume")
    end
    DM.add_layer_group("paint")
    for _, name in ipairs({ "line", "color", "shade", "fx" }) do
      DM.add_layer(name, "paint")
    end
    pcall(function()
      local tmp = DM.find_layer("_tmp")
      if tmp and tmp.isImage then
        tmp.isVisible = false
      end
    end)
  else
    if #s.layers >= 1 then
      s.layers[1].name = "skeleton"
    else
      DM.add_layer("skeleton")
    end
    for _, name in ipairs({ "volume", "line", "color", "shade", "fx" }) do
      DM.add_layer(name)
    end
  end
  if not tag_list or #tag_list == 0 then
    tag_list = {
      { name = "idle", frames = 4, ms = 200 },
      { name = "walk", frames = 8, ms = 100 },
      { name = "run", frames = 8, ms = 80 },
      { name = "attack", frames = 6, ms = 90 },
      { name = "jump", frames = 3, ms = 80 },
      { name = "fall", frames = 3, ms = 100 },
      { name = "hurt", frames = 4, ms = 100 },
      { name = "die", frames = 6, ms = 120 },
    }
  end
  DM.apply_tags(tag_list)
  if width and height and (s.width ~= width or s.height ~= height) then
    app.command.SpriteSize{
      ui = false,
      width = width,
      height = height,
      method = "nearest",
    }
  end
  return DM.info()
end

function DM.create_prop_template(frames, with_skeleton)
  frames = math.max(1, tonumber(frames) or 1)
  local s = DM.sprite()
  if #s.layers >= 1 then
    s.layers[1].name = with_skeleton and "skeleton" or "volume"
  else
    DM.add_layer(with_skeleton and "skeleton" or "volume")
  end
  local names = { "volume", "line", "color", "shade", "fx" }
  if with_skeleton then
    names = { "volume", "line", "color", "shade", "fx" }
  end
  local have = {}
  for _, layer in ipairs(DM.iter_layers()) do
    have[layer.name] = true
  end
  for _, name in ipairs(names) do
    if not have[name] then
      DM.add_layer(name)
    end
  end
  while #s.frames < frames do
    s:newEmptyFrame()
  end
  DM.set_frame_durations(1, frames, 140)
  local tagged = false
  for _, tag in ipairs(s.tags) do
    if tag.name == "loop" then
      tagged = true
    end
  end
  if frames > 1 and not tagged then
    DM.create_tag("loop", 1, frames)
  end
  return DM.info()
end

function DM.create_character_template(width, height)
  local s = DM.sprite()
  if #s.layers >= 1 then
    s.layers[1].name = "silhouette"
  else
    DM.add_layer("silhouette")
  end
  local names = { "line", "color", "shade", "fx" }
  local have = {}
  for _, layer in ipairs(s.layers) do
    have[layer.name] = true
  end
  if not have["silhouette"] then
    s.layers[1].name = "silhouette"
    have["silhouette"] = true
  end
  for _, name in ipairs(names) do
    if not have[name] then
      DM.add_layer(name)
    end
  end
  -- 16 frames: idle 1-4, walk 5-12, attack 13-16
  while #s.frames < 16 do
    s:newEmptyFrame()
  end
  DM.set_frame_durations(1, 4, 200)
  DM.set_frame_durations(5, 12, 100)
  DM.set_frame_durations(13, 16, 90)
  local function ensure_tag(name, a, b)
    for _, tag in ipairs(s.tags) do
      if tag.name == name then
        return
      end
    end
    DM.create_tag(name, a, b)
  end
  ensure_tag("idle", 1, 4)
  ensure_tag("walk", 5, 12)
  ensure_tag("attack", 13, 16)
  if width and height and (s.width ~= width or s.height ~= height) then
    app.command.SpriteSize{
      ui = false,
      width = width,
      height = height,
      method = "nearest",
    }
  end
  return DM.info()
end

function DM.create_nature_template(frames)
  frames = math.max(4, tonumber(frames) or 4)
  local s = DM.sprite()
  if #s.layers >= 1 then
    s.layers[1].name = "silhouette"
  else
    DM.add_layer("silhouette")
  end
  local names = { "color", "shade", "fx" }
  local have = {}
  for _, layer in ipairs(s.layers) do
    have[layer.name] = true
  end
  for _, name in ipairs(names) do
    if not have[name] then
      DM.add_layer(name)
    end
  end
  while #s.frames < frames do
    s:newEmptyFrame()
  end
  DM.set_frame_durations(1, frames, 140)
  local tagged = false
  for _, tag in ipairs(s.tags) do
    if tag.name == "loop" then
      tagged = true
    end
  end
  if not tagged then
    DM.create_tag("loop", 1, frames)
  end
  return DM.info()
end

function DM.ensure_tilemap(tile_size, tile_count)
  local s = DM.sprite()
  tile_size = tonumber(tile_size) or 32
  tile_count = tonumber(tile_count) or 8
  s.gridBounds = Rectangle(0, 0, tile_size, tile_size)
  local ts
  if s.tilesets and #s.tilesets > 0 then
    ts = s.tilesets[1]
  else
    ts = s:newTileset(Rectangle{ x = 0, y = 0, width = tile_size, height = tile_size }, tile_count)
    ts.name = "ground"
  end
  pcall(function()
    -- Tile 0 is empty; user tiles are 1..tile_count. Grow until that index exists.
    local guard = 0
    while guard < 80 do
      local tile = ts:tile(tile_count)
      if tile then
        break
      end
      s:newTile(ts)
      guard = guard + 1
    end
  end)
  local map = nil
  for _, layer in ipairs(s.layers) do
    if layer.isTilemap then
      map = layer
      break
    end
  end
  if not map then
    app.command.NewLayer{ tilemap = true }
    map = app.activeLayer
    if map then
      map.name = "ground"
    end
  end
  if not map or not map.isTilemap then
    DM.fail("could not create tilemap layer (need Aseprite 1.3+)")
  end
  pcall(function()
    map.tileset = ts
  end)
  map.name = "ground"
  for _, layer in ipairs(s.layers) do
    if layer.isImage and layer.name == "Layer 1" then
      layer.isVisible = false
      layer.name = "_unused"
    end
  end
  app.activeLayer = map
  return ts, map
end

function DM.tile_image(index)
  local s = DM.sprite()
  local ts = s.tilesets[1]
  if not ts then
    DM.fail("no tileset on sprite")
  end
  local tile = ts:tile(index)
  if not tile then
    DM.fail("tile not found: " .. tostring(index))
  end
  return tile.image, tile
end

function DM.fill_tile(index, color)
  local img, tile = DM.tile_image(index)
  local copy = Image(img)
  copy:clear(DM.color(color))
  tile.image = copy
  return { ok = true, index = index }
end

function DM.draw_on_tile(index, x, y, w, h, color, filled)
  local img, tile = DM.tile_image(index)
  local copy = Image(img)
  local c = DM.color(color)
  x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h)
  if filled ~= false then
    for yy = y, y + h - 1 do
      for xx = x, x + w - 1 do
        if xx >= 0 and yy >= 0 and xx < copy.width and yy < copy.height then
          copy:putPixel(xx, yy, c)
        end
      end
    end
  else
    for xx = x, x + w - 1 do
      if xx >= 0 and xx < copy.width then
        if y >= 0 and y < copy.height then copy:putPixel(xx, y, c) end
        if y + h - 1 >= 0 and y + h - 1 < copy.height then copy:putPixel(xx, y + h - 1, c) end
      end
    end
  end
  tile.image = copy
  return { ok = true, index = index }
end

function DM.paint_ground_tiles()
  local img = DM.tile_image(1)
  local sz = img.width
  local function sc(n)
    return math.max(1, math.floor(n * sz / 32))
  end
  local grass = "#4a8f3a"
  local grass_d = "#2f5c28"
  local grass_l = "#6bb24a"
  local dirt = "#8a5a32"
  local dirt_d = "#5c3a22"
  local stone = "#7a7e86"
  local stone_d = "#4a4e56"
  local water = "#3a7ea8"
  local water_d = "#245a7a"
  DM.fill_tile(1, dirt)
  DM.draw_on_tile(1, 0, 0, sz, sc(10), grass, true)
  DM.draw_on_tile(1, 0, 0, sz, sc(3), grass_l, true)
  DM.fill_tile(2, dirt)
  DM.draw_on_tile(2, 0, 0, sz, sc(4), dirt_d, true)
  DM.fill_tile(3, dirt_d)
  DM.fill_tile(4, stone)
  DM.draw_on_tile(4, sc(10), sc(10), sc(8), sc(6), stone_d, true)
  DM.fill_tile(5, water)
  DM.draw_on_tile(5, 0, sc(6), sz, sc(2), water_d, true)
  DM.fill_tile(6, stone_d)
  DM.draw_on_tile(6, 0, 0, sz, sc(10), dirt, true)
  DM.draw_on_tile(6, 0, 0, sz, sc(4), grass, true)
  DM.fill_tile(7, grass)
  DM.draw_on_tile(7, sc(6), sc(8), sc(4), sc(3), grass_d, true)
  return { ok = true, tiles = 7, tile_size = sz }
end

function DM.paint_autotile(tile_size, theme)
  tile_size = tonumber(tile_size) or 32
  theme = theme or "meadow"
  local fill, edge, accent
  if theme == "dungeon" then
    fill, edge, accent = "#4a4e56", "#2a2e36", "#7a7e86"
  elseif theme == "interior_wood" then
    fill, edge, accent = "#8a5a32", "#5c3a22", "#c4a574"
  elseif theme == "dirt" then
    fill, edge, accent = "#8a5a32", "#5c3a22", "#6b4424"
  elseif theme == "water" then
    fill, edge, accent = "#3a7ea8", "#245a7a", "#6eb4d4"
  else
    fill, edge, accent = "#5c3a22", "#3f2818", "#4a8f3a"
  end
  local grass = "#4a8f3a"
  local grass_l = "#6bb24a"
  local water = "#3a7ea8"
  local water_l = "#6eb4d4"
  local e = math.max(2, math.floor(tile_size / 8))
  -- 1 fill
  DM.fill_tile(1, fill)
  -- 2-5 edges N E S W
  DM.fill_tile(2, fill)
  DM.draw_on_tile(2, 0, 0, tile_size, e, edge, true)
  DM.fill_tile(3, fill)
  DM.draw_on_tile(3, tile_size - e, 0, e, tile_size, edge, true)
  DM.fill_tile(4, fill)
  DM.draw_on_tile(4, 0, tile_size - e, tile_size, e, edge, true)
  DM.fill_tile(5, fill)
  DM.draw_on_tile(5, 0, 0, e, tile_size, edge, true)
  -- 6-9 outer corners NE SE SW NW
  DM.fill_tile(6, fill)
  DM.draw_on_tile(6, 0, 0, tile_size, e, edge, true)
  DM.draw_on_tile(6, tile_size - e, 0, e, tile_size, edge, true)
  DM.fill_tile(7, fill)
  DM.draw_on_tile(7, tile_size - e, 0, e, tile_size, edge, true)
  DM.draw_on_tile(7, 0, tile_size - e, tile_size, e, edge, true)
  DM.fill_tile(8, fill)
  DM.draw_on_tile(8, 0, tile_size - e, tile_size, e, edge, true)
  DM.draw_on_tile(8, 0, 0, e, tile_size, edge, true)
  DM.fill_tile(9, fill)
  DM.draw_on_tile(9, 0, 0, tile_size, e, edge, true)
  DM.draw_on_tile(9, 0, 0, e, tile_size, edge, true)
  -- 10-13 inner corners
  DM.fill_tile(10, fill)
  DM.draw_on_tile(10, tile_size - e, 0, e, e, edge, true)
  DM.fill_tile(11, fill)
  DM.draw_on_tile(11, tile_size - e, tile_size - e, e, e, edge, true)
  DM.fill_tile(12, fill)
  DM.draw_on_tile(12, 0, tile_size - e, e, e, edge, true)
  DM.fill_tile(13, fill)
  DM.draw_on_tile(13, 0, 0, e, e, edge, true)
  -- 14 grass-dirt (side-on surface)
  DM.fill_tile(14, fill)
  DM.draw_on_tile(14, 0, 0, tile_size, math.floor(tile_size * 0.35), grass, true)
  DM.draw_on_tile(14, 0, 0, tile_size, math.max(2, e), grass_l, true)
  -- 15 water fill
  DM.fill_tile(15, water)
  -- 16 water shore
  DM.fill_tile(16, water)
  DM.draw_on_tile(16, 0, 0, tile_size, math.max(2, e + 1), water_l, true)
  DM.draw_on_tile(16, 0, 0, tile_size, 1, "#e8eef4", true)
  return { ok = true, tiles = 16, theme = theme, tile_size = tile_size }
end

function DM.tilemap_layer()
  local s = DM.sprite()
  for _, layer in ipairs(s.layers) do
    if layer.isTilemap then
      return layer
    end
  end
  DM.fail("no tilemap layer")
end

function DM.tilemap_cel()
  local s = DM.sprite()
  local map = DM.tilemap_layer()
  app.activeLayer = map
  local ts = map.tileset or (s.tilesets and s.tilesets[1])
  local tw = 32
  pcall(function()
    if ts and ts.grid and ts.grid.tileSize then
      tw = ts.grid.tileSize.width
    end
  end)
  local cols = math.max(1, math.ceil(s.width / tw))
  local rows = math.max(1, math.ceil(s.height / tw))
  local function make_tilemap_image()
    local img = Image(ImageSpec{
      width = cols,
      height = rows,
      colorMode = ColorMode.TILEMAP,
    })
    img:clear()
    return img
  end
  local cel = map:cel(app.activeFrame)
  if not cel then
    cel = s:newCel(map, app.activeFrame, make_tilemap_image(), Point(0, 0))
  elseif cel.image.colorMode ~= ColorMode.TILEMAP
      or cel.image.width < cols
      or cel.image.height < rows then
    local img = make_tilemap_image()
    pcall(function()
      img:drawImage(cel.image, Point(0, 0))
    end)
    cel.image = img
    cel.position = Point(0, 0)
  end
  return cel
end

function DM.set_tile(tx, ty, index)
  local cel = DM.tilemap_cel()
  local pc = app.pixelColor.tile(index)
  cel.image:putPixel(math.floor(tx), math.floor(ty), pc)
  return { ok = true, x = tx, y = ty, index = index }
end

function DM.fill_tiles(from_x, from_y, to_x, to_y, index)
  for ty = from_y, to_y do
    for tx = from_x, to_x do
      DM.set_tile(tx, ty, index)
    end
  end
  return { ok = true, index = index }
end

function DM.set_tile_grid(grid)
  -- grid is array of rows, each row array of indices
  for ty, row in ipairs(grid) do
    for tx, index in ipairs(row) do
      DM.set_tile(tx - 1, ty - 1, index)
    end
  end
  return { ok = true, rows = #grid }
end

function DM.paint_sky()
  local s = DM.sprite()
  DM.use("sky", 1)
  local img = DM.canvas()
  local top = DM.color("#5a9bc8")
  local bot = DM.color("#c5dff0")
  local h = math.max(1, s.height - 1)
  for y = 0, s.height - 1 do
    local t = y / h
    local col = Color{
      r = math.floor(top.red + (bot.red - top.red) * t + 0.5),
      g = math.floor(top.green + (bot.green - top.green) * t + 0.5),
      b = math.floor(top.blue + (bot.blue - top.blue) * t + 0.5),
      a = 255,
    }
    for x = 0, s.width - 1 do
      img:putPixel(x, y, col)
    end
  end
  local sun_x = math.max(12, s.width - 36)
  DM.draw_ellipse(sun_x, 22, 10, 10, "#ead4aa", true)
  return { ok = true }
end

function DM.layout_interior(tile_size)
  local s = DM.sprite()
  tile_size = tonumber(tile_size) or 32
  local tw = math.floor(s.width / tile_size)
  local th = math.floor(s.height / tile_size)
  if tw < 1 or th < 2 then
    DM.fail("location must be at least 1x2 tiles")
  end
  local floor_y = th - 2
  local wall_from = math.max(0, th - 4)
  for ty = wall_from, floor_y - 1 do
    for tx = 0, tw - 1 do
      DM.set_tile(tx, ty, 4)
    end
  end
  for ty = floor_y, th - 1 do
    for tx = 0, tw - 1 do
      DM.set_tile(tx, ty, 1)
    end
  end
  return { ok = true, tiles_w = tw, tiles_h = th, kind = "interior" }
end

function DM.layout_meadow(tile_size)
  local s = DM.sprite()
  tile_size = tonumber(tile_size) or 32
  local tw = math.floor(s.width / tile_size)
  local th = math.floor(s.height / tile_size)
  if tw < 1 or th < 2 then
    DM.fail("location must be at least 1x2 tiles")
  end
  local gy = th - 2
  for tx = 0, tw - 1 do
    DM.set_tile(tx, gy, 14)
    DM.set_tile(tx, gy + 1, 1)
  end
  if tw >= 4 then
    DM.set_tile(tw - 3, gy, 16)
    DM.set_tile(tw - 2, gy, 16)
    DM.set_tile(tw - 1, gy, 16)
    DM.set_tile(tw - 3, gy + 1, 15)
    DM.set_tile(tw - 2, gy + 1, 15)
    DM.set_tile(tw - 1, gy + 1, 15)
  end
  return { ok = true, tiles_w = tw, tiles_h = th }
end

function DM.assemble_location_scaffold(tile_size, theme)
  local s = DM.sprite()
  tile_size = tonumber(tile_size) or 32
  theme = theme or "meadow"
  if #s.layers >= 1 then
    s.layers[1].name = "sky"
  else
    DM.add_layer("sky")
  end
  if theme == "interior_wood" or theme == "dungeon" then
    DM.use("sky", 1)
    DM.draw_rect(0, 0, s.width, s.height, theme == "dungeon" and "#2a2438" or "#3a3228", true)
  else
    DM.paint_sky()
  end
  DM.ensure_tilemap(tile_size, 20)
  for _, layer in ipairs(s.layers) do
    if layer.isTilemap then
      layer.name = "ground"
    end
  end
  DM.paint_autotile(tile_size, theme)
  local have = {}
  for _, layer in ipairs(s.layers) do
    have[layer.name] = true
  end
  if not have["nature"] then
    DM.add_layer("nature")
  end
  if not have["furniture"] then
    DM.add_layer("furniture")
  end
  if not have["characters"] then
    DM.add_layer("characters")
  end
  if theme == "interior_wood" or theme == "dungeon" then
    DM.layout_interior(tile_size)
  else
    DM.layout_meadow(tile_size)
  end
  return DM.info()
end

function DM.stamp_sprite(src_path, dest_layer, x, y, src_frame)
  local dest = DM.sprite()
  local src, owned = DM.open_ref(src_path)
  src_frame = tonumber(src_frame) or 1
  local flat = Image(src.spec)
  flat:clear()
  local function walk(layers)
    if not layers then
      return
    end
    for _, layer in ipairs(layers) do
      if layer.isGroup then
        walk(layer.layers)
      elseif layer.isImage and layer.isVisible then
        local cel = layer:cel(src_frame)
        if cel then
          flat:drawImage(cel.image, cel.position)
        end
      end
    end
  end
  walk(src.layers)
  if owned then
    src:close()
  end
  app.activeSprite = dest
  DM.use(dest_layer, 1)
  local canvas = DM.canvas()
  canvas:drawImage(flat, Point(math.floor(x), math.floor(y)))
  return { ok = true, layer = dest_layer }
end

function DM.export_flat(path, frame)
  local s = DM.sprite()
  frame = tonumber(frame) or 1
  local img = Image(s.spec)
  img:clear()
  img:drawSprite(s, frame)
  img:saveAs(path)
  return {
    ok = true,
    path = path,
    width = s.width,
    height = s.height,
    frame = frame,
    filename = s.filename or "",
  }
end

function DM.onion_composite(path, frame, prev_n, next_n, opacity)
  local s = DM.sprite()
  frame = tonumber(frame) or app.activeFrame.frameNumber
  prev_n = tonumber(prev_n) or 2
  next_n = tonumber(next_n) or 2
  opacity = tonumber(opacity) or 96
  local w, h = s.width, s.height
  local out = Image(s.spec)
  out:clear()

  local function flattened(fn)
    local img = Image(s.spec)
    img:clear()
    img:drawSprite(s, fn)
    return img
  end

  local function blit_tint(src, r, g, b, a)
    for y = 0, h - 1 do
      for x = 0, w - 1 do
        local pc = Color(src:getPixel(x, y))
        if pc.alpha > 0 then
          local existing = Color(out:getPixel(x, y))
          local na = math.min(255, a)
          out:putPixel(x, y, Color{
            r = r,
            g = g,
            b = b,
            a = math.max(existing.alpha, na),
          })
        end
      end
    end
  end

  for i = prev_n, 1, -1 do
    local fn = frame - i
    if fn >= 1 then
      blit_tint(flattened(fn), 220, 40, 40, opacity)
    end
  end
  for i = next_n, 1, -1 do
    local fn = frame + i
    if fn <= #s.frames then
      blit_tint(flattened(fn), 40, 90, 220, opacity)
    end
  end
  out:drawImage(flattened(frame), Point(0, 0))
  out:saveAs(path)
  return { ok = true, path = path, frame = frame }
end

return DM
