--[[=======================================================-\
--||                                                       ||
--||     Sloper v0.2 by Cas Marrav (for Renoise 2.8)       ||
--||                                                       ||
--||                                                       ||
--\-=======================================================]]

-------------------------------------------------------------
-- Sloper v0.1 list                                        --
--                                                         --
--:Must haves                                              --
-- * normal operation with some different slope types      --
-- * usable GUI + keyboard operation                       --
--:Should haves                                            --
-- * keep window open option                               --
--:Could haves                                             --
-- * undo last edit                                        --
-- * save hi/lo positions, default slope type              --
-------------------------------------------------------------

local vst = nil
local vsp = nil
local vlo = nil
local vhi = nil
local vio = nil
local dialog = nil

local vtab = nil
local vlookup = {}

local vqtxt = nil
local q_st = nil
local q_sp = nil
local q_lo = nil
local q_hi = nil

local TAB_ST = 1
local TAB_SP = 2
local TAB_LO = 3
local TAB_HI = 4
local TAB_IO = 5

local SLOPE_LIN = 1
local SLOPE_EXP = 2
local SLOPE_SQR = 3
local SLOPE_COS = 4
local SLOPE_ATN = 5

local SLOPE_NAMES = { "Linear", "Exponential", "SquareRoot", "Cosine Half", "ArcTangent" }
local SLOPE_FORMULAS = { "X", "X^Y", "X^(1/Y)", "(math.cos((1-X)*math.pi)/2+.5)^Y", "(math.atan(1-T*2)/2+.5)^Y" }

local LEFT = renoise.SampleBuffer.CHANNEL_LEFT
local RIGHT = renoise.SampleBuffer.CHANNEL_RIGHT
local STEREO = renoise.SampleBuffer.CHANNEL_LEFT_AND_RIGHT

-- Main --
local function slope(st, sp, lo, hi, io)
  local rs = renoise.song()
  local sb = rs.selected_sample.sample_buffer
  if not sb.read_only then
    local step = 0.0
    local flo = lo/100.0
    local fhi = hi/100.0
    renoise.song():describe_undo("Sloper")
    local ch = sb.selected_channel
    local slope_func = loadstring("return function(X, Y) return "..SLOPE_FORMULAS[st].." end")()
    local sc = (sb.selection_end - sb.selection_start)+1
    sb:prepare_sample_data_changes()
    for i = 1, sc do
      if io == 2 then
        step = 1.0-i/sc
      else
        step = i/sc
      end
      if ch == STEREO and sb.number_of_channels == 2 then
        sb:set_sample_data( 1, sb.selection_start+i-1,
                sb:sample_data(1, sb.selection_start+i-1)*(flo+(fhi-flo)*slope_func(step, sp)) )
        sb:set_sample_data( 2, sb.selection_start+i-1,
                sb:sample_data(2, sb.selection_start+i-1)*(flo+(fhi-flo)*slope_func(step, sp)) )
      else
        if ch == STEREO then ch = 1 end
        sb:set_sample_data(ch, sb.selection_start+i-1,
                sb:sample_data(ch, sb.selection_start+i-1)*(flo+(fhi-flo)*slope_func(step, sp)) )
      end
    end
    sb:finalize_sample_data_changes()
  end
end

-- Gui --
local function q(tab)
  if tab == TAB_ST then
    return q_st
  elseif tab == TAB_SP then
    return q_sp
  elseif tab == TAB_LO then
    return q_lo
  elseif tab == TAB_HI then
    return q_hi
  end
end

local function reset_q()
  local tab = vtab.value
  if tab == TAB_SP then
    q_sp = ""
  elseif tab == TAB_LO then
    q_lo = ""
  elseif tab == TAB_HI then
    q_hi = ""
  end
  vqtxt.text = ""
end

local function key_dialog(d,k)
  local tab = vtab.value
  local vctl = vlookup[tab]

  if k.name == "up" then
    if tab == 1 then
      vctl.value = math.min(vctl.value + 1, #vctl.items)
    elseif tab == 3 or tab == 4 then
      vctl.value = math.min(vctl.value + 1, vctl.max)
    elseif tab == 5 then
      --if vctl.value == 1 then vctl.value = 2 else vctl.value = 1 end
      vctl.value = (vctl.value+2)%2+1
    end
    if tab < 5 and tab > 1 then
      if q(tab) and q(tab) ~= "" then
        vqtxt.text = q(tab)
      else
        vqtxt.text = tostring(vctl.value)
      end
    end
  elseif k.name == "down" then
    if tab == 1 then
      vctl.value = math.max(vctl.value - 1, 1)
      if vctl.value == 1 then vsp.value=1 end
    elseif tab == 3 or tab == 4 then
      vctl.value = math.max(vctl.value - 1, vctl.min)
    elseif tab == 5 then
      vctl.value = (vctl.value+2)%2+1
    end
  elseif not k.repeated then
    if k.name == "esc" then
      d:close()
    elseif k.name == "left" then
      if tab > 1 then
        tab = tab - 1
        if tab == 2 and ( vst.value == SLOPE_LIN ) then
          tab = tab - 1
        end
        vtab.value = tab
      end
    elseif k.name == "right" then
      if tab < 5 then
        tab = tab + 1
        if tab == 2 and ( vst.value == SLOPE_LIN ) then
          tab = tab + 1
        end
        vtab.value = tab
      end
    elseif k.name == "space" then
      vio.value = (vio.value+2)%2+1
    elseif k.name == "return" then
      slope(vst.value, vsp.value, vlo.value, vhi.value, vio.value)
    --elseif k.name == "back" then
    elseif k.name == "del" then
      reset_q()
    elseif k.character ~= nil then
      if tab == TAB_ST then
      elseif tab == TAB_SP then
        local new_q = q_sp .. k.character
        local num = tonumber(new_q)
        if num >= vsp.min and num <= vsp.max then
          q_sp = new_q
          vqtxt.text = new_q
          vsp.value = num
        end
      elseif tab == TAB_LO then
        local new_q = q_lo .. k.character
        local num = tonumber(new_q)
        if num >= vlo.min and num <= vlo.max then
          q_lo = new_q
          vqtxt.text = new_q
          vlo.value = num
        end
      elseif tab == TAB_HI then
        local new_q = q_hi .. k.character
        local num = tonumber(new_q)
        if num >= vhi.min and num <= vhi.max then
          q_hi = new_q
          vqtxt.text = new_q
          vhi.value = num
        end
      end
    end
  end
end

local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function show_dialog(out)
  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  q_st = ""
  q_sp = ""
  q_lo = ""
  q_hi = ""
  
  local io_value = 2
  if not out then io_value = 1 end
  
  vtab = vb:switch {
    width = "100%",
    items = { "Slope Type", "Param./Shape", "Low", "High", "Direction" },
    value = TAB_ST,
  }
  vst = vb:popup {
    width = 100,
    items = SLOPE_NAMES,
    value = 1,
  }
  vsp = vb:valuefield {
    width = 100,
    min = 0, max = 100,
    align = "right",
    value = 1,
  }
  vlo = vb:slider {
    width = 100,
    min = 0, max = 200,
    value = 0,
  }
  vhi = vb:slider {
    width = 100,
    min = 0, max = 200,
    value = 100,
  }
  vio = vb:switch {
    width = 100,
    items = { "Fade In", "Fade Out" },
    value = io_value,
  }
  
  vlookup = { vst, vsp, vlo, vhi, vio }
  
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
          vst,
        },
        vb:vertical_aligner {
          vsp,
        },
        vb:vertical_aligner {
          vlo,
        },
        vb:vertical_aligner {
          vhi,
        },
        vb:vertical_aligner {
          vio,
        },
      },
      vb:horizontal_aligner {
        mode = "right",
        margin = 2, spacing = 0, width = "100%", height = 16,
        vqtxt,
      }
    }

  close_dialog()
  dialog = renoise.app():show_custom_dialog("Sloper", dialog_content, key_dialog)
end

-- Menu --
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Sloper",
  invoke = function() show_dialog(true) end
}

-- Keys --
renoise.tool():add_keybinding {
  name = "Sample Editor:Fade:Sloper (out)",
  invoke = function() show_dialog(true) end
}
renoise.tool():add_keybinding {
  name = "Sample Editor:Fade:Sloper (in)",
  invoke = function() show_dialog(false) end
}

-- Midi --
--[[
renoise.tool():add_midi_mapping {
  name = "Sloper",
  invoke = x
}
--]]


_AUTO_RELOAD_DEBUG = function()
  
end
