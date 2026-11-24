module Demos
  # Shockwaves cross the scene; between them the pointer carries a lens.
  module Warp
    ID = "warp".freeze
    TITLE = "Mesh warp: shockwave, lens".freeze
    BLURB = "The scene drawn as a 32x18 grid of triangles whose corners move. Coarser than a shader, but it runs everywhere.".freeze
    CONTROLS = "Click: shockwave at the pointer    Move the pointer: lens".freeze
    SHOT_AT = 38

    def self.setup
      { clock: 0, waves: 0, wave: nil }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      if input[:action]
        demo[:wave] = { x: input[:mouse].x, y: input[:mouse].y, radius: 0.0 }
      elsif input[:auto] && demo[:clock] % 80 == 20
        demo[:waves] += 1
        demo[:wave] = { x: 340 + ((demo[:waves] * 420) % 700), y: 380, radius: 0.0 }
      end

      Stage.scene(args, demo[:clock])
      wave = demo[:wave]
      if wave
        wave[:radius] += 14
        fading = 1 - (wave[:radius] / 900.0)
        args.outputs.primitives << Vfx::Warp.shockwave(:scene, wave[:x], wave[:y], wave[:radius], amplitude: 34 * fading)
        demo[:wave] = nil if fading <= 0
      elsif input[:pointer]
        args.outputs.primitives << Vfx::Warp.bulge(:scene, input[:pointer][:x], input[:pointer][:y], 240, strength: 0.6)
      else
        args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
      end
    end
  end
end
