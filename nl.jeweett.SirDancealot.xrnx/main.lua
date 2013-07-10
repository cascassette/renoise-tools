-------------------------------------------------------------
-- Dancealot v6 by Cas Marrav (for Renoise 2.8)            --
-------------------------------------------------------------

--[[ TODO
  * search (q) functions for Track, Param fields, analogous to MetaMicro
  * at least 'preset' options for the Filter Type (4Pole,Moog,Bw4n,Bw8n)
  ]]

-- Vars
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

-- Const
-- For native only selection dialog
local NATIVE_SWITCH = "native"

-- Tabs.
local TAB_TRACK = 1
local TAB_EFFECT = 2
local TAB_POSITION = 3
local TAB_ACTIVE = 4
local TAB_PRESET = 5
local DEPRECATED = { "Audio/Effects/Native/*Formula", "Audio/Effects/Native/Stutter", "Audio/Effects/Native/Distortion 1", "Audio/Effects/Native/mpReverb 1", "Audio/Effects/Native/Shaper", "Audio/Effects/Native/LofiMat 1", "Audio/Effects/Native/Filter 1", "Audio/Effects/Native/Filter 2" }


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
  if device_path == "Audio/Effects/Native/#Send" then
    -- #Send to Keep Source, zero Amount, by default when inserted
    device.active_preset_data = [[<?xml version="1.0" encoding="UTF-8"?>
<FilterDevicePreset doc_version="9">
  <DeviceSlot type="SendDevice">
    <IsMaximized>true</IsMaximized>
    <SendAmount>
      <Value>0.0</Value>
    </SendAmount>
    <SendPan>
      <Value>0.5</Value>
    </SendPan>
    <DestSendTrack>
      <Value>0</Value>
    </DestSendTrack>
    <MuteSource>false</MuteSource>
    <SmoothParameterChanges>true</SmoothParameterChanges>
  </DeviceSlot>
</FilterDevicePreset>
]]
  elseif device_path == "Audio/Effects/Native/#Multiband Send" and false then
    device.active_preset_data = [[<?xml version="1.0" encoding="UTF-8"?>
<FilterDeviceClipboard doc_version="0">
  <DeviceSlot type="CrossoverDevice">
    <IsActive>true</IsActive>
    <IsSelected>true</IsSelected>
    <SelectedPresetName>Init</SelectedPresetName>
    <SelectedPresetIsModified>true</SelectedPresetIsModified>
    <IsMaximized>true</IsMaximized>
    <Out1SendAmount>
      <Value>0.0</Value>
      <Visualization>Mixer and Device</Visualization>
    </Out1SendAmount>
    <Out1DestSendTrack>
      <Value>0.0</Value>
      <Visualization>Device only</Visualization>
    </Out1DestSendTrack>
    <Out1MuteSource>false</Out1MuteSource>
    <Out2SendAmount>
      <Value>0.0</Value>
      <Visualization>Mixer and Device</Visualization>
    </Out2SendAmount>
    <Out2DestSendTrack>
      <Value>0.0</Value>
      <Visualization>Device only</Visualization>
    </Out2DestSendTrack>
    <Out2MuteSource>false</Out2MuteSource>
    <Out3SendAmount>
      <Value>0.0</Value>
      <Visualization>Mixer and Device</Visualization>
    </Out3SendAmount>
    <Out3DestSendTrack>
      <Value>0.0</Value>
      <Visualization>Device only</Visualization>
    </Out3DestSendTrack>
    <Out3MuteSource>false</Out3MuteSource>
    <GraphVisible>true</GraphVisible>
    <LowFrequency>
      <Value>0.330993205</Value>
      <Visualization>Device only</Visualization>
    </LowFrequency>
    <HighFrequency>
      <Value>0.783621252</Value>
      <Visualization>Device only</Visualization>
    </HighFrequency>
    <SmoothParameterChanges>true</SmoothParameterChanges>
    <CrossoverType>LR2</CrossoverType>
  </DeviceSlot>
</FilterDeviceClipboard>
    ]]
  elseif device_path == "Audio/Effects/Native/Filter" then
    device.active_preset_data = [[<?xml version="1.0" encoding="UTF-8"?>
<FilterDevicePreset doc_version="9">
  <DeviceSlot type="Filter3Device">
    <IsMaximized>true</IsMaximized>
    <Type>
      <Value>0.0</Value>
    </Type>
    <Frequency>
      <Value>0.5</Value>
    </Frequency>
    <Q>
      <Value>0.0</Value>
    </Q>
    <Gain>
      <Value>-15</Value>
    </Gain>
    <Inertia>
      <Value>0.0078125</Value>
    </Inertia>
    <Model>24dB Moog</Model>
  </DeviceSlot>
</FilterDevicePreset>]]
  elseif device_path == "Audio/Effects/Native/Repeater" then
    device.active_preset_data = [[<?xml version="1.0" encoding="UTF-8"?>
<FilterDevicePreset doc_version="9">
  <DeviceSlot type="RepeaterDevice">
    <IsMaximized>true</IsMaximized>
    <Mode>
      <Value>0.0</Value>
    </Mode>
    <Divisor>
      <Value>0.5</Value>
    </Divisor>
    <Hold>false</Hold>
    <SyncMode>
      <Value>0.0</Value>
    </SyncMode>
  </DeviceSlot>
</FilterDevicePreset>]]
  elseif device_path == "Audio/Effects/Native/EQ 5" then
    device.active_preset_data = [[<?xml version="1.0" encoding="UTF-8"?>
<FilterDevicePreset doc_version="9">
  <DeviceSlot type="Eq5Device">
    <IsMaximized>true</IsMaximized>
    <InputMode>L+R</InputMode>
    <MaxVisualizedGain>6</MaxVisualizedGain>
    <Gain0>
      <Value>0.0</Value>
    </Gain0>
    <Gain1>
      <Value>0.0</Value>
    </Gain1>
    <Gain2>
      <Value>0.0</Value>
    </Gain2>
    <Gain3>
      <Value>0.0</Value>
    </Gain3>
    <Gain4>
      <Value>0.0</Value>
    </Gain4>
    <Frequency0>
      <Value>100</Value>
    </Frequency0>
    <Frequency1>
      <Value>1000</Value>
    </Frequency1>
    <Frequency2>
      <Value>4000</Value>
    </Frequency2>
    <Frequency3>
      <Value>8000</Value>
    </Frequency3>
    <Frequency4>
      <Value>12000</Value>
    </Frequency4>
    <BandWidth0>
      <Value>1.0</Value>
    </BandWidth0>
    <BandWidth1>
      <Value>4</Value>
    </BandWidth1>
    <BandWidth2>
      <Value>4</Value>
    </BandWidth2>
    <BandWidth3>
      <Value>4</Value>
    </BandWidth3>
    <BandWidth4>
      <Value>1.0</Value>
    </BandWidth4>
  </DeviceSlot>
</FilterDevicePreset>]]
  elseif device_path == "Audio/Effects/Native/EQ 10" then
    device.active_preset_data = [[<?xml version="1.0" encoding="UTF-8"?>
<FilterDevicePreset doc_version="9">
  <DeviceSlot type="Eq10Device">
    <IsMaximized>true</IsMaximized>
    <InputMode>L+R</InputMode>
    <MaxVisualizedGain>6</MaxVisualizedGain>
    <Gain0>
      <Value>0.0</Value>
    </Gain0>
    <Gain1>
      <Value>0.0</Value>
    </Gain1>
    <Gain2>
      <Value>0.0</Value>
    </Gain2>
    <Gain3>
      <Value>0.0</Value>
    </Gain3>
    <Gain4>
      <Value>0.0</Value>
    </Gain4>
    <Gain5>
      <Value>0.0</Value>
    </Gain5>
    <Gain6>
      <Value>0.0</Value>
    </Gain6>
    <Gain7>
      <Value>0.0</Value>
    </Gain7>
    <Gain8>
      <Value>0.0</Value>
    </Gain8>
    <Gain9>
      <Value>0.0</Value>
    </Gain9>
    <Frequency0>
      <Value>50</Value>
    </Frequency0>
    <Frequency1>
      <Value>100</Value>
    </Frequency1>
    <Frequency2>
      <Value>300</Value>
    </Frequency2>
    <Frequency3>
      <Value>600</Value>
    </Frequency3>
    <Frequency4>
      <Value>1200</Value>
    </Frequency4>
    <Frequency5>
      <Value>2000</Value>
    </Frequency5>
    <Frequency6>
      <Value>3000.25</Value>
    </Frequency6>
    <Frequency7>
      <Value>5000</Value>
    </Frequency7>
    <Frequency8>
      <Value>10000</Value>
    </Frequency8>
    <Frequency9>
      <Value>15000</Value>
    </Frequency9>
    <BandWidth0>
      <Value>1.0</Value>
    </BandWidth0>
    <BandWidth1>
      <Value>2</Value>
    </BandWidth1>
    <BandWidth2>
      <Value>2</Value>
    </BandWidth2>
    <BandWidth3>
      <Value>2</Value>
    </BandWidth3>
    <BandWidth4>
      <Value>2</Value>
    </BandWidth4>
    <BandWidth5>
      <Value>2</Value>
    </BandWidth5>
    <BandWidth6>
      <Value>2</Value>
    </BandWidth6>
    <BandWidth7>
      <Value>2</Value>
    </BandWidth7>
    <BandWidth8>
      <Value>2</Value>
    </BandWidth8>
    <BandWidth9>
      <Value>1.0</Value>
    </BandWidth9>
  </DeviceSlot>
</FilterDevicePreset>]]
  elseif device_path == "Audio/Effects/VST/NastyDLAmkII" then
    device:parameter(11).value=4/6
  end
  if device.external_editor_available then
    device.external_editor_visible = true
    device.is_maximized = false
  end
end

local function dev_find(query, devices, device_indexes)
  query = query:lower()
  local res_names = table.create()
  local res_indexes = table.create()
  local len = #query
  local c = 1
  for k,v in ipairs(devices) do
    if v:sub(1,len):lower() == query or (v:sub(2,len+1):lower() == query and (v:sub(1,1) == "#" or v:sub(1,1) == "*")) then
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

local function init_avdev(which)
  tracktype = rs.selected_track.type
  avdev = rs.selected_track.available_devices
  if renoise.app().window.lower_frame_is_visible then
    renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
  end
  local NATIVE = (which == NATIVE_SWITCH)
  if NATIVE then
    for i = 1, 38 do
      local s = avdev[i]
      device_names[i] = s:sub(-s:reverse():find("/")+1)
    end
    local i = 39
    for _,dn in ipairs(DEPRECATED) do
      avdev[i] = dn
      device_names[i] = dn:sub(-dn:reverse():find("/")+1)
      i = i + 1
    end
    for uh = i, #avdev do
      avdev[uh] = nil
    end
  else
    for i = 1, #avdev do
      local s = avdev[i]
      device_names[i] = s:sub(-s:reverse():find("/")+1)
    end
  end
end

local function show_dialog(which)    -- 'which' can be "native" for native only
  rs = renoise.song()
  vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  for i,t in ipairs(rs.tracks) do
    track_names[i] = t.name
  end
  
  init_avdev(which)
  
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
