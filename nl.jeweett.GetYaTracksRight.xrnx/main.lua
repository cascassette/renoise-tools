--[[============================================================================
main.lua
============================================================================]]--

--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function track_same()
  local rs = renoise.song()
  local pos = 0
  local ot = rs.selected_track
  local nt = nil
  if ot.type == 1--[[renoise.Track.TRACK_TYPE_SEQUENCER]] then
    pos = rs.selected_track_index+1
    nt = rs:insert_track_at(pos)
    nt.color = ot.color
    nt.color_blend = ot.color_blend
    --nt.volume_column_visible = ot.volume_column_visible
    --nt.panning_column_visible = ot.panning_column_visible
    nt.delay_column_visible = true --ot.delay_column_visible
    nt.visible_note_columns = ot.visible_note_columns
    nt.visible_effect_columns = ot.visible_effect_columns
    nt.name = ot.name
  elseif ot.type == 4 --[[renoise.Track.TRACK_TYPE_GROUP]] then
    pos = rs.selected_track_index
    nt = rs:insert_track_at(pos)
    ot = rs:track(pos-1)
    nt.color = ot.color
    nt.color_blend = ot.color_blend
    nt.delay_column_visible = true
    nt.visible_note_columns = ot.visible_note_columns
    nt.visible_effect_columns = ot.visible_effect_columns
    nt.name = ot.name
  elseif ot.type == 3 --[[renoise.Track.TRACK_TYPE_SEND]] or ot.type == 2 --[[renoise.Track.TRACK_TYPE_MASTER]] then
    pos = rs.selected_track_index+1
    nt = rs:insert_track_at(pos)
    nt.visible_effect_columns = ot.visible_effect_columns
    -- insert send device to submaster
    local send = nt:insert_device_at("Audio/Effects/Native/#Send", 2)
    send:parameter(3).value = rs.send_track_count-1
  end
  rs.selected_track_index = pos
  -- dialog to name it??
end


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Pattern Editor:Track Control:Insert Track Right",
  invoke = track_same
}

renoise.tool():add_keybinding {
  name = "Mixer:Track Control:Insert Track Right",
  invoke = track_same
}


--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

--[[
renoise.tool():add_midi_mapping {
  name = "Tracks Right:Show Dialog...",
  invoke = track_same
}
--]]



-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end
