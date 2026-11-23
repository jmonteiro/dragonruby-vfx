module Demos
  # Splats pile up on the ground. However many there are, the layer is one sprite.
  module Decals
    ID = "decals".freeze
    TITLE = "Decals".freeze
    BLURB = "Each mark is drawn once into a render target that is never cleared. A thousand marks cost one sprite.".freeze
    CONTROLS = "Click: splat at the pointer    1: wipe clean".freeze
    SHOT_AT = 200
    FILM_FOR = 300

    COLORS = [Stage::RED, Stage::TEAL, Stage::YELLOW].freeze

    def self.setup
      { clock: 0, marks: 0, decals: Vfx::Decals.new }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      if input[:number] == 1 || demo[:marks] > 400
        Vfx::Decals.clear(demo[:decals])
        demo[:marks] = 0
      end
      if input[:action]
        splat(demo, input[:mouse].x, input[:mouse].y)
      elsif input[:auto] && demo[:clock] % 6 == 0
        splat(demo, 80 + ((demo[:marks] * 337) % 1120), 100 + ((demo[:marks] * 211) % 520))
      end

      Stage.draw(args.outputs)
      args.outputs.primitives << Vfx::Decals.draw(args.outputs, demo[:decals])
      args.outputs.primitives << Stage.text(40, 628, "#{demo[:marks]} marks, 1 sprite", color: Stage::GREY)
    end

    # One big blot and a few small ones thrown around it.
    def self.splat(demo, x, y)
      demo[:marks] += 1
      color = COLORS[demo[:marks] % COLORS.length]
      Vfx::Decals.stamp(demo[:decals], Stage.circle(x, y, 22, color, 200))
      7.times do
        reach = 20 + (rand * 50)
        angle = rand * 6.28
        drop = Stage.circle(x + (Math.cos(angle) * reach), y + (Math.sin(angle) * reach), 3 + (rand * 9), color, 200)
        Vfx::Decals.stamp(demo[:decals], drop)
      end
    end
  end
end
