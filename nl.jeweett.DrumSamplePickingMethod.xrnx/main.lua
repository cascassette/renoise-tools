-------------------------------------------------------------
-- DrumSamplePickingMethod v0.1 by Cas Marrav              --
-------------------------------------------------------------

-- Load preferences
local options = renoise.Document.create("DSPMPreferences")
{
  basefolder = [[c:\CasMarrav\Sound\samples\Cas\drums\]],
  weights = "",
}
renoise.tool().preferences = options

local categories
local cw = loadstring("return "..options.weights.value)()

-- per octave set
local newmapping1 = { "kicks", "hats", "kicks", "hats", "snares", "snares", "hats", "claps", "noises", "noises", "noises", "noises" }
local newmapping2 = { "kicks", "hats", "kicks", "hats", "snares", "claps", "snares", "claps", "kicks", "hats", "kicks", "hats", "snares", "noises", "snares", "noises" }
local newmapping3 = { "kicks", "kicks", "hats", "hats", "snares", "snares", "claps", "noises", "kicks", "kicks", "hats", "hats", "snares", "snares", "claps", "noises" }

-- Tools stuff, GUI stuff etc
local rs
local vb
local dialog

-- Sustain function, (stolen from syflom)
local function sustain_instrument()
  renoise.song().selected_instrument.sample_envelopes.volume.enabled = true
  renoise.song().selected_instrument.sample_envelopes.volume.fade_amount = renoise.InstrumentEnvelope.MIN_FADE_AMOUNT
  renoise.song().selected_instrument.sample_envelopes.volume:clear_points()
  renoise.song().selected_instrument.sample_envelopes.volume:add_point_at(1,1)
end

-- Find saved 'amount' values by category name
local function find_default_weight(c)
  for _,cwv in pairs(cw) do
    if cwv.name == c then
      --print(cwv.name .. ": " .. cwv.amount)
      return cwv.amount
    end
  end
  return 1
end

-- Main --
local function dspm(cw, total, shuffle) -- cw for category/weight pairs
  -- prepare instrument
  local nii
  local ni
  if rs.selected_instrument:sample(1).sample_buffer.has_sample_data or rs.selected_instrument.plugin_properties.plugin_loaded then
    nii = rs.selected_instrument_index+1
    ni = rs:insert_instrument_at(nii)
    ni:delete_sample_mapping_at(1,1)
  else
    nii = rs.selected_instrument_index
    ni = rs.selected_instrument
    for i=1,#ni.sample_mappings[1] do
      ni:delete_sample_mapping_at(1,1)
    end
    for i=1,#ni.samples-1 do
      ni:delete_sample_at(1)
    end
  end
  ni.name = "Drumsamples"
  rs.selected_instrument_index = nii
  for i=1,128 do ni:insert_sample_at(1) end
  -- calc the weights over 120 possible keys in renoise (sometimes we get 119 samples, oh well)
  local count = 0
  local sum = 0
  local ids = {}
  for c,a in pairs(cw) do
    if a ~= 0 then
      sum = sum + a
      count = count + 1
      ids[count] = c
    end
  end
  local weights = {}
  local smp = 1
  -- pick random samples
  for i=1,count do
    weights[i] = math.floor(cw[ids[i]]/sum*total)
    local fnlist = os.filenames(options.basefolder.value .. ids[i])
    for j=1,weights[i] do
      local fn = fnlist[math.random(#fnlist)]
      ni:sample(smp).sample_buffer:load_from(options.basefolder.value .. ids[i] .. [[\]] .. fn)
      ni:sample(smp).name = ids[i].."/"..fn
      smp = smp + 1
    end
  end
  -- shuffle them (don't sort alphabetically by group)
  if shuffle then
    for i=1,total do
      ni:swap_samples_at(math.random(total),math.random(total))
    end
  end
  -- mappings
  for i=1,total do
    ni:insert_sample_mapping(1,i,i-1,{i-1,i-1})
  end
end

local function dspm_oct(map, total, start_note)
  rs = renoise.song()
  local note = start_note
  -- prepare instrument
  local nii
  local ni
  if rs.selected_instrument:sample(1).sample_buffer.has_sample_data or rs.selected_instrument.plugin_properties.plugin_loaded then
    nii = rs.selected_instrument_index+1
    ni = rs:insert_instrument_at(nii)
    ni:delete_sample_mapping_at(1,1)
  else
    nii = rs.selected_instrument_index
    ni = rs.selected_instrument
    for i=1,#ni.sample_mappings[1] do
      ni:delete_sample_mapping_at(1,1)
    end
    for i=1,#ni.samples-1 do
      ni:delete_sample_at(1)
    end
  end
  ni.name = "Drumsamples"
  rs.selected_instrument_index = nii
  for i=1,total*#map do ni:insert_sample_at(1) end
  -- find samples
  local fnlist = {}
  local reslist = {}
  for i = 1,total do
    for n = 1,#map do
      local cat = map[n]
      if reslist[cat] == nil then reslist[cat] = {} end
      if fnlist[cat] == nil then
        fnlist[cat] = os.filenames(options.basefolder.value..cat)
      end
      local si = note-start_note+1
      local fn = fnlist[cat][math.random(#fnlist[cat])]
      while reslist[cat][fn] ~= nil do   -- make sure every sample only gets picked once
        fn = fnlist[cat][math.random(#fnlist[cat])]
      end
      reslist[cat][fn] = 1
      ni:sample(si).sample_buffer:load_from(options.basefolder.value..cat..[[\]]..fn)
      ni:sample(si).name = cat.."/"..fn
      ni:insert_sample_mapping(1,si,note,{note,note})
      note = note + 1
    end
  end
  sustain_instrument()
end

-- Dialog close --
local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

-- Dialog keys --
local function key_dialog(d, k)
  local pass = false
  if k.name == "esc" then
    close_dialog()
  elseif k.name == "return" then
    if k.modifiers == "" then
      local actual_cw = {}
      for _,c in ipairs(categories) do
        actual_cw[c] = vb.views[c].value
      end
      dspm(actual_cw, 120, vb.views['shuffle'].value)
      close_dialog()
    elseif k.modifiers == "alt" then
      wstr = "{"
      for i,c  in ipairs(categories) do wstr = wstr .. "{name='"..c.."',amount="..vb.views[c].value.."}," end
      wstr = wstr .. "}"
      options.weights.value = wstr
    end
  elseif k.character ~= nil then
    -- search
    --[[if k.modifiers == '' then
      local selector = vb.views['ins']
      for i,v in ipairs(selector.items) do
        if v:sub(1,1):upper() == k.character:upper() then
          selector.value = i
          break
        end
      end
    elseif k.modifiers == 'shift' then
      local selector = vb.views['cat']
      for i,v in ipairs(selector.items) do
        if v:sub(1,1):upper() == k.character:upper() then
          selector.value = i
          break
        end
      end
    end]]
  else
    pass = true
  end
  if pass then
    return k
  end
end

-- GUI --
local function show_dialog()
  categories = os.dirnames(options.basefolder.value)
  rs = renoise.song()
  vb = renoise.ViewBuilder()
  local vb_dialog = vb:row {}
  local coll = vb:column { id = "coll" }
  local colr = vb:column { id = "colr" }
  vb_dialog:add_child(coll)
  vb_dialog:add_child(colr)
  for i,c in ipairs(categories) do
    coll:add_child(vb:text { text = c })
    colr:add_child(vb:slider { id = c, min = 0, max = 1, value = 1 })
    vb.views[c].value = find_default_weight(c)
  end
  colr:add_child(vb:row { vb:text { text = "shuffle" }, vb:checkbox { id='shuffle', value=true } })
  dialog = renoise.app():show_custom_dialog( "DSPM", vb_dialog, key_dialog )
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:DrumSamplePickingMethod",
  invoke = show_dialog
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:DSPM - OctaveSet",
  invoke = function() dspm_oct(2, 36) end
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Instrument Box:Edit:DrumSamplePickingMethod",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:DrumSamplePickingMethod",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Instrument Keyzone:Tools:DrumSamplePickingMethod",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:DrumSamplePickingMethod",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Instrument Box:Edit:DSPM - OctaveSet",
  invoke = function() dspm_oct(newmapping1, 2, 36) end
}
renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:DSPM - OctaveSet",
  invoke = function() dspm_oct(newmapping1, 2, 36) end
}
renoise.tool():add_keybinding {
  name = "Instrument Keyzone:Tools:DSPM - OctaveSet",
  invoke = function() dspm_oct(newmapping1, 2, 36) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:DSPM - OctaveSet",
  invoke = function() dspm_oct(newmapping1, 2, 36) end
}
renoise.tool():add_keybinding {
  name = "Instrument Box:Edit:DSPM - NPadSet",
  invoke = function() dspm_oct(newmapping3, 4, 36) end
}
renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:DSPM - NPadSet",
  invoke = function() dspm_oct(newmapping3, 4, 36) end
}
renoise.tool():add_keybinding {
  name = "Instrument Keyzone:Tools:DSPM - NPadSet",
  invoke = function() dspm_oct(newmapping3, 4, 36) end
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:DSPM - NPadSet",
  invoke = function() dspm_oct(newmapping3, 4, 36) end
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
