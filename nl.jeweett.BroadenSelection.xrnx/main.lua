-------------------------------------------------------------
-- Broaden Selection v0.1 by Cas Marrav (for Renoise 2.8)    --
-------------------------------------------------------------

function set_selection_bounds_h(l, r)
  local rs = renoise.song()
  if rs.selection_in_pattern then
    local oldsel = rs.selection_in_pattern
    
    local nl = oldsel.start_track
    local nlc = oldsel.start_column
    local nr = oldsel.end_track
    local nrc = oldsel.end_column
    local ns = nil
    if l then nl = l nlc = 1 end
    if r then nr = r nrc = rs:track(nr).visible_note_columns+rs:track(nr).visible_effect_columns end
    
    ns = { start_line = oldsel.start_line,
           start_track = nl,
           start_column = nrc,
           end_line = oldsel.end_line,
           end_track = nr,
           end_column = nlc }
           
    rs.selection_in_pattern = ns
  end
end


-------------------------------------------------------------
-- Key Binding                                             --
-------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Tools:Broaden selection to the right",
  invoke = function() set_selection_bounds_h(nil, #renoise.song().tracks) end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Broaden selection to the left",
  invoke = function() set_selection_bounds_h(1, nil) end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Broaden selection left to right",
  invoke = function() set_selection_bounds_h(1, #renoise.song().tracks) end
}




_AUTO_RELOAD_DEBUG = function()
  
end
