module Demos
  # The scene behind the glass of an old television.
  module Crt
    ID = "crt".freeze
    PRO = true
    TITLE = "CRT".freeze
    BLURB = "A fragment shader: the glass bulges, scanlines split the rows, colours fringe, corners go dark.".freeze
    CONTROLS = "Move the pointer left and right: how curved the glass is".freeze
    SHOT_AT = 30

    def self.setup
      { clock: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      curve = input[:pointer] ? input[:pointer][:x] / 1280.0 * 0.4 : 0.12
      scene = Stage.scene(args, demo[:clock])
      scene.shader = Vfx::Crt.shader(curve: curve)
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
    end
  end
end
