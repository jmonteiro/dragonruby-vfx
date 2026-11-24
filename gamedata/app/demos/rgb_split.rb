module Demos
  # The scene's red and blue slide apart on every jolt and settle back.
  module RgbSplit
    ID = "rgb_split".freeze
    TITLE = "RGB split".freeze
    BLURB = "The scene drawn three times, in red, green and blue, added together. Slide red and blue apart for the fringe.".freeze
    CONTROLS = "Click or SPACE: jolt".freeze
    SHOT_AT = 24

    def self.setup
      { clock: 0, jolt: 0.0, angle: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      if input[:action] || (input[:auto] && demo[:clock] % 70 == 20)
        demo[:jolt] = 1.0
        demo[:angle] += 50
      end
      demo[:jolt] *= 0.9
      offset = 3 + (demo[:jolt] * 24)

      Stage.scene(args, demo[:clock])
      args.outputs.primitives << Vfx::RgbSplit.sprites(:scene, offset, angle: demo[:angle])
      args.outputs.primitives << Stage.text(40, 628, "offset: #{offset.round} px", color: Stage::GREY)
    end
  end
end
