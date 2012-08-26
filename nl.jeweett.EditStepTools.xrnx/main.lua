-- ESTools 0.1 (C) 2012 -Cas Marrav- Renoise v 2.8

renoise.tool():add_keybinding {
  name = "Pattern Editor:Edit Step:Set EditStep to LPB",
  invoke = function()
    edit_step(1) 
  end
}

for _,coeff in pairs {2, 3, 4, 6, 8, 12, 16} do
    renoise.tool():add_keybinding {
        name = "Pattern Editor:Edit Step:Set EditStep to LPB*"..coeff,
        invoke = function()
            edit_step(coeff)
        end
    }
    renoise.tool():add_keybinding {
        name = "Pattern Editor:Edit Step:Set EditStep to LPB/"..coeff,
        invoke = function()
            edit_step(1/coeff)
        end
    }
end

for _,special in pairs {3/8, 2/3, 3/4, 1+1/3, 1.5, 1.75} do
    renoise.tool():add_keybinding {
        name = "Pattern Editor:Edit Step:Set EditStep to LPB*"..special,
        invoke = function()
            edit_step(special)
        end
    }
end

function edit_step(number)
  local x = math.floor(renoise.song().transport.lpb * number)
  if x >= 0 and x <= 64 then
    renoise.song().transport.edit_step = x
  end
end
