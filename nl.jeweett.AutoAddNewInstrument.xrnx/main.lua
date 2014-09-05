-------------------------------------------------------------
-- Auto Insert Inst v0.1 by Cas Marrav (for Renoise 2.8)   --
-------------------------------------------------------------


-- Main --
local function plusins()
  local rs = renoise.song()
  local sii = rs.selected_instrument_index
  if sii == #rs.instruments then
    rs:insert_instrument_at(sii + 1)
  end
  rs.selected_instrument_index = sii + 1
end

local function minusins()
  local rs = renoise.song()
  local sii = rs.selected_instrument_index
  if sii > 1 then
    rs.selected_instrument_index = sii - 1
    if sii == #rs.instruments and #rs:instrument(sii).samples == 0 and #rs.instruments>10 then
      rs:delete_instrument_at(sii)
    end
  end
end

local function mkins()
  local rs = renoise.song()
  rs:insert_instrument_at(rs.selected_instrument_index+1)
  rs.selected_instrument_index = rs.selected_instrument_index+1
  rs.selected_instrument.active_tab = renoise.Instrument.TAB_SAMPLES
end

local function rmins()
  local rs = renoise.song()
  if #rs.instruments > 1 then
    rs:delete_instrument_at(rs.selected_instrument_index)
  end
end

local function plussmp()
  local rs = renoise.song()
  local ssi = rs.selected_sample_index
  local sc = #rs.selected_instrument.samples
  if ssi < sc then
    rs.selected_sample_index = ssi + 1
  elseif rs.selected_instrument:sample(sc).sample_buffer.has_sample_data then
    rs.selected_instrument:insert_sample_at(sc + 1)
    rs.selected_sample_index = ssi + 1
  end
end

local function minussmp()
  local rs = renoise.song()
  local ssi = rs.selected_sample_index
  local empty = not rs.selected_sample.sample_buffer.has_sample_data
  local sc = #rs.selected_instrument.samples
  if ssi > 1 then
    rs.selected_sample_index = ssi - 1
    if ssi == sc and empty then
      rs.selected_instrument:delete_sample_at(ssi)
    end
  end
end

local function mksmp()
  local rs = renoise.song()
  rs.selected_instrument:insert_sample_at(rs.selected_sample_index+1)
  rs.selected_sample_index = rs.selected_sample_index+1
  rs.selected_instrument.active_tab = renoise.Instrument.TAB_SAMPLES
end

local function rmsmp()
  local rs = renoise.song()
  if #rs.selected_instrument.samples > 1 then
    rs.selected_instrument:delete_sample_at(rs.selected_sample_index)
  end
end


-- Keys --
renoise.tool():add_keybinding {
  name = "Global:Instruments:Select or add Next Instrument",
  invoke = plusins
}
renoise.tool():add_keybinding {
  name = "Global:Instruments:Select or remove Prev. Instrument",
  invoke = minusins
}
renoise.tool():add_keybinding {
  name = "Global:Instruments:Select or add Next Sample",
  invoke = plussmp
}
renoise.tool():add_keybinding {
  name = "Global:Instruments:Select or remove Prev. Sample",
  invoke = minussmp
}
renoise.tool():add_keybinding {
  name = "Global:Instruments:Add Instrument",
  invoke = mkins
}
renoise.tool():add_keybinding {
  name = "Global:Instruments:Remove Instrument",
  invoke = rmins
}
renoise.tool():add_keybinding {
  name = "Global:Instruments:Add Sample",
  invoke = mksmp
}
renoise.tool():add_keybinding {
  name = "Global:Instruments:Remove Sample",
  invoke = rmsmp
}



_AUTO_RELOAD_DEBUG = function()
  
end
