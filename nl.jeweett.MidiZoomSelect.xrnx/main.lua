-------------------------------------------------------------
-- MidiZoomSelect v0.1 by Cas Marrav (for Renoise 2.8)     --
-------------------------------------------------------------

local rs, smp, len, step

-- functions --
local function lzoom(mm)
  local nv = mm.int_value  -- [0..127]
  rs = renoise.song()
  smp = rs.selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = 1
    local max = smp.sample_buffer.number_of_frames
    len = max-min
    step = math.floor(len/129)
    local rzoom = smp.sample_buffer.display_range[2]
    if nv*step+min < rzoom then
      smp.sample_buffer.display_range = { nv*step+min, rzoom }
    end
  end
end
local function rzoom(mm)
  local nv = mm.int_value+1  -- [0..127]
  rs = renoise.song()
  smp = rs.selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = 1
    local max = smp.sample_buffer.number_of_frames
    len = max-min
    step = math.floor(len/129)
    local lzoom = smp.sample_buffer.display_range[1]
    if nv == 128 then smp.sample_buffer.display_range = { lzoom, max }
    elseif nv*step+min > lzoom then
      smp.sample_buffer.display_range = { lzoom, nv*step+min }
    end
  end
end

local function lsel(mm)
  local nv = mm.int_value  -- [0..127]
  rs = renoise.song()
  smp = rs.selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = smp.sample_buffer.display_range[1]
    local max = smp.sample_buffer.display_range[2] --smp.sample_buffer.number_of_frames
    len = max-min
    step = math.floor(len/129)
    local rsel = smp.sample_buffer.selection_end
    if nv*step+min < rsel then
      smp.sample_buffer.selection_start = nv*step+min
    end
  end
end
local function rsel(mm)
  local nv = mm.int_value+1  -- [0..127]
  rs = renoise.song()
  smp = rs.selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = smp.sample_buffer.display_range[1]
    local max = smp.sample_buffer.display_range[2]
    len = max-min
    step = math.floor(len/129)
    local lsel = smp.sample_buffer.selection_start
    if nv == 128 then smp.sample_buffer.selection_end = max
    elseif nv*step+min > lsel then
      smp.sample_buffer.selection_end = nv*step+min
    end
  end
end

local function lloop(mm)
  local nv = mm.int_value  -- [0..127]
  rs = renoise.song()
  smp = rs.selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = smp.sample_buffer.display_range[1]
    local max = smp.sample_buffer.display_range[2]
    len = max-min
    step = math.floor(len/129)
    local rloop = smp.loop_end
    if nv*step+min < rloop then
      smp.loop_start = nv*step+min
    end
  end
end
local function rloop(mm)
  local nv = mm.int_value+1  -- [0..127]
  rs = renoise.song()
  smp = rs.selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = smp.sample_buffer.display_range[1]
    local max = smp.sample_buffer.display_range[2]
    len = max-min
    step = math.floor(len/129)
    local lloop = smp.loop_start
    if nv == 128 then smp.loop_end = max
    elseif nv*step+min > lloop then
      smp.loop_end = nv*step+min
    end
  end
end

-- midi binds --
renoise.tool():add_midi_mapping {
  name = "MidiZoomSelect:Selection Left marker",
  invoke = lsel
}
renoise.tool():add_midi_mapping {
  name = "MidiZoomSelect:Selection Right marker",
  invoke = rsel
}
renoise.tool():add_midi_mapping {
  name = "MidiZoomSelect:Zoom Left marker",
  invoke = lzoom
}
renoise.tool():add_midi_mapping {
  name = "MidiZoomSelect:Zoom Right marker",
  invoke = rzoom
}
renoise.tool():add_midi_mapping {
  name = "MidiZoomSelect:Loop Left marker",
  invoke = lloop
}
renoise.tool():add_midi_mapping {
  name = "MidiZoomSelect:Loop Right marker",
  invoke = rloop
}

-- reload --
_AUTO_RELOAD_DEBUG = function()
end
