-------------------------------------------------------------
-- Mashup v1.0 by Cas Marrav (for Renoise 2.8)             --
-------------------------------------------------------------

local vb
local dialog
local vb_times
local vb_formula

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:CasTools:Mash up...",
  invoke = function()
    --show_random_dialog()
    show_formula_dialog()
  end
}

-------------------------------------------------------------
-- GUI                                                     --
-------------------------------------------------------------
local function close_dialog()
  if ( dialog and dialog.visible ) then
    dialog:close()
  end
end

local function key_dialog(d,k)
  if ( k.name == "up" ) then
    vb_times.value = vb_times.value + 1
  elseif ( k.name == "down" ) then
    vb_times.value = vb_times.value - 1
  elseif ( k.name == "right" ) then
    vb_times.value = vb_times.value * 2
  elseif ( k.name == "left" ) then
    vb_times.value = vb_times.value / 2
  elseif ( k.name == "return" ) then
    local cii = renoise.song().selected_instrument_index
    local nii = renoise.song().selected_instrument_index+1
    renoise.song():insert_instrument_at(renoise.song().selected_instrument_index+1)
    --render_random_mashup( cii, nii, math.floor(vb_times.value) )
    render_mashup( cii, nii, vb_formula.value, math.floor(vb_times.value) )
    close_dialog()
  elseif ( k.name == "esc" ) then
    close_dialog()
  else
    return k
  end
end

function show_random_dialog()
  vb = renoise.ViewBuilder()
  vb_times = vb:slider { min = 1, max = 1024, value = 1, width = 200 }
  local vb_timesshow = vb:valuebox { min = 1, max = 1024, value = 1, width = 100 }
  local vb_txt = vb:text { text = "times:" }
  local vb_timesrow = vb:row { vb_txt, vb_times, vb_timesshow }
  vb_times:add_notifier(function() vb_timesshow.value = math.floor(vb_times.value) end)

  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  local dialog_content = vb:horizontal_aligner
  {
    vb:column {
      margin = DDM, spacing = CS,
      vb_timesrow,
    },
  }
    
  if not ( dialog and dialog.visible ) then
    dialog = renoise.app():show_custom_dialog( "Mash up!", dialog_content, key_dialog )
  end
end

function show_formula_dialog()
  local vb = renoise.ViewBuilder()
  local CS = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
  local DDM = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  
  --vb_formula = vb:textfield { value = "math.random(N)", width = 600 }
  vb_formula = vb:textfield { value = "1+(X-1)%N", width = 600 }
  vb_times = vb:slider { min = 1, max = 256, value = 32, width = 500 }
  local vb_timesshow = vb:valuebox { min = 1, max = 256, value = 32, width = 100 }
  local vb_timesrow = vb:row { vb_times, vb_timesshow }
  vb_times:add_notifier(function() vb_timesshow.value = math.floor(vb_times.value) end)  
  
  local vb_dialog = vb:horizontal_aligner {
    margin = DDM,
    spacing = CS,
    vb:column {
      vb:text { text = "select:" },
      vb:text { text = "times: " },
    },
    vb:column {
      vb_formula,
      vb_timesrow,
    }
  }

  local dialog_instance = renoise.app():show_custom_prompt("Mash up!",
                   vb_dialog,
                 {"Go for it!", "Cancel"})
  if dialog_instance == "Go for it!" then
    local cii = renoise.song().selected_instrument_index
    local nii = renoise.song().selected_instrument_index+1
    renoise.song():insert_instrument_at(nii)
    render_mashup( cii, nii, vb_formula.value, math.floor(vb_timesshow.value) )
  end
end

-------------------------------------------------------------
-- Main                                                    --
-------------------------------------------------------------
function render_mashup( cii, nii, formula, nl )
  local rs = renoise.song()
  local ni = rs:instrument(nii)
  local ci = rs:instrument(cii)
  local nn = ci.name .. " Mashup x " .. nl
  ni:insert_sample_at(2)
  ni:sample(2).sample_buffer:create_sample_data( 44100, 32, 1, 1 )
  ni:sample(2).name = formula
  --local bn = ci:sample_mapping(1,1).base_note
  local bn = 9
  --local sm = #ci.samples-1
  local sc = #ci:sample(1).slice_markers
  --local sl = (ci:sample(1).sample_buffer.number_of_frames/sm)
  local sl = {}
  for i = 1, sc do
    if i < sc then
      sl[i] = ci:sample(1).slice_markers[i+1] - ci:sample(1).slice_markers[i]
    else
      sl[i] = ci:sample(1).sample_buffer.number_of_frames - ci:sample(1).slice_markers[i]
    end
  end
  local cc = ci:sample(1).sample_buffer.number_of_channels    -- channel count
  local bd = ci:sample(1).sample_buffer.bit_depth             -- bit depth
  local sr = ci:sample(1).sample_buffer.sample_rate           -- sample rate
  local newlen = nl
  local newlensmp = 0
  local newlensmpx = {}
  local select = {}
  for i = 1, nl do
    --local x = math.random(sc)
    local tmpfstr = formula:gsub("X", i)
    tmpfstr = tmpfstr:gsub("N", sc)
    local x = loadstring("return "..tmpfstr)()
    select[i] = x
    newlensmpx[i] = newlensmp
    newlensmp = newlensmp + ci:sample(x+1).sample_buffer.number_of_frames
  end
  local sb = ni:sample(1).sample_buffer
  sb:create_sample_data( sr, bd, cc, newlensmp )
  sb:prepare_sample_data_changes()
  for i = 1, nl do                  -- slice
    for c = 1, cc do                -- channel
      for j = 1, sl[select[i]] do
        --sb:set_sample_data(c,(i-1)*sl+j,ci:sample(x+1).sample_buffer:sample_data(c,j))
        sb:set_sample_data(c,newlensmpx[i]+j,ci:sample(select[i]+1).sample_buffer:sample_data(c,j))
      end
    end
  end
  sb:finalize_sample_data_changes()
  ni:delete_sample_mapping_at(1, 1)
  ni:insert_sample_mapping(1, 1, bn)
  ni.name = nn
  ni:sample(1).name = nn
  rs.selected_instrument_index = nii
end

function render_random_mashup( cii, nii, nl ) -- current / new instrument index, new length (in slices)
  local rs = renoise.song()
  local ni = rs:instrument(nii)
  local ci = rs:instrument(cii)
  local nn = ci.name .. " Mashup x " .. nl
  --local bn = ci:sample_mapping(1,1).base_note
  local bn = 9
  --local sm = #ci.samples-1
  local sc = #ci:sample(1).slice_markers
  --local sl = (ci:sample(1).sample_buffer.number_of_frames/sm)
  local sl = {}
  for i = 1, sc do
    if i < sc then
      sl[i] = ci:sample(1).slice_markers[i+1] - ci:sample(1).slice_markers[i]
    else
      sl[i] = ci:sample(1).sample_buffer.number_of_frames - ci:sample(1).slice_markers[i]
    end
  end
  local cc = ci:sample(1).sample_buffer.number_of_channels    -- channel count
  local bd = ci:sample(1).sample_buffer.bit_depth             -- bit depth
  local sr = ci:sample(1).sample_buffer.sample_rate           -- sample rate
  local newlen = nl
  local newlensmp = 0
  local newlensmpx = {}
  local select = {}
  for i = 1, nl do
    local x = math.random(sc)
    select[i] = x
    newlensmpx[i] = newlensmp
    newlensmp = newlensmp + ci:sample(x+1).sample_buffer.number_of_frames
  end
  local sb = ni:sample(1).sample_buffer
  sb:create_sample_data( sr, bd, cc, newlensmp )
  sb:prepare_sample_data_changes()
  for i = 1, nl do                  -- slice
    for c = 1, cc do                -- channel
      for j = 1, sl[select[i]] do
        --sb:set_sample_data(c,(i-1)*sl+j,ci:sample(x+1).sample_buffer:sample_data(c,j))
        sb:set_sample_data(c,newlensmpx[i]+j,ci:sample(select[i]+1).sample_buffer:sample_data(c,j))
      end
    end
  end
  sb:finalize_sample_data_changes()
  ni:delete_sample_mapping_at(1, 1)
  ni:insert_sample_mapping(1, 1, bn)
  ni.name = nn
  ni:sample(1).name = nn
  rs.selected_instrument_index = nii
end

--------------------------------------------------------------------------------
-- Key Binding
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Global:Tools:Mash up...",
  --invoke = show_random_dialog
  invoke = show_formula_dialog
}

-------------------------------------------------------------
-- autoreload function                                     --
-------------------------------------------------------------
_AUTO_RELOAD_DEBUG = function()
end
