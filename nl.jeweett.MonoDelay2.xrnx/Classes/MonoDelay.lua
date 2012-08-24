--------------------------------------------------------------------------------
-- Main class
--------------------------------------------------------------------------------

local __FEEDBACKL = 3
local __FEEDBACKR = 4
local __LOOSEDELAYL = 1
local __LOOSEDELAYR = 2
local __STRICTDELAYL = 12
local __STRICTDELAYR = 13
local __STRICTOFFSETL = 14
local __STRICTOFFSETR = 15

class "MonoDelay"
  function MonoDelay:__init(device, number)
    self.__device = device
    self.__number = number
  end
  function MonoDelay:__lfix()
    self.__device:parameter(__FEEDBACKR).value_observable:remove_notifier(self.__rfix, self)
    self.__device:parameter(__LOOSEDELAYR).value_observable:remove_notifier(self.__rfix, self)
    self.__device:parameter(__STRICTDELAYR).value_observable:remove_notifier(self.__rfix, self)
    self.__device:parameter(__STRICTOFFSETR).value_observable:remove_notifier(self.__rfix, self)
    
    self.__device:parameter(__FEEDBACKR).value = self.__device:parameter(__FEEDBACKL).value
    self.__device:parameter(__LOOSEDELAYR).value = self.__device:parameter(__LOOSEDELAYL).value
    self.__device:parameter(__STRICTDELAYR).value = self.__device:parameter(__STRICTDELAYL).value
    self.__device:parameter(__STRICTOFFSETR).value = self.__device:parameter(__STRICTOFFSETL).value
    
    self.__device:parameter(__FEEDBACKR).value_observable:add_notifier(self.__rfix, self)
    self.__device:parameter(__LOOSEDELAYR).value_observable:add_notifier(self.__rfix, self)
    self.__device:parameter(__STRICTDELAYR).value_observable:add_notifier(self.__rfix, self)
    self.__device:parameter(__STRICTOFFSETR).value_observable:add_notifier(self.__rfix, self)
  end
  function MonoDelay:__rfix()
    self.__device:parameter(__FEEDBACKL).value_observable:remove_notifier(self.__lfix, self)
    self.__device:parameter(__LOOSEDELAYL).value_observable:remove_notifier(self.__lfix, self)
    self.__device:parameter(__STRICTDELAYL).value_observable:remove_notifier(self.__lfix, self)
    self.__device:parameter(__STRICTOFFSETL).value_observable:remove_notifier(self.__lfix, self)
    
    self.__device:parameter(__FEEDBACKL).value = self.__device:parameter(__FEEDBACKR).value
    self.__device:parameter(__LOOSEDELAYL).value = self.__device:parameter(__LOOSEDELAYR).value
    self.__device:parameter(__STRICTDELAYL).value = self.__device:parameter(__STRICTDELAYR).value
    self.__device:parameter(__STRICTOFFSETL).value = self.__device:parameter(__STRICTOFFSETR).value
    
    self.__device:parameter(__FEEDBACKL).value_observable:add_notifier(self.__lfix, self)
    self.__device:parameter(__LOOSEDELAYL).value_observable:add_notifier(self.__lfix, self)
    self.__device:parameter(__STRICTDELAYL).value_observable:add_notifier(self.__lfix, self)
    self.__device:parameter(__STRICTOFFSETL).value_observable:add_notifier(self.__lfix, self)
  end

