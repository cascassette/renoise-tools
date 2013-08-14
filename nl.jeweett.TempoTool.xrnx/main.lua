-------------------------------------------------------------
-- TempoTool v0.1 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

local SEMITONE_FACTOR = (2^(1/12))

-- Main --
local function tempotool()
  local rs = renoise.song()
  local smp = rs.selected_sample
  local sr = smp.sample_buffer.sample_rate
  local dur
  if smp.loop_mode ~= 1 then
    dur = (smp.loop_end-smp.loop_start)/sr
  else
    dur = (smp.number_of_frames)/sr
  end
  dur = (dur / 60)    -- convert to minutes
  dur = dur*(SEMITONE_FACTOR^(-smp.transpose))
  local beatcount = smp.beat_sync_lines/rs.transport.lpb
  local bpm = beatcount/dur
  rs.transport.bpm = bpm
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Sample Editor:\nAdjust Tempo to Sample/Loop\n",
  invoke = tempotool
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:Adjust Tempo to Sample/Loop",
  invoke = tempotool
}


-- Midi --
--[[
renoise.tool():add_midi_mapping {
  name = "Skeleton",
  invoke = x
}
--]]


_AUTO_RELOAD_DEBUG = function()
  
end
