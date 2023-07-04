-------------------------------------------------------------
-- ShoveBack v1.1 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

-- TODO: method to keep last midi value for like 1 second.
--                      (Delta from there)

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
local function shoveback_delay_column(mm)
  -- if note column change delay_value in current note_column
  -- if instr track change delay_value in every note_column (fx column)
  -- if group track change delay_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  nv = mm.int_value * 2
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  if step == 0 then step = 1 end
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  rs.transport.follow_player = false
  if column >= 1 and column <= 12 then -- instrument track
    rs:track(track).delay_column_visible = true
    local x = line % step
    if x < 1 then x = line end
    for l = x, rs:pattern(pattern).number_of_lines, step do
      rs:pattern(pattern):track(track):line(l):note_column(column).delay_value = rs:pattern(pattern):track(track):line(l):note_column(column).delay_value + nv
    end
  elseif tracktype == 1 then
    rs:track(track).delay_column_visible = true
    local x = line % step
    if x < 1 then x = line end
    for l = x, rs:pattern(pattern).number_of_lines, step do
      for c = 1, rs:track(track).visible_note_columns do
	rs:pattern(pattern):track(track):line(l):note_column(c).delay_value = rs:pattern(pattern):track(track):line(l):note_column(c).delay_value + nv
      end
    end
  elseif tracktype == 4 then
    for _, t in pairs(rs:track(track).leaves_indexes) do
      rs:track(t).delay_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
	for c = 1, rs:track(t).visible_note_columns do
	  rs:pattern(pattern):track(t):line(l):note_column(c).delay_value = rs:pattern(pattern):track(t):line(l):note_column(c).delay_value + nv
	end
      end
    end
  else
    renoise.app():show_status("dude u r in wrong track type")
  end
end

-- Main: volume column --
local function shoveback_volume_column(mm)
  -- if note column change volume_value in current note_column
  -- if instr track change volume_value in every note_column (fx column)
  -- if group track change volume_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  nv = mm.int_value
  local str = false
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  if step == 0 then step = 1 end
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  rs.transport.follow_player = false
  if column >= 1 and column <= 12 then -- instrument track
    rs:track(track).volume_column_visible = true
    local x = line % step
    if x < 1 then x = line end
    for l = x, rs:pattern(pattern).number_of_lines, step do
      rs:pattern(pattern):track(track):line(l):note_column(column).volume_value = rs:pattern(pattern):track(track):line(l):note_column(column).volume_value + nv
    end
  elseif tracktype == 1 then
    rs:track(track).volume_column_visible = true
    local x = line % step
    if x < 1 then x = line end
    for l = x, rs:pattern(pattern).number_of_lines, step do
      for c = 1, rs:track(track).visible_note_columns do
	rs:pattern(pattern):track(track):line(l):note_column(c).volume_value = rs:pattern(pattern):track(track):line(l):note_column(c).volume_value + nv
      end
    end
  elseif tracktype == 4 then
    for _, t in pairs(rs:track(track).leaves_indexes) do
      rs:track(t).volume_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
	for c = 1, rs:track(t).visible_note_columns do
	  rs:pattern(pattern):track(t):line(l):note_column(c).volume_value = rs:pattern(pattern):track(t):line(l):note_column(c).volume_value + nv
	end
      end
    end
  else
    renoise.app():show_status("dude u r in wrong track type")
  end
end

-- Main: panning column --
local function shoveback_panning_column(mm)
  -- if note column change panning_value in current note_column
  -- if instr track change panning_value in every note_column (fx column)
  -- if group track change panning_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  nv = mm.int_value
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  if step == 0 then step = 1 end
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  rs.transport.follow_player = false
  if column >= 1 and column <= 12 then -- instrument track
    rs:track(track).panning_column_visible = true
    local x = line % step
    if x < 1 then x = line end
    for l = x, rs:pattern(pattern).number_of_lines, step do
      rs:pattern(pattern):track(track):line(l):note_column(column).panning_value = rs:pattern(pattern):track(track):line(l):note_column(column).panning_value + nv
    end
  elseif tracktype == 1 then
    rs:track(track).panning_column_visible = true
    local x = line % step
    if x < 1 then x = line end
    for l = x, rs:pattern(pattern).number_of_lines, step do
      for c = 1, rs:track(track).visible_note_columns do
	rs:pattern(pattern):track(track):line(l):note_column(c).panning_value = rs:pattern(pattern):track(track):line(l):note_column(c).panning_value + nv
      end
    end
  elseif tracktype == 4 then
    for _, t in pairs(rs:track(track).leaves_indexes) do
      rs:track(t).panning_column_visible = true
      local x = line % step
      if x < 1 then x = line end
      for l = x, rs:pattern(pattern).number_of_lines, step do
	for c = 1, rs:track(t).visible_note_columns do
	  rs:pattern(pattern):track(t):line(l):note_column(c).panning_value = rs:pattern(pattern):track(t):line(l):note_column(c).panning_value + nv
	end
      end
    end
  else
    renoise.app():show_status("dude u r in wrong track type")
  end
end

-- Midi --
renoise.tool():add_midi_mapping {
  name = "Tools:Shove back:Delay",
  invoke = shoveback_delay_column
}
renoise.tool():add_midi_mapping {
  name = "Tools:Shove back:Volume",
  invoke = shoveback_volume_column
}
renoise.tool():add_midi_mapping {
  name = "Tools:Shove back:Panning",
  invoke = shoveback_panning_column
}

-- Reload --
_AUTO_RELOAD_DEBUG = function()
  --print(toint("FF"))
end

