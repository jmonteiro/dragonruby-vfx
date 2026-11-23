module Demos
  # Two scenes swap along each of the five patterns in turn.
  module LumaWipe
    ID = "luma_wipe".freeze
    PRO = true
    TITLE = "Luma wipe".freeze
    BLURB = "A fragment shader: a pattern says in what order the old scene's pixels give way to the new one's.".freeze
    CONTROLS = "Click or SPACE: next pattern".freeze
    SHOT_AT = 48
    FILM_FOR = 460

    LASTS = 60

    def self.setup
      { clock: 0, pattern: 3, at: nil, second: false }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      demo[:at] = 0 if demo[:at].nil? && (input[:action] || (input[:auto] && demo[:clock] % 90 == 20))

      draw(args, :wipe_old, demo[:second], demo[:clock])
      draw(args, :wipe_new, !demo[:second], demo[:clock])
      pattern = Vfx::LumaWipe::PATTERNS[demo[:pattern]]
      if demo[:at]
        demo[:at] += 1
        args.outputs[:wipe_old].shader = Vfx::LumaWipe.shader(:wipe_new, demo[:at].fdiv(LASTS), pattern: pattern)
        if demo[:at] >= LASTS
          demo[:at] = nil
          demo[:second] = !demo[:second]
          demo[:pattern] = (demo[:pattern] + 1) % Vfx::LumaWipe::PATTERNS.length
        end
      else
        args.outputs[:wipe_old].shader = nil
      end
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :wipe_old }
      args.outputs.primitives << Stage.text(40, 628, "pattern: :#{pattern}", color: Stage::YELLOW)
    end

    def self.draw(args, name, second, clock)
      scene = Stage.scene(args, second ? clock + 200 : clock, name)
      scene.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 255, g: 110, b: 60, a: 70 } if second
      scene.primitives << Stage.text(640, 600, second ? "Scene B" : "Scene A", size: 40, align: 0.5)
    end
  end
end
