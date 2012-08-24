if renoise.tool():has_menu_entry("Main Menu:Tools:Show Parameters...") then
  renoise.tool():remove_menu_entry("Main Menu:Tools:Show Parameters...")
end
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Show Parameters...",
  invoke = function()
    show_dialog()
  end
}

-------------------------------------------------------------
--Main: show_dialog() function
-------------------------------------------------------------
function show_dialog()
  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  local vb_controlled = vb:checkbox { value = true }
  local vb_automated = vb:checkbox { value = true }
  local vb_midibound = vb:checkbox { value = true }

  local vb_dialog =
    vb:horizontal_aligner {
      margin = DDM,
      spacing = CS,
      vb:vertical_aligner {
        margin = DDM,
        spacing = CS,
        vb_controlled,
        vb_automated,
        vb_midibound,
      },
      vb:vertical_aligner {
        margin = DDM,
        spacing = CS,
        vb:text { text = "Controlled" },
        vb:text { text = "Automated" },
        vb:text { text = "MIDI Mapped" },
      },
    }
  local dialog_instance = renoise.app():show_custom_prompt("Show Parameters",
                   vb_dialog,
                 {"Uncover!", "Cancel"})
  if dialog_instance == "Uncover!" then
    show_meters(vb_controlled.value, vb_automated.value, vb_midibound.value)
  end
end

-------------------------------------------------------------
--Main: show_meters() function
-------------------------------------------------------------
function show_meters(contr, auto, midi)
  local s = renoise.song()
  if not (contr or auto or midi) then
  for track_id, track in pairs(s.tracks) do
    for dev_id, device in pairs(track.devices) do
      for param_id, param in pairs(device.parameters) do
        param.show_in_mixer = false
      end
    end
  end
  else
  for track_id, track in pairs(s.tracks) do
    for dev_id, device in pairs(track.devices) do
      -- check for automated / midi mapped parameters
      for param_id, param in pairs(device.parameters) do
        if auto and param.is_automated then
          param.show_in_mixer = true
        elseif midi and param.is_midi_mapped then
          param.show_in_mixer = true
        end
      end
      -- if device is control device (starts with *) then show all controlled parameters!
      if contr then
        -- easy devices first: just one control voltage output
        if ( device.name == "*Key Tracker" or
               device.name == "*LFO" or
               device.name == "*Signal Follower" or
               device.name == "*Velocity Tracker" ) then
          if device.parameters[2].value ~= -1 and device.parameters[3].value ~= -1 then
            local trid = device.parameters[1].value
            local fxid = device.parameters[2].value+1
            local prid = device.parameters[3].value+1
            if trid == -1 then trid = track_id else trid = trid+1 end
            --print("source track# ", track_id, "source device# ", dev_id, "source device name ", device.name)
            --print("track# ", trid, "effect# ", fxid, "param# ", prid)
            s.tracks[trid].devices[fxid].parameters[prid].show_in_mixer = true
          end
        -- xy pad has 2 outs
        elseif device.name == "*XY Pad" then
          for i = 1,2 do
            local trid = device.parameters[i*5-2].value
            local fxid = device.parameters[i*5-1].value
            local prid = device.parameters[i*5].value
            if trid == -1 then trid = track_id else trid = trid+1 end
            if fxid ~= -1 and prid ~= -1 then
              s.tracks[trid].devices[fxid+1].parameters[prid+1].show_in_mixer = true
            end
          end
        -- finally hydra with 9 possible outs
        elseif device.name == "*Hydra" then
          for i = 1,9 do
            local trid = device.parameters[i*5-3].value
            local fxid = device.parameters[i*5-2].value
            local prid = device.parameters[i*5-1].value
            if trid == -1 then trid = track_id else trid = trid+1 end
            if fxid ~= -1 and prid ~= -1 then
              s.tracks[trid].devices[fxid+1].parameters[prid+1].show_in_mixer = true
            end
          end
        -- experimental formula support
        elseif device.name == "*Formula" then
          if device.parameters[5].value ~= -1 and device.parameters[6].value ~= -1 then
            local trid = device.parameters[4].value
            local fxid = device.parameters[5].value
            local prid = device.parameters[6].value
            if trid == -1 then trid = track_id else trid = trid+1 end
            s.tracks[trid].devices[fxid+1].parameters[prid+1].show_in_mixer = true
          end
        end
      end
    end
  end
  end -- if not (contr or auto or midi)
end
--[28] =>  Audio/Effects/*Meta/*Hydra
--          * parameters[2,3,4] (Out 1)
--          * parameters[7,8,9] (Out 2)
--          * parameters[12,13,14]
--          * etc.
--[31] =>  Audio/Effects/*Meta/*Key Tracker
--          * parameters[1,2,3]
--[32] =>  Audio/Effects/*Meta/*LFO
--          * parameters[1,2,3]
--[33] =>  Audio/Effects/*Meta/*Signal Follower
--          * parameters[1,2,3]
--[34] =>  Audio/Effects/*Meta/*Velocity Tracker
--          * parameters[1,2,3]
--[35] =>  Audio/Effects/*Meta/*XY Pad
--          * parameters[3,4,5] (X)
--          * parameters[8,9,10] (Y)
--[xx] =>  *Formula
--          * parameters[4,5,6]
