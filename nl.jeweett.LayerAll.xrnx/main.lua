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

function main()
  --local go = #renoise.song().selected_instrument.sample_mappings[1] <= 1
  --if not go then
    --answer = renoise.app():show_custom_prompt {
      --title = "Sure?",
      --renoise.ViewBuilder():text { text = "You have more than one keyzone configured for this instrument already. Are you sure you want to throw it all away?" },
      ----content_view = "You have more than one keyzone configured for this instrument already. Are you sure you want to throw it all away?",
      --{ "Yes", "No" }
    --}
    --if answer == "Yes" then go = true end
  --end
  --if go then
    local rs = renoise.song()
    local ci = rs.selected_instrument
    local rk = 48
    if #ci.sample_mappings[1] > 0 then rk = ci.sample_mappings[1][1].base_note end
    local x
    for x = 1, #ci.sample_mappings[1], 1 do
      ci:delete_sample_mapping_at(1, 1)
    end
    for x = 1, #ci.samples do
      ci:insert_sample_mapping( 1, x, 48 )
    end
  --end
end
