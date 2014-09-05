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
    
    if solo ~= 0 then
      local nclist = {}
      local nclistpos = 1
      local pat = rs:pattern(rs.sequencer:pattern(rs.transport.edit_pos.sequence))
      for i = nl, nr do
        local ct = rs:track(i)
        if ct.type == 2 then break end
        if ct.type == 1 then
          if i < oldsel.start_track or i > oldsel.end_track then
            -- if track is not in selection; everything
            for j = 1, ct.visible_note_columns do
              nclist[nclistpos] = {i, j}
              nclistpos = nclistpos + 1
            end
          elseif i == oldsel.start_track and i == oldsel.end_track then
            -- if track is both start and end of selection: check columns
            for j = 1, oldsel.start_column - 1 do
              nclist[nclistpos] = {i, j}
              nclistpos = nclistpos + 1
            end
            for j = oldsel.end_column + 1, ct.visible_note_columns do
              nclist[nclistpos] = {i, j}
              nclistpos = nclistpos + 1
            end
          elseif i == oldsel.start_track then
            -- if track start of selection: check columns
            for j = 1, oldsel.start_column - 1 do
              nclist[nclistpos] = {i, j}
              nclistpos = nclistpos + 1
            end
          elseif i == oldsel.end_track then
            -- if track end of selection: check columns
            for j = oldsel.end_column + 1, ct.visible_note_columns do
              nclist[nclistpos] = {i, j}
              nclistpos = nclistpos + 1
            end
          else
            -- if track is in selection completely: skip
          end
        end
      end
      
      -- select solo method
      if solo == 1 then
        -- method 1 (note off)
        for i = 1, nclistpos-1 do
          local ntr = nclist[i][1]
          local ncl = nclist[i][2]
          local nc = pat:track(ntr):line(oldsel.start_line):note_column(ncl)
          nc.note_value = 120
          nc.instrument_string = ""
          nc.volume_string = ""
          nc.panning_string = ""
          nc.delay_string = ""
          for k = oldsel.start_line + 1, oldsel.end_line do
            nc = pat:track(ntr):line(k):note_column(ncl)
            nc.note_string = ""
            nc.instrument_string = ""
            nc.volume_string = ""
            nc.panning_string = ""
            nc.delay_string = ""
          end
        end
      elseif solo == 2 then
        -- meth 2 (vol=00)
        for i = 1, nclistpos-1 do
          local ntr = nclist[i][1]
          local ncl = nclist[i][2]
          local nc = pat:track(ntr):line(oldsel.start_line):note_column(ncl)
          --nc.note_value = 120
          nc.note_string = ""
          nc.instrument_string = ""
          nc.volume_string = "00"
          nc.panning_string = ""
          nc.delay_string = ""
          for k = oldsel.start_line + 1, oldsel.end_line do
            nc = pat:track(ntr):line(k):note_column(ncl)
            nc.note_string = ""
            nc.instrument_string = ""
            nc.volume_string = "00"
            nc.panning_string = ""
            nc.delay_string = ""
          end
          nc.volume_string = "80"
        end
      elseif solo == 3 then
        -- meth 3 (vol fade)
        local volume_list = {128}
        local line_count = oldsel.end_line - oldsel.start_line - 1
        for i = 1, line_count do
          volume_list[i+1] = math.floor( 128 * ((line_count-i)/line_count) )
        end
        volume_list[line_count+2] = 128
        for i = 1, nclistpos-1 do
          local ntr = nclist[i][1]
          local ncl = nclist[i][2]
          for k = oldsel.start_line, oldsel.end_line do
            local nc = pat:track(ntr):line(k):note_column(ncl)
            nc.volume_value = volume_list[k-oldsel.start_line+1]
          end
          --nc.volume_string = "80"
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
  name = "Pattern Editor:Tools:NoteVol fade to the right",
  invoke = function() set_selection_bounds_h(nil, #renoise.song().tracks, nil, nil, 3) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:NoteVol fade to the left",
  invoke = function() set_selection_bounds_h(1, nil, nil, nil, 3) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:NoteVol fade left to right",
  invoke = function() set_selection_bounds_h(1,  #renoise.song().tracks, nil, nil, 3) end
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
