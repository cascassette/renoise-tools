-------------------------------------------------------------
-- Recent Files v2 by Cas Marrav (for Renoise 2.8)         --
-------------------------------------------------------------


-- GUI stuff --
local rs
local dialog = nil
local vb = nil
local select = 1
local ps = "/"
if (os.platform() == "WINDOWS") then ps = "\\" end


-- Main --
local function ls(num)
  renoise.app():load_song(renoise.app().recently_saved_song_files[num])
end

local function ll(num)
  renoise.app():load_song(renoise.app().recently_loaded_song_files[num])
end

-- GUI --
local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function key_dialog(d, k)
  if (k.character and k.character >= "0" and k.character <= "9") then
    local num=tonumber(k.character)
    if num==0 then num=10 end
    if (select==1) then
      d:close()
      ls(num)
    elseif (select==2) then
      d:close()
      ll(num)
    end
    --loadstring("l"..select.."("..k.character..")")()
  elseif (k.name == "right") then
    select = 2
    vb.views["selector_l"].style = "group"
    vb.views["selector_s"].style = "panel"
  elseif (k.name == "left") then
    select = 1
    vb.views["selector_s"].style = "group"
    vb.views["selector_l"].style = "panel"
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    --return k
  end
end

local function showgui()
  vb = renoise.ViewBuilder()
  local list_s = {}
  local list_l = {}
  local fn = ""
  local dialog_content = 
    vb:horizontal_aligner
    {
      vb:column { id = "list_s", vb:row{ id = "selector_s", style = "group", vb:text{ text = "Saved:" } } },
      vb:column { id = "list_l", vb:row{ id = "selector_l", style = "panel", vb:text{ text = "Loaded:" } } },
    }
  for i = 1, #renoise.app().recently_saved_song_files do
    fn = renoise.app().recently_saved_song_files[i]
    fn = fn:sub(fn:len()-string.find(fn:reverse(),ps)+2)
    list_s[i] = 
      vb:button { text = ""..i..". "..fn, released = function() ls(i) close_dialog() end }
    vb.views['list_s']:add_child(list_s[i])
  end
  for i = 1, #renoise.app().recently_loaded_song_files do
    fn = renoise.app().recently_loaded_song_files[i]
    fn = fn:sub(fn:len()-string.find(fn:reverse(),ps)+2)
    list_l[i] = 
      vb:button { text = ""..i..". "..fn, released = function() ll(i) close_dialog() end }
    vb.views['list_l']:add_child(list_l[i])
  end
  dialog = renoise.app():show_custom_dialog( "Recent Files", dialog_content, key_dialog )
end


-- Keys --
if renoise.tool():has_keybinding("Global:Tools:Recent Files...") then
  renoise.tool():remove_keybinding("Global:Tools:Recent Files...")
end
renoise.tool():add_keybinding {
  name = "Global:Tools:Recent Files...",
  invoke = showgui,
}

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
