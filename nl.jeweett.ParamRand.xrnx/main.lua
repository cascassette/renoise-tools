-------------------------------------------------------------
-- ParamRand v0.1 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

-- Main --
local function pr(trk)
  local rs = renoise.song()
  local dev = nil
  for i,d in ipairs(rs:track(trk).devices) do
    if d.display_name == "*Select" then
      dev = d
      break
    end
  end
  local p
  for i = 1,4 do
    p = dev:parameter(i)
    dev:parameter(i).value = math.random()*(p.value_max-p.value_min)+p.value_min
  end
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (CT)",
  invoke = function() pr(renoise.song().selected_track_index) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (Kick)",
  invoke = function() pr(1) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (Snare)",
  invoke = function() pr(2) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:ParamRand (Hihat)",
  invoke = function() pr(3) end
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (CT)",
  invoke = function() pr(renoise.song().selected_track_index) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (Kick)",
  invoke = function() pr(1) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (Snare)",
  invoke = function() pr(2) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:ParamRand (Hihat)",
  invoke = function() pr(3) end
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
