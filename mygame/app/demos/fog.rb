module Demos
  # An explorer uncovers the map. What it has left behind stays dimmed, and
  # the red creature shows only while it is in view.
  module Fog
    ID = "fog".freeze
    TITLE = "Fog of war".freeze
    BLURB = "A 32x18 grid drawn one pixel per cell and stretched over the map: unseen is black, seen is dim, in view is clear.".freeze
    CONTROLS = "Move the pointer: explore".freeze
    SHOT_AT = 150
    FILM_FOR = 360

    def self.setup
      { clock: 0, fog: Vfx::Fog.new(columns: 32, rows: 18, cell: 40) }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      clock = demo[:clock]
      fog = demo[:fog]
      explorer = input[:pointer] || { x: 640 + (420 * Math.sin(clock * 0.017)), y: 380 + (170 * Math.sin(clock * 0.029)) }
      Vfx::Fog.reveal(fog, explorer[:x], explorer[:y], 170)
      Vfx::Fog.tick(fog)

      prowler = { x: 600 + (300 * Math.sin(clock * 0.011)), y: Stage::GROUND, w: 80, h: 80 }
      Stage.draw(args.outputs)
      args.outputs.primitives << Stage.stars
      args.outputs.primitives << Stage.blob(prowler, Stage::RED) if Vfx::Fog.visible?(fog, prowler[:x] + 40, prowler[:y] + 40)
      args.outputs.primitives << Vfx::Fog.draw(args.outputs, fog)
      args.outputs.primitives << Stage.circle(explorer[:x], explorer[:y], 12, Stage::YELLOW)
    end
  end
end
