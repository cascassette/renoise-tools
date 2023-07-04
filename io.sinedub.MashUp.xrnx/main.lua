-------------------------------------------------------------
-- Mashup v1.5.1 by Cas Marrav (for Renoise 2.8)           --
-------------------------------------------------------------

-- IDEAS / TODO
-- * grains from slices or from autochops
-- * autoselect proper grain source (slices if sliced instr, autochops otherwise)
-- * overtune-like math. function refs
-- * saving and loading of settings (into sample name, for now)

local load
local vb_formula
local vb_times
local vb_timesshow
local vb_chops
local vb_chopsshow
local vb_speed
local vb_mode
local dialog

local mode = nil
local MODE_SLICES = 1
local MODE_AUTOCHOPS = 2

local focus

-- mu builtins
local muvars =  -- variables
                "local pi = math.pi " ..
                "local lowrnd_buf = 0 local lowrnd_step = 0 " ..
                "local lownoi_buf = 0 local lownoi_step = 0 "
local mufuncs = -- basics
                "local sin = math.sin " ..
                "local cos = math.cos " ..
                "local tan = math.tan " ..
                "local asin = math.asin " ..
                "local acos = math.acos " ..
                "local atan = math.atan " ..
                "local sqrt = math.sqrt " ..
                "local max = math.max " ..
                "local min = math.min " ..
                "local mod = math.mod " ..
                "local rnd = math.random " ..
                "local flr = math.floor " ..
                "local abs = math.abs " ..
                "local equ = function(x) return x end " ..
                -- logic
                "local ite = function(i, t, e) if i then return t else return e end end " ..
                "local btoi = function(b) if b then return 1 else return 0 end end " ..
                "local itob = function(i) if i<=0 then return false else return true end end " ..
                -- other basic waveforms
                --"local saw = function(x) return math.mod(((x-(1/tl))+pi)/pi, 2)-1 end " ..
                "local saw = function(x) return 2*atan(tan(x/2))/pi end " ..
                "local squ = function(x) return (flr(sin(x)/2+1)*2-1) end " ..
                "local tri = function(x) return abs(1-mod((x+1.5*pi)/pi,2))*2-1 end " ..
                "local pls = function(x) return (flr(x/2+1)*2-1) end " ..                   -- that is: pulsify
                "local ltan = function(x, y) return max(min(tan(x), y), -y)/y end " ..      -- limit tan
                -- exponential sine, saw, tri
                "local expsin = function(x, p) if p>1 then return (squ(x)^(1-p%2))*sin(x)^p else return squ(x)*abs(sin(x))^p end end " ..
                "local expsaw = function(x, p) if p>1 then return (squ(x)^(1-p%2))*saw(x)^p else return squ(x)*abs(saw(x))^p end end " ..
                "local exptri = function(x, p) if p>1 then return (squ(x)^(1-p%2))*tri(x)^p else return squ(x)*abs(tri(x))^p end end " ..
                -- sine-made (recursive formula) waveforms
                "local sinsin sinsin = function(x, p) if p>1 then return sinsin(sin(x), p-1) else return sin(x) end end " ..
                "local sinsaw sinsaw = function(x, p) if p>1 then return sin(x*p)/p+sinsaw(x, p-1) else return sin(x) end end " ..
                "local sftsaw sftsaw = function(x, p) if p>1 then return sin(x*p)/(2^p)+sftsaw(x, p-1) else return sin(x) end end " ..
                "local sinsqu sinsqu = function(x, p) if p>1 then local v = p*2-1 return sin(x*v)/v+sinsqu(x, p-1) else return sin(x) end end " ..
                -- square root sine, saw, tri
                "local sqtfunhelp sqtfunhelp = function(fun, x, p) if p>1 then return sqrt(sqtfunhelp(fun, x, p-1)) else return abs(fun(x)) end end " ..
                "local sqtsin = function(x, p) return squ(x)*sqtfunhelp(sin, x, p) end " ..
                "local sqtsaw = function(x, p) return squ(x)*sqtfunhelp(saw, x, p) end " ..
                "local sqttri = function(x, p) return squ(x)*sqtfunhelp(tri, x, p) end " ..
                -- range [0..1] to [-1..1] and vice versa (ac/dc, [0..1] is good for modulating)
                "local un = function(x) return (x+1)/2 end " ..
                "local bi = function(x) return x*2-1 end " ..
                -- distort (clip, fold, crush, noise) functions
                "local clip = function(x, y) return max(min(x, y), -y) end " ..
                "local semiclip = function(x, y, z) return (max(min(x, y), -y)*z + (1-z)*x) end " ..
                "local fold = function(x, y) return -bi(abs(1-abs(un((1+y)*x)))) end " ..
                "local semifold = function(x, y, z) return fold(x, y)*z + (1-z)*x end " ..
                "local crush = function(x, y) return flr(x*y)/y end " ..
                "local semicrush = function(x, y, z) return (flr(x*y)/y)*z + (1-z)*x end " ..
                "local noise = function(x, y, p) return x+(ite(x<0, -1, 1))*y*(abs(x)^p)*rnd() end " ..     -- add noise according to amp(x) and factor(y) and curve(p)
                "local lowrnd = function ( t, skip ) if lowrnd_step == 0 then lowrnd_buf = rnd() end lowrnd_step = mod( lowrnd_step + 1, skip ) return lowrnd_buf end " ..
                "local lownoise = function ( t, part ) if lownoi_step ~= flr(t*part) then lownoi_buf = rnd() end lownoi_step = flr(t*part) return lownoi_buf end " ..
                -- supermin/supermax type 'clip' functions
                "local supermax = function(x, y) if x >= 0 then return max(x,y) else return min(x,y) end end " ..
                "local supermin = function(x, y) if x >= 0 then return min(x,y) else return max(x,y) end end " ..
                -- morph between two functions
                "local morph = function(x, y, z) return ((1-z)*x+z*y) end " ..
                -- unary [0..1] pulse from/to
                "local upft = function(x, f, t) if x < f or x >= t then return 0 else return 1 end end " ..
                "local upf = function(x, f) if x < f then return 0 else return 1 end end " ..
                "local upt = function(x, t) if x >= t then return 0 else return 1 end end " ..
                -- ramps
                "local sqrtsqrt = function(x, p) return sqtfunhelp(equ, x, p) end " ..
                "local ru = function(t, p) return t^p end " ..                   -- ramp (exp)
                "local rd = function(t, p) return (1-t)^p end " ..
                "local aru = function(t, p) return 1-(1-t)^p end " ..            -- anti-ramp
                "local ard = function(t, p) return 1-t^p end " ..
                "local rru = function(t, p) return 1-sqrtsqrt(1-t, p) end " ..   -- root ramp
                "local rrd = function(t, p) return 1-sqrtsqrt(t, p) end " ..
                "local raru = function(t, p) return sqrtsqrt(t, p) end " ..      -- root anti-ramp
                "local rard = function(t, p) return sqrtsqrt(1-t, p) end " ..
                -- envelope
                "local env = function(x, t) local y = 0 local pc local pn = nil for i = 1, #t-1 do if pn ~= nil then pc = pn else pc = t[i] end pn = t[i+1] if x < pn[1] and x >= pc[1] then if pn[3] == nil or pn[4] == nil then y = ((x-pc[1])/(pn[1]-pc[1]))*(pn[2]-pc[2])+pc[2] else y = pn[3](((x-pc[1])/(pn[1]-pc[1])),pn[4])*(pn[2]-pc[2])+pc[2] end break end end return y end "

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Mash up...",
  invoke = function()
    --show_random_dialog()
    show_formula_dialog()
  end
}

-------------------------------------------------------------
-- GUI                                                     --
-------------------------------------------------------------
local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function key_slowdown_dialog(d,k)
  if ( k.name == "return" ) then
    local cii = renoise.song().selected_instrument_index
    local csi = renoise.song().selected_sample_index
    local nii = renoise.song().selected_instrument_index+1
    renoise.song():insert_instrument_at(nii)
    render_mashup( cii, csi, nii, "flr(mod((X+1)/"..tostring(vb_speed.value).."-1,N))+1", math.floor(vb_chops.value*vb_speed.value), MODE_AUTOCHOPS, vb_chops.value )
    close_dialog()
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    return k
  end
end

function show_slowdown_prompt()
  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  mode = MODE_AUTOCHOPS

  vb_chops = vb:minislider { min = 1, max = 1024, value = 32, width = 120 }
  vb_chopsshow = vb:valuebox { min = 1, max = 1024, value = 32, width = 80 }
  local vb_chopsrow = vb:row { vb_chops, vb_chopsshow }
  vb_chops:add_notifier(function() vb_chopsshow.value = math.floor(vb_chops.value) end)
  
  vb_speed = vb:valuefield { min = 1.0, max = 12.0, value = 2.0, width = 50 }
  
  local vb_dialog = vb:horizontal_aligner {
    margin = DDM,
    spacing = CS,
    vb:column {
      vb:text { text = "slow: " },
      vb:text { text = "reso: " },
    },
    vb:column {
      vb_speed,
      vb_chopsrow,
    }
  }
  
  dialog = renoise.app():show_custom_dialog( "MashUp: Slow Down", vb_dialog, key_slowdown_dialog )
end

local function key_speedup_dialog(d,k)
  if ( k.name == "return" ) then
    local cii = renoise.song().selected_instrument_index
    local csi = renoise.song().selected_sample_index
    local nii = renoise.song().selected_instrument_index+1
    renoise.song():insert_instrument_at(nii)
    render_mashup( cii, csi, nii, "flr(mod(X*"..tostring(vb_speed.value).."-1,N))+1", math.floor(vb_chops.value/vb_speed.value), MODE_AUTOCHOPS, vb_chops.value )
    close_dialog()
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    return k
  end
end

function show_speedup_prompt()
  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  mode = MODE_AUTOCHOPS

  vb_chops = vb:minislider { min = 1, max = 1024, value = 32, width = 120 }
  vb_chopsshow = vb:valuebox { min = 1, max = 1024, value = 32, width = 80 }
  local vb_chopsrow = vb:row { vb_chops, vb_chopsshow }
  vb_chops:add_notifier(function() vb_chopsshow.value = math.floor(vb_chops.value) end)
  
  vb_speed = vb:valuefield { min = 1.0, max = 12.0, value = 2.0, width = 50 }
  
  local vb_dialog = vb:horizontal_aligner {
    margin = DDM,
    spacing = CS,
    vb:column {
      vb:text { text = "fast: " },
      vb:text { text = "reso: " },
    },
    vb:column {
      vb_speed,
      vb_chopsrow,
    }
  }
  
  dialog = renoise.app():show_custom_dialog( "MashUp: Speed Up", vb_dialog, key_speedup_dialog )
end

local function key_dialog(d,k)
  if ( k.name == "up" ) then
    vb_times.value = vb_times.value + 1
  elseif ( k.name == "down" ) then
    vb_times.value = vb_times.value - 1
  elseif ( k.name == "right" ) then
    vb_times.value = vb_times.value * 2
  elseif ( k.name == "left" ) then
    vb_times.value = vb_times.value / 2
  elseif ( k.name == "return" ) then
    local cii = renoise.song().selected_instrument_index
    local csi = renoise.song().selected_sample_index
    local nii = renoise.song().selected_instrument_index+1
    renoise.song():insert_instrument_at(nii)
    render_mashup( cii, csi, nii, vb_formula.value, math.floor(vb_timesshow.value), mode, vb_chops.value or 0 )
    close_dialog()
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    return k
  end
end

function show_formula_dialog()
  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  mode = MODE_AUTOCHOPS
  if #renoise.song().selected_instrument:sample(1).slice_markers > 0 then
    mode = MODE_SLICES
  end
  
  vb_formula = vb:textfield { value = "rnd(N)", width = 400 }
  local vb_mode = vb:switch { items = { "Slices", "AutoChops" }, value = mode, active = false, width = 250 }
  
  vb_times = vb:slider { min = 1, max = 1048576, value = 32, width = 300 }
  vb_timesshow = vb:valuebox { min = 1, max = 1048576, value = 32, width = 100 }
  local vb_timesrow = vb:row { vb_times, vb_timesshow }
  vb_times:add_notifier(function() vb_timesshow.value = math.floor(vb_times.value) end)
  
  vb_chops = vb:slider { min = 1, max = 1024, value = 32, width = 300 }
  vb_chopsshow = vb:valuebox { min = 1, max = 1024, value = 32, width = 100 }
  local vb_chopsrow = vb:row { vb_chops, vb_chopsshow }
  vb_chops:add_notifier(function() vb_chopsshow.value = math.floor(vb_chops.value) end)
  
  local vb_dialog = nil
  if mode == MODE_SLICES then
    vb_dialog = vb:horizontal_aligner {
      margin = DDM,
      spacing = CS,
      vb:column {
        vb:text { text = "select:" },
        vb:text { text = "times: " },
        vb:text { text = "mode:  " },
      },
      vb:column {
        vb_formula,
        vb_timesrow,
        vb_mode,
      }
    }
  else
    vb_dialog = vb:horizontal_aligner {
      margin = DDM,
      spacing = CS,
      vb:column {
        vb:text { text = "select:" },
        vb:text { text = "times: " },
        vb:text { text = "grains:" },
        vb:text { text = "mode:  " },
      },
      vb:column {
        vb_formula,
        vb_timesrow,
        vb_chopsrow,
        vb_mode,
      }
    }
  end

  dialog = renoise.app():show_custom_dialog("Mash up!", vb_dialog, key_dialog)
end

--[[function show_random_dialog()
  local vb = renoise.ViewBuilder()
  vb_times = vb:slider { min = 1, max = 1024, value = 1, width = 200 }
  local vb_timesshow = vb:valuebox { min = 1, max = 1024, value = 1, width = 100 }
  local vb_txt = vb:text { text = "times:" }
  local vb_timesrow = vb:row { vb_txt, vb_times, vb_timesshow }
  vb_times:add_notifier(function() vb_timesshow.value = math.floor(vb_times.value) end)

  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  local dialog_content = vb:horizontal_aligner
  {
    vb:column {
      margin = DDM, spacing = CS,
      vb_timesrow,
    },
  }
    
  if not ( dialog and dialog.visible ) then
    dialog = renoise.app():show_custom_dialog( "Mash up!", dialog_content, key_dialog )
  end
end]]


-------------------------------------------------------------
-- Main                                                    --
-------------------------------------------------------------
function render_mashup( cii, csi, nii, formulastr, nl, mode, chops )
  local rs = renoise.song()
  local ni = rs:instrument(nii)
  local ci = rs:instrument(cii)
  --local cs = ci:sample(csi)
  local insn = ci.name .. " Mashup x " .. nl
  local smpn = ci.name .. " Mashup !! { "..
                                       "times=" .. nl .. "," ..
                                       "formula='" .. formulastr .. "'," ..
                                       "source='" .. cii .. ":" .. csi .. "'," ..
                                       "mode=" .. mode .. "," ..
                                       "chops=" .. chops ..
                                    " }"
  local lpm = ci:sample(csi).loop_mode
  -- retrieve proper base_note
  local bn = 48
  if mode == MODE_AUTOCHOPS then bn = ci:sample_mapping(1, csi).base_note end
  -- compute grain lengths
  local sc
  local sl = {}
  if mode == MODE_SLICES then
    sc = #ci:sample(1).slice_markers
    for i = 1, sc do
      if i < sc then
        sl[i] = ci:sample(1).slice_markers[i+1] - ci:sample(1).slice_markers[i]
      else
        sl[i] = ci:sample(1).sample_buffer.number_of_frames - ci:sample(1).slice_markers[i]
      end
    end
  elseif mode == MODE_AUTOCHOPS then 
    sc = chops
    local asl = math.floor(ci:sample(csi).sample_buffer.number_of_frames/sc)
    for i = 1, sc do
      sl[i] = asl
    end
  end
  -- sample properties
  local cc = ci:sample(csi).sample_buffer.number_of_channels    -- channel count
  local bd = ci:sample(csi).sample_buffer.bit_depth             -- bit depth
  local sr = ci:sample(csi).sample_buffer.sample_rate           -- sample rate
  -- formula based selection, compute total length
  local newlensmp = 0
  local newlensmpx = {}
  local select = {}
  rs:describe_undo("Render Mashup")
  local formula = loadstring( muvars .. " return function(X, N) " .. mufuncs .. " return " .. formulastr .. " end" )()
  for i = 1, nl do
    local x = math.min(math.max(
                                formula(i, sc)
                               , 1), sc)                        -- anti-crash security measure
    select[i] = x
    newlensmpx[i] = newlensmp
    newlensmp = newlensmp + sl[x] --ci:sample(x+1).sample_buffer.number_of_frames
  end
  -- render
  local sb = ni:sample(1).sample_buffer
  sb:create_sample_data( sr, bd, cc, newlensmp )
  sb:prepare_sample_data_changes()
  if mode == MODE_SLICES then
    for i = 1, nl do                  -- slice
      for c = 1, cc do                -- channel
        for j = 1, sl[select[i]] do
          sb:set_sample_data(c,newlensmpx[i]+j,
                              ci:sample(select[i]+1).sample_buffer:sample_data(c,j)
                             )
        end
      end
    end
  elseif mode == MODE_AUTOCHOPS then 
    for i = 1, nl do                  -- slice
      for c = 1, cc do                -- channel
        for j = 1, sl[select[i]] do
          sb:set_sample_data(c,newlensmpx[i]+j,
                              ci:sample(csi).sample_buffer:sample_data(c,(select[i]-1)*sl[1]+j)
                             )
        end
      end
    end
  end
  sb:finalize_sample_data_changes()
  ni:sample(1).loop_mode = lpm
  ni:delete_sample_mapping_at(1, 1)
  ni:insert_sample_mapping(1, 1, bn)
  ni.name = insn
  ni:sample(1).name = smpn
  rs.selected_instrument_index = nii
end

--[[function render_random_mashup( cii, nii, nl ) -- current / new instrument index, new length (in slices)
  local rs = renoise.song()
  local ni = rs:instrument(nii)
  local ci = rs:instrument(cii)
  local nn = ci.name .. " Mashup x " .. nl
  --local bn = ci:sample_mapping(1,1).base_note
  local bn = 9
  --local sm = #ci.samples-1
  local sc = #ci:sample(1).slice_markers
  --local sl = (ci:sample(1).sample_buffer.number_of_frames/sm)
  local sl = {}
  for i = 1, sc do
    if i < sc then
      sl[i] = ci:sample(1).slice_markers[i+1] - ci:sample(1).slice_markers[i]
    else
      sl[i] = ci:sample(1).sample_buffer.number_of_frames - ci:sample(1).slice_markers[i]
    end
  end
  local cc = ci:sample(1).sample_buffer.number_of_channels    -- channel count
  local bd = ci:sample(1).sample_buffer.bit_depth             -- bit depth
  local sr = ci:sample(1).sample_buffer.sample_rate           -- sample rate
  local newlen = nl
  local newlensmp = 0
  local newlensmpx = {}
  local select = {}
  for i = 1, nl do
    local x = math.random(sc)
    select[i] = x
    newlensmpx[i] = newlensmp
    newlensmp = newlensmp + ci:sample(x+1).sample_buffer.number_of_frames
  end
  local sb = ni:sample(1).sample_buffer
  sb:create_sample_data( sr, bd, cc, newlensmp )
  sb:prepare_sample_data_changes()
  for i = 1, nl do                  -- slice
    for c = 1, cc do                -- channel
      for j = 1, sl[ select[ i ] ] do
        --sb:set_sample_data(c,(i-1)*sl+j,ci:sample(x+1).sample_buffer:sample_data(c,j))
        sb:set_sample_data(c,newlensmpx[i]+j,ci:sample(select[i]+1).sample_buffer:sample_data(c,j))
      end
    end
  end
  sb:finalize_sample_data_changes()
  ni:delete_sample_mapping_at(1, 1)
  ni:insert_sample_mapping(1, 1, bn)
  ni.name = nn
  ni:sample(1).name = nn
  rs.selected_instrument_index = nii
end]]

--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:Mash up...",
  --invoke = show_random_dialog
  invoke = show_formula_dialog
}
renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:Mash up - Slow Down...",
  invoke = show_slowdown_prompt
}
renoise.tool():add_keybinding {
  name = "Sample Editor:Tools:Mash up - Speed Up...",
  invoke = show_speedup_prompt
}

-------------------------------------------------------------
-- autoreload function                                     --
-------------------------------------------------------------
_AUTO_RELOAD_DEBUG = function()
end
