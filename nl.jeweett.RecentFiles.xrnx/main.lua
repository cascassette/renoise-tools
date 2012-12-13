-------------------------------------------------------------
-- Recent Files v1 by Cas Marrav (for Renoise 2.8)         --
-------------------------------------------------------------


-- Main
local function ls(num)
  renoise.app():load_song(renoise.app().recently_saved_song_files[num])
end

local function ll(num)
  renoise.app():load_song(renoise.app().recently_loaded_song_files[num])
end


-- Keys --
for i = 1,10 do
  if renoise.tool():has_keybinding("Global:Tools:Recently Saved File #"..i) then
    renoise.tool():remove_keybinding("Global:Tools:Recently Saved File #"..i)
  end
  renoise.tool():add_keybinding {
    name = "Global:Tools:Recently Saved File #"..i,
    invoke = function() ls(i) end,
  }
  if renoise.tool():has_keybinding("Global:Tools:Recently Loaded File #"..i) then
    renoise.tool():remove_keybinding("Global:Tools:Recently Loaded File #"..i)
  end
  renoise.tool():add_keybinding {
    name = "Global:Tools:Recently Loaded File #"..i,
    invoke = function() ll(i) end,
  }
end


-- Reload --
_AUTO_RELOAD_DEBUG = function()
  
end