-------------------------------------------------------------
-- HammerTime v0.1 by Cas Marrav (for Renoise 2.8)         --
-------------------------------------------------------------

local dialog = nil

local vb_startpatt
local vb_verselength
local vb_timelabel_1
local vb_timelabel_2
local vb_timelabel_3
local vb_timelabel_4

-- Prefs --
local options = renoise.Document.create("HammerTimePreferences") {
  startpatt = 0,
  verselength = 16,
}
renoise.tool().preferences = options

-- Main --
local function update_text()
  local rs = renoise.song()
  local pp = rs.transport.playback_pos
  local sp = vb_startpatt.value + 1
  -- count in func is not working for now
  if pp.sequence < sp then
    vb_timelabel_1.text = "-0"
    vb_timelabel_2.text = "-0"
    vb_timelabel_3.text = "-0"
    vb_timelabel_4.text = "-0"
  else -- pp.sequence >= sp
    -- count lines
    local numlines = {}
    local linestotal = 0
    for i = vb_startpatt.value + 1, pp.sequence - 1 do
      local pnum = rs.sequencer:pattern(i)
      numlines[pnum] = rs:pattern(pnum).number_of_lines
      linestotal = linestotal + numlines[pnum]
    end
    linestotal = linestotal + pp.line - 1
    
    -- calc / mod
    local subbeats = math.mod( linestotal, rs.transport.lpb )
    local beats = math.floor( linestotal / rs.transport.lpb )
    local bars = math.floor( beats / 4 )
    beats = math.mod( beats, 4 )
    local verses = math.floor( bars / vb_verselength.value )
    bars = math.mod( bars, vb_verselength.value )
    
    -- display
    vb_timelabel_1.text = tostring( verses   + 1 )
    vb_timelabel_2.text = tostring( bars     + 1 )
    vb_timelabel_3.text = tostring( beats    + 1 )
    vb_timelabel_4.text = tostring( subbeats + 1 )
  end
end

-- Save Prefs --
--[[local function update_options()
  options.startpatt = vb_startpatt.value
  options.verselength = vb_verselength.value
end]]

-- GUI --
local function close_dialog()
  if renoise.tool():has_timer(update_text) then
    renoise.tool():remove_timer(update_text)
  end
  if dialog.visible then
    dialog:close()
    dialog = nil
  end
end

-- Key catcher --
local function key_dialog(d, k)
  local pass = false
  
  if not k.repeated then
    if k.name == "esc" then
      close_dialog()
    else
      pass = true
    end
  end
  
  if pass then return k end
end

-- GUI --
local function display_dialog()
  local rs=renoise.song()
  local vb=renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN

  if not dialog then
    -- create dialog
    vb_startpatt = vb:valuebox { min = 0, max = #rs.sequencer.pattern_sequence-1, value = options.startpatt.value, notifier = function(n) options.startpatt.value = n end }
    vb_verselength = vb:valuebox { min = 4, max = 32, value = options.verselength.value, notifier = function(n) options.verselength.value = n end }
    vb_timelabel_1 = vb:text { font = "big", align = "right", text = "01", width = 24 }
    vb_timelabel_2 = vb:text { font = "big", align = "right", text = "01", width = 24 }
    vb_timelabel_3 = vb:text { font = "big", align = "right", text = "01", width = 24 }
    vb_timelabel_4 = vb:text { font = "big", align = "right", text = "01", width = 24 }
    local vb_dialog = vb:column {
      margin = DDM,
      vb:row {
        vb_startpatt,
        vb_verselength,
      },
      vb:row {
        style = "border", margin = 1,
        vb_timelabel_1,
        vb:text { text = ".", width = 6 },
        vb_timelabel_2,
        vb:text { text = ".", width = 6 },
        vb_timelabel_3,
        vb:text { text = ".", width = 6 },
        vb_timelabel_4,
      }
    }
    
    -- show
    dialog = renoise.app():show_custom_dialog("HammerTime!", vb_dialog, key_dialog)
    
    -- bind
    renoise.tool():add_timer(update_text, 50)
  else
    -- close
    close_dialog()
  end
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:HammerTime",
  invoke = display_dialog
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:HammerTime",
  invoke = display_dialog
}


-- Midi --
--[[
renoise.tool():add_midi_mapping {
  name = "Skeleton",
  invoke = x
}
--]]


_AUTO_RELOAD_DEBUG = function()
  
end
