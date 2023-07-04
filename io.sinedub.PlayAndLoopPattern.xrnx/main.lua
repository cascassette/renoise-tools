--[[============================================================================
--                      Play And Loop Pattern                                 --
============================================================================]]--

-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end


--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function play_pattern()
  local rs = renoise.song()
  if rs.transport.playing then
    rs.transport.loop_pattern = not rs.transport.loop_pattern
  else
    rs.transport.loop_pattern = true
    rs.transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
    rs.transport.loop_pattern = true
  end
end


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Transport:Play & Loop Pattern",
  invoke = play_pattern
}


--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

renoise.tool():add_midi_mapping {
  name = "Transport:Playback:Play & Loop Pattern [Trigger+Toggle]",
  invoke = function(mm)
    if mm:is_trigger() then play_pattern() end
  end
}
