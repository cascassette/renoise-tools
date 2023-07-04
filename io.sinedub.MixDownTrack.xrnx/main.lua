-- MixDownTrack 0.2 (C) 2012 -Cas Marrav- Renoise v 2.8

-- Possible todos:
--
-- [_] Build a suitable method of inserting a max +3dB Gainer device just before sending to mixdown (muting source of course)
-- [_] Maintain a list of eligible tracks for sending to mixdown track from start (tool().app_new_document_observable, and -release_document- for stop)
--     [_] Then, force sending to mixdown track with help of song().tracks_observable
--         [_] After that, bind postfx_volume settings to the corresponding track's send device
--
-- Document (preferences-per song!) structure
--  |
--  +--- MixDown track (reference to track, track #, send track #)
--  +--- Force yes/no (to temporarily disable this behaviour)
--
-- maintaining the list is stupid. we can only replace the last send devices in the
-- dsp lists, IF they point to the mixdown track as receiver. making the list is
-- very easy, just check if a track is not the mixdown track itself, and whether
-- its routing would otherwise go towards the Master track. This is also enough
-- of a sanity check (and maybe even quicker than looking it up in the list) to
-- have before finding a tracks last send device and adjusting the amount.
--
-- also, checking to see if a send directs to the mixdown channel is the only
-- check one has, save from the dsp being the last device in the chain. having
-- the send amount and the postfx_volume equivalent might give that little bit
-- of you know, confidence. hmmm.
-- there is still no way we can find out if the device is on keep or mute mode.
--
-- keep a list of send devices added by this tool? might that help? a lot?


--renoise.tool():add_keybinding {
  --name = "Mixer:Create MixDown Track",
  --invoke = function()
    --create_mixdown_track()
  --end
--}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Create MixDown Track",
  invoke = function()
    create_mixdown_track()
  end
}

function create_mixdown_track()
  local rs = renoise.song()
  --local force = show_dialog()
  local force = "No"
  local mixdowntrack

  if force == "Yes" then
    -- TODO: use tracks observable to revise sends on added tracks
    -- TODO: use postfx_volume observable on tracks eligible for mixdown send routing
    renoise.app():show_error("Not fully implemented yet :(")
  else
    local mixdowntrackpos = -1
    for i, x in ipairs(rs.tracks) do
      if x.name == "MixDown" then
        mixdowntrackpos = i
        mixdowntrack = x
        renoise.app():show_warning("Using already available send track 'MixDown' at position #"..i)
      end
    end
    rs:describe_undo("Create mixdown track")
    if mixdowntrackpos == -1 then
      mixdowntrackpos = #rs.tracks + 1
      mixdowntrack = rs:insert_track_at(mixdowntrackpos)
    end
    mixdowntrack.name = "MixDown"
    for track_id, track in pairs(rs.tracks) do
      if track.type ~= renoise.Track.TRACK_TYPE_MASTER and track_id ~= mixdowntrackpos and track.output_routing == "Master" then
        local device = track.insert_device_at(track, tostring("Audio/Effects/Native/#Send"), #track.devices+1)
        device.parameters[3].value = rs.send_track_count-1
        -- TODO: check for postfx_volume above 0dB; create gainer?
        device.parameters[1].value = track.postfx_volume.value
      end
    end
  end
end

function show_dialog()
  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN

  local prompt = renoise.app():show_prompt("Force all tracks to mixdown?", "You are about to create a so-called MixDown bus, an extra send track where all other tracks will be routed to. Do you want to link the Send-To-MixDown behaviour to the post-volume sliders and force sending for new tracks?", {"Yes", "No"})
  return prompt
end
