module Demos
  # A creature burns away and comes back, over and over.
  module Dissolve
    ID = "dissolve".freeze
    PRO = true
    TITLE = "Dissolve with burn edge".freeze
    BLURB = "A fragment shader: noise decides the order pixels vanish in, and the ones about to go glow.".freeze
    CONTROLS = "Move the pointer left and right: how far gone".freeze
    SHOT_AT = 60

    def self.setup
      { clock: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      # There and back again, with a rest at each end.
      swing = 0.5 - (0.5 * Math.cos(demo[:clock] * 0.035))
      progress = input[:pointer] ? input[:pointer][:x] / 1280.0 : ((swing * 1.4) - 0.2).clamp(0.0, 1.0)

      Stage.draw(args.outputs)
      ghost = args.outputs[:ghost]
      ghost.w = 320
      ghost.h = 320
      ghost.background_color = [0, 0, 0, 0]
      ghost.primitives << { x: 0, y: 0, w: 320, h: 320, path: "sprites/demo/critter.png" }
      ghost.shader = Vfx::Dissolve.shader(progress, seed: 3)
      args.outputs.primitives << { x: 480, y: Stage::GROUND + 20, w: 320, h: 320, path: :ghost }
      args.outputs.primitives << Stage.text(40, 628, "progress: #{(progress * 100).round}%", color: Stage::GREY)
    end
  end
end
