module Demos
  # A ball falls and bounces. Each landing adds trauma in proportion to how
  # hard it hit, so one drop shows a big, a medium and a small shake.
  module Shake
    ID = "shake".freeze
    TITLE = "Trauma screen shake".freeze
    BLURB = "Hits add trauma; the shake is trauma squared, on smooth noise. Small hits whisper, big ones throw the screen.".freeze
    CONTROLS = "Click or SPACE: drop the ball".freeze
    SHOT_AT = 77
    FILM_FOR = 200

    def self.setup
      { shake: Vfx::Shake.new, ball: nil, rest: 0, drops: 0 }
    end

    def self.tick(args, demo, input)
      ball = demo[:ball]
      demo[:rest] += 1 if ball.nil? || ball[:resting]
      if input[:action] || (input[:auto] && demo[:rest] > 40)
        demo[:drops] += 1
        ball = demo[:ball] = { x: 400 + ((demo[:drops] * 230) % 560), y: 640.0, vy: 0.0, resting: false }
        demo[:rest] = 0
      end

      fall(ball, demo[:shake]) if ball && !ball[:resting]
      Vfx::Shake.tick(demo[:shake])

      scene = args.outputs[:scene]
      scene.w = Stage::W
      scene.h = Stage::H
      Stage.draw(scene)
      scene.primitives << Stage.circle(ball[:x], ball[:y] + 36, 36, Stage::YELLOW) if ball

      # 5% larger than the screen, so the tilted edges stay out of sight.
      args.outputs.primitives << Vfx::Shake.apply(demo[:shake], { x: -32, y: -18, w: 1344, h: 756, path: :scene })
      args.outputs.primitives << Stage.bar(40, 620, "trauma", demo[:shake][:trauma], Stage::TEAL)
      args.outputs.primitives << Stage.bar(40, 590, "shake = trauma^2", demo[:shake][:amount], Stage::RED)
    end

    def self.fall(ball, shake)
      ball[:vy] -= 0.9
      ball[:y] += ball[:vy]
      return if ball[:y] > Stage::GROUND

      impact = -ball[:vy]
      ball[:y] = Stage::GROUND
      Vfx::Shake.add(shake, impact / 32.0)
      if impact > 4
        ball[:vy] = impact * 0.45
      else
        ball[:vy] = 0.0
        ball[:resting] = true
      end
    end
  end
end
