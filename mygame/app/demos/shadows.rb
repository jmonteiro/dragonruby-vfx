module Demos
  # A light moves among pillars, and the pillars cut its glow.
  module Shadows
    ID = "shadows".freeze
    TITLE = "Shadow-casting light".freeze
    BLURB = "Rays to the ends of every wall give the shape the light can reach; its glow is drawn only inside that shape.".freeze
    CONTROLS = "Move the pointer: carry the light".freeze
    SHOT_AT = 60

    PILLARS = [[260, 430, 90, 90], [520, 250, 70, 160], [760, 470, 130, 60], [980, 300, 80, 80], [640, 520, 60, 60]].freeze
    # Each pillar's four sides as [x1, y1, x2, y2].
    WALLS = PILLARS.flat_map do |x, y, w, h|
      [[x, y, x + w, y], [x + w, y, x + w, y + h], [x + w, y + h, x, y + h], [x, y + h, x, y]]
    end.freeze

    def self.setup
      { clock: 0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      clock = demo[:clock]
      carried = input[:pointer] || { x: 640 + (420 * Math.sin(clock * 0.017)), y: 400 + (170 * Math.sin(clock * 0.027)) }
      lamp = { x: carried[:x], y: carried[:y], radius: 420, r: 255, g: 236, b: 200 }

      Stage.draw(args.outputs)
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 170, g: 185, b: 230, a: 110 }
      args.outputs.primitives << PILLARS.map { |x, y, w, h| { x: x, y: y, w: w, h: h, path: :solid, r: 70, g: 80, b: 120 } }
      glow = Vfx::Shadows.light(args.outputs, lamp, WALLS)
      args.outputs.primitives << Vfx::Lights.draw(args.outputs, [], ambient: [34, 38, 70], extra: [glow])
      args.outputs.primitives << Stage.circle(lamp[:x], lamp[:y], 8, Stage::YELLOW)
    end
  end
end
