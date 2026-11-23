module Demos
  # A point sweeps the screen in arcs and drags a ribbon behind it.
  module Ribbon
    ID = "ribbon".freeze
    TITLE = "Ribbon trail".freeze
    BLURB = "The last 18 positions joined into a band of triangles: full width at the head, a point at the tail.".freeze
    CONTROLS = "Move the pointer: draw with it".freeze
    SHOT_AT = 40

    def self.setup
      { clock: 0, ribbon: Vfx::Ribbon.new(width: 34) }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      clock = demo[:clock]
      tip = input[:pointer] || { x: 640 + (360 * Math.cos(clock * 0.13)), y: 400 + (170 * Math.sin(clock * 0.21)) }
      Vfx::Ribbon.tick(demo[:ribbon], tip[:x], tip[:y])

      Stage.draw(args.outputs)
      args.outputs.primitives << Vfx::Ribbon.sprites(demo[:ribbon], color: Stage::YELLOW, blendmode: 2)
      args.outputs.primitives << Stage.circle(tip[:x], tip[:y], 10, Stage::WHITE)
    end
  end
end
