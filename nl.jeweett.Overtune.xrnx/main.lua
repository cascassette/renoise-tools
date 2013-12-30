-------------------------------------------------------------
-- Overtune v2.5.983 by Cas Marrav (for Renoise 2.8)       --
-------------------------------------------------------------

--[[ Overtune 2.6 todo                                     --
--     * overtones always on, step1=stepn(0)               --
--       * backwards compatible loading function           --
--     * swap X and XX                                     --
--     * improve env function                              --
--       * multiline edit                                  --
--     * re-render every overtune @ SR,[Note]              --
--     * stereo phase shift in deg                         --
--   Overtune 2.7 ideas                                    --
--     * awesomesawce/detune stuff (+in settings)          --
--     * improve edit function                             --
--       * run edit function over selection only           --
--       * have x var run over whole sample/selection,     --
--         or cycle in tones/frequencies/notes             --
--     * use other samples/instr as indexable cycles       --
--     * render multiple samples for different notes       --
--       * add real ms decay type variables                --
--     * sample rate in instrument, prefs                  --
--     * tuning A-440 in instrument, preferences           --
--   Overtune 3.0 ideas                                    --
--     * sustain phase with proper repeating cycle         --
--       * way to find 'gcd' among cycle lengths           --
--     * reusable code / envelopes / wave cycles           --
--     * better interface / logic;                         --
--         (INF) list of nameable, callable subparts       --
--         one 'final' formula field to combine them       --
--                                                         --
--                                                         ]]

-- cycle length calculation
local SAMPLE_RATE = 48000
local SEMITONE_FACTOR = (2^(1/12))
local BASE_FREQ = 440               -- A-4
local BASE_NOTE = 57

-- ot gui
local load
local vb_step1
local vb_stepn
local vb_steps
local vb_times
local vb_stepsshow
local vb_timesshow
local vb_power
local vb_stereo
local vb_base_note
local dialog

local focus
local delete_obsolete_samples_on_render = false

-- ot builtins
local otvars =  -- variables
                "local pi = math.pi " ..
                "local t_buf = -1 " ..
                "local rndstw_buf = 0 " ..
                "local lowrnd_buf = 0 local lowrnd_step = 0 " ..
                "local lownoi_buf = 0 local lownoi_step = 0 " ..
                "local quantz_buf = 0 local quantz_step = 0 " ..
                "local sf = " .. SEMITONE_FACTOR .. " " ..
                "local TX = 2*pi " ..
                "local TT = 1/TX " ..
                "local FIFTH = 3/2 " ..
                "local FOURTH = 4/3 " ..
                "local MAJTHIRD = 5/4 " ..
                "local MINTHIRD = 6/5 "
local otfuncs = -- basics
                "local sin = math.sin " ..
                "local cos = math.cos " ..
                "local tan = math.tan " ..
                "local asin = math.asin " ..
                "local acos = math.acos " ..
                "local atan = math.atan " ..
                "local sinh = math.sinh " ..
                "local cosh = math.cosh " ..
                "local tanh = math.tanh " ..
                "local sqrt = math.sqrt " ..
                "local max = math.max " ..
                "local min = math.min " ..
                "local mod = math.mod " ..
                "local rnd = function() return 2*math.random()-1 end " ..
                "local urnd = math.random " ..
                "local flr = math.floor " ..
                "local abs = math.abs " ..
                "local equ = function(x) return x end " ..
                -- other basic waveforms
                "local saw = function(x) return 2*atan(tan(x/2))/pi end " ..                -- old one = math.mod(((x-(1/tl))+pi)/pi, 2)-1
                "local squ = function(x) return (flr(sin(x)/2+1)*2-1) end " ..
                "local tri = function(x) return abs(1-mod((x+1.5*pi)/pi,2))*2-1 end " ..
                "local pls = function(x) return (flr(x/2+1)*2-1) end " ..                   -- that is: pulsify
                "local par = function(x,p) return (-saw(X*2+TX*.5)^p)*squ(X)+squ(X) end " ..
                "local semipls = function(x,a) return a*pls(x)+(1-a)*x end " ..
                "local ltan = function(x, y) return max(min(tan(x), y), -y)/y end " ..      -- limit tan
                -- just for shorter notation in OT formulas
                "local sin1 = function(t) return sin(t*2*pi) end " ..
                "local squ1 = function(t) return squ(t*2*pi) end " ..
                "local tri1 = function(t) return tri(t*2*pi) end " ..
                "local saw1 = function(t) return saw(t*2*pi) end " ..
                "local pw1 = function(t,w) if mod(t,1) <= w then return 1 else return -1 end end " ..
                -- range [0..1] to [-1..1] and vice versa (ac/dc, [0..1] is good for modulating)
                "local un = function(x) return (x+1)/2 end " ..
                "local bi = function(x) return x*2-1 end " ..
                -- range [0..1] to [0..2pi] and vice versa
                "local tt = function(x) return x/2/pi end " ..
                "local tx = function(t) return t*2*pi end " ..
                -- pulsewidth wave
                "local pw = function(x,w) return pw1(tt(x),w) end " ..
                -- frequency modulation
                "local pm = function(x, p, a) return x+a*p end " ..
                "local fm = function(x, f, a) return (O-1)*2*pi+x*(1+a*f) end " ..
                --"local fm = function(c,m,a) return c*(1+m*a) end " ..
                -- ringmod/amplitude modulation
                "local am = function(c,m,a) return c*(1-a+un(m)*a) end " ..
                "local rm = function(c,m,a) return c*(1-a+abs(m)*a) end " ..
                -- semitone factor function
                "local nf = function(txp) return (2^(txp/12)) end " ..
                -- logic
                "local ite = function(i, t, e) if i then return t else return e end end " ..
                "local btoi = function(b) if b then return 1 else return 0 end end " ..
                "local itob = function(i) if i<=0 then return false else return true end end " ..
                -- exponential sine, saw, tri
                "local expsin = function(x, p) if p>1 then return (squ(x)^(1-p%2))*sin(x)^p else return squ(x)*abs(sin(x))^p end end " ..
                "local expsaw = function(x, p) if p>1 then return (squ(x)^(1-p%2))*saw(x)^p else return squ(x)*abs(saw(x))^p end end " ..
                "local exptri = function(x, p) if p>1 then return (squ(x)^(1-p%2))*tri(x)^p else return squ(x)*abs(tri(x))^p end end " ..
                -- sine-made (recursive formula) waveforms
                "local sinsin sinsin = function(x, p) if p>1 then return sinsin(sin(x), p-1) else return sin(x) end end " ..
                "local sinsaw sinsaw = function(x, p) if p>1 then return sin(x*p)/p+sinsaw(x, p-1) else return sin(x) end end " ..
                "local sftsaw sftsaw = function(x, p) if p>1 then return sin(x*p)/(2^p)+sftsaw(x, p-1) else return sin(x) end end " ..
                "local sinsqu sinsqu = function(x, p) if p>1 then local v = p*2-1 return sin(x*v)/v+sinsqu(x, p-1) else return sin(x) end end " ..
                -- awesomesines etc
                --"local awehelp = function() end " ..
                --"local awesin = function(x, d, c, rdf) end " ..
                --"local awesin awesin = function(x, c) if c <= 1 then return sin(x) else local pdec=(sf-1)^c return (0.2^c)*(sin(x*(1+pdec))+sin(x*(1-pdec)))+awesin(x, c-1) end end " ..
                --"local awesin awesin = function(x, c, d) if c <= 1 then return sin(x) else local pdec=d*(sf-1)^c return (0.5^c)*(sin(x*(1+pdec))+sin(x/(1+pdec)))+awesin(x, c-1, d) end end " ..
                --"local awesaw awesaw = function(x, c) if c <= 1 then return saw(x) else local pdec=(sf-1)^c return (0.2^c)*(saw(x*(1+pdec))+saw(x*(1-pdec)))+awesaw(x, c-1) end end " ..
                -- square root sine, saw, tri
                "local sqtfunhelp sqtfunhelp = function(fun, x, p) if p>1 then return sqrt(sqtfunhelp(fun, x, p-1)) else return abs(fun(x)) end end " ..
                "local sqtsin = function(x, p) return squ(x)*sqtfunhelp(sin, x, p) end " ..
                "local sqtsaw = function(x, p) return squ(x)*sqtfunhelp(saw, x, p) end " ..
                "local sqttri = function(x, p) return squ(x)*sqtfunhelp(tri, x, p) end " ..
                -- distort (clip, fold, crush, noise) functions
                "local shape = function(x, p) if x==0 then return x else return (x/abs(x))*abs(x)^p end end " ..
                "local semishape = function(x, p, z) return shape(x,p)*z + (1-z)*x end " ..
                "local clip = function(x, y) return (1/y)*max(min(x, y), -y) end " ..
                "local semiclip = function(x, y, z) return (max(min(x, y), -y)*z + (1-z)*x) end " ..
                "local clipp = function(x, y) return max(min(x, y), -y) end " ..
                "local semiclipp = function(x, y, z) return (max(min(x, y), -y)*z + (1-z)*x) end " ..
                "local shape_atan = function(x, y) return atan(x*y)*TT*4 end " ..
                "local expand = function(x, y, z, p) local a=abs(x) local s=a/x if a<(y-z) then return x end local b = (a-(y-z))/z local c = z*b^p return x+s*c end " ..
                "local fold = function(x, y) return -bi(abs(1-abs(un((1+y)*x)))) end " ..
                "local semifold = function(x, y, z) return fold(x, y)*z + (1-z)*x end " ..
                "local crush = function(x, y) return flr(x*y+.5)/y end " ..
                "local semicrush = function(x, y, z) return (flr(x*y+.5)/y)*z + (1-z)*x end " ..
                "local quant = function(x, dx) if quantz_step == 0 then quantz_buf = x end quantz_step = mod( quantz_step + 1, dx ) return quantz_buf end " ..
                "local semiquant = function(x, dx, z) return quant(x,dx)*z + (1-z)*x end " ..
                "local semiabs = function(x, a) return (1-a)*x+a*abs(x) end " ..
                "local noise = function(x, y, p) return (1-y)*x+(ite(x<0, -1, 1))*y*(abs(x)^p)*rnd() end " ..     -- add noise according to amp(x) and factor(y) and curve(p)
                "local lowrnd = function ( t, skip ) if t ~= t_buf then t_buf = t if lowrnd_step == 0 then lowrnd_buf = rnd() end lowrnd_step = mod( lowrnd_step + 1, skip ) end return lowrnd_buf end " ..
                "local lowrndstw = function ( t, skip, width ) if t ~= t_buf then t_buf = t if lowrnd_step == 0 then lowrnd_buf = rnd() end lowrnd_step = mod( lowrnd_step + 1, skip ) else lowrnd_buf = (lowrnd_buf + width*rnd())/(1+width) end return lowrnd_buf end " ..
                "local rndstw = function( t, width, channel ) if t ~= t_buf then rndstw_buf = rnd() end t_buf = t return rndstw_buf+channel*width*rnd() end " ..
                "local lownoise = function ( t, part ) if lownoi_step ~= flr(t*part) then lownoi_buf = rnd() end lownoi_step = flr(t*part) return lownoi_buf end " ..
                -- muffle
                "local muffle = function(x, y, z, p) local a=abs(x) local s=a/x if a<(y-z) then return x end local b = (a-(y-z))/z local c = z*(b/p)^p return x-(s*c)/p end " ..
                "local ubermuffle = function(x, y, z, p) local a=abs(x) local s=a/x if a<(y-z) then return x end local b = (a-(y-z))/z local c = z*(b/p)^p return x-(s*c) end " ..
                --"local brutalize = function(x, y, z, p) local m=min(abs(x),y-z) return (x/abs(x))*(m+z/((1/(abs(x)-m))^p)) end " ..
                --"local muffold = function(x, y, z, p) local a=abs(x) local s=a/x if a<(y-z) then return x end local b = (a-(y-z))/z local c = z*b^p return x-s*c end " ..
                -- supermin/supermax type 'clip' functions
                "local supermax = function(x, y) if x >= 0 then return max(x,y) else return min(x,y) end end " ..
                "local supermin = function(x, y) if x >= 0 then return min(x,y) else return max(x,y) end end " ..
                -- morph between two functions
                "local morph = function(x, y, z) return ((1-z)*x+z*y) end " ..
                "local mix = function(t) local sum = 0 local ml = 0 for i = 1, #t do ml = ml+t[i][2] sum = sum + t[i][2]*t[i][1] end return sum/ml end " ..
                "local funmix = function(f1, f2, x, a) return ((1-a)*f1(x)+(a)*f2(x)) end " ..
                --"local mix = function(x, ztab, functab) local factor = 0 if #ztab ~= #functab then return 0 else for _,f in ztab do factor = factor + f end local res = 0 for i = 1, #ztab do print(''..i..'. type: '..type(functab[i])) if type(functab[i]) == 'function' then res = res + ztab[i] * functab[i](x) elseif (#functab[i]) == 1 then res = res + ztab[i] * functab[i][1](x) else res = res + ztab[i] * functab[i][1](x, unpack(functab[i][2])) end end return res/factor end end  " ..
                -- unary [0..1] pulse from/to
                "local upft = function(x, f, t) if x < f or x >= t then return 0 else return 1 end end " ..
                "local upf = function(x, f) if x < f then return 0 else return 1 end end " ..
                "local upt = function(x, t) if x >= t then return 0 else return 1 end end " ..
                -- ramps
                "local sqrtsqrt = function(x, p) return sqtfunhelp(equ, x, p) end " ..
                "local ru = function(t, p) return t^p end " ..                               -- ramp (exp)
                "local rd = function(t, p) return (1-t)^p end " ..
                "local aru = function(t, p) return 1-(1-t)^p end " ..                        -- anti-ramp
                "local ard = function(t, p) return 1-t^p end " ..
                "local rru = function(t, p) return 1-sqrtsqrt(1-t, p) end " ..               -- root ramp
                "local rrd = function(t, p) return 1-sqrtsqrt(t, p) end " ..
                "local raru = function(t, p) return sqrtsqrt(t, p) end " ..                  -- root anti-ramp
                "local rard = function(t, p) return sqrtsqrt(1-t, p) end " ..
                --"local cosu = function(t, p) return (cos((1-t)*pi)/2+.5)^p end " ..          -- shaped half-cosine ramp
                --"local cosd = function(t, p) return (cos(t*pi)/2+.5)^p end " ..
                "local cosu = function(t, p) return shape((cos((1-t)*pi)/2+.5)*2-1,1/p)/2+.5 end " ..          -- shaped half-cosine ramp
                "local cosd = function(t, p) return shape((cos(t*pi)/2+.5)*2-1,1/p)/2+.5 end " ..
                --"local acosu = function(t, p) return (acos((1-t)*2-1)/pi)^p end " ..
                --"local acosd = function(t, p) return (acos(t*2-1)/pi)^p end " ..
                "local acosu = function(t, p) return shape(((acos((1-t)*2-1)/pi)*2-1),p)/2+.5 end " ..
                "local acosd = function(t, p) return shape(((acos(t*2-1)/pi)*2-1),p)/2+.5 end " ..
                "local atanu = function(t, p) return (math.atan(1-(1-t)*2)/pi*2+.5)^p end " ..  -- shaped atan ramp
                "local atand = function(t, p) return (math.atan(1-t*2)/pi*2+.5)^p end " ..
                "local recu = function(t, p) local q = 1/p return (p+1)*(q/((1-t)+q)-(1/(p+1)))/p end " ..
                "local recd = function(t, p) local q = 1/p return (p+1)*(q/(t+q)-(1/(p+1)))/p end " ..
                "local arecu = function(t, p) return 1-recd(t,p) end " ..
                "local arecd = function(t, p) return 1-recu(t,p) end " ..
                -- start later / done quicker
                "local sl = function(t,p) return max(t/p-1/p+1,0) end " ..                  -- max(T*4/3-1/3,0)
                "local dq = function(t,p) return min(t/p,1) end " ..
                -- envelope
                "local env = function(x, t) local y = 0 local pc local pn = nil for i = 1, #t-1 do if pn ~= nil then pc = pn else pc = t[i] end pn = t[i+1] if x < pn[1] and x >= pc[1] then if pn[3] == nil or pn[4] == nil then y = ((x-pc[1])/(pn[1]-pc[1]))*(pn[2]-pc[2])+pc[2] else y = pn[3](((x-pc[1])/(pn[1]-pc[1])),pn[4])*(pn[2]-pc[2])+pc[2] end break end end return y end " ..
                -- signal duplication
                "local dup = function(x, a, b) return a(x)+b(x) end "       -- not working! too bad we can't 'local xyz = function' in formulastring and still keep this whole environment
--[[local env = function(x, t)
  local y = 0
  local pc
  local pn = nil
  for i = 1, #t-1 do
    if pn ~= nil then
      pc = pn
    else
      pc = t[i]
    end
    pn = t[i+1]
    if x < pn[1] and x >= pc[1] then
      if pn[3] == nil or pn[4] == nil then
        y = ((x-pc[1])/(pn[1]-pc[1]))*(pn[2]-pc[2])+pc[2]
      else
        y = pn[3](((x-pc[1])/(pn[1]-pc[1])),pn[4])*(pn[2]-pc[2])+pc[2]
      end
      break
    end
  end
  return y
end]]
--[[local mix = function(x, ztab, functab)         --- THIS FAILS (just so you know)
  local factor = 0
  if #ztab ~= #functab then return 0
  else
    for _,f in ztab do factor = factor + f end
    local res = 0
    for i = 1, #ztab do
      print(''..i..'. type: '..type(functab[i]))
      if type(functab[i]) == 'function' then
        res = res + ztab[i] * functab[i](x)
      elseif (#functab[i]) == 1 then
        res = res + ztab[i] * functab[i][1](x)
      else
        res = res + ztab[i] * functab[i][1](x, unpack(functab[i][2]))
      end
    end
    return res/factor
  end
end]]
--[[local lowrnd_buf = 0
local lowrnd_step = 0
local lowrnd = function ( t, skip )
  if lowrnd_step == 0 then
    lowrnd_buf = rnd()
  end
  lowrnd_step = mod( lowrnd_step + 1, skip )
  return lowrnd_buf
end]]


-------------------------------------------------------------
-- Preferences                                             --
-------------------------------------------------------------

--[[ other possible options:
   * require shift modifier for fields   (done)
   * custom functions
   * custom (named) presets
                                                         --]]

local options = renoise.Document.create("OvertunePreferences") {
  step1 = "sin(X)",
  stepn = "0",
  steps = 1,
  times = 1,
  power = true,
  stereo = false,
}
renoise.tool().preferences = options

-------------------------------------------------------------
-- Help: semitone naming functions                         --
-------------------------------------------------------------

local NOTE_NAMES = { "C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-" }
local note_lookup = table.create()
local note_lookup_reverse = table.create()
local note_name_tmp
local note_number_tmp
for i = 0,9 do
  for j = 1,12 do
    note_name_tmp = NOTE_NAMES[j]..i
    note_number_tmp = (i*12)+j-1
    note_lookup[note_number_tmp] = note_name_tmp
    note_lookup_reverse[note_name_tmp] = note_number_tmp
  end
end
function note_number_to_string(number)
  if number <= #note_lookup then
    return note_lookup[number]
  else
    --return "N/A"
    return nil
  end
end
function string_to_note_number(name)
  if number <= #note_lookup_reverse then
    return note_lookup_reverse[name]
  else
    --return 0
    return nil
  end
end


-------------------------------------------------------------
-- Main: load/save/convert functions                       --
-------------------------------------------------------------

function try_and_load_1(instr)
  local ot = table.create()
  if (instr:sample(1).name == "Overtuned" and #instr.samples >= 4) then
    ot.step1 = instr:sample(2).name
    ot.stepn = instr:sample(3).name
    ot.steps = 0+(instr:sample(4).name)
    if #instr.samples >= 5 then ot.times = 0+(instr:sample(5).name) end
    if #instr.samples == 6 then if instr:sample(6).name == "1" then ot.power = true else ot.power = false end end
    ot.stereo = false
    ot.base_note = 9
  else
    ot = nil
  end
  return ot
end
function try_and_save_1(instr, settings)  -- obsolete
  instr:sample(1).name = "Overtuned"
  instr:sample(2).name = settings.step1
  instr:sample(3).name = settings.stepn
  instr:sample(4).name = tostring(settings.steps)
  instr:sample(5).name = tostring(settings.times)
  if settings.power then instr:sample(6).name = "1" else instr:sample(6).name = "0" end
end
function btos(bool)
  if bool then return "true" else return "false" end
end
function try_and_load_2(sample)
  local ot = table.create()
  local sn = sample.name
  local delim_start,delim_end=sn:find(" !! ")
  if delim_start ~= nil and delim_end ~= nil then
    local tmpname = sn:sub(1,delim_start-1)
    ot = loadstring("return "..sn:sub(delim_end+1))()
    if ot.base_note == nil then ot.base_note = 9 end
    if ot.stereo == nil then ot.stereo = false end
    ot.name = tmpname
  else
    ot = nil
  end
  return ot
end
function try_and_save_2(sample, settings)
  if not settings.name then settings.name = "Overtuned" end
  local name_str = settings.name .. " !! {" ..
                                          "step1='"..settings.step1.."'," ..
                                          "stepn='"..settings.stepn.."'," ..
                                          "steps="..settings.steps.."," ..
                                          "times="..settings.times.."," ..
                                          "power="..btos(settings.power).."," ..
                                          "stereo="..btos(settings.stereo).."," ..
                                          "base_note="..settings.base_note .. "}"
  sample.name = name_str
end

-------------------------------------------------------------
-- Main: dialog functions                                  --
-------------------------------------------------------------

function key_handler(d, k)
  local pass = false
  if not k.repeated then
    if k.name == "1" and k.modifiers == "shift" then
      vb_step1.edit_mode = true
      focus = 1
    elseif k.name == "2" and k.modifiers == "shift" then
      vb_stepn.edit_mode = true
      focus = 2
    elseif k.name == "3" and k.modifiers == "shift" then
      focus = 3
    elseif k.name == "4" and k.modifiers == "shift" then
      focus = 4
    elseif k.name == "5" and k.modifiers == "shift" then
      vb_power.value = not vb_power.value
      focus = 5
    elseif k.name == "6" and k.modifiers == "shift" then
      vb_stereo.value = not vb_stereo.value
      focus = 6
    elseif k.name == "7" and k.modifiers == "shift" then
      focus = 7
    elseif k.name == "return" then
      if k.modifiers == "" then
        render_overtune( load, { step1=vb_step1.value, stepn=vb_stepn.value, steps=math.floor(vb_stepsshow.value), times=math.floor(vb_timesshow.value), power=vb_power.value, stereo=vb_stereo.value, base_note=vb_base_note.value } )
        if dialog and dialog.visible then dialog:close() end
      elseif k.modifiers == "shift" then
        render_overtune( load, { step1=vb_step1.value, stepn=vb_stepn.value, steps=math.floor(vb_stepsshow.value), times=math.floor(vb_timesshow.value), power=vb_power.value, stereo=vb_stereo.value, base_note=vb_base_note.value } )
        --[[vb_step1.edit_mode = true
        focus = 1]]
      elseif k.modifiers == "alt" then
        options.step1.value = vb_step1.value
        options.stepn.value = vb_stepn.value
        options.steps.value = vb_stepsshow.value
        options.times.value = vb_timesshow.value
        options.power.value = vb_power.value
      end
    elseif k.name == "space" then
      if k.modifiers == "" then
        render_overtune( load, { step1=vb_step1.value, stepn=vb_stepn.value, steps=math.floor(vb_stepsshow.value), times=math.floor(vb_timesshow.value), power=vb_power.value, stereo=vb_stereo.value, base_note=vb_base_note.value } )
      elseif k.modifiers == "shift" then
        render_overtune( load, { step1=vb_step1.value, stepn=vb_stepn.value, steps=math.floor(vb_stepsshow.value), times=math.floor(vb_timesshow.value), power=vb_power.value, stereo=vb_stereo.value, base_note=vb_base_note.value } )
        if dialog and dialog.visible then dialog:close() end
      end
    elseif k.name == "esc" then
      if dialog and dialog.visible then dialog:close() end
    else--[[if k.note ~= nil then]]
      pass = true
    end
  end
  -- these can be repeated though
  if k.name == "right" then
    if focus == 3 then
      vb_stepsshow.value = math.min(vb_stepsshow.value+1, vb_stepsshow.max)
      vb_steps.value = vb_stepsshow.value
    elseif focus == 4 then
      vb_timesshow.value = math.min(vb_timesshow.value+1, vb_timesshow.max)
      vb_times.value = vb_timesshow.value
    elseif focus == 7 then
      vb_base_note.value = math.min(vb_base_note.value+1, vb_base_note.max)
    end
    pass = false
  elseif k.name == "left" then
    if focus == 3 then
      vb_stepsshow.value = math.max(vb_stepsshow.value-1, vb_stepsshow.min)
      vb_steps.value = vb_stepsshow.value
    elseif focus == 4 then
      vb_timesshow.value = math.max(vb_timesshow.value-1, vb_timesshow.min)
      vb_times.value = vb_timesshow.value
    elseif focus == 7 then
      vb_base_note.value = math.max(vb_base_note.value-1, vb_base_note.min)
    end
    pass = false
  elseif k.name == "up" then
    if focus == 3 then
      vb_stepsshow.value = math.min(vb_stepsshow.value*2, vb_stepsshow.max)
      vb_steps.value = vb_stepsshow.value
    elseif focus == 4 then
      vb_timesshow.value = math.min(vb_timesshow.value*2, vb_timesshow.max)
      vb_times.value = vb_timesshow.value
    elseif focus == 7 then
      vb_base_note.value = math.min(vb_base_note.value+12, vb_base_note.max)
    end
    pass = false
  elseif k.name == "down" then
    if focus == 3 then
      vb_stepsshow.value = math.max(math.floor(vb_stepsshow.value/2), vb_stepsshow.min)
      vb_steps.value = vb_stepsshow.value
    elseif focus == 4 then
      vb_timesshow.value = math.max(math.floor(vb_timesshow.value/2), vb_timesshow.min)
      vb_times.value = vb_timesshow.value
    elseif focus == 7 then
      vb_base_note.value = math.max(vb_base_note.value-12, vb_base_note.min)
    end
    pass = false
  end
  if pass then
    return k
  end
end

function show_dialog()
  if dialog and dialog.visible then
    --[[vb_step1.edit_mode = true
    vb_step1.edit_mode = false]]
    dialog:close()
  end
  load = false
  delete_obsolete_samples_on_render = false

  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  vb_step1 = vb:textfield { value = options.step1.value, width = 600 }
  vb_stepn = vb:textfield { value = options.stepn.value, width = 600 }
  vb_steps = vb:slider { min = 1, max = 99, value = options.steps.value, width = 550 }
  vb_times = vb:slider { min = 1, max = 1024, value = options.times.value, width = 550 }
  vb_stepsshow = vb:valuebox { min = 1, max = 99, value = options.steps.value, width = 50 }
  vb_timesshow = vb:valuebox { min = 1, max = 1024, value = options.times.value, width = 50 }
  vb_power = vb:checkbox { value = options.power.value }
  vb_stereo = vb:checkbox { value = options.stereo.value }
  --vb_tl = vb:valuebox { min = 20, max = 1604, value = 1604, width = 64 }
  vb_base_note = vb:valuebox { min = 0, max = 119, value = 9, width = 64, tostring = note_number_to_string, tonumber = string_to_note_number }
  --vb_base_noteshow = vb:textfield

  local vb_stepsrow = vb:row { vb_steps, vb_stepsshow }
  vb_steps:add_notifier(function() vb_stepsshow.value = math.floor(vb_steps.value) end)
  local vb_timesrow = vb:row { vb_times, vb_timesshow }
  vb_times:add_notifier(function() vb_timesshow.value = math.floor(vb_times.value) end)

  --check for previous settings
  local ci = renoise.song().selected_instrument
  local ot = try_and_load_1(ci)
  if ot ~= nil then
    vb_step1.value = ot.step1
    vb_stepn.value = ot.stepn
    vb_steps.value = ot.steps vb_stepsshow.value = ot.steps
    if ot.times then vb_times.value = ot.times vb_timesshow.value = ot.times end
    if ot.power then vb_power.value = ot.power end
    load = true
    delete_obsolete_samples_on_render = true
  else
    local cs = renoise.song().selected_sample
    ot = try_and_load_2(cs)
    if ot ~= nil then
      vb_step1.value = ot.step1
      vb_stepn.value = ot.stepn
      vb_steps.value = ot.steps vb_stepsshow.value = ot.steps
      vb_times.value = ot.times vb_timesshow.value = ot.times
      vb_power.value = ot.power
      vb_stereo.value = ot.stereo
      vb_base_note.value = ot.base_note
      load = true
    end
  end

  local vb_dialog =
    vb:column {
      margin = DDM,
      vb:row {
        vb:horizontal_aligner {
          --margin = DDM,
          spacing = CS,
          vb:column {
            vb:text { text = "Step 1:" },
            vb:text { text = "Step N:" },
            vb:text { text = "Step #:" },
            vb:text { text = "Time #:" },
            vb:text { text = "Power :" },
            vb:text { text = "BaseNt:" },
          },
          vb:column {
            vb_step1,
            vb_stepn,
            vb_stepsrow,
            vb_timesrow,
            vb:horizontal_aligner {
              vb_power,
              vb:space { width = 10 },
              vb:text { text = "Stereo:" },
              vb_stereo,
            },
            vb_base_note,
          },
        },
      },
      vb:row { height = 6 },
      vb:row {
        style = "group",
        width = "100%",
        vb:horizontal_aligner {
          margin = DDM/2,
          width = "100%",
          mode = "justify",
          vb:bitmap {
            mode = "transparent",
            bitmap = "overtune.bmp"
          },
          vb:column { width = 390 },
          vb:bitmap {
            mode = "transparent",
            bitmap = "by-cas.bmp"
          },
        },
      },
    }
  dialog = renoise.app():show_custom_dialog("Overtune!", vb_dialog, key_handler)
  vb_step1.edit_mode = true
  focus = 1
end

function key_handler_edit(d, k)
  local pass = false
  if not k.repeated then
    if k.name == "1" and k.modifiers == "shift" then
      vb_step1.edit_mode = true
      focus = 1
    elseif k.name == "2" and k.modifiers == "shift" then
      vb_power.value = not vb_power.value
      focus = 5
    elseif k.name == "return" then
      if k.modifiers == "" then
        edit_overtune( renoise.song().selected_sample, { step1=vb_step1.value, power=vb_power.value } )
        if dialog and dialog.visible then dialog:close() end
--[[      elseif k.modifiers == "shift" then
        render_overtune( load, { step1=vb_step1.value, stepn=vb_stepn.value, steps=math.floor(vb_stepsshow.value), times=math.floor(vb_timesshow.value), power=vb_power.value, base_note=vb_base_note.value } )
        --vb_step1.edit_mode = true
        --focus = 1
      elseif k.modifiers == "alt" then
        options.step1.value = vb_step1.value
        options.stepn.value = vb_stepn.value
        options.steps.value = vb_stepsshow.value
        options.times.value = vb_timesshow.value
        options.power.value = vb_power.value]]
      end
--[[    elseif k.name == "space" then
      if k.modifiers == "" then
        render_overtune( load, { step1=vb_step1.value, stepn=vb_stepn.value, steps=math.floor(vb_stepsshow.value), times=math.floor(vb_timesshow.value), power=vb_power.value, base_note=vb_base_note.value } )
      elseif k.modifiers == "shift" then
        render_overtune( load, { step1=vb_step1.value, stepn=vb_stepn.value, steps=math.floor(vb_stepsshow.value), times=math.floor(vb_timesshow.value), power=vb_power.value, base_note=vb_base_note.value } )
        if dialog and dialog.visible then dialog:close() end
      end]]
    elseif k.name == "esc" then
      if dialog and dialog.visible then dialog:close() end
    else--[[if k.note ~= nil then]]
      pass = true
    end
  end
  if pass then
    return k
  end
end

function show_edit_dialog()
  if dialog and dialog.visible then
    --[[vb_step1.edit_mode = true
    vb_step1.edit_mode = false]]
    dialog:close()
  end

  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  vb_step1 = vb:textfield { value = "crush(Y*sin(X*35), 10)"--[[options.step1.value]], width = 600 }
  vb_power = vb:checkbox { value = options.power.value }
  --vb_base_note = vb:valuebox { min = 0, max = 119, value = 9, width = 64, tostring = note_number_to_string, tonumber = string_to_note_number }
  --vb_base_noteshow = vb:textfield

--[[  local vb_stepsrow = vb:row { vb_steps, vb_stepsshow }
  vb_steps:add_notifier(function() vb_stepsshow.value = math.floor(vb_steps.value) end)
  local vb_timesrow = vb:row { vb_times, vb_timesshow }
  vb_times:add_notifier(function() vb_timesshow.value = math.floor(vb_times.value) end)
]]

  local vb_dialog =
    vb:column {
      margin = DDM,
      vb:row {
        vb:horizontal_aligner {
          --margin = DDM,
          spacing = CS,
          vb:column {
            vb:text { text = "Edit 1:" },
            vb:text { text = "Power :" },
          },
          vb:column {
            vb_step1,
            vb_power,
          },
        },
      },
      vb:row { height = 6 },
      vb:row {
        style = "group",
        width = "100%",
        vb:horizontal_aligner {
          margin = DDM/2,
          width = "100%",
          mode = "justify",
          vb:bitmap {
            mode = "transparent",
            bitmap = "overtune.bmp"
          },
          vb:column { width = 390 },
          vb:bitmap {
            mode = "transparent",
            bitmap = "by-cas.bmp"
          },
        },
      },
    }
  dialog = renoise.app():show_custom_dialog("Overtune! [EDIT MODE]", vb_dialog, key_handler_edit)
  vb_step1.edit_mode = true
  focus = 1
end

-------------------------------------------------------------
-- Main: render functions                                  --
-------------------------------------------------------------

function render_overtune( load, settings )
  --local vb = renoise.ViewBuilder()
  local rs = renoise.song()
  local ci = rs.selected_instrument
  local cs = rs.selected_sample
  local csi = rs.selected_sample_index
  --local tl = 1604
  local tl = math.floor(SAMPLE_RATE/(BASE_FREQ*(SEMITONE_FACTOR^(settings.base_note-BASE_NOTE)))+.5)
  local sl = tl*settings.times
  local sb        -- shortcut for sample buffers
  --local rk = 9    -- A-0 for crispness
  local formulastr = settings.step1
  local formula
  local md = 0    -- max deviation from 0 kept and used for re-scaling ('normalising')
  local vol
  local pan
  local txp
  local fit
  local lpm
  local lps
  local lpe
  local o_times = false
  local name = settings.name
  local channel_count = 1
  if settings.stereo then channel_count = 2 end
  rs:describe_undo("Render Overtune")
  -- possibly remove old samples with settings
  if delete_obsolete_samples_on_render then
    for i=2,#ci.samples do
      ci:delete_sample_at(2)
    end
  end
  -- save the settings
  -- prev. overtune sample settings
  if load then
    vol = cs.volume
    pan = cs.panning
    txp = cs.transpose
    fit = cs.fine_tune
    lpm = cs.loop_mode
    --oprint(cs.sample_buffer)
    if cs.sample_buffer.has_sample_data then
      o_times = (cs.sample_buffer.number_of_frames/tl) == settings.times
      if o_times then
        lps = cs.loop_start
        lpe = cs.loop_end
        if lpe < 1 then o_times = false end
      end
    end
  end
  --try_and_save_1(ci, {step1 = step1, stepn = stepn, steps = steps, times = times, power = power})
  try_and_save_2(cs, {step1 = settings.step1, stepn = settings.stepn, steps = settings.steps, times = settings.times, power = settings.power, stereo = settings.stereo, name = name, base_note = settings.base_note})
  if ci.name == "" then ci.name = "Overtuned" end
  if load then
    cs.volume = vol
    cs.panning = pan
    cs.transpose = txp
    cs.fine_tune = fit
    cs.loop_mode = lpm
  end
  -- build formula strings
  for i = 2, settings.steps do
    formulastr = formulastr .. "+" .. settings.stepn:gsub("N", i)
  end
  formula = loadstring(otvars.." return function(X, XX, O, T, C) ".. "local tl = ".. tl .. " " .. otfuncs .."return ".. formulastr .." end")()
  local buffer = {} buffer[1] = {} buffer[2] = {}
  for c = 1, settings.times do
    for i = 0, tl-1 do
      for channel = 1, channel_count do
        local t = ((c-1)*tl+i)/sl
        local xx = ((c-1)*tl+i)*2*math.pi / (sl/settings.times)
        local x = i*2*math.pi/tl
        local y = formula(x, xx, c, t, channel-1)
        --if settings.power then md = math.max(md, math.abs(y)) end
        md = math.max(md, math.abs(y))
        buffer[channel][1+i+((c-1)*tl)] = y
      end
    end
  end
  if settings.power then
    local pf = 1 / md
    --print(md)
    for channel = 1, channel_count do
      for i = 1, sl do
        buffer[channel][i] = buffer[channel][i]*pf
      end
    end
  end
  -- build instrument sample #1
  sb = cs.sample_buffer
  sb:create_sample_data( SAMPLE_RATE, 32, channel_count, sl )
  sb:prepare_sample_data_changes()
  for channel = 1, channel_count do
    for i = 1, sl do
      sb:set_sample_data( channel, i, buffer[channel][i] )
    end
  end
  sb:finalize_sample_data_changes()
  if not settings.power then
    renoise.app():show_status("The max dev was: "..md)
  end
  if o_times then
    cs.loop_start = lps
    cs.loop_end = lpe
  else
    cs.loop_start = 1
    cs.loop_end = sl
  end
  -- do the mappings
  cs.sample_mapping.base_note = settings.base_note
  if load then
    cs.volume = vol
    cs.panning = pan
    cs.transpose = txp
    cs.fine_tune = fit
    cs.loop_mode = lpm
  end
end

function edit_overtune ( sp, settings )            -- sp = sample pointer
  --local vb = renoise.ViewBuilder()
  local rs = renoise.song()
  local ci = rs.selected_instrument
  local cs = rs.selected_sample
  local csi = rs.selected_sample_index
  local tl = sp.sample_buffer.number_of_frames
  local sb
  --local sl = tl*settings.times
  --local rk = 9    -- A-0 for crispness
  local formulastr = settings.step1
  local formula
  local md = 0    -- max deviation from 0 kept and used for re-scaling ('normalising')
  local vol
  local pan
  local txp
  local fit
  local lpm
  local lps
  local lpe
  local o_times = false
  local name = settings.name
  rs:describe_undo("Render Overtune")
  if ci.name == "" then ci.name = "Overtuned" end
  formula = loadstring(otvars.." return function(X, T, Y, C) ".. "local tl = ".. tl .. " " .. otfuncs .. "return ".. formulastr .." end")()
  local buffer = {table.create(), table.create()}
  for c = 1, cs.sample_buffer.number_of_channels do
    for i = 0, tl-1 do
      local old_y = sp.sample_buffer:sample_data(c, i+1)
      local t = i/tl
      local x = t*2*math.pi
      local y = formula(x, t, old_y, c-1)
      if settings.power then md = math.max(md, math.abs(y)) end
      buffer[c][1+i] = y
    end
  end
  if settings.power then
    local pf = 1 / md
    for c = 1, cs.sample_buffer.number_of_channels do
      for i = 1, tl do
        buffer[c][i] = buffer[c][i]*pf
      end
    end
  end
  -- build instrument sample #1
  sb = sp.sample_buffer
  --sb:create_sample_data( SAMPLE_RATE, 32, 1, tl )
  sb:prepare_sample_data_changes()
  for c = 1, cs.sample_buffer.number_of_channels do
    for i = 1, tl do
      sb:set_sample_data( c, i, buffer[c][i] )
    end
  end
  sb:finalize_sample_data_changes()
end

function rerender_all_no_sd()
  local rs = renoise.song()
  local oi, os
  oi = rs.selected_instrument_index
  os = rs.selected_sample_index
  local num = 0
  for i = 1, #rs.instruments do
    rs.selected_instrument_index = i
    local inst = rs.selected_instrument
    for s = 1, #inst.samples do
      rs.selected_sample_index = s
      local samp = rs.selected_sample
      if (samp.name:sub(1,12) == "Overtuned !!") and (not samp.sample_buffer.has_sample_data) then
        num = num + 1
        renoise.app():show_status("Found Overtuned sample #"..num)
        local ot = try_and_load_2(samp)
        render_overtune( true, ot )
        renoise.app():show_status(tostring(num).." OT samples re-rendered and unfucked")
      end
    end
  end
  rs.selected_instrument_index = oi
  rs.selected_sample_index = os
end

--------------------------------------------------------------------------------
-- Menu, Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Overtune...",
  invoke = show_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Overtune...",
  invoke = show_dialog
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Overtune Edit...",
  invoke = show_edit_dialog
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Overtune Edit...",
  invoke = show_edit_dialog
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Overtune Re-render all with no Sample Data",
  invoke = rerender_all_no_sd
}

renoise.tool():add_keybinding {
  name = "Global:Tools:Overtune Re-render all with no Sample Data",
  invoke = rerender_all_no_sd
}

--renoise.song().overtune = show_dialog

-------------------------------------------------------------
-- Main: autoreload function                               --
-------------------------------------------------------------
_AUTO_RELOAD_DEBUG = function()
end
