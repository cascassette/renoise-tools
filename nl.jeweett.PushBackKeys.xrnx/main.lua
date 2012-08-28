-------------------------------------------------------------
-- PushBack Keys v1 by Cas Marrav (for Renoise 2.8)        --
-------------------------------------------------------------

-- Vars --
local rs
local pattern, line, step, track, column, tracktype, nv
local vb
local dialog = nil
local dialog_type

-- Const --
local COLUMN_TYPE_VOL = 1
local COLUMN_TYPE_PAN = 2
local COLUMN_TYPE_DEL = 3
local func_lookup = {}
local descript = {}

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
local function pushback_delay_column(nv)
  -- if note column change delay_value in current note_column
  -- if instr track change delay_value in every note_column (fx column)
  -- if group track change delay_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  rs.selected_track.delay_column_visible = true
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
local function pushback_volume_column(nv)
  -- if note column change volume_value in current note_column
  -- if instr track change volume_value in every note_column (fx column)
  -- if group track change volume_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  local str = false
  if nv == 128 then -- keep max volume ".." string for niceness
    str = ""
  end
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  rs.selected_track.volume_column_visible = true
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
local function pushback_panning_column(nv)
  -- if note column change panning_value in current note_column
  -- if instr track change panning_value in every note_column (fx column)
  -- if group track change panning_value in every note_column in every sub track that's an instr track
  rs = renoise.song()
  local str = false
  nv = nv + 64
  if nv == 64 then str = "" end -- keep center panorama ".." string for niceness
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  track = rs.selected_track_index
  tracktype = rs.selected_track.type
  column = rs.selected_note_column_index
  rs.selected_track.panning_column_visible = true
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

-- Gui --
func_lookup[COLUMN_TYPE_VOL] = pushback_volume_column
func_lookup[COLUMN_TYPE_PAN] = pushback_panning_column
func_lookup[COLUMN_TYPE_DEL] = pushback_delay_column
descript[COLUMN_TYPE_VOL] = "volume"
descript[COLUMN_TYPE_PAN] = "panning"
descript[COLUMN_TYPE_DEL] = "delay"

local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function key_dialog(d,k)
  if ( k.name == "up" ) then
    vb.views.pushback.value = vb.views.pushback.value - 1
    func_lookup[dialog_type](vb.views.pushback.value)
  elseif ( k.name == "down" ) then
    vb.views.pushback.value = vb.views.pushback.value + 1
    func_lookup[dialog_type](vb.views.pushback.value)
  elseif ( k.name == "left" ) then
    vb.views.pushback.value = vb.views.pushback.value - 16
    func_lookup[dialog_type](vb.views.pushback.value)
  elseif ( k.name == "right" ) then
    vb.views.pushback.value = vb.views.pushback.value + 16
    func_lookup[dialog_type](vb.views.pushback.value)
  elseif ( k.name == "return" ) then
    close_dialog()
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    return k
  end
end

local function show_dialog(column_type)
  dialog_type = column_type
  rs = renoise.song()
  if rs.selected_track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
    pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
    line = rs.transport.edit_pos.line
    step = rs.transport.edit_step
    track = rs.selected_track_index
    tracktype = rs.selected_track.type
    column = rs.selected_note_column_index
    local nc = nil  -- notecolumn to get info from
    if column >= 1 and column <= 12 then
      nc = rs:pattern(pattern):track(track):line(line):note_column(column)
    elseif tracktype == 1 then
      nc = rs:pattern(pattern):track(track):line(line):note_column(1)
    elseif tracktype == 4 then
      nc = rs:pattern(pattern):track(rs:track(track).leaves_indexes[1]):line(line):note_column(1)
    end
    local val, min, max
    if dialog_type == COLUMN_TYPE_VOL then
      min = 0 max = 128
      val = nc.volume_value
      if val == 256 then val = 128 end
    elseif dialog_type == COLUMN_TYPE_PAN then
      min = -64 max = 64
      val = nc.panning_value - 64
      if val == 191 then val = 0 end
    elseif dialog_type == COLUMN_TYPE_DEL then
      min = 0 max = 256
      val = nc.delay_value
    end
    
    vb = renoise.ViewBuilder()
    local vb_pushback = vb:valuebox { min = min, max = max, value = val, id = "pushback" }
    local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
    local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
    local dialog_content = vb:column {
      vb:row {
        vb_pushback,
      },
      vb:button {
        text = "Close",
        released = close_dialog,
      },
    }
  
    close_dialog()
    dialog = renoise.app():show_custom_dialog( "Pushback "..descript[column_type], dialog_content, key_dialog )
  end
end

-- Keys --
renoise.tool():add_keybinding {
  name = "Global:Tools:Push Back Del",
  invoke = function() show_dialog(COLUMN_TYPE_DEL) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:Push Back Vol",
  invoke = function() show_dialog(COLUMN_TYPE_VOL) end
}
renoise.tool():add_keybinding {
  name = "Global:Tools:Push Back Pan",
  invoke = function() show_dialog(COLUMN_TYPE_PAN) end
}

-- Reload --
_AUTO_RELOAD_DEBUG = function()
end
