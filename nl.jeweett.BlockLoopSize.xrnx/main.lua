
-- BlockLoopSize 0.6 (C) 2012 Cas

renoise.tool():add_keybinding {
  name = "Global:Transport:Block loop size -1",
  invoke = function()
    increase_coeff() 
  end
}

renoise.tool():add_keybinding {
  name = "Global:Transport:Block loop size +1",
  invoke = function()
    decrease_coeff() 
  end
}

renoise.tool():add_keybinding {
  name = "Global:Transport:Block loop size /2",
  invoke = function()
    smaller_coeff() 
  end
}

renoise.tool():add_keybinding {
  name = "Global:Transport:Block loop size *2",
  invoke = function()
    bigger_coeff() 
  end
}

function increase_coeff()
  if renoise.song().transport.loop_block_range_coeff ~= 16 then
    renoise.song().transport.loop_block_range_coeff = renoise.song().transport.loop_block_range_coeff + 1
  end
end

function decrease_coeff()
  if renoise.song().transport.loop_block_range_coeff ~= 2 then
    renoise.song().transport.loop_block_range_coeff = renoise.song().transport.loop_block_range_coeff - 1
  end
end

function smaller_coeff()
  if renoise.song().transport.loop_block_range_coeff <= 8 then
    renoise.song().transport.loop_block_range_coeff = renoise.song().transport.loop_block_range_coeff * 2
  end
end

function bigger_coeff()
  if renoise.song().transport.loop_block_range_coeff >= 4 and ( renoise.song().transport.loop_block_range_coeff % 2 == 0 ) then
    renoise.song().transport.loop_block_range_coeff = renoise.song().transport.loop_block_range_coeff / 2
  end
end
