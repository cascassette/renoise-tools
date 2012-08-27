-------------------------------------------------------------
-- Auto Insert Inst v0.1 by Cas Marrav (for Renoise 2.8)   --
-------------------------------------------------------------


-- Main --
local function plus()
  local rs = renoise.song()
  local sti = rs.selected_instrument_index
  if sti < #rs.instruments then
    rs.selected_instrument_index = sti + 1
  elseif rs:instrument(sti):sample(1).sample_buffer.has_sample_data then
    rs:insert_instrument_at(sti + 1)
    rs.selected_instrument_index = sti + 1
  end
end

local function minus()
  local rs = renoise.song()
  local sti = rs.selected_instrument_index
  if sti > 1 then
    rs.selected_instrument_index = sti - 1
    if sti == #rs.instruments and not rs:instrument(sti):sample(1).sample_buffer.has_sample_data then
      rs:delete_instrument_at(sti)
    end
  end
end


-- Keys --
renoise.tool():add_keybinding {
  name = "Global:Instruments:Select or add Next Instrument",
  invoke = plus
}
renoise.tool():add_keybinding {
  name = "Global:Instruments:Select or remove Prev. Instrument",
  invoke = minus
}


-- Midi --
--[[
renoise.tool():add_midi_mapping {
  name = tool_id..":Show Dialog...",
  invoke = show_dialog
}
]]

_AUTO_RELOAD_DEBUG = function()
  
end
