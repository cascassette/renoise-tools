--[[============================================================================
main.lua
============================================================================]]--

-- Placeholder for the dialog
--local dialog = nil

-- Placeholder to expose the ViewBuilder outside the show_dialog() function
--local vb = nil

-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end

-- Read from the manifest.xml file.
--class "RenoiseScriptingTool" (renoise.Document.DocumentNode)
  --function RenoiseScriptingTool:__init()    
    --renoise.Document.DocumentNode.__init(self) 
  --end


--local manifest = RenoiseScriptingTool()
--local ok,err = manifest:load_from("manifest.xml")
--local tool_name = manifest:property("Name").value
--local tool_id = manifest:property("Id").value

--class "ASISettings" (renoise.Document.DocumentNode)
  --function ASISettings:__init()
    --renoise.Document.DocumentNode.__init(self)
  --end

--local settings = ASISettings()
--local sok,serr = settings:load_from("preferences.xml")
--local autoselect = settings:property("AutoSelect")


local autoselect = true
local vstwindow = true
local rs


--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function adjust_inst()
  rs:capture_nearest_instrument_from_pattern()
end

local function show_inst()
  local cii = rs.selected_instrument_index
  -- hide window for all other windows
  for idx,ins in ipairs(rs.instruments) do
    if ins.plugin_properties.plugin_loaded and ins.plugin_properties.plugin_device.external_editor_available then
      ins.plugin_properties.plugin_device.external_editor_visible = (idx == cii)
    end
  end
end

local function init_or_refresh()

  rs = renoise.song()
  
  if autoselect then
    if rs.selected_track_index_observable:has_notifier(adjust_inst) then
      rs.selected_track_index_observable:remove_notifier(adjust_inst)
    end
    rs.selected_track_index_observable:add_notifier(adjust_inst)
  else
    if rs.selected_track_index_observable:has_notifier(adjust_inst) then
      rs.selected_track_index_observable:remove_notifier(adjust_inst)
    end
  end
  
  if vstwindow then
    if rs.selected_instrument_observable:has_notifier(show_inst) then
      rs.selected_instrument_observable:remove_notifier(show_inst)
    end
    rs.selected_instrument_observable:add_notifier(show_inst)
  else
    if rs.selected_instrument_observable:has_notifier(show_inst) then
      rs.selected_instrument_observable:remove_notifier(show_inst)
    end
  end
  
end

local function is_active()
  return autoselect
end

local function switchitonem()
  autoselect = not autoselect
  if autoselect then
    renoise.app():show_status("AutoSelect On")
    adjust_inst()
  else
    renoise.app():show_status("AutoSelect Off")
  end
  init_or_refresh()
end

local function switchvstviewing()
  vstwindow = not vstwindow
  if vstwindow then
    renoise.app():show_status("AutoShowVST On")
    show_inst()
  else
    renoise.app():show_status("AutoShowVST Off")
  end
  init_or_refresh()
end

-- This example function is called from the GUI below.
-- It will return a random string. The GUI function displays 
-- that string in a dialog.
--local function get_greeting()
  --local words = {"Hello world!", "Nice to meet you :)", "Hi there!"}
  --local id = math.random(#words)
  --return words[id]
--end





--------------------------------------------------------------------------------
-- Menu entries
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Auto Select Instrument",
  invoke = switchitonem,
  selected = is_active
}


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Tools:Auto Select Instrument",
  invoke = switchitonem
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Auto Show VST Instrument",
  invoke = switchvstviewing
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Jump to Next Track",
  invoke = function()
    local rs = renoise.song()
    rs.selected_track_index = math.mod(rs.selected_track_index,#rs.tracks)+1
  end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Jump to Previous Track",
  invoke = function()
    local rs = renoise.song()
    rs.selected_track_index = math.mod(rs.selected_track_index-2,#rs.tracks)+1
  end
}


--------------------------------------------------------------------------------
-- On Song Load
--------------------------------------------------------------------------------

renoise.tool().app_new_document_observable:add_notifier( init_or_refresh )


--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

--[[
renoise.tool():add_midi_mapping {
  name = tool_id..":Show Dialog...",
  invoke = show_dialog
}
--]]
