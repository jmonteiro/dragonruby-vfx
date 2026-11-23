# Squash and stretch on a spring.
#
# One number, :value, says how deformed a thing is: above 0 it is squashed
# (wider and shorter), below 0 stretched (taller and thinner). Width and height
# change together so the area stays the same, which is what makes it read as
# soft instead of resized. A spring pulls the value back to 0 with a wobble.
#
#   args.state.body ||= Vfx::Squash.new
#   Vfx::Squash.squash(args.state.body, 0.4) if landed
#   Vfx::Squash.stretch(args.state.body, 0.3) if jumped
#   Vfx::Squash.tick(args.state.body)
#   args.outputs.sprites << Vfx::Squash.apply(args.state.body, { x: 600, y: 100, w: 80, h: 80, path: "sprites/hero.png" })
#
# Technique: the first of Disney's twelve principles of animation, as shown for
# games in Martin Jonasson and Petri Purho's "Juice it or lose it" (2012).
# Written from scratch. This file stands alone: copy it and require it.
module Vfx
  module Squash
    # The lowest :value allowed, the furthest stretch: a fifth of the width, five
    # times the height.
    LOWEST = -0.8

    # stiffness: how hard the spring pulls back (0.1 lazy, 0.4 snappy).
    # damping: how much speed survives each frame (0.6 settles at once, 0.9 wobbles long).
    def self.new(stiffness: 0.14, damping: 0.8)
      { value: 0.0, velocity: 0.0, stiffness: stiffness, damping: damping }
    end

    # Flattens at once: 0.3 is a landing, 0.6 a heavy fall.
    def self.squash(body, amount = 0.3)
      body[:value] = [amount, LOWEST].max
      body[:velocity] = 0.0
      body
    end

    # Lengthens at once: 0.25 is a jump, 0.4 a dash.
    def self.stretch(body, amount = 0.25)
      squash(body, -amount)
    end

    # A push instead of a jump in value: the thing swells and settles. Good for
    # buttons, pickups and anything that should "pop".
    def self.pop(body, strength = 0.12)
      body[:velocity] += strength
      body
    end

    # Call once a frame.
    def self.tick(body, time_scale = 1.0)
      body[:velocity] = (body[:velocity] - (body[:stiffness] * body[:value] * time_scale)) * (body[:damping]**time_scale)
      body[:value] = [body[:value] + (body[:velocity] * time_scale), LOWEST].max
      body
    end

    # [width scale, height scale] for the current value.
    def self.scale(body)
      wide = 1.0 + body[:value]
      [wide, 1.0 / wide]
    end

    # A copy of the sprite deformed about a fixed point. `x`, `y` are the
    # sprite's bottom-left corner. pin_x 0.5, pin_y 0 keeps the feet planted.
    def self.apply(body, sprite, pin_x: 0.5, pin_y: 0.0)
      wide, tall = scale(body)
      w = sprite[:w] * wide
      h = sprite[:h] * tall
      sprite.merge(x: sprite[:x] + ((sprite[:w] - w) * pin_x), y: sprite[:y] + ((sprite[:h] - h) * pin_y), w: w, h: h)
    end
  end
end
