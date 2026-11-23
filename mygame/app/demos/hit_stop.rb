module Demos
  # The same blow twice: the upper lane plays straight through, the lower one
  # freezes for a few frames at the moment of contact.
  module HitStop
    ID = "hit_stop".freeze
    TITLE = "Hit stop".freeze
    BLURB = "The game holds still for a few frames when a blow lands. Same hit, same speed: only the pause differs.".freeze
    CONTROLS = "Click or SPACE: strike again".freeze
    SHOT_AT = 34
    FILM_FOR = 240

    FREEZE = 9
    CONTACT = 30 # the lane's own frame on which the blow lands
    TARGET_X = 860

    def self.setup
      { clock: 0, lanes: [lane(470, nil), lane(280, Vfx::HitStop.new)] }
    end

    def self.lane(y, stop)
      { y: y, time: 0.0, hit: false, stop: stop }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      if input[:action] || demo[:clock] > 120
        demo[:clock] = 0
        demo[:lanes].each do |lane|
          lane[:time] = 0.0
          lane[:hit] = false
          lane[:stop] = Vfx::HitStop.new if lane[:stop]
        end
      end

      Stage.draw(args.outputs)
      demo[:lanes].each { |lane| args.outputs.primitives << play(lane) }
    end

    def self.play(lane)
      stop = lane[:stop]
      scale = stop ? Vfx::HitStop.tick(stop) : 1.0
      lane[:time] += scale
      if lane[:time] >= CONTACT && !lane[:hit]
        lane[:hit] = true
        Vfx::HitStop.freeze(stop, FREEZE) if stop
      end
      draw(lane, scale == 0)
    end

    def self.draw(lane, frozen)
      time = lane[:time]
      after = ((time - CONTACT) / 50.0).clamp(0.0, 1.0)
      contact_x = TARGET_X - 34 # the fist's radius: it touches the target
      fist_x = if time < CONTACT
                 260 + ((contact_x - 260) * ((time / CONTACT)**2))
               else
                 contact_x - (150 * (1 - ((1 - after)**2)))
               end
      knock = lane[:hit] ? 90 * (1 - after) * [after * 8, 1.0].min : 0
      # While frozen the pair trembles a little: stillness alone reads as a stall.
      tremble = frozen ? ((Kernel.tick_count % 2) * 6) - 3 : 0
      struck = frozen || (lane[:hit] && time - CONTACT < 3)

      list = [Stage.text(60, lane[:y] + 100, lane[:stop] ? "Hit stop: #{FREEZE} frames" : "No hit stop", color: Stage::GREY)]
      list << Stage.blob({ x: TARGET_X + knock + tremble, y: lane[:y], w: 100, h: 100 }, struck ? Stage::WHITE : Stage::RED)
      list << Stage.circle(fist_x + tremble, lane[:y] + 50, 34, Stage::YELLOW)
      if struck
        list << { x: contact_x - 60, y: lane[:y] - 30, w: 220, h: 160, path: "sprites/vfx/glow.png", blendmode: 2 }
      end
      list
    end
  end
end
