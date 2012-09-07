--main
function main()
  local rs = renoise.song()
  local ci = rs.selected_instrument
  local rk = 48
  if #ci.sample_mappings[1] > 0 then rk = ci.sample_mappings[1][1].base_note end
  local x
  for x = 1, #ci.sample_mappings[1], 1 do
    ci:delete_sample_mapping_at(1, 1)
  end
  for x = 1, #ci.samples do
    ci:insert_sample_mapping( 1, x, rk )
  end
end


--menu
for _,menu in pairs {"Instrument Box", "Sample List"} do
  local function multi_instr_selected()
    return (#renoise.song().selected_instrument.samples > 1 and not renoise.song().selected_instrument.sample_mappings[1].read_only)
  end

  renoise.tool():add_menu_entry {
    name = menu .. ":Layer all samples",
    active = multi_instr_selected,
    invoke = function()
      main()
    end
  }
end

--keys
renoise.tool():add_keybinding {
  name = "Global:Tools:Duplicate Sample",
  invoke = main
}
