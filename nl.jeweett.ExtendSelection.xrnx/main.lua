-------------------------------------------------------------
-- Extend Selection v0.3 by Cas Marrav (for Renoise 2.8)   --
-------------------------------------------------------------

function set_selection_bounds_h(l, r, lc, rc, solo)
  local rs = renoise.song()
  if rs.selection_in_pattern then
    if not solo then rs:describe_undo("Extend selection") else rs:describe_undo("Note solo") end
    local oldsel = rs.selection_in_pattern
    
    local nl = oldsel.start_track
    local nlc = oldsel.start_column
    local nr = oldsel.end_track
    local nrc = oldsel.end_column
    if l then
      nl = l
      if lc then nlc = lc else nlc = 1 end
    end
    if r then
      nr = r
      if rc then nrc = rc else nrc = rs:track(nr).visible_note_columns+rs:track(nr).visible_effect_columns end
    end
    
    if solo==1 then
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
    elseif solo==2 then
      local pat = rs:pattern(rs.sequencer:pattern(rs.transport.edit_pos.sequence))
      for i = nl, nr do
        if rs:track(i).type == 2 then break end
        if i ~= rs.selected_track_index then
          local ct = rs:track(i)
          if ct.type == 1 then
            for j = 1, ct.visible_note_columns do
              local nc = pat:track(i):line(oldsel.start_line):note_column(j)
              --nc.note_value = 120
              nc.note_string = ""
              nc.instrument_string = ""
              nc.volume_string = "00"
              nc.panning_string = ""
              nc.delay_string = ""
              for k = oldsel.start_line + 1, oldsel.end_line do
                nc = pat:track(i):line(k):note_column(j)
                nc.note_string = ""
                nc.instrument_string = ""
                nc.volume_string = "00"
                nc.panning_string = ""
                nc.delay_string = ""
              end
              nc.volume_string = "80"
            end
          end
        end
      end
    else
      local ns = { start_line = oldsel.start_line,
             start_track = nl,
             start_column = nlc,
             end_line = oldsel.end_line,
             end_track = nr,
             end_column = nrc }
      rs.selection_in_pattern = ns
    end
  end
end

function set_selection_bounds_v(t, b)
  local rs = renoise.song()
  if rs.selection_in_pattern then
    rs:describe_undo("Extend selection")
    local oldsel = rs.selection_in_pattern
    
    local nt = oldsel.start_line
    local nb = oldsel.end_line
    if t then nt = t end
    if b then nb = b end
    local ns = { start_line = nt,
           start_track = oldsel.start_track,
           start_column = oldsel.start_column,
           end_line = nb,
           end_track = oldsel.end_track,
           end_column = oldsel.end_column }
    rs.selection_in_pattern = ns
  end
end


-------------------------------------------------------------
-- Key Binding                                             --
-------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Extend selection to the right",
  invoke = function() set_selection_bounds_h(nil, #renoise.song().tracks, nil, nil, 0) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Extend selection to the left",
  invoke = function() set_selection_bounds_h(1, nil, nil, nil, 0) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Extend selection left to right",
  invoke = function() set_selection_bounds_h(1, #renoise.song().tracks, nil, nil, 0) end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Note solo to the right",
  invoke = function() set_selection_bounds_h(nil, #renoise.song().tracks, nil, nil, 1) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Note solo to the left",
  invoke = function() set_selection_bounds_h(1, nil, nil, nil, 1) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Note solo left to right",
  invoke = function() set_selection_bounds_h(1,  #renoise.song().tracks, nil, nil, 1) end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:NoteVol solo to the right",
  invoke = function() set_selection_bounds_h(nil, #renoise.song().tracks, nil, nil, 2) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:NoteVol solo to the left",
  invoke = function() set_selection_bounds_h(1, nil, nil, nil, 2) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:NoteVol solo left to right",
  invoke = function() set_selection_bounds_h(1,  #renoise.song().tracks, nil, nil, 2) end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Extend selection to current track",
  invoke = function()
    local ci = renoise.song().selected_track_index
    local os = renoise.song().selection_in_pattern
    local olt = os.start_track
    local ort = os.end_track
    if ci <= olt then set_selection_bounds_h(ci, nil, nil, nil, 0)
    elseif ci >= ort then set_selection_bounds_h(nil, ci, nil, nil, 0) end
  end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Extend selection to current column",
  invoke = function()
    local cti = renoise.song().selected_track_index
    local cci = renoise.song().selected_note_column_index+renoise.song().selected_effect_column_index
    local os = renoise.song().selection_in_pattern
    local olt = os.start_track
    local olc = os.start_column
    local ort = os.end_track
    local orc = os.end_column
    if cti < olt or cci < olc then set_selection_bounds_h(cti, nil, cci, nil, 0)
    elseif cti > ort or cci > orc then set_selection_bounds_h(nil, cti, nil, cci, 0) end
  end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Max selection vertically",
  invoke = function()
    set_selection_bounds_v(1, renoise.song().selected_pattern.number_of_lines)
  end
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:Min selection vertically",
  invoke = function()
    local x = renoise.song().transport.edit_pos.line
    set_selection_bounds_v(x, x)
  end
}



_AUTO_RELOAD_DEBUG = function()
  
end
