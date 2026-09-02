-- DrawingManager live bridge. Connects to the MCP relay on 127.0.0.1:8765.

local ws
local dlg
local paused = false
local loaded_lib = false

local function status_text(text)
  if dlg then
    dlg:modify{ id = "status", text = text }
  end
end

local function split3(s)
  local a, b, c = s:match("^(.-)\0(.-)\0(.*)$")
  return a, b, c
end

local function send_result(job_id, tbl)
  if not ws then
    return
  end
  local payload = "DM_RESULT\0" .. tostring(job_id) .. "\0" .. DM.encode(tbl)
  ws:sendBinary(payload)
end

local function handle(mt, data, err)
  if mt == WebSocketMessageType.OPEN then
    status_text("connected")
  elseif mt == WebSocketMessageType.CLOSE then
    status_text("disconnected")
  elseif mt == WebSocketMessageType.TEXT or mt == WebSocketMessageType.BINARY then
    local action, title, body = split3(data)
    if not action then
      return
    end
    if action == "hello" then
      if body and body ~= "" then
        dofile(body)
        loaded_lib = true
      end
      status_text("connected (lib ok)")
      return
    end
    if paused then
      send_result(action, { ok = false, error = "paused" })
      return
    end
    if not loaded_lib and body then
      -- wrap_script dofiles the lib itself
    end
    local ok, exec_err = xpcall(function()
      local fn, load_err = load(body, "dm_job", "t")
      if not fn then
        error(load_err)
      end
      fn()
    end, debug.traceback)
    if not DM then
      send_result(action, { ok = false, error = "DM library not loaded" })
      return
    end
    if not ok then
      send_result(action, { ok = false, error = tostring(exec_err) })
    else
      send_result(action, DM._RESULT or { ok = true })
    end
  end
end

local function connect()
  local port = 8765
  local env_port = os.getenv and os.getenv("DM_LIVE_PORT")
  if env_port and env_port ~= "" then
    port = tonumber(env_port) or port
  end
  if ws then
    pcall(function() ws:close() end)
  end
  ws = WebSocket{
    url = "http://127.0.0.1:" .. tostring(port),
    onreceive = handle,
    deflate = false,
  }
  status_text("connecting…")
  ws:connect()
end

function init(plugin)
  plugin:newCommand{
    id = "drawing_manager_connect",
    title = "DrawingManager: Connect",
    group = "file_scripts",
    onclick = function()
      start_ui()
    end,
  }
end

function start_ui()
  if not dlg then
    dlg = Dialog("DrawingManager")
    dlg:label{ id = "status", text = "idle" }
    dlg:check{
      id = "pause",
      text = "Pause",
      selected = false,
      onclick = function()
        paused = dlg.data.pause and true or false
      end,
    }
    dlg:button{ text = "Connect", onclick = connect }
    dlg:button{ text = "Close", onclick = function() dlg:close() end }
    dlg:show{ wait = false }
  end
  connect()
end

function exit(plugin)
  if ws then
    pcall(function() ws:close() end)
  end
end
