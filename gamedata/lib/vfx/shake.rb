# Trauma-based screen shake.
#
# Hits add "trauma" (0..1). Trauma drains at a steady rate, and the shake is
# trauma squared, so small hits barely move the screen and big ones throw it.
# The offsets come from smooth noise, not from random numbers, so the screen
# sways instead of jittering, and the same shake looks the same at any speed.
#
#   args.state.shake ||= Vfx::Shake.new
#   Vfx::Shake.add(args.state.shake, 0.4) if hit
#   Vfx::Shake.tick(args.state.shake)
#   args.outputs.sprites << Vfx::Shake.apply(args.state.shake, { x: 0, y: 0, w: 1280, h: 720, path: :scene })
#
# Technique: Squirrel Eiserloh, "Math for Game Programmers: Juicing Your
# Cameras With Math" (GDC 2016). Written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module Shake
    # max_x, max_y: furthest offset in pixels. max_angle: furthest tilt in degrees.
    # decay: trauma lost per second. speed: how fast the noise moves, per frame.
    # power: 2 is the classic square; 3 makes small hits even quieter.
    def self.new(max_x: 28, max_y: 28, max_angle: 3.0, decay: 1.0, speed: 0.4, power: 2, seed: 0)
      { trauma: 0.0, time: 0.0, x: 0.0, y: 0.0, angle: 0.0, amount: 0.0,
        max_x: max_x, max_y: max_y, max_angle: max_angle, decay: decay, speed: speed, power: power, seed: seed }
    end

    # Adds trauma. 0.2 is a tap, 0.5 a solid hit, 1.0 the worst the screen can take.
    def self.add(shake, amount)
      shake[:trauma] = (shake[:trauma] + amount).clamp(0.0, 1.0)
      shake
    end

    # Call once a frame. Fills :x, :y and :angle, then drains trauma.
    # Pass 0 as the time scale to hold the shake still, e.g. during a hit stop.
    def self.tick(shake, time_scale = 1.0)
      return shake if time_scale == 0

      shake[:time] += shake[:speed] * time_scale
      amount = shake[:trauma]**shake[:power]
      shake[:amount] = amount
      shake[:x] = shake[:max_x] * amount * noise(shake[:time], shake[:seed])
      shake[:y] = shake[:max_y] * amount * noise(shake[:time], shake[:seed] + 1)
      shake[:angle] = shake[:max_angle] * amount * noise(shake[:time], shake[:seed] + 2)
      shake[:trauma] = [shake[:trauma] - (shake[:decay] * time_scale / 60.0), 0.0].max
      shake
    end

    # A copy of the sprite moved and tilted by the shake. The shake uncovers
    # what lies beyond the sprite's edges: scaling the scene up 5% hides small
    # shakes; for the full default shake draw the scene to a render target
    # larger than the screen, or lower max_angle.
    def self.apply(shake, sprite)
      sprite.merge(x: sprite[:x] + shake[:x], y: sprite[:y] + shake[:y],
                   angle: (sprite[:angle] || 0) + shake[:angle])
    end

    # Smooth noise between -1 and 1; `channel` picks an unrelated curve.
    def self.noise(time, channel)
      whole = time.floor
      part = time - whole
      blend = part * part * (3 - (2 * part))
      from = scatter(whole, channel)
      to = scatter(whole + 1, channel)
      ((from + ((to - from) * blend)) * 2) - 1
    end

    def self.scatter(whole, channel)
      value = Math.sin((whole * 127.1) + (channel * 311.7)) * 43_758.5453
      value - value.floor
    end
  end
end
