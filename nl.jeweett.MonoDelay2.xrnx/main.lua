--[[============================================================================
--                           Mono Delay v2                                    --
============================================================================]]--

local __DELAYDEVICE = "Audio/Effects/Native/Delay"

local __FEEDBACKL = 3
local __FEEDBACKR = 4
local __LOOSEDELAYL = 1
local __LOOSEDELAYR = 2
local __STRICTDELAYL = 12
local __STRICTDELAYR = 13
local __STRICTOFFSETL = 14
local __STRICTOFFSETR = 15

local allmd = table.create()
local mdcount = 0

require("Classes/MonoDelay")


--------------------------------------------------------------------------------
-- Other listeners
--------------------------------------------------------------------------------

function __is_mono(device)
  local well = false
  for _, md in ipairs(allmd) do
    if rawequal(md.__device, device) then
      well = true
    end
  end
  return well
end

function __get_mono(device)
  local well = nil
  for _, md in ipairs(allmd) do
    if rawequal(md.__device, device) then
      well = md
    end
  end
  return well
end

function __add_mono(sd)
  mdcount = mdcount+1
  local md = MonoDelay(sd)
  allmd[mdcount] = md
  if not sd:parameter(__FEEDBACKL).value_observable:has_notifier(md.__lfix, md) then
    sd:parameter(__FEEDBACKL).value_observable:add_notifier(md.__lfix, md)
  end
  if not sd:parameter(__LOOSEDELAYL).value_observable:has_notifier(md.__lfix, md) then
    sd:parameter(__LOOSEDELAYL).value_observable:add_notifier(md.__lfix, md)
  end
  if not sd:parameter(__STRICTDELAYL).value_observable:has_notifier(md.__lfix, md) then
    sd:parameter(__STRICTDELAYL).value_observable:add_notifier(md.__lfix, md)
  end
  if not sd:parameter(__STRICTOFFSETL).value_observable:has_notifier(md.__lfix, md) then
    sd:parameter(__STRICTOFFSETL).value_observable:add_notifier(md.__lfix, md)
  end
  if not sd:parameter(__FEEDBACKR).value_observable:has_notifier(md.__rfix, md) then
    sd:parameter(__FEEDBACKR).value_observable:add_notifier(md.__rfix, md)
  end
  if not sd:parameter(__LOOSEDELAYR).value_observable:has_notifier(md.__rfix, md) then
    sd:parameter(__LOOSEDELAYR).value_observable:add_notifier(md.__rfix, md)
  end
  if not sd:parameter(__STRICTDELAYR).value_observable:has_notifier(md.__rfix, md) then
    sd:parameter(__STRICTDELAYR).value_observable:add_notifier(md.__rfix, md)
  end
  if not sd:parameter(__STRICTOFFSETR).value_observable:has_notifier(md.__rfix, md) then
    sd:parameter(__STRICTOFFSETR).value_observable:add_notifier(md.__rfix, md)
  end
end

function __remove_mono(sd)
  local md = __get_mono(sd)
  if sd:parameter(__FEEDBACKL).value_observable:has_notifier(md.__lfix, md) then
    sd:parameter(__FEEDBACKL).value_observable:remove_notifier(md.__lfix, md)
  end
  if sd:parameter(__LOOSEDELAYL).value_observable:has_notifier(md.__lfix, md) then
    sd:parameter(__LOOSEDELAYL).value_observable:remove_notifier(md.__lfix, md)
  end
  if sd:parameter(__STRICTDELAYL).value_observable:has_notifier(md.__lfix, md) then
    sd:parameter(__STRICTDELAYL).value_observable:remove_notifier(md.__lfix, md)
  end
  if sd:parameter(__STRICTOFFSETL).value_observable:has_notifier(md.__lfix, md) then
    sd:parameter(__STRICTOFFSETL).value_observable:remove_notifier(md.__lfix, md)
  end
  if sd:parameter(__FEEDBACKR).value_observable:has_notifier(md.__rfix, md) then
    sd:parameter(__FEEDBACKR).value_observable:remove_notifier(md.__rfix, md)
  end
  if sd:parameter(__LOOSEDELAYR).value_observable:has_notifier(md.__rfix, md) then
    sd:parameter(__LOOSEDELAYR).value_observable:remove_notifier(md.__rfix, md)
  end
  if sd:parameter(__STRICTDELAYR).value_observable:has_notifier(md.__rfix, md) then
    sd:parameter(__STRICTDELAYR).value_observable:remove_notifier(md.__rfix, md)
  end
  if sd:parameter(__STRICTOFFSETR).value_observable:has_notifier(md.__rfix, md) then
    sd:parameter(__STRICTOFFSETR).value_observable:remove_notifier(md.__rfix, md)
  end
  for idx, xd in ipairs(allmd) do
    if xd == md then
      allmd[idx] = nil
    end
  end
end

function __selected_device_changed()
  local rs = renoise.song()
  local rt = renoise.tool()
  local sd = rs.selected_device
  
  local menu_device_set = "--- DSP Device:Set Mono"
  local menu_device_unset = "--- DSP Device:Unset Mono"
  
  if rt:has_menu_entry(menu_device_set) then
    rt:remove_menu_entry(menu_device_set)
  end
  if rt:has_menu_entry(menu_device_unset) then
    rt:remove_menu_entry(menu_device_unset)
  end
  
  if sd then
    if sd.device_path == __DELAYDEVICE then
      if __is_mono(sd) then
        rt:add_menu_entry {
          name = menu_device_unset,
          invoke = function()
            __remove_mono(sd)
            sd.display_name = "Delay"
          end
        }
      else
        rt:add_menu_entry {
          name = menu_device_set,
          invoke = function()
            __add_mono(sd)
            sd.display_name = "MonoDelay"
          end
        }
      end
    end
  end
end

function app_new_document()            -- 'install' in Set Rate
  local rs = renoise.song()
  if not rs.selected_device_observable:has_notifier(__selected_device_changed) then
    rs.selected_device_observable:add_notifier(__selected_device_changed)
  end
end

function app_release_document()        -- 'uninstall' in Set Rate
  local rs = renoise.song()
  if rs.selected_device_observable:has_notifier(__selected_device_changed) then
    rs.selected_device_observable:remove_notifier(__selected_device_changed)
  end
end

renoise.tool().app_new_document_observable:add_notifier(app_new_document)
renoise.tool().app_release_document_observable:add_notifier(app_release_document)




_AUTO_RELOAD_DEBUG = function()
  --__selected_device_changed()
end
