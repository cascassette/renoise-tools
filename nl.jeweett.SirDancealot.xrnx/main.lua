-------------------------------------------------------------
-- Dancealot v2.0 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

local dialog = nil
local vb = nil

-- Renoise.Song thingy that you use all the time
local rs = nil

-- Dialog sub stuff
local vtrk = nil   -- Track select
local vdsp = nil   -- DSP select
local vpos = nil   -- Position (after a certain dsp)
local vact = nil   -- Active
local vpre = nil   -- Preset (not possible right now)

local vtab = nil   -- Left/Right category select

local vinfotxt = nil
local vqtxt = nil

local avdev = nil
local track_names = {}
local device_names = {}
local position_names = {}

local q=""
local found_subset = {}
local found_subset_indexes = {}

local tracktype = nil

-- For native only selection dialog
local NATIVE_SWITCH = "native"

-- Tabs.
local TAB_TRACK = 1
local TAB_EFFECT = 2
local TAB_POSITION = 3
local TAB_ACTIVE = 4
local TAB_PRESET = 5


--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function insertfx(track_no, device_path, insert_spot, active, preset_no)
  -- DEBUG
  --[[
  local active_str = "yes"
  if not active then active_str = "no" end
  rprint( "track_no: " .. track_no )
  rprint( "device_path: " .. device_path )
  rprint( "insert_spot: " .. insert_spot )
  rprint( "active: " .. active_str )
  rprint( "preset_no: " .. preset_no )
  --]]
  
  rs = renoise.song()
  local device = rs:track(track_no):insert_device_at(device_path, insert_spot+1)
  if not active then
    device.is_active = false
  end
end

local function dev_find(query, devices, device_indexes)
  query = query:lower()
  local res_names = table.create()
  local res_indexes = table.create()
  local len = #query
  local c = 1
  for k,v in ipairs(devices) do
    if v:sub(1,len):lower() == query then
      res_names[c] = v
      res_indexes[c] = device_indexes[k]
      c = c + 1
    end
  end
  return res_names, res_indexes
end


--------------------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------------------

local function updateinfo()
  -- update info txt
  local actstr = ""
  if not vact.value then actstr = " and instantly deactivate it" end
  vinfotxt.text = "Insert a " .. device_names[found_subset_indexes[vdsp.value]] .. " on track# " .. vtrk.value .. " " .. track_names[vtrk.value] .. " at pos " .. vpos.value .. " (after " .. position_names[vpos.value] .. ")" .. actstr .. "?"
  vqtxt.text = q
end

local function key_dialog(d, k)
  local tab = vtab.value
  if k.name == "esc" then
    d:close()
  elseif k.name == "down" then
    if tab == 1 then
      local nv = vtrk.value + 1
      if nv > #rs.tracks then nv = 1 end
      vtrk.value = nv
      if rs:track(vtrk.value).type ~= tracktype then
        -- TODO: refresh avdev and positions
      end
    elseif tab == 2 then
      vdsp.value = math.min(vdsp.value + 1, #vdsp.items)
    elseif tab == 3 then
      vpos.value = math.min(vpos.value + 1, #rs.selected_track.devices)
    elseif tab == 4 then
      vact.value = not vact.value
    elseif tab == 5 then
    end
  elseif k.name == "up" then
    if tab == 1 then
      local nv = vtrk.value - 1
      if nv < 1 then nv = #rs.tracks end
      vtrk.value = nv
      if rs:track(vtrk.value).type ~= tracktype then
        -- TODO: refresh avdev and positions
      end
    elseif tab == 2 then
      vdsp.value = math.max(vdsp.value - 1, 1)
    elseif tab == 3 then
      vpos.value = math.max(vpos.value - 1, 1)
    elseif tab == 4 then
      vact.value = not vact.value
    elseif tab == 5 then
    end
  elseif k.name == "left" then
    if vtab.value > 1 then
      vtab.value = tab - 1
    else vtab.value = #vtab.items
    end
  elseif k.name == "right" then
    if vtab.value < #vtab.items then
      vtab.value = tab + 1
    else vtab.value = 1
    end
  elseif k.name == "space" then
    vact.value = not vact.value
  elseif k.name == "return" then
    insertfx(vtrk.value, avdev[found_subset_indexes[vdsp.value]], vpos.value, vact.value, vpre.value)
    d:close()
  elseif k.name == "back" then
    local len = #q - 1
    if len >= 0 then
      q = q:sub(1,len)
      found_subset = device_names
      for i = 1, #device_names do found_subset_indexes[i] = i end
      found_subset, found_subset_indexes = dev_find(q, found_subset, found_subset_indexes)
      vdsp.items = found_subset
      vdsp.value = 1
    end
  elseif k.name == "del" then
    q = ""
    found_subset = device_names
    for i = 1, #device_names do found_subset_indexes[i] = i end
    vdsp.items = found_subset
    vdsp.value = 1
  elseif k.character ~= nil then
    local nuq = q .. k.character
    local nu_found_subset, nu_found_subset_indexes
    nu_found_subset, nu_found_subset_indexes = dev_find(nuq, found_subset, found_subset_indexes)
    if #nu_found_subset > 0 then
      found_subset = nu_found_subset
      found_subset_indexes = nu_found_subset_indexes
      vdsp.items = found_subset
      q = nuq
      vdsp.value = 1
    end
  else
  end
  updateinfo()
end

local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function show_dialog(which)    -- 'which' can be "native" for native only
  rs = renoise.song()
  vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  local NATIVE = (which == NATIVE_SWITCH)
  
  for i,t in ipairs(rs.tracks) do
    track_names[i] = t.name
  end
  
  tracktype = rs.selected_track.type
  avdev = rs.selected_track.available_devices
  if NATIVE then
    for i = 1, 38 do
      local s = avdev[i]
      device_names[i] = s:sub(-s:reverse():find("/")+1)
    end
  else
    for i = 1, #avdev do
      local s = avdev[i]
      device_names[i] = s:sub(-s:reverse():find("/")+1)
    end
  end
  
  local positions = #rs.selected_track.devices
  for i = 1, positions do
    position_names[i] = rs.selected_track:device(i).display_name
  end
  
  q = ""
  found_subset = device_names
  for i = 1, #device_names do found_subset_indexes[i] = i end
  
  vtab = vb:switch {
    width = "100%",
    items = { "Track", "Effect", "After", "Active", "Preset" },
    value = TAB_EFFECT,
  }
  vtrk = vb:popup {
    width = 100,
    items = track_names,
    value = rs.selected_track_index,
  }
  vdsp = vb:popup {
    width = 100,
    items = device_names,
    value = 1,
  }
  vpos = vb:popup {
    width = 100,
    items = position_names,
    value = math.max(rs.selected_device_index, 1),
  }
  vact = vb:checkbox {
    width = 100,
    value = true,
  }
  vpre = vb:popup {
    width = 100,
    items = { "Init" },
    active = false,
  }
  
  vinfotxt = vb:text { text = "Info", width = "100%", }
  vqtxt = vb:text { text = "" }
  
  local dialog_content =
    vb:column {
      margin = DDM, spacing = CS,
      vb:horizontal_aligner {
        margin = DDM, spacing = CS, width = "100%",
        vtab
      },
      vb:row {
        style = "border",
        margin = DDM, spacing = CS,
        vb:vertical_aligner {
          vtrk,
        },
        vb:vertical_aligner {
          vdsp,
        },
        vb:vertical_aligner {
          vpos,
        },
        vb:vertical_aligner {
          vact,
        },
        vb:vertical_aligner {
          vpre,
        },
      },
      vb:row {
        style = "border",
        margin = DDM, spacing = CS, width = "100%",
        vinfotxt,
      },
      vb:horizontal_aligner {
        mode = "right",
        margin = 2, spacing = 0, width = "100%", height = 16,
        vqtxt,
      }
    }
    
  close_dialog()
  dialog = renoise.app():show_custom_dialog("Insert FX",
                   dialog_content, key_dialog)
  updateinfo()
end


--------------------------------------------------------------------------------
-- Menu entries
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:KB Insert FX...",
  invoke = show_dialog  
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:KB Insert FX (Native only)...",
  invoke = function() show_dialog(NATIVE_SWITCH) end  
}


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Tools:Dancealot KB Insert FX...",
  invoke = show_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Dancealot KB Insert FX (Native only)...",
  invoke = function() show_dialog(NATIVE_SWITCH) end
}


--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

--[[
renoise.tool():add_midi_mapping {
  name = tool_id..":Show Dialog...",
  invoke = show_dialog
}
--]]













-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end
