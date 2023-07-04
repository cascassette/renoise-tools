-------------------------------------------------------------
-- Lord Of The Things v0.1 by Cas Marrav                   --
-------------------------------------------------------------

local vb = nil
local dialog = nil
local selectdialog = nil
local device = nil
local device_tid = 0
local device_did = 0
local waiting_for_min_or_max = 0
local waiting_for_rowid = 0

local STYLE_UNSELECTED = "panel"
local STYLE_SELECTED = "group"

-- TrackDevice.track_index property
local track_index_property = property(function(self)
  for index, track in ipairs(renoise.song().tracks) do
    for i, device in ipairs(track.devices) do
      if rawequal(self, device) then
        return index
      end
    end
  end
end)
renoise.TrackDevice.track_index = track_index_property
-- TrackDevice.device_index property
local device_index_property = property(function(self)
  for index, track in ipairs(renoise.song().tracks) do
    for i, device in ipairs(track.devices) do
      if rawequal(self, device) then
        return i
      end
    end
  end
end)
renoise.TrackDevice.device_index = device_index_property

-- Math --
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

-- GUI: Event Handlers --
local function chab(val)
  device:parameter(1).value = val
  vb.views['ab'].value = val
  local txt_a, txt_b
  txt_a = tostring(round((1.0-val)*100, 3))
  txt_b = tostring(round(val*100, 3))
  vb.views['txt_a'].text = txt_a
  vb.views['txt_b'].text = txt_b
end
local function selectdialog_close()
  if selectdialog and selectdialog.visible then
    selectdialog:close()
  end
end
local function selectdialog_go()
  local pi = vb.views['selectdialogparam'].value
  local param = renoise.song().selected_device:parameter(pi)
  -- set the min/max value on the hydra first
  local limval = param.value / (param.value_max - param.value_min)
  device:parameter(5*(waiting_for_rowid-1)+5+waiting_for_min_or_max).value = limval
  -- next, on the gui
  if waiting_for_min_or_max == 0 then
    vb.views["s_a"..waiting_for_rowid].value = limval
  else
    vb.views["s_b"..waiting_for_rowid].value = limval
  end
  -- now bind the hydra param on correct row
  device:parameter(5*(waiting_for_rowid-1)+4).value = pi
  vb.views['parsel'..waiting_for_rowid].value = pi+1
  selectdialog_close()
  renoise.song().selected_track_index = device.track_index
  renoise.song().selected_device_index = device.device_index
end
local function selectdevicegui()
  local dev = renoise.song().selected_device
  -- called when a row's A or B button is pressed which does not have a parameter selected yet
  if dev ~= nil then
    local ti = dev.track_index+1
    local di = dev.device_index+1
    if ti == (device.track_index + 1) then
      ti = 1
    end
    -- change hydra row dest. track and device
    device:parameter(5*(waiting_for_rowid-1)+2).value = ti - 2
    device:parameter(5*(waiting_for_rowid-1)+3).value = di - 1
    -- change gui row dest. track and device
    vb.views['trksel'..waiting_for_rowid].value = ti
    vb.views['dspsel'..waiting_for_rowid].value = di
    -- show _modal_ dialog with param select, copy value to either min_or_max
    local pl = {}
    for i, p in ipairs(dev.parameters) do
      pl[i] = p.name
    end
    selectdialog = renoise.app():show_custom_dialog("Parameter select", 
          vb:column {
            vb:popup { id = "selectdialogparam", items = pl },
            vb:row {
              vb:button { text = "OK", notifier = selectdialog_go, },
              vb:button { text = "Cancel", notifier = selectdialog_close, },
            },
          })
  end
  renoise.song().selected_device_observable:remove_notifier(selectdevicegui)
end
local function limbutton(min_or_max, rowid, bulk)
  if device:parameter(5*(rowid-1)+4).value ~= -1 then
    -- find actual device parameter value
    local trksel = device:parameter(5*(rowid-1)+2).value+2
    local dspsel = device:parameter(5*(rowid-1)+3).value+1
    local parsel = device:parameter(5*(rowid-1)+4).value+1
    local trkid = trksel - 1
    if trkid == 0 then
      trkid = device_tid
    end
    local param = renoise.song():track(trkid):device(dspsel):parameter(parsel)
    local limval = param.value / (param.value_max - param.value_min)
    -- bind it to min/max according to which button was pressed
    device:parameter(5*(rowid-1)+5+min_or_max).value = limval
    if min_or_max == 0 then
      vb.views["s_a"..rowid].value = limval
    else
      vb.views["s_b"..rowid].value = limval
    end
  elseif not bulk then
    waiting_for_min_or_max = min_or_max
    waiting_for_rowid = rowid
    if not renoise.song().selected_device_observable:has_notifier(selectdevicegui) then
      renoise.song().selected_device_observable:add_notifier(selectdevicegui)
    end
  end
end
local function chslider(value, min_or_max, rowid)
  device:parameter(5*(rowid-1)+5+min_or_max).value = value
end
local function chtrk(trkid, rowid)
  device:parameter(5*(rowid-1)+2).value = trkid-2
  local dspsel = device:parameter(5*(rowid-1)+3).value+2
  local parsel = device:parameter(5*(rowid-1)+4).value+2
  trkid = trkid - 1
  if trkid == 0 then
    trkid = device.track_index
  end
  local dspnames = {}
  for i, d in ipairs(renoise.song():track(trkid).devices) do
    dspnames[i+1] = d.name
  end
  dspnames[1] = "None"
  vb.views["dspsel"..rowid].value = 1
  vb.views["dspsel"..rowid].items = dspnames
  device:parameter(5*(rowid-1)+3).value = -1
  vb.views["parsel"..rowid].value = 1
  vb.views["parsel"..rowid].items = { "None" }
  device:parameter(5*(rowid-1)+4).value = -1
  vb.views["table_row"..rowid].style = STYLE_UNSELECTED
end
local function chdsp(dspid, rowid)
  device:parameter(5*(rowid-1)+3).value = dspid-2
  local trksel = device:parameter(5*(rowid-1)+2).value+2
  local parsel = device:parameter(5*(rowid-1)+4).value+2
  local trkid = trksel - 1
  if trkid == 0 then
    trkid = device_tid
  end
  dspid = dspid - 1
  local parnames = {}
  if dspid ~= 0 then
    for i, p in ipairs(renoise.song():track(trkid):device(dspid).parameters) do
      parnames[i+1] = p.name
    end
  end
  parnames[1] = "None"
  vb.views["parsel"..rowid].value = 1
  vb.views["parsel"..rowid].items = parnames
  device:parameter(5*(rowid-1)+4).value = -1
  vb.views["table_row"..rowid].style = STYLE_UNSELECTED
end
local function chpar(parid, rowid)
  device:parameter(5*(rowid-1)+4).value = parid-2
  if parid > 1 then
    vb.views["table_row"..rowid].style = STYLE_SELECTED
  end
end

-- GUI: Build Dialog --
local function table_row(number, trknames)
  local num = tostring(number)
  -- find current hydra row's settings
  local trksel = device:parameter(5*(num-1)+2).value+2
  local dspsel = device:parameter(5*(num-1)+3).value+2
  local parsel = device:parameter(5*(num-1)+4).value+2
  local minval = device:parameter(5*(num-1)+5).value
  local maxval = device:parameter(5*(num-1)+6).value
  local s = STYLE_UNSELECTED
  if parsel > 1 then s = STYLE_SELECTED end
  local trkid = trksel - 1
  if trkid == 0 then
    trkid = device_tid
  end
  local dspnames = {}
  for i, d in ipairs(renoise.song():track(trkid).devices) do
    dspnames[i+1] = d.name
  end
  dspnames[1] = "None"
  local dspid = dspsel - 1
  local parnames = {}
  if dspid ~= 0 then
    for i, p in ipairs(renoise.song():track(trkid):device(dspid).parameters) do
      parnames[i+1] = p.name
    end
  end
  parnames[1] = "None"
  -- build gui elements for row with implicit id names for about everything
  return vb:row {
    margin = 5,
    style = s,
    id = "table_row"..num,
    vb:text { text = num..".", width = 20, align = "right" },
    vb:text { text = "TRK" },
    vb:popup {
      id = "trksel"..num,
      items = trknames,
      value = trksel,
      notifier = function(i) chtrk(i, number) end,
    },
    vb:text { text = " DSP" },
    vb:popup {
      id = "dspsel"..num,
      items = dspnames,
      value = dspsel,
      notifier = function(i) chdsp(i, number) end,
    },
    vb:text { text = " PAR" },
    vb:popup {
      id = "parsel"..num,
      items = parnames,
      value = parsel,
      notifier = function(i) chpar(i, number) end,
    },
    vb:button {
      id = "b_a"..num,
      text = "A",
      width = 30,
      notifier = function() limbutton(0, number) end,
    },
    vb:minislider {
      id = "s_a"..num,
      value = minval,
      height = 18,
      notifier = function(i) chslider(i, 0, number) end,
    },
    vb:button {
      id = "b_b"..num,
      text = "B",
      width = 30,
      notifier = function() limbutton(1, number) end,
    },
    vb:minislider {
      id = "s_b"..num,
      value = maxval,
      height = 18,
      notifier = function(i) chslider(i, 1, number) end,
    },
    --[[vb:switch {
      items = { "I", "O" },
      value = 2,
      width = 32,
    },]]
    --[[vb:text { text = "SLOPE" },
    vb:popup { items = { "-LOG", "-EXP", "LIN", "EXP", "LOG" }, value = 3, width = 48 },]]
  }
end
local function manage_hydra()
  local rs = renoise.song()
  if rs.selected_device.device_path == "Audio/Effects/Native/*Hydra" then
    device = rs.selected_device
    device_did = rs.selected_device_index
    device_tid = device.track_index
    vb = renoise.ViewBuilder()
    
    local trknames = {}
    local dspnames = {}
    local parnames = {}
    local cv = .5
    for i, t in ipairs(rs.tracks) do
      trknames[i+1] = t.name
    end
    trknames[1] = "Current"
    for i, d in ipairs(rs.selected_track.devices) do
      dspnames[i+1] = d.name
    end
    dspnames[1] = "None"
    for i, p in ipairs(rs.selected_device.parameters) do
      parnames[i+1] = p.name
    end
    parnames[1] = "None"
    
    cv = device:parameter(1).value
    local txt_a, txt_b
    txt_a = tostring(round((1.0-cv)*100, 3))
    txt_b = tostring(round(cv*100, 3))
    
    local rows = {}
    for i = 1, 9 do
      rows[i] = table_row(i, trknames)
    end
    
    local vb_dialog = vb:column{
      vb:row{
        margin = 5,
        --style = "border",
        width = "100%",
        vb:checkbox { value = device.is_active, notifier = function(b) device.is_active = b end, },
        vb:space { width = 100, },
        vb:button { text = "A", width = 30, notifier = function() for i = 1,9 do limbutton(0, i, true) end end, },
        vb:button { text = "<", width = 30, notifier = function() chab(0) end, },
        vb:text { text = txt_a, width = 30, align = "right", id = "txt_a", },
        vb:minislider { height = 18, width = 100, value = cv, id = "ab", notifier = chab, },
        vb:text { text = txt_b, width = 30, id = "txt_b", },
        vb:button { text = ">", width = 30, notifier = function() chab(1) end, },
        vb:button { text = "B", width = 30, notifier = function() for i = 1,9 do limbutton(1, i, true) end end, },
        --[[vb:space { width = 250 },
        vb:button { text = "Hook All" },
        vb:button { text = "Unhook All" },]]
      },
      rows[1],
      rows[2],
      rows[3],
      rows[4],
      rows[5],
      rows[6],
      rows[7],
      rows[8],
      rows[9],
      vb:row{
        margin = 2, width = "100%",
        style = "border",
        vb:text { text = "  Status: ready" },
      },
    }
    
    if dialog and dialog.visible then
      dialog:close()
    end
    dialog = renoise.app():show_custom_dialog("Lord Of The Things", vb_dialog)
  end
end


-- Menu --
--[[renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Skeleton",
  invoke = x
}]]


-- Keys --
--[[renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Skeleton",
  invoke = x
}]]
renoise.tool():add_keybinding {
  name = "Global:Tools:Manage Hydra..",
  invoke = manage_hydra
}


_AUTO_RELOAD_DEBUG = function()
  
end
