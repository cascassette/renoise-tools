-------------------------------------------------------------
--Midi Mappings
-------------------------------------------------------------
if renoise.tool():has_midi_mapping("Transport:Playback:Skip to Line [Set]") then
  renoise.tool():remove_midi_mapping("Transport:Playback:Skip to Line [Set]")
end
renoise.tool():add_midi_mapping {
  name = "Transport:Playback:Skip to Line [Set]",
  invoke = function(mm) skip(mm) end
}

-------------------------------------------------------------
--Main: skip function
-------------------------------------------------------------
function skip(midi_message)
  local s = renoise.song()
  local follow = s.transport.follow_player
  local current_seq
  if follow then current_seq = s.transport.playback_pos.sequence
  else           current_seq = s.transport.edit_pos.sequence end
  local current_pat = s.sequencer.pattern_sequence[current_seq]
  local pat_length = s.patterns[current_pat].number_of_lines
  local skipto = 1
  -- debug info
  --print("MidiSkip DEBUG INFO")
  --print("current_seq:", current_seq)
  --print("current_pat:", current_pat)
  --print("pat_length :", pat_length)
  -- if abs_value then skip to line no.
  --  (distribute possible values over current pattern length)
  if midi_message:is_abs_value() then
    if pat_length == 128 then
      skipto = midi_message.int_value+1 -- translation: pattern lines start with 1
    else
      skipto = math.floor(midi_message.int_value/128*pat_length)+1
    end
    if follow then s.transport.playback_pos = renoise.SongPos(current_seq, skipto)
    else           s.transport.edit_pos = renoise.SongPos(current_seq, skipto) end
  -- if rel_value then skip back/fw x lines
  --elseif midi_message:is_rel_value() then
    -- not supported yet
    -- will get more complicated, skipping back etc, 
  end
end

-------------------------------------------------------------
--Main: skip functions to emulate F9 through F12 buttons
-------------------------------------------------------------
--function goto1()
--end

--function goto2()
--end

--function goto3()
--end

--function goto4()
--end
