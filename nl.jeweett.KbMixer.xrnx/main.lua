--[[============================================================================
--                           Keyboard Mixer                                   --
============================================================================]]--

-- TODOS
-- [_] In normal groups, instead of solo, mute others (in group)
-- [_] If recording/editing, also save player_pos_beats per track that is muted
--     [_] And then, when done, if still in record mode (player stopped or
--               everything unsolod), remove the notes that were muted

--------------------------------------------------------------------------------
-- Track.track_index property
--------------------------------------------------------------------------------
local track_index_property = property(function(self)
  for index, track in ipairs(renoise.song().tracks) do
    if (rawequal(self, track)) then
      return index
    end
  end
end)
renoise.Track.track_index = track_index_property
renoise.GroupTrack.track_index = track_index_property

--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------
local function mute_toggle(i)
  --oprint(t)
  --print (t.name)
  print(i)
  if i > 0 then
    local t = renoise.song():track(i)
    if t.mute_state ~= renoise.Track.MUTE_STATE_ACTIVE then
      t:unmute()
    else
      t:mute()
    end
  end
end

local function muso(n, ms)
  local rs = renoise.song()
  local make_annoying_list = false
  local idx = 0
  if rs.selected_track.type == 3 then      -- send track: mute send tracks
    idx = n + rs.sequencer_track_count+1
  elseif rs.selected_track.type == 4 then  -- group track: mute within (direct) members
    if n <= #rs.selected_track.members then
      idx = rs.selected_track.members[#rs.selected_track.members-n+1].track_index
    end
  elseif rs.selected_track.type == 1 then  -- sequencer track: mute in current group
    local p = rs.selected_track.group_parent
    if p ~= nil then
      if n <= #p.members then
        idx = p.members[#p.members-n+1].track_index
      end
    else
      make_annoying_list = true
    end
  end
  if rs.selected_track.type == 2 or        -- master track: mute supergroups
                  make_annoying_list then
    -- compose list of seq/grp tracks without parent
    local l = {}
    local c = 0
    for i = 1, rs.sequencer_track_count do
      if rs:track(i).group_parent == nil then
        c = c + 1
        l[c] = i
      end
    end
    if n <= c then
      idx = l[n]
    end
  end
  if ms == 1 then
    --print("Muting trk# "..idx)
    mute_toggle(idx)
  elseif ms == 2 then
    --print("Soloing trk# "..idx)
    rs:track(idx):solo()
  end
end

local function mu(n)
  muso(n, 1)
end

local function so(n)
  muso(n, 2)
end


--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

for i = 1,8 do
  renoise.tool():add_keybinding {
    name = "Global:Track Muting:Mute Here #"..i,
    invoke = function()
      mu(i)
    end
  }
end

for i = 1,8 do
  renoise.tool():add_keybinding {
    name = "Global:Track Muting:Solo Here #"..i,
    invoke = function()
      so(i)
    end
  }
end

renoise.tool():add_keybinding {
  name = "Global:Track Muting:Solo Off",
  invoke = function()
    renoise.song():track(renoise.song().sequencer_track_count+1):solo()
  end
}


_AUTO_RELOAD_DEBUG = function()
  
end
