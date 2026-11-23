module Demos
  # Bolts strike the ground. Each strike is redrawn as a new bolt every third
  # frame while it fades, which is what makes it crackle.
  module Lightning
    ID = "lightning".freeze
    TITLE = "Lightning".freeze
    BLURB = "A straight line with its middle pushed sideways, then each half again, five times over. Redrawn every third frame.".freeze
    CONTROLS = "Click: strike the pointer".freeze
    SHOT_AT = 24

    LASTS = 16

    def self.setup
      { clock: 0, strikes: 0, left: 0, from: 640, to: [640, Stage::GROUND] }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      if input[:action]
        strike(demo, input[:mouse].x, input[:mouse].y)
      elsif input[:auto] && demo[:clock] % 45 == 20
        strike(demo, 260 + ((demo[:strikes] * 310) % 800), Stage::GROUND)
      end

      Stage.draw(args.outputs)
      return if demo[:left] <= 0

      demo[:left] -= 1
      power = demo[:left].to_f / LASTS
      x, y = demo[:to]
      # The seed changes every third frame: a new bolt between the same two points.
      pieces = Vfx::Lightning.bolt(demo[:from], 660, x, y, seed: (demo[:strikes] * 100) + demo[:left].idiv(3))
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 190, g: 220, b: 255, a: 60 * power }
      args.outputs.primitives << Vfx::Lightning.sprites(pieces, alpha: 255 * power)
      args.outputs.primitives << { x: x - 90, y: y - 90, w: 180, h: 180, path: "sprites/vfx/glow.png", blendmode: 2, a: 255 * power }
    end

    def self.strike(demo, x, y)
      demo[:strikes] += 1
      demo[:left] = LASTS
      demo[:to] = [x, y]
      demo[:from] = x + (((demo[:strikes] * 137) % 300) - 150)
    end
  end
end
