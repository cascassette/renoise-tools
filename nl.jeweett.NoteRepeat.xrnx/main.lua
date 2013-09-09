-------------------------------------------------------------
-- Note Repeat v0.1 by Cas Marrav (for Renoise 2.8)        --
-------------------------------------------------------------

local vb
local rs
local dialog = nil

--              notes:      C  D    E    F  G    A    B    C    D    E    F     G    A    B     C
local NOTE_REPEAT_MODES = { 2, 3/2, 4/3, 1, 3/4, 2/3, 1/2, 3/8, 1/3, 1/4, 3/16, 1/6, 1/8, 3/32, 1/12 }
local WHITES =            { 0, 2,   4,   5, 7,   9,   11,  12,  14,  16,  17,   19,  21,  23,   24 }
local NAMES =             { "2 Beat", "1 Beat D", "4 Beat T", "1 Beat", "1/2 Beat D", "2 Beat T", "1/2 Beat", "1/4 Beat D", "1 Beat T", "1/4 Beat", "1/8 Beat D", "1/2 Beat T", "1/8 Beat", "1/16 Beat D", "1/4 Beat T",  }

-- Main --
local function make_noterepeat_instrument()
  rs = renoise.song()
  local cs = rs.selected_sample
  local csb = cs.sample_buffer
  if not csb.has_sample_data then return end
  local bps = rs.transport.bpm/60
  local nii = rs.selected_instrument_index+1
  local ni = rs:insert_instrument_at(nii)
  local nsb, new_length_in_seconds, new_length_in_samples, max
  for i = 1, #NOTE_REPEAT_MODES do
    if i == 1 then
      nsb = ni:sample(1).sample_buffer
    else
      ni:insert_sample_at(i)
      nsb = ni:sample(i).sample_buffer
    end
    new_length_in_seconds = NOTE_REPEAT_MODES[i]/bps
    new_length_in_samples = math.floor(new_length_in_seconds*rs.selected_sample.sample_buffer.sample_rate+.5)
    nsb:create_sample_data(csb.sample_rate,csb.bit_depth,csb.number_of_channels,new_length_in_samples)
    nsb:prepare_sample_data_changes()
    max = math.min(csb.number_of_frames, new_length_in_samples)
    for s = 1, max do
      for c = 1, csb.number_of_channels do
        nsb:set_sample_data(c, s, csb:sample_data(c, s))
      end
    end
    nsb:finalize_sample_data_changes()
    ni:sample(i).name = cs.name.." "..NAMES[i]
  end
  for _,m in ipairs(ni.sample_mappings[1]) do
    ni:delete_sample_mapping_at(1,_)
  end
  local start = 36
  local note
  for i = 1, #WHITES do
    note = start+WHITES[i]
    ni:insert_sample_mapping(1,i,note,{note,note})
  end
  ni.name = cs.name
  rs.selected_instrument_index = nii
end

local function fixlength(lines, transpose, rep)
  local cs = rs.selected_sample
  local csb = cs.sample_buffer
  local lps = rs.transport.lpb*rs.transport.bpm/60
  local new_length_in_seconds = lines/lps
  local new_length_in_samples = math.floor(new_length_in_seconds*rs.selected_sample.sample_buffer.sample_rate+.5)
  local nii = rs.selected_instrument_index+1
  local ni = rs:insert_instrument_at(nii)
  local nsb = ni:sample(1).sample_buffer
  nsb:create_sample_data(csb.sample_rate,csb.bit_depth,csb.number_of_channels,new_length_in_samples)
  nsb:prepare_sample_data_changes()
  local max = math.min(csb.number_of_frames, new_length_in_samples)
  for i = 1, max do
    for c = 1, csb.number_of_channels do
      nsb:set_sample_data(c, i, csb:sample_data(c, i))
    end
  end
  nsb:finalize_sample_data_changes()
  ni.name = cs.name
  ni:sample(1).name = cs.name
  rs.selected_instrument_index = nii
end


-- Gui --
local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function key_dialog(d,k)
  --print(k.name)
  if ( k.name == "up" ) then
    vb.views.lines.value = vb.views.lines.value - 1
  elseif ( k.name == "down" ) then
    vb.views.lines.value = vb.views.lines.value + 1
  elseif ( k.name == "left" ) then
    vb.views.lines.value = math.floor( vb.views.lines.value / 2 + .5 )
  elseif ( k.name == "right" ) then
    vb.views.lines.value = vb.views.lines.value * 2
  elseif ( k.name == "prior" ) then
    if k.modifiers == "shift" then
      vb.views.transpose.value = vb.views.transpose.value - 12
    else
      vb.views.transpose.value = vb.views.transpose.value - 1
    end
  elseif ( k.name == "next" ) then
    if k.modifiers == "shift" then
      vb.views.transpose.value = vb.views.transpose.value + 12
    else
      vb.views.transpose.value = vb.views.transpose.value + 1
    end
  elseif ( k.name == "space" ) then
    vb.views.rep.value = not vb.views.rep.value
  elseif ( k.name == "return" ) then
    fixlength(vb.views.lines.value,vb.views.transpose.value,vb.views.rep.value)
    close_dialog()
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    return k
  end
end

local function show_dialog()
  rs = renoise.song()
  vb = renoise.ViewBuilder()

  local vb_lines = vb:valuebox { min = 1, max = rs.selected_pattern.number_of_lines, value = rs.transport.lpb, id = "lines" }
  local vb_transpose = vb:valuebox { min = -120, max = 120, value = rs.selected_sample.transpose, id = "transpose" }
  local vb_rep = vb:checkbox { value = true, id = "rep" }
  local dialog_content = vb:row {
    vb_lines,
    vb:space { width = 8 },
    vb_transpose,
    vb:space { width = 8 },
    vb_rep,
  }
  close_dialog()
  dialog = renoise.app():show_custom_dialog( "Note Repeat Sample", dialog_content, key_dialog )
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Sample Editor:Note Repeat...",
  invoke = show_dialog
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Sample Editor:Edit:Note Repeat...",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Sample Editor:Edit:New Note Repeat Instrument from Sample",
  invoke = make_noterepeat_instrument
}


-- Midi --
--[[
renoise.tool():add_midi_mapping {
  name = "Tools:Note Repeat",
  invoke = show_dialog
}
--]]


_AUTO_RELOAD_DEBUG = function()
  
end
