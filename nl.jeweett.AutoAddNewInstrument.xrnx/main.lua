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
    if sii == #rs.instruments and not rs:instrument(sii):sample(1).sample_buffer.has_sample_data and #rs.instruments>10 then
      rs:delete_instrument_at(sii)
    end
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



_AUTO_RELOAD_DEBUG = function()
  
end
