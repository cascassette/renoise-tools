--[[==========================================================================||
||                                B A S E M E N T   1                         ||
||==========================================================================]]--

--------------------------------------------------------------------------------
-- Placeholder for the dialog and other gui stuff
--------------------------------------------------------------------------------
local dialog = nil
local vb = nil
local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
local DM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN

--------------------------------------------------------------------------------
-- Song placeholder
--------------------------------------------------------------------------------
local rs = nil

--------------------------------------------------------------------------------
-- Which Basement dialog is active?
--------------------------------------------------------------------------------
local BASEMENT_VIEW_NONE = 0
local BASEMENT_VIEW_DEFAULT = 1
local BASEMENT_VIEW_MIXER = 2
local BASEMENT_VIEW_HYDRAS = 3
local BASEMENT_VIEW_INSERT = 4
local BASEMENT_VIEW_EFFECT = 5
local BASEMENT_VIEW_INSTRUMENT = 6
local BASEMENT_VIEW_SLICE = 7
local BASEMENT_VIEW_SYNTH = 8
local BASEMENT_VIEW_TEST = 99

local basement_active_view = BASEMENT_VIEW_NONE

--------------------------------------------------------------------------------
-- MIDI Feedback stuff for MPKMini Pads
--------------------------------------------------------------------------------
local PAD_CC  = { 116, 117, 118, 119, 112, 113, 114, 115, 124, 125, 126, 127, 120, 121, 122, 123 }
--local mpk_out = renoise.Midi.create_output_device(renoise.Midi.available_output_devices()[3])
--local mpk_out = renoise.Midi.create_output_device("MPK mini MIDI 1")
local mpk_out = renoise.Midi.create_output_device("MPK mini")

--------------------------------------------------------------------------------
-- Placeholders for GUI fields accessible in MIDI callback procedures
--------------------------------------------------------------------------------
local vtest_infotxt = nil

local vdefault_knoba = nil
local vdefault_knobb = nil
local vdefault_knobc = nil
local vdefault_knobd = nil
local vdefault_knobe = nil
local vdefault_knobf = nil
local vdefault_knobg = nil
local vdefault_knobh = nil
local vdefault_infotxt = nil

--[[local vmixer_knoba = nil
local vmixer_knobb = nil
local vmixer_knobc = nil
local vmixer_knobd = nil
local vmixer_knobe = nil
local vmixer_knobf = nil
local vmixer_knobg = nil
local vmixer_knobh = nil
local vmixer_desca = nil
local vmixer_descb = nil
local vmixer_descc = nil]]

local vhydras_knoba = nil
local vhydras_knobb = nil
local vhydras_knobc = nil
local vhydras_knobd = nil
local vhydras_knobe = nil
local vhydras_knobf = nil
local vhydras_knobg = nil
local vhydras_knobh = nil

local vinsert_knoba = nil
local vinsert_knobb = nil
local vinsert_knobc = nil
local vinsert_knobd = nil
local vinsert_tab = nil
local vinsert_infotxt = nil
local vinsert_trk = nil
local vinsert_dsp = nil
local vinsert_pos = nil
local vinsert_act = nil

local veffect_knobs = {}

local vinstrument_knoba = nil
local vinstrument_knobb = nil
local vinstrument_knobc = nil
local vinstrument_knobd = nil
local vinstrument_knobe = nil
local vinstrument_knobf = nil
local vinstrument_knobg = nil
local vinstrument_knobh = nil

local vslice_knobsel = nil
local vslice_knobfunc = nil
local vslice_knoba = nil
local vslice_knobb = nil
local vslice_knobx = nil
local vslice_knoby = nil
local vslice_knobc = nil
local vslice_knobd = nil
local vslice_labela = nil
local vslice_labelb = nil
local vslice_labelx = nil
local vslice_labely = nil
local vslice_labelc = nil
local vslice_labeld = nil
local vslice_infotxt = nil
local vslice_smp = nil
local vslice_fnc = nil

--[[local vsynth_knoba = nil
local vsynth_knobb = nil
local vsynth_knobc = nil
local vsynth_knobd = nil
local vsynth_knobe = nil
local vsynth_knobf = nil
local vsynth_knobg = nil
local vsynth_knobh = nil
local vsynth_boxa = nil
local vsynth_boxb = nil
local vsynth_boxc = nil
local vsynth_boxd = nil
local vsynth_boxe = nil
local vsynth_boxf = nil
local vsynth_boxg = nil
local vsynth_boxh = nil]]

--------------------------------------------------------------------------------
-- Other variables and constants used in MIDI callback procedures
--------------------------------------------------------------------------------
local default_hydraf = nil
local default_hydraq = nil

local default_MSPM = 60000
local default_DPL = 256
local DEFAULT_EDITSTEPOPTS = { 0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64 }

--[[local mixer_tra = nil
local mixer_trb = nil
local mixer_trc = nil
local mixer_trm = nil]]

local HYDRAS_HYDRAPATH = "Audio/Effects/Native/*Hydra"
local hydras_hydras = {}
local hydras_names = {}
local hydras_sv = {}

--local INSERT_NATIVE_SWITCH = "native"
local insert_avdev = {}
local insert_track_names = {}
local insert_device_names = {}
local insert_position_names = {}

local effect_effect = nil
local effect_params = {}
local effect_pnames = {}

--local instrument_NNA_MODE_NAMES = { "Cut", "Note Off", "Continue" }
local instrument_sample = nil
local instrument_sample_index = 1
local instrument_samples = {}
local instrument_apply_to_all = false

local SLICE_FUNC_ZOOM = 1
local SLICE_FUNC_SLICE = 2
local SLICE_FUNC_REVERSE = 3
local SLICE_FUNC_CANCEL = 4
--[[
local SLICE_FUNC_SYNC = 4
local SLICE_FUNC_INS = 5
local SLICE_FUNC_VIEW = 6]]
local SLICE_LOOP_MODE_NAMES = { "Off", "Forward", "Backward", "PingPong" }
local SLICE_SLICEOPTS = { 0, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64 }
local slice_oldmarkers = {}
--local SLICE_SHORT = { "X",     "CUT",   "REV",     "SYNC",      "ZOOM", "INS",         "VIEW" }
--local SLICE_FUNCS = { "Close", "Slice", "Reverse", "Beat Sync", "Zoom", "Delay (Fit)", "Sample View Mode" }
local SLICE_SHORT = { "ZOOM", "CUT",   "REV",     "CANCEL", }
local SLICE_FUNCS = { "Zoom", "Slice", "Reverse", "Cancel", }
local slice_func = SLICE_FUNC_SLICE
local SLICE_FUNC_ZOOM_VERTICAL = 1
local SLICE_FUNC_ZOOM_SELECT = 2
local SLICE_FUNC_ZOOM_LOOPMRK = 3
local SLICE_SUBZOOM_FUNCS = { "Vert", "Select", "Loop" }
local SLICE_SUBZOOM_DESCS = { "Zoom+Select+Vertical zoom", "Zoom+Select+Functions", "Zoom+Loop markers" }
local SLICE_FUNC_ZOOM_SELECT_LOOP = 1
local SLICE_FUNC_ZOOM_SELECT_INST = 2
local SLICE_FUNC_ZOOM_SELECT_SAMP = 3
local SLICE_FUNC_ZOOM_SELECT_NONE = 4
local SLICE_SUBSELECT_FUNCS = { "LOOP",           "INST",                             "SAMP",                         "NONE",      }
local SLICE_SUBSELECT_DESCS = { "Loop selection", "Copy selection to new Instrument", "Copy selection to new Sample", "No action", }

--[[
local SYNTH_MAX_OPS = 4
local SYNTH_SAMPLE_BIT_DEPTH = 32
local SYNTH_SAMPLE_FREQUENCY = 44100 --this should be set to the driver' sample rate
local SYNTH_SAMPLE_CHANS = 1
local SYNTH_WAVETYPE_SIN = 1
local SYNTH_WAVETYPE_SAW = 2
local SYNTH_WAVETYPE_SQU = 3
local SYNTH_WAVETYPE_TRI = 4
local SYNTH_WAVETYPE_NOI = 5
local SYNTH_WAVETYPE_NAMES = { "Sine", "Sawtooth", "Square", "Triangle", "Noise" }
local SYNTH_WHICHTONE_NOR = 1
local SYNTH_WHICHTONE_EVE = 2
local SYNTH_WHICHTONE_ODD = 3
local SYNTH_WHICHTONE_EXP = 4
local SYNTH_WHICHTONE_TRI = 5
local SYNTH_WHICHTONE_PNT = 6
local SYNTH_WHICHTONE_NAMES = { "All", "Even", "Odd", "Exponential 2^N", "Exponential 3^N", "Exponential 5^N" }
local SYNTH_OVERTONE_FAT = 1    -- no decay
local SYNTH_OVERTONE_NOR = 2    -- N (linear) decay
local SYNTH_OVERTONE_DBL = 3    -- 2*N decay
local SYNTH_OVERTONE_EXP = 4    -- 2^N decay
local SYNTH_OVERTONE_NAMES = { "Full", "Normal", "2xNormal" }
local SYNTH_OPMODE_ADD = 1
local SYNTH_OPMODE_MOD = 2
local SYNTH_OPMODE_NAMES = { "Add", "Mod" }
local SYNTH_FREQMULT_NAMES = { 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
local SYNTH_MAX_OVERTONES = 99
local synth_wavetypes = {}
local synth_whichtones = {}
local synth_overtones = {}
local synth_opmodes = {}
local synth_freqmults = {}
local synth_phaseshifts = {}
local synth_ampfactors = {}
]]


--------------------------------------------------------------------------------
-- Helper functions
--------------------------------------------------------------------------------

local function mod_midi_value(mv, min, max, integer)
  if integer then
    local nv = mv / 128
    return math.floor(nv*(max-min + 1)+min)
  else
    local nv = mv / 127
    return (nv*(max-min)+min)
  end
end

local function bool_to_int(bool)
  if bool then return 1 else return 0 end
end

local function int_to_bool(int)
  if int == 0 then return false else return true end
end

local function send_midi_cc_feedback(number, value)
  mpk_out:send({ 179, number, value })
end

local function insertfx(track_no, device_path, insert_spot, active)
  rs = renoise.song()
  local device = rs:track(track_no):insert_device_at(device_path, insert_spot+1)
  if not active then
    device.is_active = false
  end
end

local function vis_tracks()
  rs = renoise.song()
  local c = 0
  local res = {}
  for i, t in ipairs(rs.tracks) do
    if t.type == 3 or t.type == 2 then
      c = c + 1
      res[c] = i
    else
      local p = t.group_parent
      local stillopen = true
      while stillopen and p ~= nil do
        if p.group_collapsed then
          stillopen = false
        end
        p = p.group_parent
      end
      if stillopen then
        c = c + 1
        res[c] = i
      end
    end
  end
  return res
end

local track_index_property = property(function(self)
  for index, track in ipairs(renoise.song().tracks) do
    if (rawequal(self, track)) then
      return index
    end
  end
end)
renoise.Track.track_index = track_index_property
renoise.GroupTrack.track_index = track_index_property

function find_leaves_indexes(self)
  local list = table.create()
  for _, t in ipairs(self.members) do
    if t.type == 1 then
      list:insert(t.track_index)
    elseif t.type == 4 then
      local sublist = find_leaves_indexes(t)
      for i = 1, #sublist do
        list:insert(sublist[i])
      end
    end
  end
  return list
end
local grouptrack_leaves_indexes_property = property(find_leaves_indexes)
renoise.GroupTrack.leaves_indexes = grouptrack_leaves_indexes_property


--------------------------------------------------------------------------------
-- GUI functions
--------------------------------------------------------------------------------

local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
  basement_active_view = BASEMENT_VIEW_NONE
  for i=9,12 do
    send_midi_cc_feedback(PAD_CC[i], 0)
  end
  send_midi_cc_feedback(PAD_CC[16], 0)
end

local function key_default(d, k)
  if k.name == "esc" then
    close_dialog()
  end
end

-- BASEMENT_VIEW_TEST Mode
local function show_test_dialog()
  if basement_active_view == BASEMENT_VIEW_TEST then
    close_dialog()
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end
    
    vb = renoise.ViewBuilder()
    vtest_infotxt = vb:text { text = "Info container" }
    local dialog_content = vb:row {
      margin = 2*DM, style = "border", width = 300,
      vtest_infotxt
    }
    dialog = renoise.app():show_custom_dialog( "Basement: Inactive (test)", dialog_content, key_default )
    basement_active_view = BASEMENT_VIEW_TEST
  end
end

-- BASEMENT_VIEW_DEFAULT Mode
local function show_default_dialog()
  if basement_active_view == BASEMENT_VIEW_DEFAULT then
    close_dialog()
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end
    
    vb = renoise.ViewBuilder()
    rs = renoise.song()
    
    local shiftval
    local bpm = rs.transport.bpm
    local lpb = rs.transport.lpb
    local dedelay_base = (default_MSPM / bpm / lpb / default_DPL)
    shiftval = rs.selected_track.output_delay / dedelay_base + 256
    
    local msttrkvol = rs:track(rs.sequencer_track_count+1):device(1):parameter(5)

    local qntval = 0
    if rs.transport.record_quantize_enabled then qntval = rs.transport.record_quantize_lines end
    
    local kbvval = 0
    if rs.transport.keyboard_velocity_enabled then kbvval = rs.transport.keyboard_velocity end
    
    default_hydraf = nil
    default_hydraq = nil
    if rs:track(#rs.tracks).name == "MixDown" then
      if #rs:track(#rs.tracks).devices > 3 then
        if rs:track(#rs.tracks):device(2).display_name == "@F" and rs:track(#rs.tracks):device(3).display_name == "@Q" then
          default_hydraf = rs:track(#rs.tracks):device(2)
          default_hydraq = rs:track(#rs.tracks):device(3)
        end
      end
    else
      if #rs:track(rs.sequencer_track_count+1).devices > 3 then
        if rs:track(rs.sequencer_track_count+1):device(2).display_name == "@F" and rs:track(rs.sequencer_track_count+1):device(3).display_name == "@Q" then
          default_hydraf = rs:track(rs.sequencer_track_count+1):device(2)
          default_hydraq = rs:track(rs.sequencer_track_count+1):device(3)
        end
      end
    end
        
    vdefault_knoba = vb:rotary {
        min = 0,
        max = 8,
        value = rs.transport.octave,
    }
    vdefault_knobb = vb:rotary {
        min = 0,
        max = 512,
        value = math.max(math.min(shiftval, 512), 0),
    }
    vdefault_knobc = vb:rotary {
        min = 32,
        max = 128,
        value = rs.transport.bpm,
    }
    vdefault_knobd = vb:rotary {
        min = msttrkvol.value_min,
        max = msttrkvol.value_max,
        value = msttrkvol.value,
    }
    vdefault_knobe = vb:rotary {
        min = 0,
        max = 32,
        value = qntval,
    }
    vdefault_knobf = vb:rotary {
        min = 0,
        max = 128,
        value = kbvval,
        active = rs.transport.keyboard_velocity_enabled,
    }
    vdefault_infotxt = vb:text {
        width = "100%",
        text = "Track Shift is "..math.floor(shiftval-256)
    }
    if default_hydraf ~= nil and default_hydraq ~= nil then
      vdefault_knobg = vb:rotary {
          min = default_hydraf:parameter(1).value_min,
          max = default_hydraf:parameter(1).value_max,
          value = default_hydraf:parameter(1).value,
      }
      vdefault_knobh = vb:rotary {
          min = default_hydraq:parameter(1).value_min,
          max = default_hydraq:parameter(1).value_max,
          value = default_hydraq:parameter(1).value,
      }
    else
      vdefault_knobg = vb:rotary {
          min = 0,
          max = 1,
          value = 0.5,
          active = false,
      }
      vdefault_knobh = vb:rotary {
          min = 0,
          max = 1,
          value = 0.0,
          active = false,
      }
    end
    local dialog_content = vb:column {
      margin = 2*DM, style = "border", --[[width = 300,--]]
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vdefault_knoba,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Oct" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vdefault_knobb,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Shift" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vdefault_knobc,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "BPM" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vdefault_knobd,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "M Vol" },
          },
        },
      },
      vb:row {
        height = 24,
      },
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vdefault_knobe,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Quant" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vdefault_knobf,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "KB Vel." },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vdefault_knobg,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "F" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vdefault_knobh,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Q" },
          },
        },
      },
      vb:row {
        height = 12,
      },
      vb:row {
        style = "border",
        width = "100%",
        vdefault_infotxt,
      },
    }
    dialog = renoise.app():show_custom_dialog( "Basement: Global (default)", dialog_content, key_default )
    basement_active_view = BASEMENT_VIEW_DEFAULT
    send_midi_cc_feedback(PAD_CC[16], 1)
  end
end

-- BASEMENT_VIEW_MIXER Mode
local function show_mixer_dialog()
  if basement_active_view == BASEMENT_VIEW_MIXER then
    close_dialog()
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end
    
    vb = renoise.ViewBuilder()
    rs = renoise.song()
    local VOLMIN = rs:track(1).postfx_volume.value_min
    local VOLMAX = rs:track(1).postfx_volume.value_max
    local PANMIN = rs:track(1).postfx_panning.value_min
    local PANMAX = rs:track(1).postfx_panning.value_max
    local ct = rs.selected_track_index
    -- control 3 tracks at the same time max
    if ct < 2 then ct = 2 elseif ct > (#rs.tracks-1) then ct = (#rs.tracks-1) end
    rs.selected_track_index = ct
    mixer_tra = rs:track(rs.selected_track_index-1)
    mixer_trb = rs.selected_track
    mixer_trc = rs:track(rs.selected_track_index+1)
    mixer_trm = rs:track(rs.sequencer_track_count+1)
    local MSTMIN = mixer_trm.postfx_volume.value_min
    local MSTMAX = mixer_trm.postfx_volume.value_max
    
    vmixer_knoba = vb:rotary {
        min = 2,
        max = #rs.tracks-1,
        value = ct,
    }
    vmixer_knobb = vb:rotary {
        min = PANMIN,
        max = PANMAX,
        value = mixer_tra.postfx_panning.value,
    }
    vmixer_knobc = vb:rotary {
        min = PANMIN,
        max = PANMAX,
        value = mixer_trb.postfx_panning.value,
    }
    vmixer_knobd = vb:rotary {
        min = PANMIN,
        max = PANMAX,
        value = mixer_trc.postfx_panning.value,
    }
    vmixer_knobe = vb:rotary {
        min = MSTMIN,
        max = MSTMAX,
        value = mixer_trm.postfx_volume.value,
    }
    vmixer_knobf = vb:rotary {
        min = VOLMIN,
        max = VOLMAX,
        value = mixer_tra.postfx_volume.value,
    }
    vmixer_knobg = vb:rotary {
        min = VOLMIN,
        max = VOLMAX,
        value = mixer_trb.postfx_volume.value,
    }
    vmixer_knobh = vb:rotary {
        min = VOLMIN,
        max = VOLMAX,
        value = mixer_trc.postfx_volume.value,
    }
    vmixer_desca = vb:text { text = mixer_tra.name }
    vmixer_descb = vb:text { text = mixer_trb.name }
    vmixer_descc = vb:text { text = mixer_trc.name }
    local dialog_content = vb:column {
      margin = 2*DM, style = "border", --[[width = 300,--]]
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_knoba,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Select" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_knobb,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Pan/Vol" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_knobc,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Pan/Vol" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_knobd,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Pan/Vol" },
          },
        },
      },
      vb:row {
        height = 24,
      },
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_knobe,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Master" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_knobf,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_desca,
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_knobg,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_descb,
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_knobh,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vmixer_descc,
          },
        },
      },
    }
    dialog = renoise.app():show_custom_dialog( "Basement: Levels (mixer)", dialog_content, key_default )
    basement_active_view = BASEMENT_VIEW_MIXER
    send_midi_cc_feedback(PAD_CC[11], 1)
  end
end

-- BASEMENT_VIEW_HYDRAS Mode
local function show_hydras_dialog()
  if basement_active_view == BASEMENT_VIEW_HYDRAS then
    close_dialog()
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end
    
    vb = renoise.ViewBuilder()
    rs = renoise.song()
    
    -- bind the 8 possible "@hydras", as many as there are
    -- set hydras_hydras, hydras_names and hydras_sv for each
    local maxdev = #rs.selected_track.devices
    local nowdev = math.max(rs.selected_device_index, 2)  -- start from currently selected device, or start left
    hydras_hydras = {}
    hydras_names = {}
    hydras_sv = {}
    local hindexes = {}
    -- first enumerate every possible hydra
    local c = 0
    local cl = 0
    local cr = 0
    for i = 2, maxdev do
      local dev = rs.selected_track:device(i)
      if (dev.device_path == HYDRAS_HYDRAPATH) and (dev.is_active) and (dev.display_name:sub(1, 1) == "@") then
        c = c + 1
        if i < nowdev then cl = cl + 1 else cr = cr + 1 end
        hindexes[c] = i
      end
    end
    -- then, see which 8 we want to see
    if c <= 8 then
      for i = 1, c do
        local dev = rs.selected_track:device(hindexes[i])
        hydras_hydras[i] = dev
        hydras_names[i] = dev.display_name:sub(2)
        hydras_sv[i] = dev:parameter(1).value
      end
      for i = c+1, 8 do
        hydras_hydras[i] = nil
        hydras_names[i] = "none"
        hydras_sv[i] = 0.0
      end
    else
      local rr = math.min(8, cr)
      local rl = 8 - rr
      local offset = cl - rl
      print (rr + rl == 8)
      for i = 1, rl do
        local dev = rs.selected_track:device(hindexes[i+offset])
        hydras_hydras[i] = dev
        hydras_names[i] = dev.display_name:sub(2)
        hydras_sv[i] = dev:parameter(1).value
      end
      for i = rl+1, 8 do
        local dev = rs.selected_track:device(hindexes[i+offset])
        hydras_hydras[i] = dev
        hydras_names[i] = dev.display_name:sub(2)
        hydras_sv[i] = dev:parameter(1).value
      end
    end
    
    vhydras_knoba = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = hydras_sv[1],
        active = (hydras_hydras[1] ~= nil)
    }
    vhydras_knobb = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = hydras_sv[2],
        active = (hydras_hydras[2] ~= nil)
    }
    vhydras_knobc = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = hydras_sv[3],
        active = (hydras_hydras[3] ~= nil)
    }
    vhydras_knobd = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = hydras_sv[4],
        active = (hydras_hydras[4] ~= nil)
    }
    vhydras_knobe = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = hydras_sv[5],
        active = (hydras_hydras[5] ~= nil)
    }
    vhydras_knobf = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = hydras_sv[6],
        active = (hydras_hydras[6] ~= nil)
    }
    vhydras_knobg = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = hydras_sv[7],
        active = (hydras_hydras[7] ~= nil)
    }
    vhydras_knobh = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = hydras_sv[8],
        active = (hydras_hydras[8] ~= nil)
    }
    local dialog_content = vb:column {
      margin = 2*DM, style = "border",
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vhydras_knoba,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = hydras_names[1] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vhydras_knobb,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = hydras_names[2] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vhydras_knobc,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = hydras_names[3] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vhydras_knobd,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = hydras_names[4] },
          },
        },
      },
      vb:row {
        height = 24,
      },
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vhydras_knobe,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = hydras_names[5] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vhydras_knobf,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = hydras_names[6] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vhydras_knobg,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = hydras_names[7] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vhydras_knobh,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = hydras_names[8] },
          },
        },
      },
    }
    --print("nowdev: "..nowdev.."    maxdev: "..maxdev.."     c: "..c)
    if c > 0 then
      dialog = renoise.app():show_custom_dialog( "Basement: Shape (hydras)", dialog_content, key_default )
      basement_active_view = BASEMENT_VIEW_HYDRAS
      send_midi_cc_feedback(PAD_CC[12], 1)
    end
  end
end

-- BASEMENT_VIEW_INSERT Mode
local function insert_updateinfotxt()
  -- update info txt
  local actstr = ""
  if not vinsert_act.value then actstr = ", inactively" end
  vinsert_infotxt.text = "Insert a " .. insert_device_names[vinsert_dsp.value] .. " on track# " .. vinsert_trk.value .. " " .. insert_track_names[vinsert_trk.value] .. " at pos " .. vinsert_pos.value .. " (after " .. insert_position_names[vinsert_pos.value] .. ")" .. actstr .. "?"
end
local function insert_update_track(track_no)
  -- refresh avdev, device_names and position_names
  local old_dsp = vinsert_dsp.value
  local old_pos = vinsert_pos.value
  insert_avdev = {}
  insert_device_names = {}
  insert_position_names = {}
  for i,f in ipairs(rs:track(track_no).available_devices) do
    if f:sub(1,20) == "Audio/Effects/Native" then
      insert_avdev[i] = f
      insert_device_names[i] = f:sub(-f:reverse():find("/")+1)
    end
  end
  for i = 1, #rs:track(track_no).devices do
    insert_position_names[i] = rs.selected_track:device(i).display_name
  end
  -- available devices gui update
  vinsert_dsp.items = insert_device_names
  vinsert_dsp.value = old_dsp
  vinsert_knobb.max = #insert_device_names
  vinsert_knobb.value = old_dsp
  -- available positions gui update
  vinsert_pos.items = insert_position_names
  vinsert_pos.value = #insert_position_names
  vinsert_knobc.max = #insert_position_names
  vinsert_knobc.value = #insert_position_names
end
local function key_insert(d, k)
  local tab = vinsert_tab.value
  if k.name == "esc" then
    close_dialog()
  elseif k.name == "down" then
    if tab == 1 then
      vinsert_trk.value = vinsert_trk.value - 1
      vinsert_knoba.value = vinsert_trk.value
      insert_update_track(vinsert_trk.value)
    elseif tab == 2 then
      vinsert_dsp.value = vinsert_dsp.value - 1
      vinsert_knobb.value = vinsert_dsp.value
    elseif tab == 3 then
      vinsert_pos.value = vinsert_pos.value - 1
      vinsert_knobc.value = vinsert_pos.value
    elseif tab == 4 then
      vinsert_act.value = not vinsert_act.value
      if vinsert_act.value then
        vinsert_knobd.value = 1
      else
        vinsert_knobd.value = 0
      end
    end
  elseif k.name == "up" then
    if tab == 1 then
      vinsert_trk.value = vinsert_trk.value + 1
      vinsert_knoba.value = vinsert_trk.value
      insert_update_track(vinsert_trk.value)
    elseif tab == 2 then
      vinsert_dsp.value = vinsert_dsp.value + 1
      vinsert_knobb.value = vinsert_dsp.value
    elseif tab == 3 then
      vinsert_pos.value = vinsert_pos.value + 1
      vinsert_knobc.value = vinsert_pos.value
    elseif tab == 4 then
      vinsert_act.value = not vinsert_act.value
      if vinsert_act.value then
        vinsert_knobd.value = 1
      else
        vinsert_knobd.value = 0
      end
    end
  elseif k.name == "left" then
    vinsert_tab.value = tab - 1
  elseif k.name == "right" then
    vinsert_tab.value = tab + 1
  elseif k.name == "space" then
    vinsert_act.value = not vinsert_act.value
  elseif k.name == "return" then
    insertfx(vinsert_trk.value, insert_avdev[vinsert_dsp.value], vinsert_pos.value, vinsert_act.value)
    close_dialog()
  --elseif k.name == "backspace" then
  --else
  end
  insert_updateinfotxt()
end
local function show_insert_dialog()
  if basement_active_view == BASEMENT_VIEW_INSERT then
    insertfx(vinsert_trk.value, insert_avdev[vinsert_dsp.value], vinsert_pos.value, vinsert_act.value)
    close_dialog()
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end
    
    vb = renoise.ViewBuilder()
    rs = renoise.song()
    
    insert_track_names = {}
    for i,t in ipairs(rs.tracks) do
      insert_track_names[i] = t.name
    end
    
    local NATIVE = true
    for i,f in ipairs(rs.selected_track.available_devices) do
      if f:sub(1,20) == "Audio/Effects/Native" then
        insert_avdev[i] = f
        insert_device_names[i] = f:sub(-f:reverse():find("/")+1)
      end
    end

    for i = 1, #rs.selected_track.devices do
      insert_position_names[i] = rs.selected_track:device(i).display_name
    end
    
    local pos = rs.selected_device_index
    if pos == 0 then pos = #rs.selected_track.devices end
    
    vinsert_knoba = vb:rotary {
        min = 1,
        max = #rs.tracks,
        value = rs.selected_track_index,
    }
    vinsert_knobb = vb:rotary {
        min = 1,
        max = #insert_avdev,
        value = 1,
    }
    vinsert_knobc = vb:rotary {
        min = 1,
        max = #rs.selected_track.devices,
        value = pos,
    }
    vinsert_knobd = vb:rotary {
        min = 0.0,
        max = 1.0,
        value = 1,
    }
    vinsert_trk = vb:popup {
      width = 100,
      items = insert_track_names,
      value = rs.selected_track_index,
    }
    vinsert_dsp = vb:popup {
      width = 100,
      items = insert_device_names,
      value = 1,
    }
    vinsert_pos = vb:popup {
      width = 100,
      items = insert_position_names,
      value = pos,
    }
    vinsert_act = vb:checkbox {
      width = 100,
      value = true,
    }
    vinsert_tab = vb:switch {
      width = 400,
      items = { "Track", "Effect", "After", "Active" },
      value = 2,
    }
    vinsert_infotxt = vb:text { text = "Info", width = "100%", }
    local dialog_content = vb:column {
      margin = 2*DM, style = "border", spacing = CS,
      vb:row {
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinsert_knoba,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinsert_trk,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinsert_knobb,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinsert_dsp,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinsert_knobc,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinsert_pos,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinsert_knobd,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinsert_act,
          },
        },
      },
      vb:row {
        style = "border",
        width = "100%",
        vinsert_tab
      },
      vb:row {
        style = "border",
        width = "100%",
        vinsert_infotxt
      },
    }
    dialog = renoise.app():show_custom_dialog( "Basement: Insert", dialog_content, key_insert )
    insert_updateinfotxt()
    basement_active_view = BASEMENT_VIEW_INSERT
    send_midi_cc_feedback(PAD_CC[9], 1)
  end
end

-- BASEMENT_VIEW_EFFECT Mode
local function show_effect_dialog()
  if basement_active_view == BASEMENT_VIEW_EFFECT then
    close_dialog()
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end
    
    vb = renoise.ViewBuilder()
    rs = renoise.song()
    
    effect_effect = rs.selected_device
    if effect_effect == nil then
      effect_effect = rs.selected_track:device(1)
      rs.selected_device_index = 1
    end
    
    if effect_effect.device_path == "Audio/Effects/Native/*Hydra"
    or effect_effect.device_path == "Audio/Effects/Native/*Instr. Automation"
    or effect_effect.device_path == "Audio/Effects/Native/*Instr. MIDI Control"
    or effect_effect.device_path == "Audio/Effects/Native/*Key Tracker"
    or effect_effect.device_path == "Audio/Effects/Native/*LFO"
    or effect_effect.device_path == "Audio/Effects/Native/*Meta Mixer"
    or effect_effect.device_path == "Audio/Effects/Native/*Signal Follower"
    or effect_effect.device_path == "Audio/Effects/Native/*Velocity Tracker"
    or effect_effect.device_path == "Audio/Effects/Native/*XY Pad"
    then
      --close_dialog()
      return
    end
    
    veffect_knobs = {}
    effect_params = {}
    effect_pnames = {}
    
    if #effect_effect.parameters < 8 then
      for i,p in ipairs(effect_effect.parameters) do
        veffect_knobs[i] = vb:rotary {
          min = p.value_min,
          max = p.value_max,
          value = p.value
          --bind = p.value_observable
        }
        effect_params[i] = p
        effect_pnames[i] = p.name
      end
      for i = #effect_effect.parameters+1, 8 do
        veffect_knobs[i] = vb:rotary {
          min = 0, max = 1, value = 0, active = false
        }
        effect_params[i] = nil
        effect_pnames[i] = "none"
      end
    else
      for i = 1, 8 do
        local p = effect_effect:parameter(i)
        veffect_knobs[i] = vb:rotary {
          min = p.value_min,
          max = p.value_max,
          value = p.value
          --bind = p.value_observable
        }
        effect_params[i] = p
        effect_pnames[i] = p.name
      end
    end
    
    local dialog_content = vb:column {
      margin = 2*DM, style = "border", --[[width = 300,--]]
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            veffect_knobs[1],
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = effect_pnames[1] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            veffect_knobs[2],
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = effect_pnames[2] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            veffect_knobs[3],
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = effect_pnames[3] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            veffect_knobs[4],
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = effect_pnames[4] },
          },
        },
      },
      vb:row {
        height = 24,
      },
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            veffect_knobs[5],
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = effect_pnames[5] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            veffect_knobs[6],
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = effect_pnames[6] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            veffect_knobs[7],
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = effect_pnames[7] },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            veffect_knobs[8],
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = effect_pnames[8] },
          },
        },
      },
    }
    dialog = renoise.app():show_custom_dialog( "Basement: Parameters (effect)", dialog_content, key_default )
    basement_active_view = BASEMENT_VIEW_EFFECT
    send_midi_cc_feedback(PAD_CC[10], 1)
  end
end

-- BASEMENT_VIEW_INSTRUMENT Mode
local function show_instrument_dialog()
  if basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    if instrument_apply_to_all then
      local base = renoise.song().selected_sample
      local vol = base.volume
      local pan = base.panning
      local txp = base.transpose
      local fit = base.fine_tune
      local nna = base.new_note_action
      local lpm = base.loop_mode
      local ixp = base.interpolation_mode
      local syn = base.beat_sync_lines
      local son = base.beat_sync_enabled
      for i, slice in ipairs(renoise.song().selected_instrument.samples) do
        slice.volume = vol 
        slice.panning = pan 
        slice.transpose = txp 
        slice.fine_tune = fit 
        slice.new_note_action = nna 
        slice.loop_mode = lpm 
        slice.interpolation_mode = ixp 
        slice.beat_sync_lines = syn 
        slice.beat_sync_enabled = son 
      end
    end
    close_dialog()
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end
    
    instrument_apply_to_all = false

    vb = renoise.ViewBuilder()
    rs = renoise.song()
    local VOLMIN = 0
    local VOLMAX = 4
    local PANMIN = 0
    local PANMAX = 1
    --local TXPMIN = -120
    --local TXPMAX = 120
    local TXPMIN = -48
    local TXPMAX = 48
    local FNTMIN = -127
    local FNTMAX = 127
    
    vinstrument_knoba = vb:rotary {
        min = 1,
        max = #rs.selected_instrument.samples,
        value = rs.selected_sample_index,
    }
    vinstrument_knobb = vb:rotary {
        min = FNTMIN,
        max = FNTMAX,
        value = rs.selected_sample.fine_tune,
    }
    vinstrument_knobc = vb:rotary {
        min = TXPMIN,
        max = TXPMAX,
        value = math.min(math.max(rs.selected_sample.transpose, TXPMIN), TXPMAX),
    }
    vinstrument_knobd = vb:rotary {
        min = VOLMIN,
        max = VOLMAX,
        value = rs.selected_sample.volume,
    }
    vinstrument_knobe = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
    }
    vinstrument_knobf = vb:rotary {
        min = 1,
        max = 3,
        value = rs.selected_sample.new_note_action,
    }
    vinstrument_knobg = vb:rotary {
        min = 1,
        max = 4,
        value = rs.selected_sample.loop_mode,
    }
    vinstrument_knobh = vb:rotary {
        min = PANMIN,
        max = PANMAX,
        value = rs.selected_sample.panning,
    }
    local dialog_content = vb:column {
      margin = 2*DM, style = "border", --[[width = 300,--]]
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinstrument_knoba,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Select" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinstrument_knobb,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Fine" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinstrument_knobc,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Xpose" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinstrument_knobd,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Volume" },
          },
        },
      },
      vb:row {
        height = 24,
      },
      vb:row {
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinstrument_knobe,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Apply" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinstrument_knobf,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "NNA" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinstrument_knobg,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Loop" },
          },
        },
        vb:column {
          width = 50,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vinstrument_knobh,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vb:text { text = "Pan" },
          },
        },
      },
    }
    renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR
    renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
    dialog = renoise.app():show_custom_dialog( "Basement: Synth (instrument)", dialog_content, key_default )
    basement_active_view = BASEMENT_VIEW_INSTRUMENT
    send_midi_cc_feedback(PAD_CC[11], 1)
  end
end

-- BASEMENT_VIEW_SLICE Mode
local function slice_rezoom()
  rs = renoise.song()
  if vslice_knobb.value > vslice_knoba.value then
    rs.selected_sample.sample_buffer.display_range = { vslice_knoba.value, vslice_knobb.value }
    vslice_knobc.min = vslice_knoba.value
    vslice_knobc.max = vslice_knobb.value - 1
    vslice_knobd.min = vslice_knoba.value + 1
    vslice_knobd.max = vslice_knobb.value
    if vslice_knobx.value == SLICE_FUNC_ZOOM_SELECT then -- select
      vslice_knobc.value = math.max(rs.selected_sample.sample_buffer.selection_start, vslice_knobc.min)
      vslice_knobd.value = math.min(rs.selected_sample.sample_buffer.selection_end, vslice_knobd.max)
    elseif vslice_knobx.value == SLICE_FUNC_ZOOM_LOOPMRK then
      vslice_knobc.value = math.max(rs.selected_sample.loop_start, vslice_knobc.min)
      vslice_knobd.value = math.min(rs.selected_sample.loop_end, vslice_knobd.max)
    end
  end
end
local function slice_reselect()
  rs = renoise.song()
  if vslice_knobd.value > vslice_knobc.value then
    rs.selected_sample.sample_buffer.selection_range = { vslice_knobc.value, vslice_knobd.value }
  end
end
local function slice_reloop()
  rs = renoise.song()
  if vslice_knobd.value > vslice_knobc.value then
    rs.selected_sample.loop_start = vslice_knobc.value
    rs.selected_sample.loop_end = vslice_knobd.value
  end
end
local function slice_sel2loop()
  rs.selected_sample.loop_start = rs.selected_sample.sample_buffer.selection_start
  rs.selected_sample.loop_end   = rs.selected_sample.sample_buffer.selection_end
  if rs.selected_sample.loop_mode == renoise.Sample.LOOP_MODE_OFF then
    rs.selected_sample.loop_mode = renoise.Sample.LOOP_MODE_FORWARD
  end
end
local function slice_copysel2newinst()
  local oldsamp = rs.selected_sample
  local sr      = oldsamp.sample_buffer.sample_rate
  local bd      = oldsamp.sample_buffer.bit_depth
  local ms      = oldsamp.sample_buffer.number_of_channels
  local sstart  = rs.selected_sample.sample_buffer.selection_start
  local send    = rs.selected_sample.sample_buffer.selection_end
  local len     = send - sstart
  if len > 0 then
    -- make room
    local newinstpos = rs.selected_instrument_index+1
    local newinst = rs:insert_instrument_at(newinstpos)
    -- select new
    rs.selected_instrument_index = rs.selected_instrument_index + 1
    newinst:sample(1).sample_buffer:create_sample_data( sr, bd, ms, len )
    local newsamp = newinst:sample(1)
    newsamp.sample_buffer:prepare_sample_data_changes()
    for c = 1, ms do
      for i = 1, len do
        newsamp.sample_buffer:set_sample_data(c, i, oldsamp.sample_buffer:sample_data(c,i+sstart))
      end
    end
    newsamp.sample_buffer:finalize_sample_data_changes()
    newinst.name = oldsamp.name .. " part"
    newsamp.name = oldsamp.name .. " part"
  end
end
local function slice_reverse()
  local oldsamp = rs.selected_sample
  if oldsamp.sample_buffer.number_of_frames > 8000 then
    renoise.app():show_warning("Too long. Go do it yourself!!")
  else
    -- haha.. TODO
  end
end
local function show_slice_dialog()
  if basement_active_view == BASEMENT_VIEW_SLICE then
    local close = true
    -- process
    rs = renoise.song()
    if slice_func == SLICE_FUNC_CANCEL then
      -- undo slicing
      for i, m in ipairs(rs.selected_instrument:sample(1).slice_markers) do
        rs.selected_instrument:sample(1):delete_slice_marker(m)
      end
      for i, m in ipairs(slice_oldmarkers) do
        rs.selected_instrument:sample(1):insert_slice_marker(m)
      end
      -- undo zooming
      for i, s in ipairs(renoise.song().selected_instrument.samples) do
        s.sample_buffer.vertical_zoom_factor = 1
        s.sample_buffer.display_range = { 1, s.sample_buffer.number_of_frames }
      end
    elseif slice_func == SLICE_FUNC_ZOOM then
      if vslice_knobx.value == SLICE_FUNC_ZOOM_SELECT then
        if vslice_knoby.value == SLICE_FUNC_ZOOM_SELECT_LOOP then
          slice_sel2loop()
        elseif vslice_knoby.value == SLICE_FUNC_ZOOM_SELECT_INST then
          slice_copysel2newinst()
          close = false
        elseif vslice_knoby.value == SLICE_FUNC_ZOOM_SELECT_SAMP then
        elseif vslice_knoby.value == SLICE_FUNC_ZOOM_SELECT_NONE then
          -- possibly select none: not possible yet
        end
      end
    elseif slice_func == SLICE_FUNC_REVERSE then
      if vslice_knoba.value == 1 then
        slice_reverse()
      end
    end
    --[[for i, s in ipairs(renoise.song().selected_instrument.samples) do  --undo zooming
      s.sample_buffer.vertical_zoom_factor = 1
    end]]
    if close then
      close_dialog()
    end
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end

    vb = renoise.ViewBuilder()
    rs = renoise.song()
    -- Since it's called slice mode it will start in slice mode
    slice_func = SLICE_FUNC_SLICE
    local nowopt = #SLICE_SLICEOPTS
    for i, x in ipairs(SLICE_SLICEOPTS) do
      if #rs.selected_instrument:sample(1).slice_markers == x then
        nowopt = i
      end
    end
    slice_oldmarkers = {}
    for i, x in ipairs(rs.selected_instrument:sample(1).slice_markers) do
      slice_oldmarkers[i] = x
    end
    vslice_knobsel = vb:rotary {
        min = 1,
        max = #rs.selected_instrument.samples,
        value = rs.selected_sample_index,
    }
    vslice_knobfunc = vb:rotary {
        min = 1,
        max = #SLICE_FUNCS,
        value = slice_func,
    }
    vslice_knoba = vb:rotary {
        min = 1,
        max = #SLICE_SLICEOPTS,
        value = nowopt,
    }
    vslice_knobb = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
        active = false,
    }
    vslice_knobx = vb:rotary {
        min = 1,
        max = 2,
        value = 1,
    }
    vslice_knoby = vb:rotary {
        min = 0,
        max = 1,
        value = 1,
    }
    vslice_knobc = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
        active = false,
    }
    vslice_knobd = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
        active = false,
    }
    local samples_names = {}
    for i,s in ipairs(rs.selected_instrument.samples) do
      samples_names[i] = s.name
    end
    vslice_smp = vb:popup {
      width = 100,
      items = samples_names,
      value = rs.selected_sample_index
    }
    vslice_fnc = vb:popup {
      width = 100,
      items = SLICE_SHORT,
      value = slice_func,
    }
    vslice_labela = vb:text { text = "" .. #rs.selected_instrument:sample(1).slice_markers }
    vslice_labelb = vb:text { text = "" }
    vslice_labelc = vb:text { text = "" }
    vslice_labeld = vb:text { text = "" }
    vslice_labelx = vb:text { text = "" }
    vslice_labely = vb:text { text = "" }
    vslice_infotxt = vb:text { text = SLICE_FUNCS[slice_func], width = "100%", }
    
    local dialog_content = vb:column {
      margin = 2*DM, style = "border", spacing = CS,
      vb:row {
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_knobsel,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_smp,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_knobfunc,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_fnc,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_knoba,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_labela,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_knobb,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_labelb,
          },
        },
      },
      --[[
      vb:row {
        style = "border",
        width = "100%",
        vslice_tab
      },
      --]]
      vb:row {
        height = 24,
      },
      vb:row {
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_knobx,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_labelx,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_knoby,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_labely,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_knobc,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_labelc,
          },
        },
        vb:column {
          width = 100,
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_knobd,
          },
          vb:horizontal_aligner {
            width = "100%", mode = "center",
            vslice_labeld,
          },
        },
      },
      vb:row {
        style = "border",
        width = "100%",
        vslice_infotxt
      },
    }
    
    dialog = renoise.app():show_custom_dialog( "Basement: Sample (slice)", dialog_content, key_default )
    basement_active_view = BASEMENT_VIEW_SLICE
    send_midi_cc_feedback(PAD_CC[15], 1)
  end
end

-- BASEMENT_VIEW_SYNTH Mode
local function show_synth_dialog()
  if basement_active_view == BASEMENT_VIEW_SYNTH then
    close_dialog()
  else
    if basement_active_view ~= BASEMENT_VIEW_NONE then
      close_dialog()
    end

    -- do nothing
    vb = renoise.ViewBuilder()
    rs = renoise.song()
    --[[
    vsynth_knoba = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
        active = false,
    }
    vsynth_knobb = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
        active = false,
    }
    vsynth_knobc = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
        active = false,
    }
    vsynth_knobd = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
        active = false,
    }
    vsynth_knobe = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
    }
    vsynth_knobf = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
    }
    vsynth_knobg = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
    }
    vsynth_knobh = vb:rotary {
        min = 0,
        max = 1,
        value = 0,
    }
    vsynth_boxa = vb:popup { items = {} }
    vsynth_boxb = vb:popup { items = {} }
    vsynth_boxc = vb:popup { items = {} }
    vsynth_boxd = vb:popup { items = {} }
    vsynth_boxe = vb:popup { items = {} }
    vsynth_boxf = vb:popup { items = {} }
    vsynth_boxg = vb:popup { items = {} }
    vsynth_boxh = vb:popup { items = {} }
    
    local dialog_content = vb:column {
    }]]
    
    --dialog = renoise.app():show_custom_dialog( "Basement: Synth", dialog_content, key_default )
    --basement_active_view = BASEMENT_VIEW_SYNTH
    --send_midi_cc_feedback(PAD_CC[11], 1)
  end
end


--------------------------------------------------------------------------------
-- MIDI callback functions
--------------------------------------------------------------------------------
local function test_midi_messages(mm, origin)
  vtest_infotxt.text = "MIDI Info: " .. origin .. " set to " .. mm.int_value
end

local function panic_close_mpk()
  for i = 1,16 do
    send_midi_cc_feedback(PAD_CC[i], 0)
  end
  mpk_out:close()
end

local function pad_update_follow()
  send_midi_cc_feedback(PAD_CC[1], bool_to_int(rs.transport.follow_player))
end

local function pad_update_dsp_active(check)
  if not check then
    if rs.selected_device == nil then
    else
      send_midi_cc_feedback(PAD_CC[2], bool_to_int(rs.selected_device.is_active))
    end
  else
    send_midi_cc_feedback(PAD_CC[2], bool_to_int(rs.selected_device.is_active))
  end
end

local function pad_update_block()
  send_midi_cc_feedback(PAD_CC[3], bool_to_int(rs.transport.loop_block_enabled))
end

local function pad_update_metro()
  send_midi_cc_feedback(PAD_CC[4], bool_to_int(rs.transport.metronome_enabled))
end

local function pad_update_playing()
  send_midi_cc_feedback(PAD_CC[5], bool_to_int(rs.transport.playing))
end

local function pad_update_loop()
  send_midi_cc_feedback(PAD_CC[6], bool_to_int(rs.transport.loop_pattern))
end

local function pad_update_rec()
  send_midi_cc_feedback(PAD_CC[8], bool_to_int(rs.transport.edit_mode))
end

local function pad_update_midframe()
  send_midi_cc_feedback(PAD_CC[13], bool_to_int(renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR))
  send_midi_cc_feedback(PAD_CC[14], bool_to_int(renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_MIXER))
  send_midi_cc_feedback(PAD_CC[15], bool_to_int(renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR))
end

local function pad_update_all()
  pad_update_dsp_active()
  pad_update_playing()
  pad_update_follow()
  pad_update_block()
  pad_update_metro()
  pad_update_loop()
  pad_update_rec()

  pad_update_midframe()
end

local function pad(number, mm)
  --print("MIDI Info: Pad " .. number .. " pressed with value " .. mm.int_value)
  rs = renoise.song()
  local val = mm.int_value
  if number == 1 then
    if val > 0 then
      rs.transport.follow_player = not rs.transport.follow_player
    else
      pad_update_follow()
    end
  elseif number == 2 then
    local f = rs.selected_device
    if f ~= nil then
      if val > 0 and rs.selected_device_index > 1 then
        rs.selected_device.is_active = not rs.selected_device.is_active
      else
        pad_update_dsp_active(true)
      end
    end
  elseif number == 3 then
    if val > 0 then
      rs.transport.loop_block_enabled = not rs.transport.loop_block_enabled
    else
      pad_update_block()
    end
  elseif number == 4 then
    if val > 0 then
      rs.transport.metronome_enabled = not rs.transport.metronome_enabled
    else
      pad_update_metro()
    end
  elseif number == 5 then
    if val > 0 then
      if rs.transport.playing then
        rs.transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
      else
        rs.transport:start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
      end
    else
      pad_update_playing()
    end
  elseif number == 6 then
    if val > 0 then
      if rs.transport.playing then
        rs.transport.loop_pattern = not rs.transport.loop_pattern
      elseif not rs.transport.loop_pattern then
        rs.transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
        rs.transport.loop_pattern = true
      else
        rs.transport.loop_pattern = false
      end
    else
      pad_update_loop()
      pad_update_playing()
    end
  elseif number == 7 then
    if val > 0 then
      if rs.transport.playing then
        rs.transport:stop()
      else
        rs.transport:panic()
        rs.transport.loop_pattern = false
        local npos = rs.transport.playback_pos
        if npos.line > 1 then
          rs.transport.playback_pos = renoise.SongPos(npos.sequence, 1)
        else
          rs.transport.playback_pos = renoise.SongPos(1, 1)
        end
      end
    else
      pad_update_loop()
      pad_update_playing()
    end
  elseif number == 8 then
    if val > 0 then
      rs.transport.edit_mode = not rs.transport.edit_mode
      if rs.transport.edit_mode and not rs.transport.playing then
        rs.transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
      end
    else
      pad_update_rec()
      pad_update_playing()
    end
  elseif number == 9 then
    if val > 0 then
      show_insert_dialog()
    end
  elseif number == 10 then
    if val > 0 then
      show_effect_dialog()
    end
  elseif number == 11 then
    if val > 0 then
      if renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_MIXER then
        --show_mixer_dialog()
      elseif renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR and
             not rs.selected_sample.sample_buffer.has_sample_data then
        show_synth_dialog()
      else
        show_instrument_dialog()
      end
    end
  elseif number == 12 then
    if val > 0 then
      show_hydras_dialog()
    end
  elseif number == 13 then
    if val > 0 then
      if renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR then
      --[[
          renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER => together with track dsps
          renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES
          renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES
          renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM

          renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
          renoise.ApplicationWindow.MIDDLE_FRAME_MIXER
          renoise.ApplicationWindow.MIDDLE_FRAME_KEYZONE_EDITOR
          renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR

          renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
          renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
          renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
          renoise.ApplicationWindow.LOWER_FRAME_SONG_PROPERTIES
      --]]
        local swaplow = false
        -- cycle upper/lower frames suitable for view together with pattern editor
        if renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER
          renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES
        end
      else
        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
        renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
      end
    else
      pad_update_midframe()
    end
  elseif number == 14 then
    if val > 0 then
      if renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_MIXER then
        if not renoise.app().window.lower_frame_is_visible then
          renoise.app().window.lower_frame_is_visible = true
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES
          renoise.app().window.lower_frame_is_visible = false
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM
          renoise.app().window.lower_frame_is_visible = false
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER
          renoise.app().window.lower_frame_is_visible = true
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES
          renoise.app().window.lower_frame_is_visible = false
        end
      else
        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_MIXER
        renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
      end
    else
      pad_update_midframe()
    end
  elseif number == 15 then
    if val > 0 then
      if renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR then
        -- Sample Editor Button: Mode 1
        --[[ 
            if renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER and
               renoise.app().window.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES then
                    renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES
                    renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES and
               renoise.app().window.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES then
                    renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER
                    renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER and
               renoise.app().window.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS then
                    renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES
                    renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
        elseif renoise.app().window.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES and
               renoise.app().window.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS then
                    renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER
                    renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
        else
                    renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER
                    renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
        end
        --]]
        -- Sample Editor Button: Mode 2
        if renoise.app().window.sample_record_dialog_is_visible and not rs.selected_sample.sample_buffer.has_sample_data then
          rs.transport:start_stop_sample_recording()
        elseif renoise.app().window.sample_record_dialog_is_visible and rs.selected_sample.sample_buffer.has_sample_data then
          renoise.app().window.sample_record_dialog_is_visible = false
        elseif not renoise.app().window.sample_record_dialog_is_visible and not rs.selected_sample.sample_buffer.has_sample_data then
          renoise.app().window.sample_record_dialog_is_visible = true
        -- Sample Editor Button: Mode 3
        else
          show_slice_dialog()
        end
      else
        renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR
        if not rs.selected_sample.sample_buffer.has_sample_data then
          renoise.app().window.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER
        end
      end
    else
      pad_update_midframe()
    end
  elseif number == 16 then
    if val > 0 then
      show_default_dialog()
    end
  end
end

local function a(mm)
  rs = renoise.song()
  if basement_active_view == BASEMENT_VIEW_TEST then
    test_midi_messages(mm, "Knob A")
  elseif basement_active_view == BASEMENT_VIEW_NONE then
    local nv = mod_midi_value(mm.int_value, 1, #rs.instruments, true)
    rs.selected_instrument_index = nv
    if (nv == #rs.instruments and #rs.selected_instrument.samples > 0 and rs.selected_instrument:sample(1).sample_buffer.has_sample_data) or
       (nv == #rs.instruments and #rs:instrument(nv-1).samples > 0 and rs:instrument(nv-1):sample(1).sample_buffer.has_sample_data) then
      rs:insert_instrument_at(#rs.instruments+1)
    end
  elseif basement_active_view == BASEMENT_VIEW_DEFAULT then
    --local nv = mm.int_value * vdefault_knoba.max / 128
    local nv = mod_midi_value(mm.int_value, vdefault_knoba.min, vdefault_knoba.max, true)
    vdefault_knoba.value = nv
    rs.transport.octave = nv
    --[[rs.selected_instrument_index = nv]]
  elseif basement_active_view == BASEMENT_VIEW_MIXER then
    local nv = mod_midi_value(mm.int_value, vmixer_knoba.min, vmixer_knoba.max, true)
    if nv < 2 then nv = 2 elseif nv > (#rs.tracks-1) then nv = #rs.tracks-1 end
    vmixer_knoba.value = nv
    rs.selected_track_index = nv
    mixer_tra = rs:track(rs.selected_track_index-1)
    mixer_trb = rs.selected_track
    mixer_trc = rs:track(rs.selected_track_index+1)
    vmixer_desca.text = mixer_tra.name
    vmixer_descb.text = mixer_trb.name
    vmixer_descc.text = mixer_trc.name
    vmixer_knobb.value = mixer_tra.postfx_panning.value
    vmixer_knobc.value = mixer_trb.postfx_panning.value
    vmixer_knobd.value = mixer_trc.postfx_panning.value
    vmixer_knobf.value = mixer_tra.postfx_volume.value
    vmixer_knobg.value = mixer_trb.postfx_volume.value
    vmixer_knobh.value = mixer_trc.postfx_volume.value
  elseif basement_active_view == BASEMENT_VIEW_HYDRAS then
    local nv = mod_midi_value(mm.int_value, 0, 1, false)
    vhydras_knoba.value = nv
    if hydras_hydras[1] then
      hydras_hydras[1]:parameter(1).value = nv
    end
    -- TODO: write automation if recording
  elseif basement_active_view == BASEMENT_VIEW_INSERT then
    vinsert_tab.value = 1
    local nv = mod_midi_value(mm.int_value, vinsert_knoba.min, vinsert_knoba.max, true)
    vinsert_knoba.value = nv
    vinsert_trk.value = nv
    insert_update_track(vinsert_trk.value)
    insert_updateinfotxt()
  elseif basement_active_view == BASEMENT_VIEW_EFFECT then
    local nv = mod_midi_value(mm.int_value, effect_params[1].value_min, effect_params[1].value_max, false)
    veffect_knobs[1].value = nv
    if effect_params[1] ~= nil then
      effect_params[1].value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    local nv = mod_midi_value(mm.int_value, vinstrument_knoba.min, vinstrument_knoba.max, true)
    vinstrument_knoba.value = nv
    rs.selected_sample_index = nv
    vinstrument_knobb.value = rs.selected_sample.fine_tune
    vinstrument_knobc.value = rs.selected_sample.transpose
    vinstrument_knobd.value = rs.selected_sample.volume
    vinstrument_knobe.value = 0
    instrument_apply_to_all = false
    vinstrument_knobf.value = rs.selected_sample.new_note_action
    vinstrument_knobg.value = rs.selected_sample.loop_mode
    vinstrument_knobh.value = rs.selected_sample.panning
  elseif basement_active_view == BASEMENT_VIEW_SLICE then
    local nv = mod_midi_value(mm.int_value, vslice_knobsel.min, vslice_knobsel.max, true)
    vslice_knobsel.value = nv
    rs.selected_sample_index = nv
    vslice_smp.value = nv
    -- update?
    vslice_infotxt.text = "Selected sample #"..nv..". "..rs.selected_sample.name
    if slice_func == SLICE_FUNC_SLICE then
    elseif slice_func == SLICE_FUNC_ZOOM then
      -- knob a, knob b
      vslice_knoba.min = 1
      vslice_knoba.max = rs.selected_sample.sample_buffer.number_of_frames-1
      vslice_knoba.value = rs.selected_sample.sample_buffer.display_start
      vslice_knobb.min = 2
      vslice_knobb.max = rs.selected_sample.sample_buffer.number_of_frames
      vslice_knobb.value = rs.selected_sample.sample_buffer.display_range[2]-1
      --[[vslice_labelx.text = SLICE_SUBZOOM_FUNCS[SLICE_FUNC_ZOOM_SELECT]
      vslice_labely.text = SLICE_SUBSELECT_FUNCS[1]
      vslice_knobx.min = 1
      vslice_knobx.max = #SLICE_SUBZOOM_FUNCS
      vslice_knobx.value = SLICE_FUNC_ZOOM_SELECT
      vslice_knoby.min = 1
      vslice_knoby.max = #SLICE_SUBSELECT_FUNCS
      vslice_knoby.value = SLICE_FUNC_ZOOM_SELECT_LOOP]]
      -- knob c, knob d
      vslice_knobc.min = vslice_knoba.value
      vslice_knobc.max = vslice_knobb.value - 1
      vslice_knobc.value = math.max(rs.selected_sample.sample_buffer.selection_start, vslice_knobc.min)
      vslice_knobd.min = vslice_knoba.value + 1
      vslice_knobd.max = vslice_knobb.value
      vslice_knobd.value = math.min(rs.selected_sample.sample_buffer.selection_end, vslice_knobd.max)
      -- vertical zoom
      --rs.selected_sample.sample_buffer.vertical_zoom_factor=0.125
    end
  end
end

local function b(mm)
  rs = renoise.song()
  if basement_active_view == BASEMENT_VIEW_TEST then
    test_midi_messages(mm, "Knob B")
  elseif basement_active_view == BASEMENT_VIEW_NONE then
    -- TODO: only select 'visible' tracks (not the ones hidden in collapsed groups)
    local vt = vis_tracks()
    local nv = mod_midi_value(mm.int_value, 1, #vt, true)
    rs.selected_track_index = vt[nv]
  elseif basement_active_view == BASEMENT_VIEW_DEFAULT then
    local nv = mod_midi_value(mm.int_value, vdefault_knobb.min, vdefault_knobb.max, true)
    vdefault_knobb.value = nv
    local bpm = rs.transport.bpm
    local lpb = rs.transport.lpb
    local delay_base = default_MSPM / bpm / lpb / default_DPL
    local delay = delay_base * (nv-256)
    if delay >= -100 and delay <= 100 then
      rs.selected_track.output_delay = delay
      vdefault_infotxt.text = "Track Shift is "..math.floor(nv-256)
    end
  elseif basement_active_view == BASEMENT_VIEW_MIXER then
    local nv = mod_midi_value(mm.int_value, vmixer_knobb.min, vmixer_knobb.max, false)
    vmixer_knobb.value = nv
    mixer_tra.postfx_panning.value = nv
  elseif basement_active_view == BASEMENT_VIEW_HYDRAS then
    local nv = mod_midi_value(mm.int_value, 0, 1, false)
    vhydras_knobb.value = nv
    if hydras_hydras[2] then
      hydras_hydras[2]:parameter(1).value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSERT then
    vinsert_tab.value = 2
    local nv = mod_midi_value(mm.int_value, vinsert_knobb.min, vinsert_knobb.max, true)
    vinsert_knobb.value = nv
    vinsert_dsp.value = nv
    insert_updateinfotxt()
  elseif basement_active_view == BASEMENT_VIEW_EFFECT then
    local nv = mod_midi_value(mm.int_value, effect_params[2].value_min, effect_params[2].value_max, false)
    veffect_knobs[2].value = nv
    if effect_params[2] ~= nil then
      effect_params[2].value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    local nv = mod_midi_value(mm.int_value, vinstrument_knobb.min, vinstrument_knobb.max, true)
    if nv > -3 and nv < 3 then nv = 0 end
    vinstrument_knobb.value = nv
    rs.selected_sample.fine_tune = nv
  elseif basement_active_view == BASEMENT_VIEW_SLICE then
    local nv = mod_midi_value(mm.int_value, vslice_knobfunc.min, vslice_knobfunc.max, true)
    vslice_knobfunc.value = nv
    vslice_fnc.value = nv
    vslice_infotxt.text = SLICE_FUNCS[nv]
    slice_func = nv
    if nv == SLICE_FUNC_ZOOM then
      vslice_labela.text = "[<--"
      vslice_labelb.text = "-->]"
      vslice_labelc.text = "[[-"
      vslice_labeld.text = "-]]"
      -- knob a, knob b
      vslice_knoba.min = 1
      vslice_knoba.max = rs.selected_sample.sample_buffer.number_of_frames-1
      vslice_knoba.value = rs.selected_sample.sample_buffer.display_start
      vslice_knobb.min = 2
      vslice_knobb.max = rs.selected_sample.sample_buffer.number_of_frames
      vslice_knobb.value = rs.selected_sample.sample_buffer.display_range[2]-1
      -- knob x = subfunc
      vslice_labelx.text = SLICE_SUBZOOM_FUNCS[SLICE_FUNC_ZOOM_VERTICAL]
      vslice_labely.text = "Zoom" --SLICE_SUBSELECT_FUNCS[SLICE_FUNC_ZOOM_SELECT_LOOP]
      vslice_knobx.min = 1
      vslice_knobx.max = #SLICE_SUBZOOM_FUNCS
      vslice_knobx.value = SLICE_FUNC_ZOOM_VERTICAL
      vslice_knoby.min = 0
      vslice_knoby.max = 1
      vslice_knoby.value = 1-math.sqrt(rs.selected_sample.sample_buffer.vertical_zoom_factor)
      -- knob c, knob d
      vslice_knobc.min = vslice_knoba.value
      vslice_knobc.max = vslice_knobb.value - 1
      vslice_knobc.value = math.min(math.max(rs.selected_sample.sample_buffer.selection_start, vslice_knobc.min), vslice_knobc.max)
      vslice_knobd.min = vslice_knoba.value + 1
      vslice_knobd.max = vslice_knobb.value
      vslice_knobd.value = math.max(math.min(rs.selected_sample.sample_buffer.selection_end, vslice_knobd.max), vslice_knobd.min)
      vslice_infotxt.text = SLICE_SUBZOOM_DESCS[SLICE_FUNC_ZOOM_VERTICAL]
    elseif nv == SLICE_FUNC_SLICE then
      vslice_knoba.min = 1
      vslice_knoba.max = #SLICE_SLICEOPTS
      local nowopt = #SLICE_SLICEOPTS
      for i, x in ipairs(SLICE_SLICEOPTS) do
        if #rs.selected_instrument:sample(1).slice_markers == x then
          nowopt = i
        end
      end
      vslice_knoba.value = nowopt
      vslice_knobb.min = 0
      vslice_knobb.max = 1
      vslice_knobb.value = 0      
      vslice_knobc.min = 0
      vslice_knobc.max = 1
      vslice_knobc.value = 0      
      vslice_knobd.min = 0
      vslice_knobd.max = 1
      vslice_knobd.value = 0      
      vslice_labela.text = "" .. #rs.selected_instrument:sample(1).slice_markers
      vslice_labelb.text = ""
      vslice_labelc.text = ""
      vslice_labeld.text = ""
      vslice_knobx.min = 0
      vslice_knobx.max = 1
      vslice_knobx.value = 0
      vslice_knoby.min = 0
      vslice_knoby.max = 1
      vslice_knoby.value = 0
      vslice_labelx.text = ""
      vslice_labely.text = ""
    elseif nv == SLICE_FUNC_REVERSE then
      vslice_knoba.min = 0
      vslice_knoba.max = 1
      vslice_knoba.value = 0
      vslice_labela.text = "Reverse"
      vslice_knobb.min = 0
      vslice_knobb.max = 1
      vslice_knobb.value = 0      
      vslice_knobc.min = 0
      vslice_knobc.max = 1
      vslice_knobc.value = 0      
      vslice_knobd.min = 0
      vslice_knobd.max = 1
      vslice_knobd.value = 0      
      vslice_labelx.text = ""
      vslice_labely.text = ""
      vslice_labelb.text = ""
      vslice_labelc.text = ""
      vslice_labeld.text = ""
    else
      vslice_labela.text = ""
      vslice_labelb.text = ""
      vslice_labelc.text = ""
      vslice_labeld.text = ""
    end
  end
end

local function c(mm)
  rs = renoise.song()
  if basement_active_view == BASEMENT_VIEW_TEST then
    test_midi_messages(mm, "Knob C")
  elseif basement_active_view == BASEMENT_VIEW_NONE then
    local nv = mm.int_value * 2
    if renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR then
    rs:describe_undo("Push Back "..nv)
    local pattern = rs.sequencer:pattern(rs.transport.edit_pos.sequence)
    local line = rs.transport.edit_pos.line
    local step = rs.transport.edit_step
    local track = rs.selected_track_index
    local tracktype = rs.selected_track.type
    local column = rs.selected_note_column_index
    local succeed = true
    if step == 0 then
      if column >= 1 and column <= 12 then
        rs:track(track).delay_column_visible = true
        rs:pattern(pattern):track(track):line(line):note_column(column).delay_value = nv
      elseif tracktype == 1 then
        rs:track(track).delay_column_visible = true
        for c = 1, rs:track(track).visible_note_columns do
          rs:pattern(pattern):track(track):line(line):note_column(c).delay_value = nv
        end
      elseif tracktype == 4 then
        for _, t in pairs(rs:track(track).leaves_indexes) do
          rs:track(t).delay_column_visible = true
          for c = 1, rs:track(t).visible_note_columns do
            rs:pattern(pattern):track(t):line(line):note_column(c).delay_value = nv
          end
        end
      else
        renoise.app():show_status("dude u r in wrong track type")
        succeed = false
      end
    else
      rs.transport.follow_player = false
      if column >= 1 and column <= 12 then -- instrument track
        rs:track(track).delay_column_visible = true
        local x = line % step
        if x < 1 then x = 1 end
        for l = x, rs:pattern(pattern).number_of_lines, step do
          rs:pattern(pattern):track(track):line(l):note_column(column).delay_value = nv
        end
      elseif tracktype == 1 then
        rs:track(track).delay_column_visible = true
        local x = line % step
        if x < 1 then x = 1 end
        for l = x, rs:pattern(pattern).number_of_lines, step do
          for c = 1, rs:track(track).visible_note_columns do
            rs:pattern(pattern):track(track):line(l):note_column(c).delay_value = nv
          end
        end
      elseif tracktype == 4 then
        for _, t in pairs(rs:track(track).leaves_indexes) do
          rs:track(t).delay_column_visible = true
          local x = line % step
          if x < 1 then x = 1 end
          for l = x, rs:pattern(pattern).number_of_lines, step do
            for c = 1, rs:track(t).visible_note_columns do
              rs:pattern(pattern):track(t):line(l):note_column(c).delay_value = nv
            end
          end
        end
      else
        renoise.app():show_status("dude u r in wrong track type")
        succeed = false
      end
    if succeed then
      renoise.app():show_status("Push Back "..nv)
    end
    end -- if renoise.app().window.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    end
  elseif basement_active_view == BASEMENT_VIEW_DEFAULT then
    local nv = mod_midi_value(mm.int_value, vdefault_knobc.min, vdefault_knobc.max, false)
    vdefault_knobc.value = nv
    rs.transport.bpm = nv
  elseif basement_active_view == BASEMENT_VIEW_MIXER then
    local nv = mod_midi_value(mm.int_value, vmixer_knobc.min, vmixer_knobc.max, false)
    vmixer_knobc.value = nv
    mixer_trb.postfx_panning.value = nv
  elseif basement_active_view == BASEMENT_VIEW_HYDRAS then
    local nv = mod_midi_value(mm.int_value, 0, 1, false)
    vhydras_knobc.value = nv
    if hydras_hydras[3] then
      hydras_hydras[3]:parameter(1).value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSERT then
    vinsert_tab.value = 3
    local nv = mod_midi_value(mm.int_value, vinsert_knobc.min, vinsert_knobc.max, true)
    vinsert_knobc.value = nv
    vinsert_pos.value = nv
    insert_updateinfotxt()
  elseif basement_active_view == BASEMENT_VIEW_EFFECT then
    local nv = mod_midi_value(mm.int_value, effect_params[3].value_min, effect_params[3].value_max, false)
    veffect_knobs[3].value = nv
    if effect_params[3] ~= nil then
      effect_params[3].value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    local nv = mod_midi_value(mm.int_value, vinstrument_knobc.min, vinstrument_knobc.max, true)
    --if nv > -8 and nv < 8 then nv = 0 end
    vinstrument_knobc.value = nv
    rs.selected_sample.transpose = nv
  elseif basement_active_view == BASEMENT_VIEW_SLICE then
    local nv = mod_midi_value(mm.int_value, vslice_knoba.min, vslice_knoba.max, true)
    vslice_knoba.value = nv
    if slice_func == SLICE_FUNC_SLICE then
      local parts = SLICE_SLICEOPTS[nv]
      if not rs.selected_sample.is_slice_alias and #rs.selected_sample.slice_markers ~= parts then
        for i, m in ipairs(renoise.song().selected_sample.slice_markers) do
          renoise.song().selected_sample:delete_slice_marker(m)
        end
        local div = rs.selected_sample.sample_buffer.number_of_frames / parts
        for i = 1, parts do
          renoise.song().selected_sample:insert_slice_marker((i-1)*div+1)
        end
        if parts == 0 then
          vslice_infotxt.text = "Slices removed"
        else
          vslice_infotxt.text = SLICE_FUNCS[SLICE_FUNC_SLICE] .. " in " .. parts .. " equal parts"
        end
        vslice_labela.text = "" .. parts
        vslice_knobsel.max = #rs.selected_instrument.samples
        vslice_knobsel.value = 1
        local smpnames = {}
        for i, s in ipairs(rs.selected_instrument.samples) do
          smpnames[i] = s.name
        end
        vslice_smp.items = smpnames
        vslice_smp.value = 1
      end
    elseif slice_func == SLICE_FUNC_ZOOM then
      slice_rezoom()
    end
  end
end

local function d(mm)
  rs = renoise.song()
  if basement_active_view == BASEMENT_VIEW_TEST then
    test_midi_messages(mm, "Knob D")
  elseif basement_active_view == BASEMENT_VIEW_NONE then
    local nv = mod_midi_value(mm.int_value, 1, #rs.sequencer.pattern_sequence, true)
    local pos = nil
    if rs.transport.follow_player then
      pos = rs.transport.playback_pos
      rs.transport.playback_pos = renoise.SongPos(nv, math.min(pos.line, rs:pattern(rs.sequencer:pattern(nv)).number_of_lines))
    else
      pos = rs.transport.edit_pos
      rs.transport.edit_pos = renoise.SongPos(nv, math.min(pos.line, rs:pattern(rs.sequencer:pattern(nv)).number_of_lines))
    end
  elseif basement_active_view == BASEMENT_VIEW_DEFAULT then
    local nv = mod_midi_value(mm.int_value, vdefault_knobd.min, vdefault_knobd.max, false)
    vdefault_knobd.value = nv
    rs:track(rs.sequencer_track_count+1).postfx_volume.value = nv
    --[[rs.transport.edit_pos = renoise.SongPos(nv, rs.transport.edit_pos.line)]]
  elseif basement_active_view == BASEMENT_VIEW_MIXER then
    local nv = mod_midi_value(mm.int_value, vmixer_knobd.min, vmixer_knobd.max, false)
    vmixer_knobd.value = nv
    mixer_trc.postfx_panning.value = nv
  elseif basement_active_view == BASEMENT_VIEW_HYDRAS then
    local nv = mod_midi_value(mm.int_value, 0, 1, false)
    vhydras_knobd.value = nv
    if hydras_hydras[4] then
      hydras_hydras[4]:parameter(1).value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSERT then
    vinsert_tab.value = 4
    local nv = true
    if mm.int_value < 96 then nv = false end
    if nv then
      vinsert_knobd.value = 1
    else
      vinsert_knobd.value = 0
    end
    vinsert_act.value = nv
    insert_updateinfotxt()
  elseif basement_active_view == BASEMENT_VIEW_EFFECT then
    local nv = mod_midi_value(mm.int_value, effect_params[4].value_min, effect_params[4].value_max, false)
    veffect_knobs[4].value = nv
    if effect_params[4] ~= nil then
      effect_params[4].value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    local nv = mod_midi_value(mm.int_value, vinstrument_knobd.min, vinstrument_knobd.max, false)
    vinstrument_knobd.value = nv
    rs.selected_sample.volume = nv
  elseif basement_active_view == BASEMENT_VIEW_SLICE then
    local nv = mod_midi_value(mm.int_value+1, vslice_knobb.min, vslice_knobb.max, true)-1
    vslice_knobb.value = nv
    if slice_func == SLICE_FUNC_ZOOM then
      slice_rezoom()
    end
  end
end

local function e(mm)
  rs = renoise.song()
  if basement_active_view == BASEMENT_VIEW_TEST then
    test_midi_messages(mm, "Knob E")
  elseif basement_active_view == BASEMENT_VIEW_NONE then
    local nv = mod_midi_value(mm.int_value, 1, #DEFAULT_EDITSTEPOPTS, true)
    rs.transport.edit_step = DEFAULT_EDITSTEPOPTS[nv]
  elseif basement_active_view == BASEMENT_VIEW_DEFAULT then
    local nv = mod_midi_value(mm.int_value, vdefault_knobe.min, vdefault_knobe.max, true)
    vdefault_knobe.value = nv
    if nv == 0 then
      rs.transport.record_quantize_enabled = false
    else
      rs.transport.record_quantize_enabled = true
      rs.transport.record_quantize_lines = nv
    end
    --[[rs.transport.edit_step = DEFAULT_EDITSTEPOPTS[nv]]
  elseif basement_active_view == BASEMENT_VIEW_MIXER then
    local nv = mod_midi_value(mm.int_value, vmixer_knobe.min, vmixer_knobe.max, false)
    vmixer_knobe.value = nv
    mixer_trm.postfx_volume.value = nv
  elseif basement_active_view == BASEMENT_VIEW_HYDRAS then
    local nv = mod_midi_value(mm.int_value, 0, 1, false)
    vhydras_knobe.value = nv
    if hydras_hydras[5] then
      hydras_hydras[5]:parameter(1).value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_EFFECT then
    local nv = mod_midi_value(mm.int_value, effect_params[5].value_min, effect_params[5].value_max, false)
    veffect_knobs[5].value = nv
    if effect_params[5] ~= nil then
      effect_params[5].value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    local nv = mod_midi_value(mm.int_value, vinstrument_knobe.min, vinstrument_knobe.max, true)
    vinstrument_knobe.value = nv
    instrument_apply_to_all = int_to_bool(nv)
  elseif basement_active_view == BASEMENT_VIEW_SLICE then
    local nv = mod_midi_value(mm.int_value, vslice_knobx.min, vslice_knobx.max, true)
    local ov = vslice_knobx.value
    vslice_knobx.value = nv
    if vslice_knobfunc.value == SLICE_FUNC_ZOOM and ov ~= nv then
      vslice_labelx.text = SLICE_SUBZOOM_FUNCS[nv]
      if nv == SLICE_FUNC_ZOOM_SELECT then
        vslice_labely.text = SLICE_SUBSELECT_FUNCS[SLICE_FUNC_ZOOM_SELECT_INST]
        vslice_knoby.min = 1
        vslice_knoby.max = #SLICE_SUBSELECT_FUNCS
        vslice_knoby.value = SLICE_FUNC_ZOOM_SELECT_INST
        vslice_labelc.text = "[[-"
        vslice_labeld.text = "-]]"
        vslice_knobc.min = vslice_knoba.value
        vslice_knobc.max = vslice_knobb.value - 1
        vslice_knobc.value = math.max(rs.selected_sample.sample_buffer.selection_start, vslice_knobc.min)
        vslice_knobd.min = vslice_knoba.value + 1
        vslice_knobd.max = vslice_knobb.value
        vslice_knobd.value = math.min(rs.selected_sample.sample_buffer.selection_end, vslice_knobd.max)
        vslice_infotxt.text = SLICE_SUBZOOM_DESCS[SLICE_FUNC_ZOOM_SELECT]
      elseif nv == SLICE_FUNC_ZOOM_LOOPMRK then
        vslice_labely.text = SLICE_LOOP_MODE_NAMES[rs.selected_sample.loop_mode]
        vslice_knoby.min = 1
        vslice_knoby.max = #SLICE_LOOP_MODE_NAMES
        vslice_knoby.value = rs.selected_sample.loop_mode
        vslice_labelc.text = "[[-"
        vslice_labeld.text = "-]]"
        vslice_knobc.min = vslice_knoba.value
        vslice_knobc.max = vslice_knobb.value - 1
        vslice_knobc.value = math.max(rs.selected_sample.loop_start, vslice_knobc.min)
        vslice_knobd.min = vslice_knoba.value + 1
        vslice_knobd.max = vslice_knobb.value
        vslice_knobd.value = math.min(rs.selected_sample.loop_end, vslice_knobd.max)
        vslice_infotxt.text = SLICE_SUBZOOM_DESCS[SLICE_FUNC_ZOOM_LOOPMRK]
      elseif nv == SLICE_FUNC_ZOOM_VERTICAL then
        vslice_labely.text = "Zoom"
        vslice_knoby.min = 0
        vslice_knoby.max = 1
        vslice_knoby.value = 1-math.sqrt(rs.selected_sample.sample_buffer.vertical_zoom_factor)
        vslice_labelc.text = "[[-"
        vslice_labeld.text = "-]]"
        vslice_knobc.min = vslice_knoba.value
        vslice_knobc.max = vslice_knobb.value - 1
        vslice_knobc.value = math.max(rs.selected_sample.loop_start, vslice_knobc.min)
        vslice_knobd.min = vslice_knoba.value + 1
        vslice_knobd.max = vslice_knobb.value
        vslice_knobd.value = math.min(rs.selected_sample.loop_end, vslice_knobd.max)
        vslice_infotxt.text = SLICE_SUBZOOM_DESCS[SLICE_FUNC_ZOOM_VERTICAL]
      end
    end
  end
end

local function f(mm)
  rs = renoise.song()
  if basement_active_view == BASEMENT_VIEW_TEST then
    test_midi_messages(mm, "Knob F")
  elseif basement_active_view == BASEMENT_VIEW_NONE then
    local nv = mod_midi_value(mm.int_value, rs.selected_track.postfx_volume.value_min, rs.selected_track.postfx_volume.value_max, false)
    rs.selected_track.postfx_volume.value = nv
  elseif basement_active_view == BASEMENT_VIEW_DEFAULT then
    local nv = mod_midi_value(mm.int_value, vdefault_knobf.min, vdefault_knobf.max, false)
    vdefault_knobf.value = nv
    if nv == 128 then
      rs.transport.keyboard_velocity = 64
      rs.transport.keyboard_velocity_enabled = false
    else
      if nv < 67 and nv > 61 then nv = 64
      elseif nv < 34 and nv > 30 then nv = 32
      elseif nv < 98 and nv > 94 then nv = 96 end
      rs.transport.keyboard_velocity = nv
      rs.transport.keyboard_velocity_enabled = true
    end
    vdefault_knobf.active = rs.transport.keyboard_velocity_enabled
    --[[rs.selected_track.postfx_volume.value = nv]]
  elseif basement_active_view == BASEMENT_VIEW_MIXER then
    local nv = mod_midi_value(mm.int_value, vmixer_knobf.min, vmixer_knobf.max, false)
    vmixer_knobf.value = nv
    mixer_tra.postfx_volume.value = nv
  elseif basement_active_view == BASEMENT_VIEW_HYDRAS then
    local nv = mod_midi_value(mm.int_value, 0, 1, false)
    vhydras_knobf.value = nv
    if hydras_hydras[6] then
      hydras_hydras[6]:parameter(1).value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_EFFECT then
    local nv = mod_midi_value(mm.int_value, effect_params[6].value_min, effect_params[6].value_max, false)
    veffect_knobs[6].value = nv
    if effect_params[6] ~= nil then
      effect_params[6].value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    local nv = mod_midi_value(mm.int_value, vinstrument_knobf.min, vinstrument_knobf.max, true)
    vinstrument_knobf.value = nv
    rs.selected_sample.new_note_action = nv
  elseif basement_active_view == BASEMENT_VIEW_SLICE then
    if vslice_knobfunc.value == SLICE_FUNC_ZOOM then
      if vslice_knobx.value == SLICE_FUNC_ZOOM_SELECT then
        local nv = mod_midi_value(mm.int_value, vslice_knoby.min, vslice_knoby.max, true)
        vslice_knoby.value = nv
        --[[  -- immediate slice
        if nv == SLICE_FUNC_ZOOM_SELECT_LOOP then
          slice_sel2loop()
        elseif nv == SLICE_FUNC_ZOOM_SELECT_INST then
        elseif nv == SLICE_FUNC_ZOOM_SELECT_SAMP then
        end
        ]]
        vslice_labely.text = SLICE_SUBSELECT_FUNCS[nv]
        vslice_infotxt.text = SLICE_SUBSELECT_DESCS[nv]
      elseif vslice_knobx.value == SLICE_FUNC_ZOOM_LOOPMRK then
        local nv = mod_midi_value(mm.int_value, vslice_knoby.min, vslice_knoby.max, true)
        vslice_knoby.value = nv
        local ov = rs.selected_sample.loop_mode
        if ov ~= nv then
          rs.selected_sample.loop_mode = nv
          vslice_labely.text = SLICE_LOOP_MODE_NAMES[nv]
        end
      elseif vslice_knobx.value == SLICE_FUNC_ZOOM_VERTICAL then
        local nv = mod_midi_value(mm.int_value, vslice_knoby.min, vslice_knoby.max, false)
        vslice_knoby.value = nv
        rs.selected_sample.sample_buffer.vertical_zoom_factor = (1-nv)^2
      end
    end
  end
end

local function g(mm)
  rs = renoise.song()
  if basement_active_view == BASEMENT_VIEW_TEST then
    test_midi_messages(mm, "Knob G")
  elseif basement_active_view == BASEMENT_VIEW_NONE then
    local nv = mod_midi_value(mm.int_value, 1, #rs.selected_track.devices, false)
    rs.selected_device_index = nv
    pad_update_dsp_active(true)
  elseif basement_active_view == BASEMENT_VIEW_DEFAULT then
    local nv = mod_midi_value(mm.int_value, vdefault_knobg.min, vdefault_knobg.max, false)
    vdefault_knobg.value = nv
    if vdefault_knobg.active then
      default_hydraf:parameter(1).value = nv
    end
    --[[rs.selected_device_index = nv]]
  elseif basement_active_view == BASEMENT_VIEW_MIXER then
    local nv = mod_midi_value(mm.int_value, vmixer_knobg.min, vmixer_knobg.max, false)
    vmixer_knobg.value = nv
    mixer_trb.postfx_volume.value = nv
  elseif basement_active_view == BASEMENT_VIEW_HYDRAS then
    local nv = mod_midi_value(mm.int_value, 0, 1, false)
    vhydras_knobg.value = nv
    if hydras_hydras[7] then
      hydras_hydras[7]:parameter(1).value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_EFFECT then
    local nv = mod_midi_value(mm.int_value, effect_params[7].value_min, effect_params[7].value_max, false)
    veffect_knobs[7].value = nv
    if effect_params[7] ~= nil then
      effect_params[7].value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    local nv = mod_midi_value(mm.int_value, vinstrument_knobg.min, vinstrument_knobg.max, true)
    vinstrument_knobg.value = nv
    rs.selected_sample.loop_mode = nv
  elseif basement_active_view == BASEMENT_VIEW_SLICE then
    local nv = mod_midi_value(mm.int_value, vslice_knobc.min, vslice_knobc.max, true)
    vslice_knobc.value = nv
    if vslice_knobfunc.value == SLICE_FUNC_ZOOM then
      if vslice_knobx.value == SLICE_FUNC_ZOOM_SELECT or vslice_knobx.value == SLICE_FUNC_ZOOM_VERTICAL then
        slice_reselect()
      elseif vslice_knobx.value == SLICE_FUNC_ZOOM_LOOPMRK then
        slice_reloop()
      end
    end
  end
end

local function h(mm)
  rs = renoise.song()
  if basement_active_view == BASEMENT_VIEW_TEST then
    test_midi_messages(mm, "Knob H")
  elseif basement_active_view == BASEMENT_VIEW_NONE then
    local pos = nil
    if rs.transport.follow_player then
      pos = rs.transport.playback_pos
      local nv = mod_midi_value(mm.int_value, 1, rs:pattern(rs.sequencer.pattern_sequence[pos.sequence]).number_of_lines, true)
      rs.transport.playback_pos = renoise.SongPos(pos.sequence, nv)
    else
      pos = rs.transport.edit_pos
      local nv = mod_midi_value(mm.int_value, 1, rs:pattern(rs.sequencer.pattern_sequence[pos.sequence]).number_of_lines, true)
      rs.transport.edit_pos = renoise.SongPos(pos.sequence, nv)
    end
  elseif basement_active_view == BASEMENT_VIEW_DEFAULT then
    local nv = mod_midi_value(mm.int_value, vdefault_knobh.min, vdefault_knobh.max, false)
    vdefault_knobh.value = nv
    if vdefault_knobh.active then
      default_hydraq:parameter(1).value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_MIXER then
    local nv = mod_midi_value(mm.int_value, vmixer_knobh.min, vmixer_knobh.max, false)
    vmixer_knobh.value = nv
    mixer_trc.postfx_volume.value = nv
  elseif basement_active_view == BASEMENT_VIEW_HYDRAS then
    local nv = mod_midi_value(mm.int_value, 0, 1, false)
    vhydras_knobh.value = nv
    if hydras_hydras[8] then
      hydras_hydras[8]:parameter(1).value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_EFFECT then
    local nv = mod_midi_value(mm.int_value, effect_params[8].value_min, effect_params[8].value_max, false)
    veffect_knobs[8].value = nv
    if effect_params[8] ~= nil then
      effect_params[8].value = nv
    end
  elseif basement_active_view == BASEMENT_VIEW_INSTRUMENT then
    local nv = mod_midi_value(mm.int_value, vinstrument_knobg.min, vinstrument_knobg.max, false)
    vinstrument_knobe.value = nv
    rs.selected_sample.panning = nv
  elseif basement_active_view == BASEMENT_VIEW_SLICE then
    local nv = mod_midi_value(mm.int_value+1, vslice_knobd.min, vslice_knobd.max, true)-1
    vslice_knobd.value = nv
    if vslice_knobfunc.value == SLICE_FUNC_ZOOM then
      if vslice_knobx.value == SLICE_FUNC_ZOOM_SELECT or vslice_knobx.value == SLICE_FUNC_ZOOM_VERTICAL then
        slice_reselect()
      elseif vslice_knobx.value == SLICE_FUNC_ZOOM_LOOPMRK then
        slice_reloop()
      end
    end
  end
end


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Basement:Show test dialog (disable encoder reaction)...",
  invoke = show_test_dialog
}

--[[
renoise.tool():add_keybinding {
  name = "Global:Basement:Show Default Dialog...",
  invoke = show_default_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Basement:Show Mixer Dialog...",
  invoke = show_mixer_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Basement:Show Hydras Dialog...",
  invoke = show_hydras_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Basement:Show Insert Dialog...",
  invoke = show_insert_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Basement:Show Effect Dialog...",
  invoke = show_effect_dialog
}
--]]

renoise.tool():add_keybinding {
  name = "Global:Basement:Close MPK Out",
  invoke = panic_close_mpk
}


--------------------------------------------------------------------------------
-- MIDI Mapping
--------------------------------------------------------------------------------

--[[
renoise.tool():add_midi_mapping {
  name = "Basement:Show Test Dialog...",
  invoke = show_test_dialog
}
--]]

--[[renoise.tool():add_midi_mapping {
  name = "Basement:Show Default Dialog...",
  invoke = function(mm)
    if mm.int_value > 0 then show_default_dialog() end
  end
}

renoise.tool():add_midi_mapping {
  name = "Basement:Show Mixer Dialog...",
  invoke = function(mm)
    if mm.int_value > 0 then show_mixer_dialog() end
  end
}

renoise.tool():add_midi_mapping {
  name = "Basement:Show Hydras Dialog...",
  invoke = function(mm)
    if mm.int_value > 0 then show_hydras_dialog() end
  end
}

renoise.tool():add_midi_mapping {
  name = "Basement:Show Insert Dialog...",
  invoke = function(mm)
    if mm.int_value > 0 then show_insert_dialog() end
  end
}

renoise.tool():add_midi_mapping {
  name = "Basement:Show Effect Dialog...",
  invoke = function(mm)
    if mm.int_value > 0 then show_effect_dialog() end
  end
}--]]

--[[for i = 1, 16 do
  renoise.tool():add_midi_mapping {
    name = "Basement:Pad " .. i,
    invoke = function(mm)
      pad(i, mm)
    end
  }
end--]]

renoise.tool():add_midi_mapping {
  name = "Basement:Pad 1",
  invoke = function(mm)
    pad(1, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 2",
  invoke = function(mm)
    pad(2, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 3",
  invoke = function(mm)
    pad(3, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 4",
  invoke = function(mm)
    pad(4, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 5",
  invoke = function(mm)
    pad(5, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 6",
  invoke = function(mm)
    pad(6, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 7",
  invoke = function(mm)
    pad(7, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 8",
  invoke = function(mm)
    pad(8, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 9",
  invoke = function(mm)
    pad(9, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 10",
  invoke = function(mm)
    pad(10, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 11",
  invoke = function(mm)
    pad(11, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 12",
  invoke = function(mm)
    pad(12, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 13",
  invoke = function(mm)
    pad(13, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 14",
  invoke = function(mm)
    pad(14, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 15",
  invoke = function(mm)
    pad(15, mm)
  end
}
renoise.tool():add_midi_mapping {
  name = "Basement:Pad 16",
  invoke = function(mm)
    pad(16, mm)
  end
}

renoise.tool():add_midi_mapping {
  name = "Basement:a",
  invoke = a
}

renoise.tool():add_midi_mapping {
  name = "Basement:b",
  invoke = b
}

renoise.tool():add_midi_mapping {
  name = "Basement:c",
  invoke = c
}

renoise.tool():add_midi_mapping {
  name = "Basement:d",
  invoke = d
}

renoise.tool():add_midi_mapping {
  name = "Basement:e",
  invoke = e
}

renoise.tool():add_midi_mapping {
  name = "Basement:f",
  invoke = f
}

renoise.tool():add_midi_mapping {
  name = "Basement:g",
  invoke = g
}

renoise.tool():add_midi_mapping {
  name = "Basement:h",
  invoke = h
}


--------------------------------------------------------------------------------
-- Listeners (transport)
--------------------------------------------------------------------------------

local function remove_hooks()
  if renoise.song().transport.playing_observable:has_notifier(pad_update_playing) then
    renoise.song().transport.playing_observable:remove_notifier(pad_update_playing)
  end
  if renoise.song().transport.metronome_enabled_observable:has_notifier(pad_update_metro) then
    renoise.song().transport.metronome_enabled_observable:remove_notifier(pad_update_metro)
  end
  if renoise.song().transport.loop_pattern_observable:has_notifier(pad_update_loop) then
    renoise.song().transport.loop_pattern_observable:remove_notifier(pad_update_loop)
  end
  if renoise.song().transport.edit_mode_observable:has_notifier(pad_update_rec) then
    renoise.song().transport.edit_mode_observable:remove_notifier(pad_update_rec)
  end
  if renoise.song().selected_device_index_observable:has_notifier(pad_update_dsp_active) then
    renoise.song().selected_device_index_observable:remove_notifier(pad_update_dsp_active)
  end
  if renoise.song().transport.follow_player_observable:has_notifier(pad_update_follow) then
    renoise.song().transport.follow_player_observable:remove_notifier(pad_update_follow)
  end
  if renoise.app().window.active_middle_frame_observable:has_notifier(pad_update_midframe) then
    renoise.app().window.active_middle_frame_observable:remove_notifier(pad_update_midframe)
  end
end
local function add_hooks()
  remove_hooks()
  renoise.song().transport.playing_observable:add_notifier(pad_update_playing)
  renoise.song().transport.metronome_enabled_observable:add_notifier(pad_update_metro)
  renoise.song().transport.loop_pattern_observable:add_notifier(pad_update_loop)
  renoise.song().transport.edit_mode_observable:add_notifier(pad_update_rec)
  renoise.song().selected_device_index_observable:add_notifier(pad_update_dsp_active)
  renoise.song().transport.follow_player_observable:add_notifier(pad_update_follow)
  renoise.app().window.active_middle_frame_observable:add_notifier(pad_update_midframe)
end
local function init()
  rs = renoise.song()
  pad_update_all()
  add_hooks()
end
renoise.tool().app_new_document_observable:add_notifier(init)


-- Do this when saving file
_AUTO_RELOAD_DEBUG = function()
  init()
end
