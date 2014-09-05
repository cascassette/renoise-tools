-------------------------------------------------------------
-- ParamRand v0.1 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

-- DEPRECATED

-- purely for operation with the start-kicksnaremixer-reaktorextended-5.xrns and up

-- vars
local roots = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }
local scales = { "Major", "Minor", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Ionian", "Aeolian", "Locrian", "Blues", "Prometeus", "Enigmatic", "Whole Tone", "6 Tone", "3 semitones", "4 semitones", "Chromatic" }

-- Main: scale callback
local function rtsc_change()
  local rs=renoise.song()
  --[[renoise.app():show_status(
      roots[math.floor(rs:track(rs.sequencer_track_count+1):device(2):parameter(1).value*(#roots-1)+1)] .. " " ..
      scales[math.floor(rs:track(rs.sequencer_track_count+1):device(3):parameter(1).value*(#scales-1)+1)])]]
  print(
      " " .. rs:track(rs.sequencer_track_count+1):device(3):parameter(1).value .. "   " ..
      roots[math.floor(rs:track(rs.sequencer_track_count+1):device(2):parameter(1).value*(#roots-1)+1)] .. " " ..
      scales[math.floor(rs:track(rs.sequencer_track_count+1):device(3):parameter(1).value*(#scales-1)+1)])
end

-- Main: drum shuffler --
local function pr(trk)
  local rs = renoise.song()
  local dev = nil
  for i,d in ipairs(rs:track(trk).devices) do
    if d.display_name == "*Select" then
      dev = d
      break
    end
  end
  if dev ~= nil then
    local p
    for i = 1,4 do
      p = dev:parameter(i)
      dev:parameter(i).value = math.random()*(p.value_max-p.value_min)+p.value_min
    end
  end
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (CT)",
  invoke = function() pr(renoise.song().selected_track_index) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (All)",
  invoke = function()
    for i = 1, renoise.song().sequencer_track_count do
      pr(i) 
    end
  end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (Kick)",
  invoke = function() pr(1) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (Snare)",
  invoke = function() pr(2) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (Hihat)",
  invoke = function() pr(3) end
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (CT)",
  invoke = function() pr(renoise.song().selected_track_index) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (All)",
  invoke = function()
    for i = 1, renoise.song().sequencer_track_count do
      pr(i) 
    end
  end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (Kick)",
  invoke = function() pr(1) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (Snare)",
  invoke = function() pr(2) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (Hihat)",
  invoke = function() pr(3) end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:ParamRand (CT)",
  invoke = function() pr(renoise.song().selected_track_index) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:ParamRand (All)",
  invoke = function()
    for i = 1, renoise.song().sequencer_track_count do
      pr(i) 
    end
  end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:ParamRand (Kick)",
  invoke = function() pr(1) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:ParamRand (Snare)",
  invoke = function() pr(2) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:ParamRand (Hihat)",
  invoke = function() pr(3) end
}


-- Midi --
--[[
renoise.tool():add_midi_mapping {
  name = "Skeleton",
  invoke = x
}
--]]

local function songretypescan()
  local rs = renoise.song()
  local mt = rs:track(rs.sequencer_track_count+1)
  if #mt.devices >= 3 and mt:device(2).display_name == "*Root" and mt:device(3).display_name == "*Scale" then
    if not mt:device(2):parameter(1).value_observable:has_notifier(rtsc_change) then
      mt:device(2):parameter(1).value_observable:add_notifier(rtsc_change)
    end
    if not mt:device(3):parameter(1).value_observable:has_notifier(rtsc_change) then
      mt:device(3):parameter(1).value_observable:add_notifier(rtsc_change)
    end
  end
end

if not renoise.tool().app_new_document_observable:has_notifier(songretypescan) then renoise.tool().app_new_document_observable:add_notifier(songretypescan) end

_AUTO_RELOAD_DEBUG = function()
  songretypescan()
end
