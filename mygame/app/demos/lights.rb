module Demos
  # A dark scene with a torch, a lamp and a light that follows the pointer.
  module Lights
    ID = "lights".freeze
    TITLE = "Light map".freeze
    BLURB = "Lights are added onto a dark picture, and that picture is multiplied over the scene. No shader.".freeze
    CONTROLS = "Move the pointer: carry the light".freeze
    SHOT_AT = 40

    def self.setup
      { clock: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      clock = demo[:clock]
      carried = input[:pointer] || { x: 640 + (380 * Math.sin(clock * 0.02)), y: 420 + (130 * Math.sin(clock * 0.031)) }
      lights = [{ x: carried[:x], y: carried[:y], radius: 240, r: 255, g: 244, b: 220 },
                { x: 345, y: Stage::GROUND + 120, radius: 190 * Vfx::Lights.flicker(clock), r: 255, g: 150, b: 60 },
                { x: 1000, y: 460, radius: 170, r: 90, g: 220, b: 255 }]

      Stage.draw(args.outputs)
      # Daylight over the gallery's night scene, so there is something to darken.
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 170, g: 185, b: 230, a: 110 }
      args.outputs.primitives << Stage.cast(clock)
      args.outputs.primitives << Vfx::Lights.draw(args.outputs, lights, ambient: [44, 48, 84])
    end
  end
end
