-------------------------------------------------------------
-- PDub/PCut v0.2 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

-- Main --
local function pdub(include_auto)
  local rs = renoise.song()
  local curpat_index = rs.sequencer:pattern(rs.selected_sequence_index)
  local curpat = rs:pattern(curpat_index)
  local len = curpat.number_of_lines
  local lina = len*256
  local a
  local pt
  if len <= renoise.Pattern.MAX_NUMBER_OF_LINES/2 then
    curpat.number_of_lines = curpat.number_of_lines * 2
    if not curpat.is_empty then
      for ti,t in pairs(curpat.tracks) do
        for li,l in pairs(t.lines) do
          t:line(li+len):copy_from(l)
        end
        if include_auto then
          for di,d in pairs(rs:track(ti).devices) do
            for pi,p in pairs(d.parameters) do
              a = t:find_automation(p)
              if a then
                for api,ap in pairs(a.points) do
                  a:add_point_at(ap.time+len, ap.value)
                end
              end
            end
          end
        end
      end
    end
  else
    local vb = renoise.ViewBuilder()
    renoise.app:show_custom_prompt("Fault", vb:text { text = "Did not dub: pattern exceeds max length" }, { "OK" })
  end
end

local function pdub_ia()    -- include automation
  local rs = renoise.song()
  local curpat_index = rs.sequencer.pattern_sequence[rs.transport.edit_pos.sequence]
  local curpat = rs:pattern(curpat_index)
  local newpat_index = rs.sequencer:insert_new_pattern_at(curpat_index+1)
  local newpat = rs:pattern(newpat_index)
  newpat.number_of_lines = curpat_number_of_lines
  newpat:copy_from(curpat)
end

local function pcut()
  local rs = renoise.song()
  local ep = rs.transport.edit_pos
  local cpi = rs.transport.selected_pattern_index
  local cp = rs.transport.selected_pattern
  local lc = ep.line      -- rs.selected_line_index
  local csi = ep.sequence
  local inserts = table.create()
  -- think about where to put the 'second halves'
  for i,s in ipairs(rs.sequencer.pattern_sequence) do
    if s == cpi then
      inserts.add(i)
    end
  end
  local first_occ = inserts[1]
  local add = 0
  npi = rs.sequencer:insert_new_pattern_at(csi+1)
  for i = lc,cp.number_of_lines do
  end
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:PDub",
  invoke = function() pdub(false) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:PDub + Auto",
  invoke = function() pdub(true) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:PCut",
  invoke = pcut
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:PDub",
  invoke = function() pdub(false) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:PDub + Auto",
  invoke = function() pdub(true) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:PCut",
  invoke = pcut
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
