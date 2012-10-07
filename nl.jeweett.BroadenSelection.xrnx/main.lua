-------------------------------------------------------------
-- Broaden Selection v0.1 by Cas Marrav (for Renoise 2.8)  --
-------------------------------------------------------------

function set_selection_bounds_h(l, r, solo)
  local rs = renoise.song()
  if rs.selection_in_pattern then
    if not solo then rs:describe_undo("Broaden selection") else rs:describe_undo("Note solo") end
    local oldsel = rs.selection_in_pattern
    
    local nl = oldsel.start_track
    local nlc = oldsel.start_column
    local nr = oldsel.end_track
    local nrc = oldsel.end_column
    if l then nl = l nlc = 1 end
    if r then nr = r nrc = rs:track(nr).visible_note_columns+rs:track(nr).visible_effect_columns end
    
    if solo then
      local pat = rs:pattern(rs.sequencer:pattern(rs.transport.edit_pos.sequence))
      for i = nl, nr do
        if rs:track(i).type == 2 then break end
        if i ~= rs.selected_track_index then
          local ct = rs:track(i)
          if ct.type == 1 then
            for j = 1, ct.visible_note_columns do
              local nc = pat:track(i):line(oldsel.start_line):note_column(j)
              nc.note_value = 120
              nc.instrument_string = ""
              nc.volume_string = ""
              nc.panning_string = ""
              nc.delay_string = ""
              for k = oldsel.start_line + 1, oldsel.end_line do
                nc = pat:track(i):line(k):note_column(j)
                nc.note_string = ""
                nc.instrument_string = ""
                nc.volume_string = ""
                nc.panning_string = ""
                nc.delay_string = ""
              end
            end
          end
        end
      end
    else
      local ns = { start_line = oldsel.start_line,
             start_track = nl,
             start_column = nrc,
             end_line = oldsel.end_line,
             end_track = nr,
             end_column = nlc }
      rs.selection_in_pattern = ns
    end
  end
end


-------------------------------------------------------------
-- Key Binding                                             --
-------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Tools:Broaden selection to the right",
  invoke = function() set_selection_bounds_h(nil, #renoise.song().tracks, false) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:Broaden selection to the left",
  invoke = function() set_selection_bounds_h(1, nil, false) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:Broaden selection left to right",
  invoke = function() set_selection_bounds_h(1, #renoise.song().tracks, false) end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Note solo to the right",
  invoke = function() set_selection_bounds_h(nil, #renoise.song().tracks, true) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:Note solo to the left",
  invoke = function() set_selection_bounds_h(1, nil, true) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:Note solo left to right",
  invoke = function() set_selection_bounds_h(1,  #renoise.song().tracks, true) end
}



_AUTO_RELOAD_DEBUG = function()
  
end
