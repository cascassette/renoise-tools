-------------------------------------------------------------
-- Best Views v1.0 by Cas Marrav (for Renoise 2.8)         --
-------------------------------------------------------------

-- globs
local rw

local function ufr()
  local uf = renoise.app().window.active_upper_frame + 1
  if uf > 4 then uf = 1 end
  renoise.app().window.active_upper_frame = uf
end
local function lfr()
  local lf = renoise.app().window.active_lower_frame + 1
  if lf > 4 then lf = 1 end
  renoise.app().window.active_lower_frame = lf
end
local function cfr()
  local mf = renoise.app().window.active_middle_frame + 1
  if mf > 4 then mf = 1 end
  renoise.app().window.active_middle_frame = mf
end
local function ufrr()
  local uf = renoise.app().window.active_upper_frame - 1
  if uf < 1 then uf = 4 end
  renoise.app().window.active_upper_frame = uf
end
local function lfrr()
  local lf = renoise.app().window.active_lower_frame - 1
  if lf < 1 then lf = 4 end
  renoise.app().window.active_lower_frame = lf
end
local function cfrr()
  local mf = renoise.app().window.active_middle_frame - 1
  if mf < 1 then mf = 4 end
  renoise.app().window.active_middle_frame = mf
end

local function cv()
  rw = renoise.app().window
  rw.lower_frame_is_visible = false
  rw.upper_frame_is_visible = false
end

local function hud()
  rw = renoise.app().window
  if rw.lower_frame_is_visible and rw.upper_frame_is_visible then
    rw.lower_frame_is_visible = false
    rw.upper_frame_is_visible = false
  else
    rw.lower_frame_is_visible = true
    rw.upper_frame_is_visible = true
  end
end

local function sfr()
  rw = renoise.app().window
  rw.lower_frame_is_visible = not rw.lower_frame_is_visible
  rw.upper_frame_is_visible = not rw.upper_frame_is_visible
--[[  if rw.lower_frame_is_visible then
    rw.lower_frame_is_visible = false
    rw.upper_frame_is_visible = true
  else
    rw.lower_frame_is_visible = true
    rw.upper_frame_is_visible = false
  end]]
end

local function db()
  rw = renoise.app().window
  rw.upper_frame_is_visible = true
  rw.active_upper_frame = 1
  rw.disk_browser_is_expanded = true
end

local function pe()
  rw = renoise.app().window
  if rw.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR then
    rw.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
    if rw.lower_frame_is_visible then
      rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
    end
  else
    if rw.lower_frame_is_visible and rw.upper_frame_is_visible then
      cv()
    elseif rw.lower_frame_is_visible then
      lfr()
    elseif rw.upper_frame_is_visible then
      ufr()
    end
--[[    if rw.lower_frame_is_visible then
      if rw.active_lower_frame ~= renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
      end
    end
    if rw.upper_frame_is_visible then
      rw.upper_frame_is_visible = false
    end]]
  end
end

local function mx()
  rw = renoise.app().window
  if rw.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_MIXER then
    rw.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_MIXER
  else
    if rw.lower_frame_is_visible and rw.upper_frame_is_visible then
      cv()
    elseif rw.lower_frame_is_visible then
      lfr()
    elseif rw.upper_frame_is_visible then
      ufr()
    end
--[[    if rw.lower_frame_is_visible and rw.upper_frame_is_visible then
      cv()
    elseif rw.lower_frame_is_visible then
      if rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
      elseif rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
      elseif rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION or rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_SONG_PROPERTIES then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
      end
    elseif rw.upper_frame_is_visible then
      if rw.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM or rw.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER then
        rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES
      elseif rw.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES then
        rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES
      elseif rw.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES then
        rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM
      end
    end]]
  end
end

local function se()
  rw = renoise.app().window
  if rw.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR then
    rw.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR
  else
    if rw.lower_frame_is_visible and rw.upper_frame_is_visible then
      cv()
    elseif rw.lower_frame_is_visible then
      lfr()
    elseif rw.upper_frame_is_visible then
      ufr()
    end
--[[    if rw.lower_frame_is_visible then
      if rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION
      elseif rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
      elseif rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION or rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_SONG_PROPERTIES then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
      end
    elseif rw.upper_frame_is_visible then
      if rw.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM or rw.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER then
        rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES
      elseif rw.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES then
        rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES
      elseif rw.active_upper_frame == renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES then
        rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM
      end
    end]]
  end
end

local function sk()
  rw = renoise.app().window
  if rw.active_middle_frame ~= renoise.ApplicationWindow.MIDDLE_FRAME_KEYZONE_EDITOR then
    rw.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_KEYZONE_EDITOR
  else
    if rw.lower_frame_is_visible and rw.upper_frame_is_visible then
      cv()
    elseif rw.lower_frame_is_visible then
      lfr()
    elseif rw.upper_frame_is_visible then
      ufr()
    end
--[[    if rw.lower_frame_is_visible then
      if rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
      elseif rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
      elseif rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION or rw.active_lower_frame == renoise.ApplicationWindow.LOWER_FRAME_SONG_PROPERTIES then
        rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
      end
    elseif rw.upper_frame_is_visible then
      ufr()
    end]]
  end
end

local function uf()
  rw = renoise.app().window
  rw.upper_frame_is_visible = not rw.upper_frame_is_visible
  if rw.upper_frame_is_visible then
    if rw.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR then
      rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES
    elseif rw.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_MIXER then
      rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM
    elseif rw.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_KEYZONE_EDITOR then
      rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_DISK_BROWSER
    elseif rw.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR then
      rw.active_upper_frame = renoise.ApplicationWindow.UPPER_FRAME_MASTER_SCOPES
    end
  end
end

local function uf2()
  rw = renoise.app().window
  if not rw.upper_frame_is_visible then
    rw.upper_frame_is_visible = true
    rw.lower_frame_is_visible = false
  else
    ufr()
  end
end

local function lf()
  rw = renoise.app().window
  rw.lower_frame_is_visible = not rw.lower_frame_is_visible
  if rw.lower_frame_is_visible then
    if rw.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR then
      rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
    elseif rw.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_MIXER then
      rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
    elseif rw.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_KEYZONE_EDITOR then
      rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_INSTRUMENT_PROPERTIES
    elseif rw.active_middle_frame == renoise.ApplicationWindow.MIDDLE_FRAME_SAMPLE_EDITOR then
      rw.active_lower_frame = renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
    end
  end
end

local function lf2()
  rw = renoise.app().window
  if not rw.lower_frame_is_visible then
    rw.lower_frame_is_visible = true
    rw.upper_frame_is_visible = false
  else
    lfr()
  end
end

-- keys
renoise.tool():add_keybinding {
  name = "Global:View:Best View Pattern Editor",
  invoke = pe
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Mixer",
  invoke = mx
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Sample Editor",
  invoke = se
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Sample Keyzones",
  invoke = sk
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View ClearView",
  invoke = cv
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Head Up Display",
  invoke = hud
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View DiskBrowser",
  invoke = db
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Switch Upper/Lower Frame",
  invoke = sfr
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Upper Frame",
  invoke = uf
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Lower Frame",
  invoke = lf
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Upper Frame 2",
  invoke = uf2
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Lower Frame 2",
  invoke = lf2
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Upper Frame Rotate",
  invoke = ufr
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Lower Frame Rotate",
  invoke = lfr
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Middle Frame Rotate",
  invoke = cfr
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Upper Frame Rotate Reverse",
  invoke = ufrr
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Lower Frame Rotate Reverse",
  invoke = lfrr
}
renoise.tool():add_keybinding {
  name = "Global:View:Best View Middle Frame Rotate Reverse",
  invoke = cfrr
}


-- auto reload
_AUTO_RELOAD_DEBUG = function()
end
