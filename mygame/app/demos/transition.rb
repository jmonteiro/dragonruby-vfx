module Demos
  # Two scenes take turns; each change uses the next kind of transition.
  module Transition
    ID = "transition".freeze
    TITLE = "Scene transitions".freeze
    BLURB = "Each transition covers the screen and uncovers it. The scene is swapped on the one frame it is fully covered.".freeze
    CONTROLS = "Click or SPACE: next transition    1 iris   2 tiles   3 wipe   4 blinds   5 fade".freeze
    SHOT_AT = 36
    FILM_FOR = 470

    ORDER = [:iris, :tiles, :wipe, :blinds, :fade].freeze

    def self.setup
      { transition: Vfx::Transition.new, clock: 0, next: 0, last: nil, second: false }
    end

    def self.tick(args, demo, input)
      transition = demo[:transition]
      demo[:clock] += 1
      chosen = input[:number] && ORDER[input[:number] - 1]
      chosen ||= ORDER[demo[:next]] if input[:action] || (input[:auto] && demo[:clock] % 90 == 20)
      if chosen && !Vfx::Transition.active?(transition)
        demo[:last] = chosen
        demo[:next] = (ORDER.index(chosen) + 1) % ORDER.length
        Vfx::Transition.start(transition, chosen, x: 345, y: Stage::GROUND + 45)
      end
      Vfx::Transition.tick(transition)
      demo[:second] = !demo[:second] if Vfx::Transition.midpoint?(transition)

      Stage.draw(args.outputs)
      args.outputs.primitives << Stage.cast(demo[:second] ? demo[:clock] + 200 : demo[:clock])
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 255, g: 110, b: 60, a: 70 } if demo[:second]
      args.outputs.primitives << Stage.text(640, 600, demo[:second] ? "Scene B" : "Scene A", size: 40, align: 0.5)
      args.outputs.primitives << Vfx::Transition.overlay(transition)
      return unless demo[:last]

      args.outputs.primitives << Stage.text(40, 628, "Vfx::Transition.start(transition, :#{demo[:last]})", color: Stage::YELLOW)
    end
  end
end
