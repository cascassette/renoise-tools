--[[============================================================================
main.lua
============================================================================]]--

local opts = { 0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64 }

--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

function es_set(mm)
  --oprint(mm)
  local nv = mm.int_value / 128 * 13 + 1
  renoise.song().transport.edit_step = opts[math.floor(nv)]
end

renoise.tool():add_midi_mapping {
  name = "Transport:Edit:Edit Step [Set]",
  invoke = es_set
}

--------------------------------------------------------------------------------
-- Debug / Reload
--------------------------------------------------------------------------------

-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end
