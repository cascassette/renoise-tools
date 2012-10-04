-------------------------------------------------------------
-- ShowParams v2 by Cas Marrav (for Renoise 2.8)           --
-------------------------------------------------------------

-- GUI: show_dialog() function                             --
function show_dialog()
  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  local vb_controlled = vb:checkbox { value = true }
  local vb_automated = vb:checkbox { value = true }
  local vb_midibound = vb:checkbox { value = true }
  local vb_currtrack = vb:checkbox { value = true }

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
        vb_currtrack,
      },
      vb:vertical_aligner {
        margin = DDM,
        spacing = CS,
        vb:text { text = "Controlled" },
        vb:text { text = "Automated" },
        vb:text { text = "MIDI Mapped" },
        vb:text { text = "Current Track only" },
      },
    }
  local dialog_instance = renoise.app():show_custom_prompt("Show Parameters",
                   vb_dialog,
                 {"Uncover!", "Cancel"})
  if dialog_instance == "Uncover!" then
    if not vb_currtrack.value then
      show_meters(vb_controlled.value, vb_automated.value, vb_midibound.value, nil)
    else
      show_meters(vb_controlled.value, vb_automated.value, vb_midibound.value, renoise.song().selected_track_index)
    end
  end
end

-- Main: show_meters() function                            --
function show_meters(contr, auto, midi, tr)
  local s = renoise.song()
  if not (contr or auto or midi) then
    if tr == nil then
      for track_id, track in pairs(s.tracks) do
        for dev_id, device in pairs(track.devices) do
          for param_id, param in pairs(device.parameters) do
            param.show_in_mixer = false
          end
        end
      end
    end
  else
    if tr == nil then
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
              if device:parameter(2).value ~= -1 and device:parameter(3).value ~= -1 then
                local trid = device:parameter(1).value
                local fxid = device:parameter(2).value+1
                local prid = device:parameter(3).value+1
                if trid == -1 then trid = track_id else trid = trid+1 end
                --print("source track# ", track_id, "source device# ", dev_id, "source device name ", device.name)
                --print("track# ", trid, "effect# ", fxid, "param# ", prid)
                s:track(trid):device(fxid):parameter(prid).show_in_mixer = true
              end
            -- xy pad has 2 outs
            elseif device.name == "*XY Pad" then
              for i = 1,2 do
                local trid = device:parameter(i*5-2).value
                local fxid = device:parameter(i*5-1).value
                local prid = device:parameter(i*5).value
                if trid == -1 then trid = track_id else trid = trid+1 end
                if fxid ~= -1 and prid ~= -1 then
                  s:track(trid):device(fxid+1):parameter(prid+1).show_in_mixer = true
                end
              end
            -- finally hydra with 9 possible outs
            elseif device.name == "*Hydra" then
              for i = 1,9 do
                local trid = device:parameter(i*5-3).value
                local fxid = device:parameter(i*5-2).value
                local prid = device:parameter(i*5-1).value
                if trid == -1 then trid = track_id else trid = trid+1 end
                if fxid ~= -1 and prid ~= -1 then
                  s:track(trid):device(fxid+1):parameter(prid+1).show_in_mixer = true
                end
              end
            -- experimental formula support
            elseif device.name == "*Formula" then
              if device:parameter(5).value ~= -1 and device:parameter(6).value ~= -1 then
                local trid = device:parameter(4).value
                local fxid = device:parameter(5).value
                local prid = device:parameter(6).value
                if trid == -1 then trid = track_id else trid = trid+1 end
                s:track(trid):device(fxid+1):parameter(prid+1).show_in_mixer = true
              end
            end
          end
        end
      end
    else  -- tr ~= nil
      local track = s:track(tr)
      local track_id = tr
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
            if device:parameter(2).value ~= -1 and device:parameter(3).value ~= -1 then
              local trid = device:parameter(1).value
              local fxid = device:parameter(2).value+1
              local prid = device:parameter(3).value+1
              if trid == -1 then trid = track_id else trid = trid+1 end
              --print("source track# ", track_id, "source device# ", dev_id, "source device name ", device.name)
              --print("track# ", trid, "effect# ", fxid, "param# ", prid)
              s:track(trid):device(fxid):parameter(prid).show_in_mixer = true
            end
          -- xy pad has 2 outs
          elseif device.name == "*XY Pad" then
            for i = 1,2 do
              local trid = device:parameter(i*5-2).value
              local fxid = device:parameter(i*5-1).value
              local prid = device:parameter(i*5).value
              if trid == -1 then trid = track_id else trid = trid+1 end
              if fxid ~= -1 and prid ~= -1 then
                s:track(trid):device(fxid+1):parameter(prid+1).show_in_mixer = true
              end
            end
          -- finally hydra with 9 possible outs
          elseif device.name == "*Hydra" then
            for i = 1,9 do
              local trid = device:parameter(i*5-3).value
              local fxid = device:parameter(i*5-2).value
              local prid = device:parameter(i*5-1).value
              if trid == -1 then trid = track_id else trid = trid+1 end
              if fxid ~= -1 and prid ~= -1 then
                s:track(trid):device(fxid+1):parameter(prid+1).show_in_mixer = true
              end
            end
          -- experimental formula support
          elseif device.name == "*Formula" then
            if device:parameter(5).value ~= -1 and device:parameter(6).value ~= -1 then
              local trid = device:parameter(4).value
              local fxid = device:parameter(5).value
              local prid = device:parameter(6).value
              if trid == -1 then trid = track_id else trid = trid+1 end
              s:track(trid):device(fxid+1):parameter(prid+1).show_in_mixer = true
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

function toggle_mixer_params()
  local rs = renoise.song()
  local cd = rs.selected_device
  if cd ~= nil then
    local switch = false
    for i,p in ipairs(cd.parameters) do
      if not p.show_in_mixer then
        switch = true
      end
    end
    for i,p in ipairs(cd.parameters) do
      p.show_in_mixer = switch
    end
  end
end

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Show Parameters...",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Mixer:Tools:Show Parameters...",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Mixer:Tools:Toggle Parameters in Mixer",
  invoke = toggle_mixer_params
}

-- Main: autoreload function                               --
_AUTO_RELOAD_DEBUG = function()
end
