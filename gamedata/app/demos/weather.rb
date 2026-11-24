module Demos
  # Rain, then snow, over the same scene.
  module Weather
    ID = "weather".freeze
    TITLE = "Rain and snow".freeze
    BLURB = "Every drop has a depth: near ones are bigger, faster, brighter and land nearer. Rain leans as it falls, and splashes.".freeze
    CONTROLS = "Click or SPACE: rain or snow".freeze
    SHOT_AT = 40
    FILM_FOR = 360

    def self.setup
      { clock: 0, kind: :rain, weather: make(:rain) }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      if input[:action] || (input[:auto] && demo[:clock] % 180 == 0)
        demo[:kind] = demo[:kind] == :rain ? :snow : :rain
        demo[:weather] = make(demo[:kind])
      end
      Vfx::Weather.tick(demo[:weather])

      Stage.draw(args.outputs)
      args.outputs.primitives << Stage.cast(demo[:clock])
      # An overcast sky: the weather shows better, and feels wetter, on a dimmed scene.
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 10, g: 16, b: 34, a: 90 }
      args.outputs.primitives << Vfx::Weather.sprites(demo[:weather])
      args.outputs.primitives << Stage.text(40, 628, "Vfx::Weather.new(:#{demo[:kind]}, ground: #{Stage::GROUND})", color: Stage::YELLOW)
    end

    # The ground's far edge is the top of the stage's floor; drops land from there down.
    def self.make(kind)
      Vfx::Weather.new(kind, ground: Stage::GROUND, ground_depth: 110)
    end
  end
end
