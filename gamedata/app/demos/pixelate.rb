module Demos
  # The block size swells and shrinks, or follows the pointer.
  module Pixelate
    ID = "pixelate".freeze
    TITLE = "Pixelate".freeze
    BLURB = "The scene is drawn into a tiny render target and stretched back with no smoothing. No shader.".freeze
    CONTROLS = "Move the pointer left and right: block size".freeze
    SHOT_AT = 40
    FILM_FOR = 160

    def self.setup
      { clock: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      size = if input[:pointer]
               1 + (input[:pointer][:x] / 1280.0 * 47)
             else
               1 + (24 * (0.5 - (0.5 * Math.cos(demo[:clock] * 0.04))))
             end
      size = size.round

      Stage.scene(args, demo[:clock])
      args.outputs.primitives << Vfx::Pixelate.draw(args.outputs, :scene, size)
      args.outputs.primitives << Stage.text(40, 628, "block: #{size} px", color: Stage::GREY)
    end
  end
end
