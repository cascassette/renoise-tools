-------------------------------------------------------------
-- MiniTab v1 by Cas Marrav (for Renoise 2.8)              --
-------------------------------------------------------------

-- Main function
-------------------------------------------------------------

local function minitabl()
  local rs=renoise.song()
  local sti = rs.selected_track_index
  local nci = rs.selected_note_column_index
  local eci = rs.selected_effect_column_index
  local nnci
  local neci
  if nci ~= 0 then
    if rs.selected_track.collapsed then
      -- find rightmost column in prev track
      if sti > 1 then
        local fx = true
        if --[[got effect columns]] rs:track(sti-1).visible_effect_columns > 0 then
          neci = rs:track(sti-1).visible_effect_columns
        else
          nnci = rs:track(sti-1).visible_note_columns
          fx = false
        end
        rs.selected_track_index = sti - 1
        if fx then rs.selected_effect_column_index = neci else rs.selected_note_column_index = nnci end
      else
        rs.selected_track_index = #rs.tracks
        rs.selected_effect_column_index = rs.selected_track.visible_effect_columns
      end
    elseif rs.selected_sub_column_type ~= renoise.Song.SUB_COLUMN_NOTE then
      rs.selected_note_column_index = nci
    elseif nci > 1 then
      rs.selected_note_column_index = nci - 1
    else
      -- find rightmost column in prev track
      if sti > 1 then
        local fx = true
        if --[[got effect columns]] rs:track(sti-1).visible_effect_columns > 0 then
          neci = rs:track(sti-1).visible_effect_columns
        else
          nnci = rs:track(sti-1).visible_note_columns
          fx = false
        end
        rs.selected_track_index = sti - 1
        if fx then rs.selected_effect_column_index = neci else rs.selected_note_column_index = nnci end
      else
        rs.selected_track_index = #rs.tracks
        rs.selected_effect_column_index = rs.selected_track.visible_effect_columns
      end
    end
  elseif eci ~= 0 then
    if rs.selected_track.collapsed then
      local fx = true
      if --[[got effect columns]] rs:track(sti-1).visible_effect_columns > 0 then
        neci = rs:track(sti-1).visible_effect_columns
      else
        nnci = rs:track(sti-1).visible_note_columns
        fx = false
      end
      rs.selected_track_index = sti - 1
      if fx then rs.selected_effect_column_index = neci else rs.selected_note_column_index = nnci end
    elseif eci > 1 then
      rs.selected_effect_column_index = eci - 1
    else
      if rs.selected_track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
        rs.selected_note_column_index = rs.selected_track.visible_note_columns
      else
        local fx = true
        if --[[got effect columns]] rs:track(sti-1).visible_effect_columns > 0 then
          neci = rs:track(sti-1).visible_effect_columns
        else
          nnci = rs:track(sti-1).visible_note_columns
          fx = false
        end
        rs.selected_track_index = sti - 1
        if fx then rs.selected_effect_column_index = neci else rs.selected_note_column_index = nnci end
      end
    end
  end
end

local function minitabr()
  local rs=renoise.song()
  local sti = rs.selected_track_index
  local nci = rs.selected_note_column_index
  local eci = rs.selected_effect_column_index
  if rs.selected_track.collapsed then
    rs.selected_track_index = sti + 1
  elseif nci ~= 0 then
    if nci < rs.selected_track.visible_note_columns then
      rs.selected_note_column_index = nci + 1
    else
      if rs.selected_track.visible_effect_columns > 0 then
        rs.selected_effect_column_index = 1
      else
        rs.selected_track_index = sti + 1
      end
    end
  elseif eci ~= 0 then
    if eci < rs.selected_track.visible_effect_columns then
      rs.selected_effect_column_index = eci + 1
    else
      if sti < #rs.tracks then
        rs.selected_track_index = sti + 1
      else
        rs.selected_track_index = 1
      end
    end
  end
end


-- Key Binding
-------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Pattern Editor:Navigation:MiniTab Jump Left",
  invoke = minitabl
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Navigation:MiniTab Jump Right",
  invoke = minitabr
}


-- MIDI Mapping
-------------------------------------------------------------

--[[
renoise.tool():add_midi_mapping {
  name = tool_id..":Show Dialog...",
  invoke = show_dialog
}
--]]



_AUTO_RELOAD_DEBUG = function()
end
