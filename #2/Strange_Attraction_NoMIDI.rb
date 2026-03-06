"
_- Strange Attraction ~ [No-MIDI] by TRIBΞHOLZ -_'
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
s_path = "C:/Users/rober/Desktop/2_PROJΞCTS/3 - TRIBΞHOLZ/1_SonicPi/Strange Attraction/Samples"

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
#MIXER
master = 1
kick_amp = 0.5
drop_amp = 0.0
snare_amp = 0.3
tz_amp = 0.2
drumkit_amp = 0.0

madbass_amp = 0.0
lead_amp = 0.0
drone_amp = 0.0
noise_amp = 0.0
piep_amp = 0.0
vocal_amp = 0.0
stuff_amp = 0.0

synth_amp = 0.0


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

#---------------------------------------------------------
#KICKs
with_fx :distortion, distort: 0.4, mix: 0.3  do
  with_fx :eq, low_shelf: 0.05, low: 0.05 do
    with_fx :mono do
      live_loop :kick do
        #stop
        if pattern(kick_pattern)
          sample s[:kick],
            amp: kick_amp * master,
            beat_stretch: 1,
            cutoff: 120
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
      amp: kick_amp * 0.5 * master,
      rate: 1,# 0.5 | 1 | ring(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1).tick,
      cutoff: 80
    sleep 0.5
  end
  
end

#TZTZTZTZ
with_fx :flanger, mix: 0.3 do
  live_loop :tz, sync: :kick do
    if pattern(tz_pattern)
      sample s[:tz],
        amp: tz_amp * master,
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
        amp: drop_amp * master,
        beat_stretch: 0.15, # 0.15 | 0.4
        cutoff: 85
    end
    sleep 1
  end
end


live_loop :piep do
  if pattern(piep_pattern)
    with_fx :reverb, mix: 0.5 do
      with_fx :echo, phase: 0.5 do
        sample :elec_bell,
          amp: piep_amp * master,
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
      sample s[:snare], amp: snare_amp * master, cutoff: 85, beat_stretch: 0.4 # 0.5, 1
    end
    sleep 0.25
  end
end
#end

#PIEP
live_loop :piep, sync: :metro do
  with_fx :reverb, mix: 0.5, room: 0.75 do
    with_fx :slicer, phase: 0.5 do
      sample s[:piep],
        amp: piep_amp * master,
        beat_stretch: 2,
        rpitch: ring(8, 3, -8, -3).tick
      sleep 4
    end
  end
end



#stuff
with_fx :reverb, mix: 0.35, room: 0.9  do
  #with_fx :echo, phase: 1 do
  live_loop :stuff, sync: :metro do
    #sstop
    sample s[:synth_loop],
      amp: stuff_amp * master,
      beat_stretch: 8,
      rate:  ring(-0.1, -0.2,-0.3, -0.4).tick,
      pitch: ring(12, 8, 4, 0).tick
    sleep 16
    #end
  end
end

#NOISE
live_loop :noise, sync: :metro do
  with_fx :reverb, mix: 0.5, room: 0.75 do
    with_fx :slicer, phase: 0.5 do
      sample s[:atmo],
        amp: noise_amp * master,
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
            cutoff: synth_co.look,
            res: 0.1, # 0.1 | 0.5
            attack: 0.1,
            amp: synth_amp * master,
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
        amp: lead_amp,
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
        amp: madbass_amp * master,
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
        amp: atmo_amp * master,
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
        amp: drone_amp * master,
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
      sleep 4
      sample s[:vocal], start: 0.0, finish: 0.14, #start: 0.082, finish: 0.124  | start: 0.124, finish: 0.182
        amp: vocal_amp * master,
        beat_stretch: 1000,
        rate: (ring 1, 1).tick
      sleep 64 # 2 | 64
      #end
    end
  end
end