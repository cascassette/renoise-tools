-------------------------------------------------------------
-- Render Track No FX v0.1 by Cas Marrav (for Renoise 2.8) --
-------------------------------------------------------------

-- Vars
local indexes_on = {}
local indexes_mst_on = {}
local dialog, rote
local rs
local vb
local fn

-- Idle callback to display progress
local function idle_callback()
  rote.value = rs.rendering_progress
end

-- Callback when rendering done
local function render_done_callback()
  -- read wav file back in
  rs.selected_instrument:sample(1).sample_buffer:load_from(fn)
  rs.selected_instrument.name = rs.selected_track.name.." Render"
  
  -- close window
  dialog:close()
  
  -- let em know
  renoise.app():show_status("Render Track without FX: Done.")
  
  -- reset device on/off statuses
  for i,d in ipairs(rs.selected_track.devices) do
    d.is_active = indexes_on[i]
  end
  for i,d in ipairs(rs:track(rs.sequencer_track_count+1).devices) do
    d.is_active = indexes_mst_on[i]
  end
  
  -- unsolo track
  rs.selected_track.solo_state = false
  
  -- remove notifier
  renoise.tool().app_idle_observable:remove_notifier(idle_callback)
  
  -- remove temp file
  os.remove(fn)
end

-- Main --
local function rendertracknofx(selection)
  rs=renoise.song()
  if rs.rendering then
    -- abort
    renoise.app():show_status("Rendering in progress, track freezing not available.")
    return
  end
  -- re-init
  indexes_on = {}
  indexes_mst_on = {}
  vb = renoise.ViewBuilder()
  if rs.transport.playing then
    rs.transport.panic()
  end
  --[[if (not (#rs.selected_instrument.samples>0 and rs.selected_instrument:sample(1).sample_buffer.has_sample_data)) and 
     (not falsers.selected_instrument.plugin_properties.plugin_loaded) and 
     (rs.selected_instrument.midi_output_properties.device_name == "") then
    -- instrument non empty - have to make new instrument
    -- try to first select instrument used on current track so you keep the order a bit
    rs:capture_nearest_instrument_from_pattern()
    rs:insert_instrument_at(rs.selected_instrument_index+1)
    rs.selected_instrument_index = rs.selected_instrument_index+1
  end]]
  rs:capture_nearest_instrument_from_pattern()
  rs:insert_instrument_at(rs.selected_instrument_index+1)
  rs.selected_instrument_index = rs.selected_instrument_index+1
  
  -- get temporary filename
  fn = os.tmpname("wav")
  
  -- info for current track (during rendering, current track can't be changed, thus we won't have to save that)
  local cti = rs.selected_track_index
  local ct = rs.selected_track
  
  -- save state for all devices in current track, then turn them off
  for i,d in ipairs(ct.devices) do
    indexes_on[i] = d.is_active
    if i ~= 1 then  -- don't try to disable the 'mixer' device
      d.is_active = false
    end
  end
  -- save state for all devices in master track, then turn them off
  for i,d in ipairs(rs:track(rs.sequencer_track_count+1).devices) do
    indexes_mst_on[i] = d.is_active
    if i ~= 1 then  -- don't try to disable the 'mixer' device
      d.is_active = false
    end
  end
  
  -- make a window to display the rendering_progress
  rote = vb:rotary { value = 0.0, id = "rote" }
  
  -- solo the track;
  -- first, figure out if we need to "unsolo all" aka if anything is solo'ed right now
  local anysolo = false
  for i,t in ipairs(rs.tracks) do
    if t.solo_state then
      anysolo = true
      break
    end
  end
  if anysolo then
    rs:track(rs.sequencer_track_count+1):solo()
  end
  -- solo the track
  rs.selected_track:solo()
  
  -- figure out start and end pos
  local epos,spos
  if selection then
    spos = renoise.SongPos(rs.transport.edit_pos.sequence, 1)
    epos = renoise.SongPos(rs.transport.edit_pos.sequence, rs.selected_pattern.number_of_lines)
  else
    spos = renoise.SongPos(rs.transport.edit_pos.sequence, rs.selection_in_pattern.start_line)
    epos = renoise.SongPos(rs.transport.edit_pos.sequence, rs.selection_in_pattern.end_line)
  end
  
  -- render the pattern (callback function will reset the devices to original state)
  renoise.song():render({start_pos = spos,
                         end_pos = epos,
                         --bit_depth = renoise.tool().preferences.bitdepth.value,
                         --interpolation = "cubic",  --renoise.tool().preferences.interpolation.value,
                         priority = 'low'  --priority = renoise.tool().preferences.priority.value,   -- default: high
                        },
                        fn, render_done_callback)
  
  -- show window
  dialog = renoise.app():show_custom_dialog( "Rendering..", vb:row { rote } )
  
  -- register idle_observable listener to display progress
  renoise.tool().app_idle_observable:add_notifier(idle_callback)
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Render Track No FX",
  invoke = function() rendertracknofx(false) end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Render Selection No FX",
  invoke = function() rendertracknofx(true) end
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Pattern Editor:Track Operations:Render Track No FX",
  invoke = function() rendertracknofx(false) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Track Operations:Render Selection No FX",
  invoke = function() rendertracknofx(true) end
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
