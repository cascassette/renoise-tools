--[[============================================================================
main.lua
============================================================================]]--

-- Placeholder for the dialog
--local dialog = nil

-- Placeholder to expose the ViewBuilder outside the show_dialog() function
--local vb = nil

local rs

-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end

-- Read from the manifest.xml file.
class "RenoiseScriptingTool" (renoise.Document.DocumentNode)
  function RenoiseScriptingTool:__init()    
    renoise.Document.DocumentNode.__init(self) 
    self:add_property("Name", "Untitled Tool")
    self:add_property("Id", "Unknown Id")
  end

local manifest = RenoiseScriptingTool()
local ok,err = manifest:load_from("manifest.xml")
local tool_name = manifest:property("Name").value
local tool_id = manifest:property("Id").value


--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function group_selected_tracks()
  rs = renoise.song()
  if rs.selection_in_pattern ~= nil then
    local st = rs.selection_in_pattern.start_track
    local et = rs.selection_in_pattern.end_track
    rs:insert_group_at(et+1)
    for i = et, st, -1 do
      rs:add_track_to_group(st, et+1)
    end
    rs:track(et+1).color = rs:track(st).color
  end
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

--renoise.tool():add_menu_entry {
  --name = "Main Menu:Tools:Group Selected Tracks",
  --invoke = group_selected_tracks
--}


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Tools:Group Selected Tracks",
  invoke = group_selected_tracks
}


--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

--[[
renoise.tool():add_midi_mapping {
  name = tool_id..":Show Dialog...",
  invoke = show_dialog
}
--]]
