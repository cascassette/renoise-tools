-------------------------------------------------------------
-- PDub v0.1 by Cas Marrav (for Renoise 2.8)               --
-------------------------------------------------------------

-- Main --
local function pdub()
  local rs = renoise.song()
  local curpat_index = rs.sequencer.pattern_sequence[rs.transport.edit_pos.sequence]
  local curpat = rs:pattern(curpat_index)
  local len = curpat.number_of_lines
  if len <= renoise.Pattern.MAX_NUMBER_OF_LINES/2 then
    curpat.number_of_lines = curpat.number_of_lines * 2
    if not curpat.is_empty then
      for _,t in pairs(curpat.tracks) do
        --t:lines_in_range(len+1, 2*len) = t:lines_in_range(1, len)
        for i,l in pairs(t.lines) do
          t:line(i+len):copy_from(l)
        end
      end
    end
  else
    local vb = renoise.ViewBuilder()
    renoise.app:show_custom_prompt("Fault", vb:text { text = "Did not dub: pattern exceeds max length" }, { "OK" })
  end
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:PDub",
  invoke = pdub
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Global:Tools:PDub",
  invoke = pdub
}


-- Midi --
--[[
renoise.tool():add_midi_mapping {
  name = "PDub",
  invoke = pdub
}
--]]


_AUTO_RELOAD_DEBUG = function()
  
end
