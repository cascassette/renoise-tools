-------------------------------------------------------------
-- Clean Drums v0.01 by Cas Marrav (for Renoise 2.8)       --
-------------------------------------------------------------

-- Main --
local function cleandrums()
  local rs=renoise.song()
  for i,line in ipairs(rs.selected_pattern_track.lines) do
    --print(i, line:note_column(1).note_string)
    for j,col in ipairs(line.note_columns) do
      if col.note_value == 120 then
        col:clear()
      end
    end
  end
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Clean Drums (remove note offs)",
  invoke = cleandrums
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Clean Drums",
  invoke = cleandrums
}


-- Midi --
renoise.tool():add_midi_mapping {
  name = "Tools:Clean Drums",
  invoke = function(mm) if mm.is_trigger() and mm.int_value > 0 then cleandrums() end end
}


_AUTO_RELOAD_DEBUG = function()
  
end
