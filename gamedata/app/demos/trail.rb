module Demos
  # A creature loops around the screen and leaves fading copies of itself.
  module Trail
    ID = "trail".freeze
    TITLE = "Afterimage trail".freeze
    BLURB = "Every other frame the trail keeps a copy of the sprite where it was; the copies fade and shrink.".freeze
    CONTROLS = "Click or SPACE: dash".freeze
    SHOT_AT = 50

    def self.setup
      { trail: Vfx::Trail.new, phase: 0.0, dash: 0, clock: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      demo[:dash] = 45 if input[:action] || (input[:auto] && demo[:clock] % 160 == 100)
      demo[:dash] -= 1 if demo[:dash] > 0
      demo[:phase] += demo[:dash] > 0 ? 0.11 : 0.05
      rect = { x: 595 + (430 * Math.sin(demo[:phase])), y: 380 + (140 * Math.sin(demo[:phase] * 2)), w: 90, h: 90 }

      Vfx::Trail.tick(demo[:trail], rect.merge(path: :solid))
      Stage.draw(args.outputs)
      args.outputs.primitives << Vfx::Trail.sprites(demo[:trail], color: Stage::TEAL, shrink: 0.3)
      args.outputs.primitives << Stage.blob(rect, Stage::TEAL)
    end
  end
end
