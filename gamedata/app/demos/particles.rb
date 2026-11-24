module Demos
  # A fountain, a torch and explosions, all from the one `emit` call.
  module Particles
    ID = "particles".freeze
    TITLE = "Particles".freeze
    BLURB = "One emit call with ranges for speed, life and size. Additive blending makes the fire and sparks glow.".freeze
    CONTROLS = "Click: explosion at the pointer".freeze
    SHOT_AT = 42

    def self.setup
      { emitter: Vfx::Particles.new, clock: 0, bursts: 0 }
    end

    def self.tick(args, demo, input)
      emitter = demo[:emitter]
      demo[:clock] += 1
      fountain(emitter)
      torch(emitter)
      if input[:action]
        explode(emitter, input[:mouse].x, input[:mouse].y)
      elsif input[:auto] && demo[:clock] % 70 == 30
        demo[:bursts] += 1
        explode(emitter, 480 + ((demo[:bursts] * 170) % 400), 430)
      end
      Vfx::Particles.tick(emitter)

      Stage.draw(args.outputs)
      args.outputs.primitives << Vfx::Particles.sprites(emitter)
      args.outputs.primitives << Stage.text(40, 628, "#{Vfx::Particles.count(emitter)} particles", color: Stage::GREY)
    end

    def self.fountain(emitter)
      Vfx::Particles.emit(emitter, x: 260, y: Stage::GROUND, count: 2, angle: 90, spread: 22, speed: 9..12,
                                   life: 60..80, size: 8..12, color: Stage::TEAL, gravity: 0.22)
    end

    def self.torch(emitter)
      Vfx::Particles.emit(emitter, x: 1020, y: Stage::GROUND + 10, count: 2, angle: 90, spread: 50, speed: 1..3,
                                   life: 25..45, size: 20..34, size_end: 2, color: [255, 200, 90],
                                   color_end: [220, 50, 30], gravity: -0.04, blendmode: 2)
    end

    def self.explode(emitter, x, y)
      Vfx::Particles.emit(emitter, x: x, y: y, count: 14, speed: 0.5..2, life: 50..80, size: 24..40, size_end: 80,
                                   color: [120, 125, 140], alpha: 110, gravity: -0.02, drag: 0.97)
      Vfx::Particles.emit(emitter, x: x, y: y, count: 50, speed: 2..10, life: 20..48, size: 6..16,
                                   color: [255, 235, 150], color_end: [255, 70, 30], gravity: 0.15, drag: 0.96,
                                   blendmode: 2)
    end
  end
end
