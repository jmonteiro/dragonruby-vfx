module Demos
  # A creature takes a steady beating; every fifth blow is a critical.
  module DamageNumbers
    ID = "damage_numbers".freeze
    TITLE = "Damage numbers".freeze
    BLURB = "Numbers pop out oversized, rise, slow down and fade. A dark copy underneath keeps them readable.".freeze
    CONTROLS = "Click or SPACE: a flurry of hits".freeze
    SHOT_AT = 70

    def self.setup
      { clock: 0, hits: 0, numbers: Vfx::DamageNumbers.new }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      blows = input[:action] ? 6 : 0
      blows = 1 if input[:auto] && demo[:clock] % 12 == 0
      blows.times { strike(demo) }
      Vfx::DamageNumbers.tick(demo[:numbers])

      Stage.draw(args.outputs)
      args.outputs.primitives << Stage.blob({ x: 570, y: Stage::GROUND, w: 140, h: 140 }, Stage::RED)
      args.outputs.primitives << Vfx::DamageNumbers.labels(demo[:numbers])
    end

    def self.strike(demo)
      demo[:hits] += 1
      x = 600 + (rand * 80)
      y = Stage::GROUND + 150
      if demo[:hits] % 5 == 0
        Vfx::DamageNumbers.pop(demo[:numbers], x: x, y: y, text: "#{30 + (rand * 30).to_i}!", size: 52, color: Stage::YELLOW, rise: 4.2)
      else
        Vfx::DamageNumbers.pop(demo[:numbers], x: x, y: y, text: 4 + (rand * 16).to_i, drift: 1.6)
      end
    end
  end
end
