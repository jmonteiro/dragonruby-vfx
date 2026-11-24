module Demos
  # Two creatures make the same jump. The left one keeps its shape; the right
  # one stretches on take-off and squashes on landing.
  module Squash
    ID = "squash".freeze
    TITLE = "Squash and stretch".freeze
    BLURB = "A spring deforms the sprite and keeps its area: stretch on take-off, squash on landing. Same jump on both sides.".freeze
    CONTROLS = "Click or SPACE: jump".freeze
    SHOT_AT = 63

    SIZE = 96

    def self.setup
      { clock: 0, y: 0.0, vy: 0.0, body: Vfx::Squash.new }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      grounded = demo[:y] <= 0 && demo[:vy] <= 0
      if grounded && (input[:action] || (input[:auto] && demo[:clock] % 90 == 20))
        demo[:vy] = 17.0
        Vfx::Squash.stretch(demo[:body], 0.3)
      elsif !grounded
        demo[:vy] -= 0.8
        demo[:y] += demo[:vy]
        if demo[:y] <= 0
          demo[:y] = 0.0
          demo[:vy] = 0.0
          Vfx::Squash.squash(demo[:body], 0.4)
        end
      end
      demo[:y] += demo[:vy] if grounded && demo[:vy] > 0
      Vfx::Squash.tick(demo[:body])

      Stage.draw(args.outputs)
      rigid = { x: 420 - (SIZE / 2), y: Stage::GROUND + demo[:y], w: SIZE, h: SIZE }
      soft = Vfx::Squash.apply(demo[:body], rigid.merge(x: 860 - (SIZE / 2)))
      args.outputs.primitives << Stage.blob(rigid, Stage::GREY)
      args.outputs.primitives << Stage.blob(soft, Stage::TEAL)
      args.outputs.primitives << Stage.text(420, 150, "Rigid", color: Stage::GREY, align: 0.5)
      args.outputs.primitives << Stage.text(860, 150, "Vfx::Squash", color: Stage::TEAL, align: 0.5)
    end
  end
end
