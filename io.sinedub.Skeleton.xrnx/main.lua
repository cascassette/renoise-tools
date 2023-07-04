-------------------------------------------------------------
-- Skeleton v0.1 by Cas Marrav (for Renoise 2.8)           --
-------------------------------------------------------------

-- Main --
local function x()
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Skeleton",
  invoke = x
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Skeleton",
  invoke = x
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
