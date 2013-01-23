-------------------------------------------------------------
-- AddFXCol v0.01 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

-- Main --
local function add()
  renoise.song().selected_track.visible_effect_columns = math.min(renoise.song().selected_track.visible_effect_columns+1,renoise.song().selected_track.max_effect_columns)
end
local function remove()
  renoise.song().selected_track.visible_effect_columns = math.max(renoise.song().selected_track.visible_effect_columns-1,renoise.song().selected_track.min_effect_columns)
end


-- Menu --
--[[
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Skeleton",
  invoke = x
}
--]]


-- Keys --
renoise.tool():add_keybinding {
  name = "Pattern Editor:Track Control:Add FX Column",
  invoke = add
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Track Control:Remove FX Column",
  invoke = remove
}


-- Midi --
--[[
renoise.tool():add_midi_mapping {
  name = "Skeleton",
  invoke = x
}
--]]
