module Demos
  # Three looks from the same strips: a reflection, a heat haze and a glitch.
  module Slices
    ID = "slices".freeze
    TITLE = "Row slices: reflection, haze, glitch".freeze
    BLURB = "The scene redrawn as thin horizontal strips, each moved sideways. No shader.".freeze
    CONTROLS = "Click or SPACE: next look    1 reflection   2 wave   3 glitch".freeze
    SHOT_AT = 40
    FILM_FOR = 420

    LOOKS = ["reflection", "wave", "glitch"].freeze

    def self.setup
      { clock: 0, look: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      clock = demo[:clock]
      demo[:look] = input[:number] - 1 if input[:number] && input[:number] <= LOOKS.length
      demo[:look] = (demo[:look] + 1) % LOOKS.length if input[:action] || (input[:auto] && clock % 140 == 0)

      Stage.scene(args, clock)
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
      case LOOKS[demo[:look]]
      when "reflection"
        # The ground becomes water: a dark pool, then the mirrored strips.
        args.outputs.primitives << { x: 0, y: 0, w: 1280, h: Stage::GROUND, path: :solid, r: 16, g: 24, b: 48 }
        args.outputs.primitives << Vfx::Slices.reflection(:scene, clock, water_y: Stage::GROUND, depth: Stage::GROUND)
      when "wave"
        args.outputs.primitives << Vfx::Slices.wave(:scene, clock, y: Stage::GROUND, h: 300, amplitude: 5, wavelength: 46)
      when "glitch"
        # A burst of glitch every second or so, with new bands every fourth frame.
        args.outputs.primitives << Vfx::Slices.glitch(:scene, clock.idiv(4)) if clock % 50 < 22
      end
      args.outputs.primitives << Stage.text(40, 628, "Vfx::Slices.#{LOOKS[demo[:look]]}", color: Stage::YELLOW)
    end
  end
end
