"
_- Strange Attraction ~ [Chaotic Algorithms] by TRIBΞHOLZ -_'
_-_-__--_-_--__-_--__-___--_-_--_--_-_-_-__-."
#---------------------------------------------------------
#PRESETS
use_bpm 146
use_debug false
use_real_time

use_osc "127.0.0.1", 9000

#---------------------------------------------------------
#METRONOME
live_loop :metro do
  sleep 1
end

#---------------------------------------------------------
#SAMPLES
s_path = "C:/Users/rober/Desktop/SOUND/Tracks/Strange Attraction/Samples"

s = {
  kick: "#{s_path}/kick.wav",
  bass: "#{s_path}/bass.wav",
  mad_bass: "#{s_path}/mad_bass_loop.wav",
  tz: "#{s_path}/tz.wav",
  snare: "#{s_path}/snare.wav",
  tom: "#{s_path}/tom.wav",
  piep: "#{s_path}/piep.wav",
  drone:  "#{s_path}/drone.wav",
  lead:  "#{s_path}/lead.wav",
  vocal:  "#{s_path}/the_strange_attractor.wav", #sample tooo big for GitHub -> Find video here https://www.youtube.com/watch?v=Cget6JxSpfQ
  atmo_loop: "#{s_path}/atmo_loop.wav",
  synth_loop:  "#{s_path}/synth_loop.wav",
  high_pitch: "#{s_path}/highpitch.wav",
  atmo: "#{s_path}/atmo.wav" #24
}
#---------------------------------------------------------
#PATTERNS
define :pattern do |p|
  return p.ring.tick == "x"
end

kick_pattern = ("xoxoxoxoxoxoxoxo")
tz_pattern = ("xxxxxxxxxxxxxxxx")
piep_pattern = ("xx___x___x___x__")
drop_pattern = ("x_x_x_x_x_x_x_")
snare_pattern = [[0, 0, 0, 0, 1, 0, 0, 0],[0, 0, 0, 0, 1, 0, 1, 1],[0, 0, 0, 0, 1, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 1]].flatten

#---------------------------------------------------------
#MIDI MIXER
define :scale_midi do |val, min, max|
  return min + (val.to_f / 127) * (max - min)
end

define :set_midi do |cc, value, min, max, osc_path=nil|
  scaled = min + (value.to_f / 127) * (max - min)
  $midi_values[cc] = scaled
  
  if osc_path
    osc osc_path, scaled
  end
end

$midi_values ||= Hash.new(0.01)

live_loop :midi_controls do
  key, value = sync "/midi:midi_mix_1:1/control_change"
  
  case key
  #DRUMS
  when 17 # kick_amp + bass_amps
    set_midi 17, value, 130, 40
  when 19 # kick_amp + bass_amps
    set_midi 19, value, 0, 1.2
  when 23 # tz_amp
    set_midi 23, value, 0, 0.5
  when 27 # drop_amp
    set_midi 27, value, 0, 1
  when 31 # piep_amp
    set_midi 31, value, 0, 1
  when 49 # tom_amp
    set_midi 49, value, 0, 1
    
    #SUGAR
    
  when 53 # piep_amp
    set_midi 53, value, 0, 0.4
  when 52 # piep_phase
    set_midi 52, value, 0.5, 8
  when 57 # highpitch_amp
    set_midi 57, value, 0, 0.3
  when 56 # highpitch_phase
    set_midi 56, value, 0.5, 4
  when 61 # synth_amp
    set_midi 61, value, 0, 0.5
  when 60 # synth_cutoff
    set_midi 60, value, 60, 100, "/cutoff"
  when 58 # synth_attack
    set_midi 58, value, 1, 8
  when 59 # synth_attack
    set_midi 59, value, 0.15, 1, "/attack"
  when 62 # lead_amp
    set_midi 62, value, 0, 0.3
    
    #ATMO
  when 18 # mad_bass_amp
    set_midi 18, value, 0, 0.75
  when 22 # atmo_amp
    set_midi 22, value, 0, 0.75
  when 26 # drone_amp
    set_midi 26, value, 0, 0.2
  when 30 # vocal_amp
    set_midi 30, value, 0, 0.6
  when 48 # noise_amp
    set_midi 48, value, 0, 0.6
    
    
    #VISUALS
  when 58 # synth_cutoff
    set_midi 58, value, 0.1, 3, "/visual"
  end
end

#---------------------------------------------------------
#KICKs
with_fx :distortion, distort: 0.4, mix: 0.3  do
  with_fx :eq, low_shelf: 0.05, low: 0.05 do
    with_fx :mono do
      live_loop :kick do
        #stop
        if pattern(kick_pattern)
          sample s[:kick],
            amp: $midi_values[19],
            beat_stretch: 1,
            cutoff: $midi_values[17]
        end
        sleep 0.5
      end
    end
  end
end

#BASS
with_fx :mono do
  #stop
  live_loop :bass do
    sleep 0.5
    sample s[:bass],
      amp: $midi_values[19] * 1,
      rate: ring(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1).tick,# 0.5 | 1 | ring(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1).tick,
      cutoff: $midi_values[17]
    sleep 0.5
  end
  
end

#TZTZTZTZ
with_fx :flanger, mix: 0.3 do
  live_loop :tz, sync: :kick do
    if pattern(tz_pattern)
      sample s[:tz],
        amp: $midi_values[23] ,
        rate: 2.5,
        cutoff: 120,
        beat_stretch: 1,
        rpitch: 20,
        release: 0.08,
        attack: 0.01
    end
    sleep 1
  end
end

#DROP

with_fx :reverb, mix: 0.5, room: 0.35 do
  live_loop :drop do
    if pattern(drop_pattern)
      sample :sn_zome, #:sn_zome | s[:snare]
        amp: $midi_values[27],
        beat_stretch: 0.15, # 0.15 | 0.4
        cutoff: 85
    end
    sleep 1
  end
end


live_loop :tütü do
  if pattern(piep_pattern)
    with_fx :reverb, mix: 0.5 do
      with_fx :echo, phase: 0.5 do
        sample :elec_bell,
          amp: $midi_values[31],
          beat_stretch: 1,
          rate: 12,
          cutoff: 85
      end
    end
  end
  sleep 1
end

#TOM
#with_fx :echo, phase: 0.5 do
live_loop :snare, sync: :metro do
  32.times do |i|
    if snare_pattern[i] ==  1
      sample s[:snare], amp: $midi_values[49], cutoff: 85, beat_stretch: 0.4 # 0.5, 1
    end
    sleep 0.25
  end
end
#end

#PIEP
live_loop :piep, sync: :metro do
  with_fx :reverb, mix: 0.5, room: 0.75 do
    with_fx :slicer, phase: $midi_values[52] do
      sample s[:piep],
        amp: $midi_values[53],
        beat_stretch: 2,
        rpitch: ring(8, 3, -8, -3).tick
      sleep 4
    end
  end
end



#stuff
with_fx :reverb, mix: 0.35, room: 0.9  do
  #with_fx :echo, phase: 1 do
  live_loop :noise, sync: :metro do
    #sstop
    sample s[:synth_loop],
      amp: $midi_values[48],
      beat_stretch: 8,
      rate:  ring(-0.1, -0.2,-0.3, -0.4).tick,
      pitch: ring(12, 8, 4, 0).tick
    sleep 16
    #end
  end
end

#NOISE
live_loop :highpitch, sync: :metro do
  with_fx :reverb, mix: 0.5, room: 0.75 do
    with_fx :slicer, phase: $midi_values[56] do
      sample s[:atmo],
        amp: $midi_values[57],
        beat_stretch: 12,
        rpitch: ring(2, 1).tick
      sleep 4
    end
  end
end

#SYNTH
with_fx :flanger, phase: 4, feedback: 0.4 do #phase: 4
  with_fx :reverb, mix: 0.6, room: 0.1 do
    #with_fx :slicer, phase: 0.5 do
    live_loop :synth1, sync: :metro do
      #stop
      synth_co = range(85, 65, 0.5).mirror
      use_random_seed ring(11111).tick #11111
      16.times do # 4 | 16
        with_synth :bass_foundation do
          n1 = (ring :f3, :d3, :e3).choose
          play n1,
            release: 0.25,#6 | 0.25
            cutoff: $midi_values[60],
            res: 0.1, # 0.1 | 0.5
            attack: $midi_values[59],
            amp: $midi_values[61],
            pitch: -1 # -10 | -1
          sleep 0.5 #4 | 0.5
          # end
        end
      end
    end
  end
end

#LEAD
live_loop :lead, sync: :metro do
  with_fx :reverb, mix: 0.5, room: 0.75 do
    with_fx :slicer, phase: 0.5 do
      sample s[:lead], start: 0.0, finish: 0.5,
        amp: $midi_values[62],
        beat_stretch: 32,
        rpitch: ring(8, 3).tick
      sleep 8
    end
  end
end

#MAD BASS
live_loop :madbass, sync: :metro do
  with_fx :echo, phase: 1 , feedback: 0.95 do
    with_fx :lpf, cutoff: 100 do
      sample  s[:mad_bass],
        amp: $midi_values[18],
        beat_stretch: (ring 24 , 32).tick,
        rate: 0.25, #1 & 0.25
        cutoff: 100,
        pitch: 10 #-10
      sleep 8
    end
  end
end

#ATMO
live_loop :atmo, sync: :metro do
  stop
  with_fx :reverb, mix: 0.5, room: 0.75  do
    with_fx :slicer, phase: 0.5 do
      sample s[:atmo_loop],
        amp: $midi_values[22],
        beat_stretch: 24,
        rpitch: ring(-8, -1).tick #-8, -12, -8, -1
      sleep 24
    end
  end
end

#DRONE
live_loop :drone, sync: :metro do
  with_fx :reverb, mix: 0.5, room: 0.9  do
    with_fx :echo, phase: 1 do
      sample s[:drone],
        amp: $midi_values[26],
        beat_stretch: 32, #32
        rate: (ring 0.5, 0.7, 1, -0.7).tick,
        pitch: -12
      sleep 32
    end
  end
end

#VOCAL
#sample tooo big for GitHub
#Find video here https://www.youtube.com/watch?v=Cget6JxSpfQ
live_loop :vocal, sync: :metro do
  with_fx :reverb, mix: 0.5, room: 0.75 do
    with_fx :flanger, phase: 0.25 do #flanger
      #with_fx :slicer, phase: 0.5 do
      #stop
      sleep 84
      sample s[:vocal], start: 0.1355, finish: 0.182, #start: 0.082, finish: 0.124  | start: 0.124, finish: 0.182
        amp: $midi_values[30],
        beat_stretch: 1000,
        rate: (ring 1, 1).tick
      sleep 64 # 2 | 64
      #end
    end
  end
end