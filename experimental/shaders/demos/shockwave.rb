module Demos
  # Rings spread from blast after blast.
  module Shockwave
    ID = "shockwave".freeze
    PRO = true
    TITLE = "Shockwave".freeze
    BLURB = "A fragment shader: pixels near the ring are read from nearer the centre, so the picture is pushed outwards.".freeze
    CONTROLS = "Click: blast at the pointer".freeze
    SHOT_AT = 34

    def self.setup
      { clock: 0, blasts: 0, wave: nil }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      if input[:action]
        demo[:wave] = { x: input[:mouse].x, y: input[:mouse].y, radius: 0.0 }
      elsif input[:auto] && demo[:clock] % 80 == 20
        demo[:blasts] += 1
        demo[:wave] = { x: 340 + ((demo[:blasts] * 420) % 700), y: 380, radius: 0.0 }
      end

      scene = Stage.scene(args, demo[:clock])
      wave = demo[:wave]
      if wave
        wave[:radius] += 14
        fading = 1 - (wave[:radius] / 900.0)
        scene.shader = Vfx::Shockwave.shader(wave[:x], wave[:y], wave[:radius], strength: 36 * fading)
        demo[:wave] = nil if fading <= 0
      else
        scene.shader = nil
      end
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
    end
  end
end
