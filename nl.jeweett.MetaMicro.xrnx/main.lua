-------------------------------------------------------------
-- MetaMicro v0.2 by Cas Marrav (for Renoise 2.8)          --
-------------------------------------------------------------

local dialog = nil
local vb = nil

-- Renoise.Song thingy that you use all the time
local rs = nil

-- Dialog sub stuff
local vtrk = nil   -- Track select
local vdsp = nil   -- DSP select
local vpmt = nil   -- Parameter
local vmin = nil   -- Min
local vmax = nil   -- Max

local vtab = nil
local vlookup = {}

local vinfotxt = nil
local vqtxt = nil

local trk_names = {}
local dsp_names = {}
local pmt_names = {}

local q_trk = ""
local q_dsp = ""
local q_pmt = ""
local q_min = ""
local q_max = ""
local found_subset_trk = {} local found_subset_indices_trk = {}
local found_subset_dsp = {} local found_subset_indices_dsp = {}
local found_subset_pmt = {} local found_subset_indices_pmt = {}

-- Tabs
local TAB_TRK = 1
local TAB_DSP = 2
local TAB_PMT = 3
local TAB_MIN = 4
local TAB_MAX = 5

local MM_SEARCH = false

local DEBUG = true
local DRY_RUN = false


--------------------------------------------------------------------------------
-- Find functions
--------------------------------------------------------------------------------

local function find_objnames(query, obj_names, obj_indices, substr)
  local new_names = table.create()
  local new_indices = table.create()
  local len = #query
  local c = 1
  for k,v in ipairs(obj_names) do
    if substr then
      for i = 1, (#v - len) do
        if v:sub(i,len+i):lower() == query then
          new_names[c] = v
          new_indices[c] = obj_indices[k]
          c = c + 1
        end
      end
    else
      if v:sub(1,len):lower() == query then
        new_names[c] = v
        new_indices[c] = obj_indices[k]
        c = c + 1
      end
    end
  end
  return new_names, new_indices
end


--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

local function bind(metadev, trkno, dspno, pmtno, min, max)
  if DEBUG or DRY_RUN then
    print ("meta dev name: " .. metadev.name)
    print ("trk #: " .. trkno .. "   " .. rs:track(trkno).name)
    print ("dsp #: " .. dspno .. "   " .. rs:track(trkno):device(dspno).name)
    print ("pmt #: " .. pmtno .. "   " .. rs:track(trkno):device(dspno):parameter(pmtno).name)
    print ("min  : " .. min )
    print ("max  : " .. max )
  end
  if not DRY_RUN then
    local add = 0
    if metadev.name == "*Formula" then add = 3 end
    --Destination
    if not (metadev.name == "*Hydra" or metadev.name == "*XY Pad") then
      metadev:parameter(1+add).value = trkno-1
      metadev:parameter(2+add).value = dspno-1
      metadev:parameter(3+add).value = pmtno-1
    else
    end
    --Scaling
    min = min / 100.0
    max = max / 100.0
    if metadev.name == "*LFO" then
      local dev = (max-min)
      local mid = (max-min)/2+min - .5
      if DEBUG then
        print ("mid  : " .. mid )
        print ("dev  : " .. dev )
      end
      metadev:parameter(4).value = dev -- amplitude
      metadev:parameter(5).value = mid
    elseif metadev.name == "*Hydra" or metadev.name == "*XY Pad" then
      -- TODO: mode func arg
    else
      metadev:parameter(4+add).value = min
      metadev:parameter(5+add).value = max
    end
  end
end


--------------------------------------------------------------------------------
-- GUI functions
--------------------------------------------------------------------------------

local function q()
  local tab = vtab.value
  if tab == TAB_TRK then
    return q_trk
  elseif tab == TAB_DSP then
    return q_dsp
  elseif tab == TAB_PMT then
    return q_pmt
  elseif tab == TAB_MIN then
    return q_min
  elseif tab == TAB_MAX then
    return q_max
  end
end

local function seltrk(obj)
  if obj then
    return renoise.song():track(found_subset_indices_trk[vtrk.value])
  else
    return found_subset_indices_trk[vtrk.value]
  end
end

local function seldsp(obj)
  if obj then
    return seltrk(true):device(found_subset_indices_dsp[vdsp.value])
  else
    return found_subset_indices_dsp[vdsp.value]
  end
end

local function selpmt(obj)
  if obj then
    return seldsp(true):parameter(found_subset_indices_pmt[vpmt.value])
  else
    return found_subset_indices_pmt[vpmt.value]
  end
end

local function updateinfo()
  rs = renoise.song()
  local qstr
  local tab = vtab.value
  if tab == TAB_TRK then
    qstr = q_trk
  elseif tab == TAB_DSP then
    qstr = q_dsp
  elseif tab == TAB_PMT then
    qstr = q_pmt
  elseif tab == TAB_MIN then
    qstr = q_min
  elseif tab == TAB_MAX then
    qstr = q_max
  end
  vqtxt.text = qstr
  --vinfotxt.text = "..."
  vinfotxt.text = "Set Mod Destination for "..rs.selected_device.display_name.." to trk "..seltrk(false)..". "..seltrk(true).name.." dsp "..seldsp(false)..". "..seldsp(true).name.." pmt "..selpmt(false)..". "..selpmt(true).name.."?"
end

local function reset_q()
  local tab = vtab.value
  if tab == TAB_TRK then
    found_subset_trk = trk_names
    for i = 1, #trk_names do found_subset_indices_trk[i] = i end
    vtrk.items = trk_names
    q_trk = ""
  elseif tab == TAB_DSP then
    found_subset_dsp = dsp_names
    for i = 1, #dsp_names do found_subset_indices_dsp[i] = i end
    vdsp.items = dsp_names
    q_dsp = ""
  elseif tab == TAB_PMT then
    found_subset_pmt = pmt_names
    for i = 1, #pmt_names do found_subset_indices_pmt[i] = i end
    vpmt.items = pmt_names
    q_pmt = ""
  elseif tab == TAB_MIN then
    q_min = ""
  elseif tab == TAB_MAX then
    q_max = ""
  end
end

local function chtrk()
  for i,d in ipairs(seltrk(true).devices) do
    dsp_names[i] = d.name
  end
  vdsp.value = 1
  vdsp.items = dsp_names
  for i,p in ipairs(seldsp(true).parameters) do
    pmt_names[i] = p.name
  end
  vpmt.value = 1
  vpmt.items = pmt_names
end

local function chdsp()
  for i,p in ipairs(seldsp(true).parameters) do
    pmt_names[i] = p.name
  end
  vpmt.value = 1
  vpmt.items = pmt_names
end

local function chpmt()
end

local function chval()
  local tab = vtab.value
  if tab == TAB_TRK then
    chtrk()
  elseif tab == TAB_DSP then
    chdsp()
  elseif tab == TAB_PMT then
    chpmt()
  elseif tab == TAB_MIN then
  elseif tab == TAB_MAX then
  end
end

local function chtab()
  --reset_q()
end

local function key_dialog(d, k)
  local tab = vtab.value
  local vctl = vlookup[tab]
  if k.name == "esc" then
    d:close()
  elseif k.name == "left" then
    if tab > 1 then
      tab = tab - 1
      vtab.value = tab
      chtab()
    end
  elseif k.name == "right" or k.name == "tab" then
    if tab < 5 then
      tab = tab + 1
      vtab.value = tab
      chtab()
    end
  elseif k.name == "down" then
    if tab <= TAB_PMT then
      vctl.value = math.min(vctl.value + 1, #vctl.items)
    else
      vctl.value = math.min(vctl.value + 1, vctl.max)
    end
    chval()
  elseif k.name == "up" then
    if tab <= TAB_PMT then
      vctl.value = math.max(vctl.value - 1, 1)
    else
      vctl.value = math.max(vctl.value - 1, 1)
    end
    chval()
  elseif k.name == "space" then
    -- reset min & max? reset all??
    -- mode switch:
    --   if LFO > min/max to mid/ddev
    --   if XY / Hydra > cycle dest. number
    --   if sigfol etc > nothing
  elseif k.name == "return" then
    bind(rs.selected_device, seltrk(), seldsp(), selpmt(), vmin.value, vmax.value)
    d:close()
  elseif k.name == "back" then
    local len = #q() - 1
    if len > 0 then
      if tab >= TAB_MIN --[[or tab == TAB_MAX]] then
        local new_q = q():sub(1, #q()-1)
        local num = tonumber(new_q)
        if num >= vlookup[tab].min and num <= vlookup[tab].max then
          if tab == TAB_MIN then
            q_min = new_q
          elseif tab == TAB_MAX then
            q_max = new_q
          end
          vlookup[tab].value = num
        end
      else
        local new_q = q():sub(1, len)
        local new_found_subset, new_found_subset_indices
        reset_q()
        new_found_subset, new_found_subset_indices = find_objnames(new_q, found_subset, found_subset_indices, MM_SEARCH)
        found_subset = new_found_subset
        found_subset_indices = new_found_subset_indices
        vlookup[tab].items = found_subset
        if tab == TAB_TRK then
          q_trk = new_q
        elseif tab == TAB_DSP then
          q_dsp = new_q
        elseif tab == TAB_PMT then
          q_pmt = new_q
        end
        vlookup[tab].value = 1
      end
      if tab == TAB_TRK then chtrk()
      elseif tab == TAB_DSP then chdsp() end
    elseif len == 0 then
      reset_q()
    end
  elseif k.name == "del" then
    reset_q()
  elseif k.character ~= nil then
    if tab >= TAB_MIN --[[or tab == TAB_MAX]] and ((k.character >= "0" and k.character <= "9") or k.character == ".") then
      if tab == TAB_MIN then
        local new_q = q_min .. k.character
        local num = tonumber(new_q)
        if num >= vlookup[tab].min and num <= vlookup[tab].max then
          q_min = new_q
          vlookup[tab].value = num
        end
      elseif tab == TAB_MAX then
        local new_q = q_max .. k.character
        local num = tonumber(new_q)
        if num >= vlookup[tab].min and num <= vlookup[tab].max then
          q_max = new_q
          vlookup[tab].value = num
        end
      end
    else
      if tab == TAB_TRK then
        local new_q = q_trk .. k.character
        local new_found_subset, new_found_subset_indices
        new_found_subset, new_found_subset_indices = find_objnames(new_q, found_subset_trk, found_subset_indices_trk, MM_SEARCH)
        if #new_found_subset > 0 then
          found_subset_trk = new_found_subset
          found_subset_indices_trk = new_found_subset_indices
          vtrk.items = found_subset_trk
          q_trk = new_q
          vtrk.value = 1
          chtrk()
        end
      elseif tab == TAB_DSP then
        local new_q = q_dsp .. k.character
        local new_found_subset, new_found_subset_indices
        new_found_subset, new_found_subset_indices = find_objnames(new_q, found_subset_dsp, found_subset_indices_dsp, MM_SEARCH)
        if #new_found_subset > 0 then
          found_subset_dsp = new_found_subset
          found_subset_indices_dsp = new_found_subset_indices
          vdsp.items = found_subset_dsp
          q_dsp = new_q
          vdsp.value = 1
          chdsp()
        end
      elseif tab == TAB_PMT then
        local new_q = q_pmt .. k.character
        local new_found_subset, new_found_subset_indices
        new_found_subset, new_found_subset_indices = find_objnames(new_q, found_subset_pmt, found_subset_indices_pmt, MM_SEARCH)
        if #new_found_subset > 0 then
          found_subset_pmt = new_found_subset
          found_subset_indices_pmt = new_found_subset_indices
          vpmt.items = found_subset_pmt
          q_pmt = new_q
          vpmt.value = 1
          chpmt()
        end
      end
    end
  end
  updateinfo()
end

local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function show_dialog()
  rs = renoise.song()
  vb = renoise.ViewBuilder()
  print (rs.selected_device.name:sub(1,1))
  if rs.selected_device.name:sub(1,1) == "*" then
    local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
    local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN

    local default_device_no = 1
    if #rs.selected_track.devices > rs.selected_device_index then default_device_no = rs.selected_device_index + 1 end

    --selected tab = track
    for i,t in ipairs(rs.tracks) do
      trk_names[i] = t.name
      found_subset_indices_trk[i] = i
    end
    found_subset_trk = trk_names
    for i,d in ipairs(rs.selected_track.devices) do
      dsp_names[i] = d.name
      found_subset_indices_dsp[i] = i
    end
    found_subset_dsp = dsp_names
    for i,p in ipairs(rs.selected_track:device(default_device_no).parameters) do
      pmt_names[i] = p.name
      found_subset_indices_pmt[i] = i
    end
    found_subset_pmt = pmt_names

    q_trk = ""
    q_dsp = ""
    q_pmt = ""
    q_min = ""
    q_max = ""
    
    vtab = vb:switch {
      width = "100%",
      items = { "Track", "Effect", "Parameter", "Min", "Max" },
      value = TAB_PMT,
    }
    vtrk = vb:popup {
      width = 100,
      items = found_subset_trk,
      value = rs.selected_track_index,
    }
    vdsp = vb:popup {
      width = 100,
      items = found_subset_dsp,
      value = default_device_no,
    }
    vpmt = vb:popup {
      width = 100,
      items = found_subset_pmt,
      value = 1,
    }
    vmin = vb:slider {
      width = 100,
      min = 0, max = 100,
      value = 0,
    }
    vmax = vb:slider {
      width = 100,
      min = 0, max = 100,
      value = 100,
    }

    --vlookup = { TAB_TRK = vtrk, TAB_DSP = vdsp, TAB_PMT = vpmt, TAB_MIN = vmin, TAB_MAX = vmax }
    vlookup = { vtrk, vdsp, vpmt, vmin, vmax }

    vinfotxt = vb:text { text = "Info", width = "100%", }
    vqtxt = vb:text { text = "" }

    local dialog_content = 
      vb:column {
        margin = DDM, spacing = CS,
        vb:horizontal_aligner {
          margin = DDM, spacing = CS, width = "100%",
          vtab
        },
        vb:row {
          style = "border",
          margin = DDM, spacing = CS,
          vb:vertical_aligner {
            vtrk,
          },
          vb:vertical_aligner {
            vdsp,
          },
          vb:vertical_aligner {
            vpmt,
          },
          vb:vertical_aligner {
            vmin,
          },
          vb:vertical_aligner {
            vmax,
          },
        },
        vb:row {
          style = "border",
          margin = DDM, spacing = CS, width = "100%",
          vinfotxt,
        },
        vb:horizontal_aligner {
          mode = "right",
          margin = 2, spacing = 0, width = "100%", height = 16,
          vqtxt,
        }
      }

    close_dialog()
    dialog = renoise.app():show_custom_dialog("Meta Micro", dialog_content, key_dialog)
    updateinfo()
  else
    renoise.app():show_custom_prompt("Error", vb:text({text = "Selected device is not a meta device"}), { "OK" })
  end
end

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:MetaMicro...",
  invoke = show_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Tools:MetaMicro...",
  invoke = show_dialog
}
