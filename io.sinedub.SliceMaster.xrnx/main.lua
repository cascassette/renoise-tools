--[[============================================================================
main.lua
============================================================================]]--

--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function re_copy()
  local base = renoise.song().selected_instrument:sample(1)
  local vol = base.volume
  local pan = base.panning
  local txp = base.transpose
  local fit = base.fine_tune
  local nna = base.new_note_action
  local lpm = base.loop_mode
  local ixp = base.interpolation_mode
  local syn = base.beat_sync_lines
  local son = base.beat_sync_enabled
  for i, slice in ipairs(renoise.song().selected_instrument.samples) do
    slice.volume = vol 
    slice.panning = pan 
    slice.transpose = txp 
    slice.fine_tune = fit 
    slice.new_note_action = nna 
    slice.loop_mode = lpm 
    slice.interpolation_mode = ixp 
    slice.beat_sync_lines = syn 
    slice.beat_sync_enabled = son 
  end
end

--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:SliceMaster:ReMaster",
  invoke = re_copy
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







_AUTO_RELOAD_DEBUG = function()
  
end
