-------------------------------------------------------------
-- MidiZoomSelect v0.1 by Cas Marrav (for Renoise 2.8)     --
-------------------------------------------------------------

local rs, smp, len, step

-- functions --
local function lzoom(mm)
  local smp = renoise.song().selected_sample
  if smp.sample_buffer.has_sample_data then
    smp.sample_buffer.display_range = { (smp.sample_buffer.display_range[2]-2) * mm.int_value / 127 + 1, smp.sample_buffer.display_range[2] }
  end
end
local function rzoom(mm)
  local smp = renoise.song().selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = smp.sample_buffer.display_range[1]
    local max = smp.sample_buffer.number_of_frames
    smp.sample_buffer.display_range = { smp.sample_buffer.display_range[1], (max-min) * mm.int_value / 127 + min + 1 }
  end
end

local function lsel(mm)
  local smp = renoise.song().selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = smp.sample_buffer.display_range[1]
    local max = smp.sample_buffer.display_range[2]
    smp.sample_buffer.selection_start = (max-min) * mm.int_value / 127 + min + 1
  end
end
local function rsel(mm)
  local smp = renoise.song().selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = smp.sample_buffer.display_range[1]
    local max = smp.sample_buffer.display_range[2]
    smp.sample_buffer.selection_end = (max-min) * mm.int_value / 127 + min + 1
  end
end

local function lloop(mm)
  local smp = renoise.song().selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = smp.sample_buffer.display_range[1]
    local max = math.min(smp.loop_end, smp.sample_buffer.display_range[2])
    smp.loop_start = (max-min) * mm.int_value / 127 + min
  end
end
local function rloop(mm)
  local smp = renoise.song().selected_sample
  if smp.sample_buffer.has_sample_data then
    local min = math.max(smp.loop_start, smp.sample_buffer.display_range[1])
    local max = smp.sample_buffer.display_range[2]
    smp.loop_end = (max-min-1) * mm.int_value / 127 + min
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
