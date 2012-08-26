-------------------------------------------------------------
-- Laydee v0.2 by Cas Marrav (for Renoise 2.8)             --
-------------------------------------------------------------

local rs
local MSPM = 60000
local DPL = 256
local dialog = nil
local vb = nil
local pattern, line, step, track, column, delay



--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function dedelaytrack()
  rs = renoise.song()
  local bpm = rs.transport.bpm
  local lpb = rs.transport.lpb
  local dedelay_base = MSPM / bpm / lpb / DPL
  local dedelay = dedelay_base * vb.views.laydee.value
  if dedelay >= -100 and dedelay <= 100 then
    rs:track(track).output_delay = dedelay
  end
end



--------------------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------------------

local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function key_dialog(d,k)
  if ( k.name == "up" ) then
    vb.views.laydee.value = vb.views.laydee.value - 1
    dedelaytrack()
  elseif ( k.name == "down" ) then
    vb.views.laydee.value = vb.views.laydee.value + 1
    dedelaytrack()
  elseif ( k.name == "left" ) then
    vb.views.laydee.value = vb.views.laydee.value - 16
    dedelaytrack()
  elseif ( k.name == "right" ) then
    vb.views.laydee.value = vb.views.laydee.value + 16
    dedelaytrack()
  elseif ( k.name == "return" ) then
    dedelaytrack()
    close_dialog()
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    return k
  end
end

local function laydee_dialog()
  rs = renoise.song()
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  track = rs.selected_track_index
  column = rs.selected_note_column_index
  delay = 0
  if rs:track(track).output_delay ~= 0 then
    local delay_base = MSPM / rs.transport.bpm / rs.transport.lpb / DPL
    delay = math.floor(rs:track(track).output_delay / delay_base)
  elseif column > 0 then
    delay = -(rs:pattern(pattern):track(track):line(line):note_column(column).delay_value)
  end
  
  vb = renoise.ViewBuilder()
  local vb_pushback = vb:valuebox { min = -DPL, max = DPL, value = delay, id = "laydee" }
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
  
  if not ( dialog and dialog.visible ) then
    dialog = renoise.app():show_custom_dialog( "Laydee", dialog_content, key_dialog )
  end
  dedelaytrack()
end

local function laydee_nodialog()
  rs = renoise.song()
  pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
  line = rs.transport.edit_pos.line
  step = rs.transport.edit_step
  track = rs.selected_track_index
  column = rs.selected_note_column_index
  delay = 0
  if column > 0 then
    delay = -(rs:pattern(pattern):track(track):line(line):note_column(column).delay_value)
  end
  local bpm = rs.transport.bpm
  local lpb = rs.transport.lpb
  local dedelay_base = MSPM / bpm / lpb / DPL
  local dedelay = dedelay_base * delay
  if dedelay >= -100 and dedelay <= 100 then
    rs:track(track).output_delay = dedelay
  end
end



--------------------------------------------------------------------------------
-- Menu entries
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Set Track Output Delay in sublines...",
  invoke = laydee_dialog
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:AutoLaydee",
  invoke = laydee_dialog
}


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Tools:Set Track Output Delay in sublines...",
  invoke = laydee_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Tools:AutoLaydee",
  invoke = laydee_nodialog
}


-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  --print(toint("FF"))
end

