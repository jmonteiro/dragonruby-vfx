module Demos
  # Vignette and grain over the scene; a click switches them on and off.
  module Film
    ID = "film".freeze
    TITLE = "Vignette and film grain".freeze
    BLURB = "Two overlays: a sprite that darkens the corners, and noise laid at a new random position every frame.".freeze
    CONTROLS = "Click or SPACE: both, vignette only, grain only, neither".freeze
    SHOT_AT = 12
    FILM_FOR = 80 # grain compresses badly; keep the GIF short

    MODES = [["Both", true, true], ["Vignette only", true, false], ["Grain only", false, true],
             ["Neither", false, false]].freeze

    def self.setup
      { clock: 0, mode: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      demo[:mode] = (demo[:mode] + 1) % MODES.length if input[:action]
      name, vignette, grain = MODES[demo[:mode]]

      Stage.draw(args.outputs)
      args.outputs.primitives << Stage.cast(demo[:clock])
      args.outputs.primitives << Vfx::Film.grain(strength: 0.14) if grain
      args.outputs.primitives << Vfx::Film.vignette(strength: 0.85) if vignette
      args.outputs.primitives << Stage.text(40, 628, name, color: Stage::YELLOW)
    end
  end
end
