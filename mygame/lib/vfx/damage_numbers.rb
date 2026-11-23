# Damage numbers: text that pops out of a hit, rises, slows and fades.
#
#   args.state.numbers ||= Vfx::DamageNumbers.new
#   Vfx::DamageNumbers.pop(args.state.numbers, x: enemy_x, y: enemy_y, text: 12) if hit
#   Vfx::DamageNumbers.pop(args.state.numbers, x: enemy_x, y: enemy_y, text: "38!", size: 44, color: [255, 204, 77]) if crit
#   Vfx::DamageNumbers.tick(args.state.numbers)
#   args.outputs.primitives << Vfx::DamageNumbers.labels(args.state.numbers)
#
# Technique: the floating combat text of action RPGs. Written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module DamageNumbers
    def self.new
      { live: [] }
    end

    # text: anything; it is shown with to_s. size: pixels. life: frames.
    # rise: speed upwards at birth. drift: how far sideways a number may wander.
    # gravity: how fast the rise slows; above rise / life the number falls back.
    def self.pop(numbers, x:, y:, text:, color: [255, 255, 255], size: 30, life: 55, rise: 3.2, drift: 1.0, gravity: 0.07)
      numbers[:live] << { x: x, y: y, vx: (rand - 0.5) * 2 * drift, vy: rise, text: text.to_s, color: color,
                          size: size, age: 0.0, life: life.to_f, gravity: gravity }
      numbers
    end

    # Call once a frame.
    def self.tick(numbers, time_scale = 1.0)
      numbers[:live].reject! do |number|
        number[:age] += time_scale
        number[:x] += number[:vx] * time_scale
        number[:y] += number[:vy] * time_scale
        number[:vy] -= number[:gravity] * time_scale
        number[:age] >= number[:life]
      end
      numbers
    end

    # Two labels per number: a dark copy underneath so it reads on anything.
    def self.labels(numbers)
      numbers[:live].flat_map do |number|
        spent = number[:age] / number[:life]
        size = number[:size] * swell(number[:age])
        alpha = 255 * [(1 - spent) / 0.4, 1].min # fades over the last 40% of its life
        r, g, b = number[:color]
        label = { x: number[:x], y: number[:y], text: number[:text], size_px: size, anchor_x: 0.5, anchor_y: 0.5,
                  r: r, g: g, b: b, a: alpha, primitive_marker: :label }
        [label.merge(x: number[:x] + 2, y: number[:y] - 2, r: 0, g: 0, b: 0, a: alpha * 0.7), label]
      end
    end

    # Born at 1.6 times its size, settling to 1 over six frames: the "pop".
    def self.swell(age)
      age < 6 ? 1.6 - (age * 0.1) : 1.0
    end
  end
end
