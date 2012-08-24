-- ESTools 0.1 (C) 2012 -Cas Marrav- Renoise v 2.8

renoise.tool():add_keybinding {
  name = "Pattern Editor:Edit Step:Edit Step to LPB",
  invoke = function()
    edit_step(1) 
  end
}

for _,coeff in pairs {2, 3, 4, 6, 8, 12, 16} do
    renoise.tool():add_keybinding {
        name = "Pattern Editor:Edit Step:Edit Step to LPB*"..coeff,
        invoke = function()
            edit_step(coeff)
        end
    }
    renoise.tool():add_keybinding {
        name = "Pattern Editor:Edit Step:Edit Step to LPB/"..coeff,
        invoke = function()
            edit_step(1/coeff)
        end
    }
end

function edit_step(number)
  local x = math.floor(renoise.song().transport.lpb * number)
  if x >= 0 and x <= 64 then
    renoise.song().transport.edit_step = x
  end
end
