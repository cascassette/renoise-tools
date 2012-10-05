-------------------------------------------------------------
-- Duplicate Sample v1 by Cas Marrav (for Renoise 2.8)     --
-------------------------------------------------------------

-- Main --
local function dubsmp(kz)
  local rs = renoise.song()
  rs:describe_undo("Duplicate Sample")
  local csi = rs.selected_sample_index
  local ci = rs.selected_instrument
  ci:insert_sample_at(csi+1)
  ci:sample(csi+1):copy_from(ci:sample(csi))
  if kz then
    local layers = {}
    local count = 0
    for i,l in ipairs(ci.sample_mappings[1]) do
      if l.sample_index == csi then
        count = count + 1
        layers[count] = { base_note = l.base_note,
                      map_velocity_to_volume = l.map_velocity_to_volume,
                      note_range = l.note_range,
                      use_envelopes = l.use_envelopes,
                      velocity_range = l.velocity_range }
      end
    end
    for i = 1, #layers do
      local sm = ci:insert_sample_mapping( 1, csi+1, layers[i].base_note )
      sm.use_envelopes = layers[i].use_envelopes
      sm.map_velocity_to_volume = layers[i].map_velocity_to_volume
      sm.note_range = layers[i].note_range
      sm.velocity_range = layers[i].velocity_range
    end
  end
  rs.selected_sample_index = csi+1
end

local function delsmp()
  local rs = renoise.song()
  rs:describe_undo("Delete Sample")
  rs:delete_sample_at(rs.selected_sample_index)
end

--renoise.tool():remove_keybinding("Global:Tools:Duplicate Sample")
-- Keys --
renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:Duplicate Sample",
  invoke = dubsmp
}
renoise.tool():add_keybinding {
  name = "Instrument Keyzone:Tools:Duplicate Sample",
  invoke = function() dubsmp(true) end
}

renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:Delete Sample",
  invoke = delsmp
}
renoise.tool():add_keybinding {
  name = "Instrument Keyzone:Tools:Delete Sample",
  invoke = delsmp
}

-- Menu --
--[[renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Duplicate Sample",
  invoke = dubsmp
}]]




--------------------
_AUTO_RELOAD_DEBUG = function()
  
end
