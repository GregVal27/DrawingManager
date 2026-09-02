-- Demon 96: pose + paint tags. Still (frame 1) painted separately.
-- Idle: copy still paint → shift_rect / rotate_pixels NN → 1px brush.
-- Do not call paint_demon_96_all (walk) without user «ок».

local function vis(name, v)
  pcall(function()
    DM.find_layer(name).isVisible = v
  end)
end

local function hide_pose_show_paint()
  vis("paint", true)
  vis("line", true)
  vis("color", true)
  vis("shade", true)
  vis("fx", true)
  vis("skeleton", false)
  vis("volume", false)
  vis("_tmp", false)
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
    vis(n, false)
  end
end

function demon_96_anim_keys()
  return {
    idle = {
      { body_dy = 1, hump_extra = 0, chest_extra = 0, jaw_dy = 0, tail_dx = 0, tail_dy = 1, tail_ang = 5, horn_ang = 4, plant_n = true, plant_f = true },
      { body_dy = -2, hump_extra = -1, chest_extra = -1, jaw_dy = 1, tail_dx = -1, tail_dy = 0, tail_ang = -5, horn_ang = -6, spec = true, plant_n = true, plant_f = true },
      { body_dy = -1, hump_extra = -1, chest_extra = 0, jaw_dy = 2, tail_dx = -1, tail_dy = -1, tail_ang = -8, horn_ang = -4, lid = true, plant_n = true, plant_f = true },
      { body_dy = 2, hump_extra = 1, chest_extra = 1, jaw_dy = 1, tail_dx = 1, tail_dy = 1, tail_ang = 6, horn_ang = 5, plant_n = true, plant_f = true },
    },
    walk = {
      { nlx = 6, nly = 0, flx = -5, fly = 0, by = 0, nax = -3, fax = 2, hx = 1, tail_bx = -1, plant_n = true, plant_f = true },
      { nlx = 5, nly = 0, flx = -4, fly = -5, by = 1, nax = -4, nay = 1, fax = 3, fay = -1, hx = 1, plant_n = true, plant_f = false },
      { nlx = 2, nly = 0, flx = 1, fly = -3, by = 0, nax = -1, fax = 1, plant_n = true, plant_f = false },
      { nlx = -3, nly = 0, flx = 5, fly = -8, by = -1, nax = 2, nay = -1, fax = -2, hx = -1, plant_n = true, plant_f = false },
      { nlx = -6, nly = 0, flx = 6, fly = 0, by = 0, nax = 3, fax = -3, hx = -1, tail_bx = 1, plant_n = true, plant_f = true },
      { nlx = -5, nly = -5, flx = 5, fly = 0, by = 1, nax = 4, nay = -1, fax = -4, fay = 1, hx = -1, plant_n = false, plant_f = true },
      { nlx = 0, nly = -3, flx = 2, fly = 0, by = 0, nax = 1, fax = -1, plant_n = false, plant_f = true },
      { nlx = 5, nly = -8, flx = -3, fly = 0, by = -1, nax = -2, fax = 2, hx = 1, plant_n = false, plant_f = true },
    },
    run = {
      { nlx = 4, nly = -10, flx = -6, fly = -12, by = -3, nax = -5, fax = 4, hx = 2, plant_n = false, plant_f = false },
      { nlx = 7, nly = -4, flx = -8, fly = -6, by = -1, nax = -4, fax = 3, hx = 2, plant_n = false, plant_f = false },
      { nlx = 8, nly = 0, flx = -7, fly = -2, by = 2, nax = -6, fax = 4, hx = 1, plant_n = true, plant_f = false },
      { nlx = 1, nly = -2, flx = -1, fly = -4, by = 0, hx = 0, plant_n = false, plant_f = false },
      { nlx = -6, nly = -12, flx = 4, fly = -10, by = -3, nax = 5, fax = -4, hx = -2, plant_n = false, plant_f = false },
      { nlx = -8, nly = -6, flx = 7, fly = -4, by = -1, nax = 4, fax = -3, hx = -2, plant_n = false, plant_f = false },
      { nlx = -7, nly = -2, flx = 8, fly = 0, by = 2, nax = 6, fax = -4, hx = -1, plant_n = false, plant_f = true },
      { nlx = -1, nly = -4, flx = 1, fly = -2, by = 0, plant_n = false, plant_f = false },
    },
    attack = {
      { bx = 6, by = 1, nax = 10, nay = 2, hdx = 4, hdy = 1, hx = 2, smear = true, claw = true, plant_n = true, plant_f = true },
      { bx = 8, by = 0, nax = 12, nay = 1, hdx = 5, hx = 3, smear = true, claw = true, plant_n = true, plant_f = true },
      { bx = 5, by = 0, nax = 6, nay = 1, hdx = 2, plant_n = true, plant_f = true },
      { bx = 3, nax = 3, hdx = 1, plant_n = true, plant_f = true },
      { bx = 1, nax = 1, plant_n = true, plant_f = true },
      { bx = 0, plant_n = true, plant_f = true },
    },
    jump = {
      { by = 2, nax = -2, fax = 1, plant_n = true, plant_f = true },
      { by = -8, nly = -6, fly = -5, nax = 3, fax = -3, hdy = -2, plant_n = false, plant_f = false },
      { by = -11, nly = -4, fly = -8, nax = -4, fax = 4, hdy = -3, tail_by = -14, plant_n = false, plant_f = false },
    },
    fall = {
      { by = -6, hdy = 3, tail_by = -12, nly = -6, fly = -5, plant_n = false, plant_f = false },
      { by = -3, hdy = 4, tail_by = -14, nly = -5, fly = -4, plant_n = false, plant_f = false },
      { by = 2, hdy = 5, tail_by = -10, nly = -2, fly = -2, plant_n = false, plant_f = false },
    },
    hurt = {
      { bx = -10, by = -2, nax = -4, hdx = -3, tail_by = -4, plant_n = true, plant_f = true },
      { bx = -6, by = 0, nax = -2, hdx = -1, plant_n = true, plant_f = true },
      { bx = -3, by = 1, plant_n = true, plant_f = true },
      { bx = -1, by = 0, plant_n = true, plant_f = true },
    },
    die = {
      { bx = -10, by = -2, nax = -4, hdx = -3, plant_n = true, plant_f = true },
      { bx = -8, by = 3, nax = -3, jaw_by = 1, tail_by = 2, plant_n = true, plant_f = true },
      { bx = -6, by = 6, nax = -2, jaw_by = 2, tail_by = 4, hdy = 2, plant_n = true, plant_f = true },
      { bx = -4, by = 9, nax = -1, jaw_by = 3, tail_by = 6, hdy = 3, plant_n = true, plant_f = true },
      { bx = -3, by = 11, jaw_by = 4, tail_by = 7, hdy = 4, plant_n = true, plant_f = true },
      { bx = -2, by = 12, jaw_by = 5, tail_by = 8, hdy = 4, plant_n = true, plant_f = true },
    },
  }
end

local TAGS = {
  { name = "idle", from = 2 },
  { name = "walk", from = 6 },
  { name = "run", from = 14 },
  { name = "attack", from = 22 },
  { name = "jump", from = 28 },
  { name = "fall", from = 31 },
  { name = "hurt", from = 34 },
  { name = "die", from = 38 },
}

function pose_demon_96_all()
  local keys = demon_96_anim_keys()
  for _, tag in ipairs(TAGS) do
    local list = keys[tag.name]
    for i, o in ipairs(list) do
      pose_demon_96_at(tag.from + i - 1, o)
    end
  end
end

function paint_demon_96_all()
  local keys = demon_96_anim_keys()
  local painted = {}
  for _, tag in ipairs(TAGS) do
    local list = keys[tag.name]
    for i, o in ipairs(list) do
      local f = tag.from + i - 1
      paint_demon_96_at(f, o)
      painted[#painted + 1] = f
    end
  end
  hide_pose_show_paint()
  DM.result({ ok = true, pass = "paint_all", frames = painted })
end

local PAINT_LAYERS = { "line", "color", "shade", "fx" }
local HOOF_Y = 86

local function cel_has_opaque(layer_name, frame)
  local ok, has = pcall(function()
    DM.use(layer_name, frame)
    local img = DM.canvas()
    local s = DM.sprite()
    for y = 0, s.height - 1 do
      for x = 0, s.width - 1 do
        if Color(img:getPixel(x, y)).alpha > 0 then
          return true
        end
      end
    end
    return false
  end)
  return ok and has
end

local function each_paint(frame, fn)
  for _, name in ipairs(PAINT_LAYERS) do
    fn(name, frame)
  end
end

function paint_demon_96_idle()
  if not cel_has_opaque("color", 1) then
    paint_demon_96()
  end
  for f = 2, 5 do
    DM.copy_cels(1, f, PAINT_LAYERS)
  end
  local keys = demon_96_anim_keys().idle
  local painted = {}
  for i, o in ipairs(keys) do
    local f = 1 + i
    local by = o.body_dy or 0
    each_paint(f, function(layer)
      DM.shift_rect(layer, f, 0, 0, 96, HOOF_Y, 0, by)
    end)
    local hx = o.hump_extra or 0
    if hx ~= 0 then
      each_paint(f, function(layer)
        DM.shift_rect(layer, f, 24, 16 + by, 20, 20, 0, hx)
      end)
    end
    local ch = o.chest_extra or 0
    if ch ~= 0 then
      each_paint(f, function(layer)
        DM.shift_rect(layer, f, 36, 38 + by, 20, 14, 0, ch)
      end)
    end
    local jy = o.jaw_dy or 0
    if jy ~= 0 then
      each_paint(f, function(layer)
        DM.shift_rect(layer, f, 68, 49 + by, 18, 8, 0, jy)
      end)
    end
    local tdx = o.tail_dx or 0
    local tdy = o.tail_dy or 0
    if tdx ~= 0 or tdy ~= 0 then
      each_paint(f, function(layer)
        DM.shift_rect(layer, f, 5, 56 + by, 32, 26, tdx, tdy)
      end)
    end
    local tang = o.tail_ang or 0
    if tang ~= 0 then
      local tcx, tcy = 34, 59 + by + tdy
      each_paint(f, function(layer)
        DM.rotate_pixels(layer, f, tcx, tcy, tang, 24)
      end)
    end
    local hang = o.horn_ang or 0
    if hang ~= 0 then
      local hcx, hcy = 62, 38 + by
      each_paint(f, function(layer)
        DM.rotate_pixels(layer, f, hcx, hcy, hang, 34)
      end)
    end
    paint_idle_hybrid_brush(f, o)
    painted[#painted + 1] = f
  end
  hide_pose_show_paint()
  DM.result({ ok = true, pass = "paint_idle_hybrid", frames = painted })
end

function pose_and_paint_demon_96_all()
  pose_demon_96_all()
  paint_demon_96_all()
end
