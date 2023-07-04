-------------------------------------------------------------
-- PushBack v1.1 by Cas Marrav (for Renoise 2.8)           --
-------------------------------------------------------------

-- Vars --
local rs
local pattern, line, step, track, column, tracktype, nv

-- Track.track_index property
local track_index_property = property(function(self)
  for index, track in ipairs(renoise.song().tracks) do
    if (rawequal(self, track)) then
      return index
    end
  end
end)
renoise.Track.track_index = track_index_property
renoise.GroupTrack.track_index = track_index_property

-- GroupTrack.leaves_indexes property
function find_leaves_indexes(self)
  local list = table.create()
  for _, t in ipairs(self.members) do
    if t.type == 1 then
      list:insert(t.track_index)
    elseif t.type == 4 then
      local sublist = find_leaves_indexes(t)
      for i = 1, #sublist do
        list:insert(sublist[i])
      end
    end
  end
  return list
end
local grouptrack_leaves_indexes_property = property(find_leaves_indexes)
renoise.GroupTrack.leaves_indexes = grouptrack_leaves_indexes_property

-- Main: delay column --
local function pushback_delay_column(mm)
  -- if note column change delay_value in current note_column
  -- if instr track change delay_value in every note_column (fx column)
  -- if group track change delay_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  nv = mm.int_value * 2
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  if step == 0 then
    if column >= 1 and column <= 12 then
      rs:track(track).delay_column_visible = true
      rs:pattern(pattern):track(track):line(line):note_column(column).delay_value = nv
    elseif tracktype == 1 then
      rs:track(track).delay_column_visible = true
      --for c = 1, rs:track(track).max_note_columns do
      for c = 1, rs:track(track).visible_note_columns do
        rs:pattern(pattern):track(track):line(line):note_column(c).delay_value = nv
      end
    elseif tracktype == 4 then
      for _, t in pairs(rs:track(track).leaves_indexes) do
        rs:track(t).delay_column_visible = true
        for c = 1, rs:track(t).visible_note_columns do
          rs:pattern(pattern):track(t):line(line):note_column(c).delay_value = nv
        end
      end
    else
      renoise.app():show_status("dude u r in wrong track type")
    end
  else
    rs.transport.follow_player = false
    if column >= 1 and column <= 12 then -- instrument track
      rs:track(track).delay_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
        rs:pattern(pattern):track(track):line(l):note_column(column).delay_value = nv
      end
    elseif tracktype == 1 then
      rs:track(track).delay_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
        for c = 1, rs:track(track).visible_note_columns do
          rs:pattern(pattern):track(track):line(l):note_column(c).delay_value = nv
        end
      end
    elseif tracktype == 4 then
      for _, t in pairs(rs:track(track).leaves_indexes) do
        rs:track(t).delay_column_visible = true
        local x = line % step
        if x < 1 then x = line end
        for l = x, rs:pattern(pattern).number_of_lines, step do
          for c = 1, rs:track(t).visible_note_columns do
            rs:pattern(pattern):track(t):line(l):note_column(c).delay_value = nv
          end
        end
      end
    else
      renoise.app():show_status("dude u r in wrong track type")
    end
  end
end

-- Main: volume column --
local function pushback_volume_column(mm)
  -- if note column change volume_value in current note_column
  -- if instr track change volume_value in every note_column (fx column)
  -- if group track change volume_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  nv = mm.int_value
  local str = false
  if nv == 127 then -- keep max volume ".." string for niceness
    str = ""
  end
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  if step == 0 then
    if column >= 1 and column <= 12 then
      rs:track(track).volume_column_visible = true
      if not str then
        rs:pattern(pattern):track(track):line(line):note_column(column).volume_value = nv
      else rs:pattern(pattern):track(track):line(line):note_column(column).volume_string = str end
    elseif tracktype == 1 then
      rs:track(track).volume_column_visible = true
      --for c = 1, rs:track(track).max_note_columns do
      for c = 1, rs:track(track).visible_note_columns do
        if not str then
          rs:pattern(pattern):track(track):line(line):note_column(c).volume_value = nv
        else rs:pattern(pattern):track(track):line(line):note_column(c).volume_string = str end
      end
    elseif tracktype == 4 then
      for _, t in pairs(rs:track(track).leaves_indexes) do
        rs:track(t).volume_column_visible = true
        for c = 1, rs:track(t).visible_note_columns do
          if not str then
            rs:pattern(pattern):track(t):line(line):note_column(c).volume_value = nv
          else rs:pattern(pattern):track(t):line(line):note_column(c).volume_string = str end
        end
      end
    else
      renoise.app():show_status("dude u r in wrong track type")
    end
  else
    rs.transport.follow_player = false
    if column >= 1 and column <= 12 then -- instrument track
      rs:track(track).volume_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
        if not str then
          rs:pattern(pattern):track(track):line(l):note_column(column).volume_value = nv
        else rs:pattern(pattern):track(track):line(l):note_column(column).volume_string = str end
      end
    elseif tracktype == 1 then
      rs:track(track).volume_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
        for c = 1, rs:track(track).visible_note_columns do
          if not str then
            rs:pattern(pattern):track(track):line(l):note_column(c).volume_value = nv
          else rs:pattern(pattern):track(track):line(l):note_column(c).volume_string = str end
        end
      end
    elseif tracktype == 4 then
      for _, t in pairs(rs:track(track).leaves_indexes) do
        rs:track(t).volume_column_visible = true
        local x = line % step
        if x < 1 then x = line end
        for l = x, rs:pattern(pattern).number_of_lines, step do
          for c = 1, rs:track(t).visible_note_columns do
            if not str then
              rs:pattern(pattern):track(t):line(l):note_column(c).volume_value = nv
            else rs:pattern(pattern):track(t):line(l):note_column(c).volume_string = str end
          end
        end
      end
    else
      renoise.app():show_status("dude u r in wrong track type")
    end
  end
end

-- Main: panning column --
local function pushback_panning_column(mm)
  -- if note column change panning_value in current note_column
  -- if instr track change panning_value in every note_column (fx column)
  -- if group track change panning_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  nv = mm.int_value
  local str = false
  if nv == 64 then str = "" end -- keep center panorama ".." string for niceness
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  if step == 0 then
    if column >= 1 and column <= 12 then
      rs:track(track).panning_column_visible = true
      if not str then
        rs:pattern(pattern):track(track):line(line):note_column(column).panning_value = nv
      else rs:pattern(pattern):track(track):line(line):note_column(column).panning_string = str end
    elseif tracktype == 1 then
      rs:track(track).panning_column_visible = true
      --for c = 1, rs:track(track).max_note_columns do
      for c = 1, rs:track(track).visible_note_columns do
        if not str then
          rs:pattern(pattern):track(track):line(line):note_column(c).panning_value = nv
        else rs:pattern(pattern):track(track):line(line):note_column(c).panning_string = str end
      end
    elseif tracktype == 4 then
      for _, t in pairs(rs:track(track).leaves_indexes) do
        rs:track(t).panning_column_visible = true
        for c = 1, rs:track(t).visible_note_columns do
          if not str then
            rs:pattern(pattern):track(t):line(line):note_column(c).panning_value = nv
          else rs:pattern(pattern):track(t):line(line):note_column(c).panning_string = str end
        end
      end
    else
      renoise.app():show_status("dude u r in wrong track type")
    end
  else
    rs.transport.follow_player = false
    if column >= 1 and column <= 12 then -- instrument track
      rs:track(track).panning_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
        if not str then
          rs:pattern(pattern):track(track):line(l):note_column(column).panning_value = nv
        else rs:pattern(pattern):track(track):line(l):note_column(column).panning_string = str end
      end
    elseif tracktype == 1 then
      rs:track(track).panning_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
        for c = 1, rs:track(track).visible_note_columns do
          if not str then
            rs:pattern(pattern):track(track):line(l):note_column(c).panning_value = nv
          else rs:pattern(pattern):track(track):line(l):note_column(c).panning_string = str end
        end
      end
    elseif tracktype == 4 then
      for _, t in pairs(rs:track(track).leaves_indexes) do
        rs:track(t).panning_column_visible = true
        local x = line % step
        if x < 1 then x = line end
        for l = x, rs:pattern(pattern).number_of_lines, step do
          for c = 1, rs:track(t).visible_note_columns do
            if not str then
              rs:pattern(pattern):track(t):line(l):note_column(c).panning_value = nv
            else rs:pattern(pattern):track(t):line(l):note_column(c).panning_string = str end
          end
        end
      end
    else
      renoise.app():show_status("dude u r in wrong track type")
    end
  end
end

-- Midi --
renoise.tool():add_midi_mapping {
  name = "Tools:Push back:Delay",
  invoke = pushback_delay_column
}
renoise.tool():add_midi_mapping {
  name = "Tools:Push back:Volume",
  invoke = pushback_volume_column
}
renoise.tool():add_midi_mapping {
  name = "Tools:Push back:Panning",
  invoke = pushback_panning_column
}

-- Reload --
_AUTO_RELOAD_DEBUG = function()
  --print(toint("FF"))
end

