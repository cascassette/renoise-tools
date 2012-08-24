--[[============================================================================
--                       Reorganize Envelopes                                 --
============================================================================]]--


--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function minimize_deactivated()
  local rs = renoise.song()
  local st = rs.selected_track
  local cd
  for i, cd in ipairs(st.devices) do
    --print ("dev# " .. i .. " :  " .. cd.display_name)
    if not cd.is_active then
      cd.is_maximized = false
    end
  end
end

local function minimize_external()
  local rs = renoise.song()
  local st = rs.selected_track
  local cd
  for i, cd in ipairs(st.devices) do
    --print ("dev# " .. i .. " :  " .. cd.display_name)
    if cd.external_editor_available then
      cd.is_maximized = false
    end
  end
end

local function deactivate_unused_meta()
  local rs = renoise.song()
  local st = rs.selected_track
  local dc = #st.devices
  local cd
  for i, cd in ipairs(st.devices) do
    --print ("dev# " .. i .. " :  " .. cd.display_name)
    if cd.name == "*LFO" and (cd:parameter(2).value == -1 or cd:parameter(3).value == -1) then
      cd.is_active = false
    end
  end
end


--------------------------------------------------------------------------------
-- Menu entries
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Reorganize DSPs:Minimize all deactivated (CT)",
  invoke = minimize_deactivated
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Reorganize DSPs:Minimize all external (CT)",
  invoke = minimize_external
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Reorganize DSPs:Minimize all external and deactivated (CT)",
  invoke = function() minimize_deactivated() minimize_external() end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Reorganize DSPs:Drop all unused lfos/envelopes (CT)",
  invoke = function() deactivate_unused_meta() minimize_deactivated() end
}


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Track DSPs:Minimize all deactivated (CT)",
  invoke = minimize_deactivated
}

renoise.tool():add_keybinding {
  name = "Global:Track DSPs:Minimize all external (CT)",
  invoke = minimize_external
}

renoise.tool():add_keybinding {
  name = "Global:Track DSPs:Minimize all external and deactivated (CT)",
  invoke = function() minimize_deactivated() minimize_external() end
}

renoise.tool():add_keybinding {
  name = "Global:Track DSPs:Drop all unused lfos/envelopes (CT)",
  invoke = function() deactivate_unused_meta() minimize_deactivated() end
}






-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  
end
