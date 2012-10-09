-------------------------------------------------------------
-- InstrMixer v1 by Cas Marrav (for Renoise 2.8)           --
-------------------------------------------------------------

-- Implemented:
--[[
   * Mixer window to visualize what samples do within an instrument
   * Arrow keys and other keys easy to memorize, to control:
      * currently selected sample
      * volume, panning, loop mode, nna, transpose, finetune
      * ←/→ change sample
      * ↑/↓ change volume
      * I/O change panning
      * K/L change transpose
      * ,/. change finetune
      * P/[ change loop mode
      * ;/' change cut mode
   * Simple mute/solo sample functions (same keys: 1 and a)
   * Simple instrument change listen + support
   * Sample add/dupe support
   * Basic mouse slider action (select sample on value change)
   * Volume >0dB support
--]]

-- To do:
--[[
   * Small 'headers' indicating slider meaning
   * Multi-solo by mixing with mute key
   * Backup params before dialog opens => esc to undo
   ...
   * Think about visibility of increments / diff in txp/fit/pan
      maybe still again an 'infotxt' box
--]]


-- Vars --
local rs
local vb
local dialog

local sliders = {}
local selected

local instno
local sampcount

--local bak
local volbackup = {}
local volbackup_mute = table.create()


-- Const --
local CUT_MODES = { "ᐭ", "ᐅ", "ᐴ" }
local LOOP_MODES = { "ᐅ", "ᐅᐆ", "ᐅᐋ", "ᐆᐋ" }
--local CUT_MODES = { "Cut", "Note Off", "Continue" }
--local LOOP_MODES = { "»×", "»»", "««", "»«" }
--local LOOP_MODES = { "ᐅ", "ᐆᐆ", "ᐋᐋ", "ᐆᐋ" }

local pmtname     = { vol = "volume", pan = "panning", lpm = "loop_mode", ctm = "new_note_action", txp = "transpose", fit = "fine_tune" }
local inc_amounts = { vol = .05,      pan = .05      , lpm = 1,           ctm = 1                , txp = 1,           fit = 16 }
local snaps =       { vol =   1,      pan = 0.5      ,                                                                fit = 0  } --- not used yet


-- Hooks (selected_instrument)
local function hook_si()
  if dialog then
    dialog:close()
    --show_dialog()
    instrmixer()
  end
end

local function hook_ss()
  selected = renoise.song().selected_sample_index
  for i, s in ipairs(sliders) do
    s.style = "body"
  end
  sliders[selected].style = "panel"
  renoise.app():show_status(renoise.song().selected_sample.name)
end

local function select(i)
  selected = i
  update_sel()
end

local function inst_hook()
  if not renoise.song().selected_instrument_index_observable:has_notifier(hook_si) then
    renoise.song().selected_instrument_index_observable:add_notifier(hook_si)
  end
  if not renoise.song().selected_sample_index_observable:has_notifier(hook_ss) then
    renoise.song().selected_sample_index_observable:add_notifier(hook_ss)
  end
end

local function deinst_hook()
  if renoise.song().selected_instrument_index_observable:has_notifier(hook_si) then
    renoise.song().selected_instrument_index_observable:remove_notifier(hook_si)
  end
  if renoise.song().selected_sample_index_observable:has_notifier(hook_ss) then
    renoise.song().selected_sample_index_observable:remove_notifier(hook_ss)
  end
end


-- Backup/Restore
--[[
local function backup()
  local rs = renoise.song()
  bak = table.create()
  for i, s in ipairs(rs.selected_instrument.samples) do
    bak[i] = {
                vol = s.volume,
                pan = s.panning,
                lpm = s.loop_mode,
                txp = s.transpose,
                fit = s.fine_tune,
             }
  end
end

local function restore()
  local ci = renoise.song().selected_instrument
  for i, t in ipairs(bak) do
    ci:sample(i).volume    = t.vol
    ci:sample(i).panning   = pan,
    ci:sample(i).loop_mode = lpm,
    ci:sample(i).transpose = txp,
    ci:sample(i).fine_tune = fit,
  end
end
]]


-- Sample Dupe/Delete (with added functionality to not fuckup notifiers)
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
  hook_si()
  rs.selected_sample_index = csi+1
end

local function delsmp()
  renoise.song():describe_undo("Delete Sample")
  renoise.song().selected_instrument:delete_sample_at(rs.selected_sample_index)
  hook_si()
end


-- Solo & Mute
local function solo_backup_volumes()
  volbackup = table.create()
  for i, s in ipairs(renoise.song():instrument(instno).samples) do
    volbackup[i] = s.volume
  end
end

local function solo_restore_volumes()
  for i, s in ipairs(renoise.song():instrument(instno).samples) do
    s.volume = volbackup[i] 
  end
  volbackup = table.create()
end

local function soloing()
  return (#volbackup > 0)
end

local function solo()
  if not soloing() then
    solo_backup_volumes()
    for i, s in ipairs(renoise.song():instrument(instno).samples) do
      if i ~= selected then s.volume = 0 end
    end
  else
    solo_restore_volumes()
  end
end

local function mute()
  if volbackup_mute[selected] == nil then
    volbackup_mute[selected] = renoise.song():instrument(instno):sample(selected).volume
    renoise.song():instrument(instno):sample(selected).volume = 0
  else
    renoise.song():instrument(instno):sample(selected).volume = volbackup_mute[selected]
    volbackup_mute[selected] = nil
  end
end


-- GUI / Control
local function close_dialog()
  if ( dialog and dialog.visible ) then
    deinst_hook()
    dialog:close()
  end
end

local function get_selected(str, num)
  return vb.views[str..num]
end

local function mod_func(str, factor)
  local ctrl = get_selected(str, selected)
  if str == "lpm" then
    ctrl.value = math.min( math.max( ctrl.value + factor*inc_amounts[str], 1 ), #LOOP_MODES )
  elseif str == "ctm" then
    ctrl.value = math.min( math.max( ctrl.value + factor*inc_amounts[str], 1 ), #CUT_MODES )
  else
    ctrl.value = math.min( math.max( ctrl.value + factor*inc_amounts[str], ctrl.min ), ctrl.max )
  end
  loadstring("renoise.song().selected_instrument:sample("..selected..")."..pmtname[str].." = "..ctrl.value)()
end

local function update_volumes_gui()
  for i, s in ipairs(renoise.song():instrument(instno).samples) do
    get_selected("vol", i).value = s.volume
  end
end

local function key_dialog(d,k)
  if k.name == "right" then
    selected = math.min (selected + 1, #sliders)
    update_sel()
  elseif k.name == "left" then
    selected = math.max (selected - 1, 1)
    update_sel()
  elseif k.name == "up" then
    mod_func("vol", 1)
  elseif k.name == "down" then
    mod_func("vol", -1)
  elseif k.character == "o" then
    mod_func("pan", 1)
  elseif k.character == "i" then
    mod_func("pan", -1)
  elseif k.character == "l" then
    mod_func("txp", 1)
  elseif k.character == "k" then
    mod_func("txp", -1)
  elseif k.character == "." then
    mod_func("fit", 1)
  elseif k.character == "," then
    mod_func("fit", -1)
  elseif k.character == "[" then
    mod_func("lpm", 1)
  elseif k.character == "p" then
    mod_func("lpm", -1)
  elseif k.character == "'" then
    mod_func("ctm", 1)
  elseif k.character == ";" then
    mod_func("ctm", -1)
  elseif k.character == "1" then
    solo()
    update_volumes_gui()
  elseif k.character == "a" then
    mute()
    update_volumes_gui()
  elseif k.name == "numpad +" then
    renoise.song().selected_instrument_index = math.min(renoise.song().selected_instrument_index + 1, #renoise.song().instruments)
  elseif k.name == "numpad -" then
    renoise.song().selected_instrument_index = math.max(renoise.song().selected_instrument_index - 1, 1)
  elseif k.character == "d" then
    dubsmp(not (k.modifiers == "shift"))
  elseif k.character == "x" then
    delsmp()
  elseif k.name == "space" then
    -- apply to all???
  elseif k.name == "return" then
    close_dialog()
  elseif k.name == "esc" then
    --restore()
    close_dialog()
  else
    return k
  end
end

function make_sliders()
  vb = renoise.ViewBuilder()
  sliders = {}
  local res = vb:column {
    vb:row { id = "matrix" },
  }
  local smp
  for i = 1, sampcount do
    smp = renoise.song().selected_instrument:sample(i)
    --if smp.volume > 1 then smp.volume = 1 end
    sliders[i] = 
      vb:column {
        vb:slider { id = "vol"..i, min = 0, max = 4, value = smp.volume, height = 150, width = 40,
                    notifier=function(val) select(i) renoise.song():instrument(instno):sample(i).volume = val end },
                    
        vb:minislider { id = "pan"..i, min =    0, max =   1, value = smp.panning        , height = 20, width = 40,
                    notifier=function(val) select(i) renoise.song():instrument(instno):sample(i).panning = val end },
                    
        vb:minislider { id = "txp"..i, min = -120, max = 120, value = smp.transpose      , height = 20, width = 40,
                    notifier=function(val) select(i) renoise.song():instrument(instno):sample(i).transpose = val end },
                    
        vb:minislider { id = "fit"..i, min = -127, max = 127, value = smp.fine_tune      , height = 20, width = 40,
                    notifier=function(val) select(i) renoise.song():instrument(instno):sample(i).fine_tune = val end },
                    
        vb:popup      { id = "lpm"..i, items = LOOP_MODES   , value = smp.loop_mode      , height = 20, width = 40,
                    notifier=function(val) select(i) renoise.song():instrument(instno):sample(i).loop_mode = val end },
                    
        vb:popup      { id = "ctm"..i, items = CUT_MODES    , value = smp.new_note_action, height = 20, width = 40,
                    notifier=function(val) select(i) renoise.song():instrument(instno):sample(i).new_note_action = val end },
      }
--[[for _,pmt in ipairs({'vol','pan','txp','fit','lpm','ctm'}) do
      vb.views[pmt..i]:add_notifier(function() 
                                      loadstring("renoise.song().selected_instrument:sample("..i..")."..pmtname[pmt].." = "..vb.views[pmt..i].value)()
                                    end)
    end]]
    vb.views['matrix']:add_child(sliders[i])
  end
  return res
end

function update_sel()
  for i, s in ipairs(sliders) do
    s.style = "body"
  end
  sliders[selected].style = "panel"
  renoise.song().selected_sample_index = selected
  --vb.views['smpname'].text = renoise.song().selected_sample.name
  renoise.app():show_status(renoise.song().selected_sample.name)
end

function show_dialog()
  --backup()
  local stuff = make_sliders()
  selected = renoise.song().selected_sample_index

  --vb = renoise.ViewBuilder()
  if not ( dialog and dialog.visible ) then
    dialog = renoise.app():show_custom_dialog( "InstruMix", stuff, key_dialog )
  elseif dialog then
    dialog:show()
  end
  update_sel()
  inst_hook()
end

local function init_vars()
  instno = rs.selected_instrument_index
  sampcount = #rs.selected_instrument.samples
end

function instrmixer()
  rs = renoise.song()
  renoise.app().window.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
  init_vars()
  show_dialog()
end


-- Keys --
renoise.tool():add_keybinding {
  name = "Global:Tools:Show Instrument Mixer...",
  invoke = instrmixer
}


-- Reload --
_AUTO_RELOAD_DEBUG = function()
end
