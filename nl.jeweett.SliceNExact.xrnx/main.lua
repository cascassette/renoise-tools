--[[============================================================================
--                                Slice n Exact                               --
============================================================================]]--

-- Placeholder for the dialog
local dialog = nil

-- Placeholder to expose the ViewBuilder outside the show_dialog() function
local vb = nil

local rs = nil

--local opts = { 0, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64 }


--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function slice_it(parts)
  renoise.song():describe_undo("Slice in ".. parts .."equal parts")
  -- remove existing slices
  for i, m in ipairs(renoise.song().selected_sample.slice_markers) do
    renoise.song().selected_sample:delete_slice_marker(m)
  end
  -- put new markers at equal spaces
  local div = renoise.song().selected_sample.sample_buffer.number_of_frames / parts
  for i = 1, parts do
    renoise.song().selected_sample:insert_slice_marker((i-1)*div+1)
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

--[[
local function toint(v)
  return opts[v]
end

local function tostr(v)
  return tostring(opts[v])
end
--]]

local function key_dialog(d,k)
  if ( k.name == "up" ) then
    vb.views.parts.value = vb.views.parts.value + 1
  elseif ( k.name == "down" ) then
    vb.views.parts.value = vb.views.parts.value - 1
  elseif ( k.name == "left" ) then
    vb.views.parts.value = vb.views.parts.value / 2
  elseif ( k.name == "right" ) then
    vb.views.parts.value = vb.views.parts.value * 2
  elseif ( k.name == "return" ) then
    slice_it(vb.views.parts.value)
    --close_dialog()
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    return k
  end
end

local function show_dialog()
  rs = renoise.song()
  vb = renoise.ViewBuilder()
  local vb_slices = vb:valuebox { min = 0, max = 1024, value = #renoise.song().selected_sample.slice_markers, id = "parts", --[[tonumber = toint, tostring = tostr--]] }
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  local dialog_content = vb:column {
    vb:row {
      vb_slices,
    },
    vb:button {
      text = "Close",
      released = close_dialog,
    },
  }
  
  if not ( dialog and dialog.visible ) then
    dialog = renoise.app():show_custom_dialog( "Slice", dialog_content, key_dialog )
  end
end


--------------------------------------------------------------------------------
-- Menu entries
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Slice 'n' Exact...",
  invoke = show_dialog  
}


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Tools:Slice 'n' Exact...",
  invoke = show_dialog
}


--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

renoise.tool():add_midi_mapping {
  name = "Tools:Slice 'n' Exact...",
  invoke = show_dialog
}






-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end
