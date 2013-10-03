-------------------------------------------------------------
-- PDub/PCut v0.3 by Cas Marrav (for Renoise 2.8)          --
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
    return true
  else
    --local vb = renoise.ViewBuilder()
    --renoise.app:show_custom_prompt("Fault", vb:text { text = "Did not dub: pattern exceeds max length" }, { "OK" })
    renoise.app:show_status("Failed to PDub: pattern would exceed max length")
    return false
  end
end

local function selectionpdub()
  local rs = renoise.song()
  if rs.sequencer.selection_range[1]==0 and rs.sequencer.selection_range[2]==0 then
    pdub(true)
  else
    local h = {}
    local p
    local c = 0
    for i = rs.sequencer.selection_range[1], rs.sequencer.selection_range[2] do
      p = rs.sequencer:pattern(i)
      if not h[p] then
        rs.selected_sequence_index = i
        if pdub(true) then c = c + 1 end
        h[p] = true
      end
    end
    renoise.app():show_status("Successfully PDubbed "..c.." patterns.")
  end
end

--[[local function pdub_ia()    -- include automation
  local rs = renoise.song()
  local curpat_index = rs.sequencer.pattern_sequence[rs.transport.edit_pos.sequence]
  local curpat = rs:pattern(curpat_index)
  local newpat_index = rs.sequencer:insert_new_pattern_at(curpat_index+1)
  local newpat = rs:pattern(newpat_index)
  newpat.number_of_lines = curpat_number_of_lines
  newpat:copy_from(curpat)
end]]

local function pcut()
  local rs = renoise.song()
  local ep = rs.transport.edit_pos
  local cpi = rs.selected_pattern_index
  local cp = rs.selected_pattern
  local lc = ep.line
  local csi = ep.sequence
  local inserts = {}
  -- think about where to put the 'second halves'
  for i,s in ipairs(rs.sequencer.pattern_sequence) do
    if s == cpi then
      table.insert(inserts, i)
    end
  end
  local first_occ = inserts[1]
  local npi = rs.sequencer:insert_new_pattern_at(first_occ+1)
  local np = rs:pattern(npi)
  np.number_of_lines = cp.number_of_lines+1-lc
  for ti,t in ipairs(np.tracks) do
    for i = lc,cp.number_of_lines do
      t:line(i+1-lc):copy_from(cp:track(ti):line(i))
    end
  end
  cp.number_of_lines = lc-1
  for i,pi in ipairs(inserts) do
    if i > 1 then
      rs.sequencer:insert_sequence_at(pi+i+1,npi)
    end
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
  name = "Pattern Sequencer:Cloning:PDub Selection + Auto",
  invoke = selectionpdub
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
