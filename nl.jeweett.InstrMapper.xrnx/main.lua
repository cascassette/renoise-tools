-------------------------------------------------------------
-- InstrMapper v1 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

-- Set folder for Maschine (TM) Library "Samples" folder here
local basefolder = [[c:\CasMarrav\Sound\samples\Maschine\Maschine Library\Samples\Instruments\]]
local categories = os.dirnames(basefolder)

-- Tools stuff, GUI stuff etc
local rs
local vb
local dialog

-- For ordering samples
local keys_f = { "C", "DB", "D", "EB", "E", "F", "GB", "G", "AB", "A", "BB", "B" }
local keys_s = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }
local lookup_f = {}
local lookup_s = {}
for i,k in ipairs(keys_f) do
  lookup_f[k] = i
end
for i,k in ipairs(keys_s) do
  lookup_s[k] = i
end

-- Main --
local function create_mapped_instr(cat, ins, otr)
  local sl -- sample filename list
  local sample_folder = basefolder..cat..[[\]]..ins..[[ Samples\]]
  sl = os.filenames(sample_folder)
  local ml = {} -- mapping list
  -- every mapping entry gets: index(ordered), basenote, filename, lo_note, hi_note  ('note_range'), note_name
  -- calculate base_notes
  local bn = {} -- base notes
  for i,n in ipairs(sl) do
    local fn = n
    n = n:sub(1,-5)
    n = n:sub(-string.reverse(n):find(" ")+1)
    local oct=n:sub(-1)+otr
    local nn = n
    n = n:sub(1,-2)
    n = n:upper()
    local v = lookup_f[n]
    if v == nil then v = lookup_s[n] end
    local bn = oct*12+v-1
    ml[i] = { fn = fn, bn = bn, ln = bn, hn = bn, nn = nn }
  end
  -- sort by base note
  local function note_sort(a,b)
    return a.bn<b.bn
  end
  table.sort(ml, note_sort)
  -- make new instrument if necessary (+remove all layers)
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
  end
  ni.name = cat.." / "..ins
  rs.selected_instrument_index = nii
  -- make the mappings span (+pre-allocate sample slots)
  ml[1].ln=0
  for i=1,#ml-1 do
    ml[i].hn = ml[i+1].ln-1
    ni:insert_sample_at(1)
  end
  ml[#ml].hn=119
  for i,m in ipairs(ml) do
    ni:sample(i).sample_buffer:load_from(sample_folder..m.fn)
    ni:sample(i).name = m.nn:sub(1,1):upper()..m.nn:sub(2)
    ni:sample(i).loop_release = true
    ni:insert_sample_mapping(1, i, m.bn, {m.ln, m.hn})
  end
  -- set volume envelope
  ni.sample_envelopes.volume:init()
  ni.sample_envelopes.volume.enabled = true
  ni.sample_envelopes.volume.fade_amount = 0
  ni.sample_envelopes.volume:add_point_at(1,1)
  ni.sample_envelopes.volume:add_point_at(7,0)
  ni.sample_envelopes.volume.play_mode = 2
  ni.sample_envelopes.volume.sustain_position = 1
  ni.sample_envelopes.volume.sustain_enabled = true
  ni.sample_envelopes.volume.length = 49
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
    create_mapped_instr(vb.views['cat'].items[vb.views['cat'].value], vb.views['ins'].items[vb.views['ins'].value], vb.views['otr'].value)
    close_dialog()
  elseif k.name == "left" then
    vb.views['cat'].value=math.max(1,vb.views['cat'].value-1)
  elseif k.name == "right" then
    vb.views['cat'].value=math.min(vb.views['cat'].value+1,#vb.views['cat'].items)
  elseif k.name == "up" then
    vb.views['ins'].value=math.max(1,vb.views['ins'].value-1)
  elseif k.name == "down" then
    vb.views['ins'].value=math.min(vb.views['ins'].value+1,#vb.views['ins'].items)
  elseif k.name == "numpad *" then
    vb.views['otr'].value=math.min(vb.views['otr'].value+1,vb.views['otr'].max)
  elseif k.name == "numpad /" then
    vb.views['otr'].value=math.max(vb.views['otr'].value+1,vb.views['otr'].min)
  elseif k.character ~= nil then
    if k.modifiers == '' then
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
    end
  else
    pass = true
  end
  if pass then
    return k
  end
end

-- GUI --
local function update_ins_list(i)
  vb.views["ins"].value=1
  local list = os.dirnames(basefolder .. vb.views["cat"].items[i])
  for i,s in ipairs(list) do
    list[i] = s:sub(1,-9)
  end
  vb.views["ins"].items = list
end

local function show_dialog()
  rs = renoise.song()
  vb = renoise.ViewBuilder()
  local vb_dialog = vb:row {
    margin = 5, spacing = 2,
    vb:column {
      vb:text { text = "Cat." },
      vb:chooser { id = "cat", items = categories, notifier = update_ins_list },
    },
    vb:column {
      vb:text { text = "Inst." },
      vb:chooser { id = "ins", items = {'a','b'}, width = 180, active = false },
    },
    vb:column {
      vb:text { text = "Txpose" },
      vb:valuebox { id = "otr", min = -2, max = 2, value = 1 },
    },
  }
  dialog = renoise.app():show_custom_dialog( "InstruMap", vb_dialog, key_dialog )
  update_ins_list(1)
  vb.views["ins"].active = true
end


-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:InstrMapper",
  invoke = show_dialog
}


-- Keys --
renoise.tool():add_keybinding {
  name = "Instrument Box:Edit:InstrMapper",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:InstrMapper",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Instrument Keyzone:Tools:InstrMapper",
  invoke = show_dialog
}
renoise.tool():add_keybinding {
  name = "Pattern Editor:Tools:InstrMapper",
  invoke = show_dialog
}


_AUTO_RELOAD_DEBUG = function()
  
end
