--[[============================================================================
main.lua
============================================================================]]--

--------------------------------------------------------------------------------
-- Helper functions
--------------------------------------------------------------------------------

local BIND_STRING = [[
      <MidiMappings>
        <MidiMapping>
          <MappingMode>Controllers</MappingMode>
          <ControllerMode>Absolute 7 bit</ControllerMode>
          <NoteMode>Trigger</NoteMode>
          <Channel>0</Channel>
          <CCNumberOrNote>22</CCNumberOrNote>
          <Min>0.0</Min>
          <Max>1.0</Max>
        </MidiMapping>
      </MidiMappings>
]]

local function message(msg)
  print(msg)
  renoise.app():show_status(msg)
end

local function remove_spacing(s)
  local t = ""
  --local skipthese = " \t\n"
  local skipthese = "\t\n"
  --for i = 1, #s do local c = s:sub(i, i) print("char: ") rprint(c) rprint(skipthese:find(c))
  for i = 1, #s do
    local c = s:sub(i, i)
    if skipthese:find(c) == nil then
      t = t .. c
    end
  end
  return t
end

local function debug_thingy(dev)
  if dev ~= 2 and dev ~= 3 then dev = 2 end --device number
  --rprint(string)
  --print("looking for hydra1...")
  --print(renoise.song():track(1):device(2).active_preset_data)
  --print("looking for hydra2...")
  --print(renoise.song():track(1):device(3).active_preset_data)
  local apds = renoise.song():track(1):device(dev).active_preset_data
  --print(apds:find("InputValue"))
  --print(apds:sub(apds:find("InputValue")))
  --print(apds:sub(apds:find("InputValue")+37))
  local lhs = apds:sub(1, apds:find("InputValue")+37)
  local rhs = apds:sub(apds:find("InputValue")+38)
  --print(lhs..rhs)
  --print(BIND_STRING)
  --print(lhs..BIND_STRING..rhs)
  print(remove_spacing(lhs..BIND_STRING..rhs))
  renoise.song():track(1):device(dev).active_preset_data = remove_spacing(lhs..BIND_STRING..rhs)
end

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Switch it on em",
  invoke = function()
    debug_thingy(3)
  end
}


-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function()
  --debug_thingy(3)
end
