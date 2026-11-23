# Particles: bursts and streams of small sprites that move, shrink and fade.
#
# `emit` adds particles; each one is an ordinary sprite Hash with a few extra
# keys (velocity, age), so `sprites` hands them straight to the renderer.
# Numbers that should vary take a Range: speed: 2..6 gives each particle its own.
#
#   args.state.sparks ||= Vfx::Particles.new
#   if hit
#     Vfx::Particles.emit(args.state.sparks, x: 640, y: 360, count: 30, speed: 2..8, life: 20..40,
#                         size: 6..12, color: [255, 220, 120], color_end: [255, 60, 30],
#                         gravity: 0.15, blendmode: 2)
#   end
#   Vfx::Particles.tick(args.state.sparks)
#   args.outputs.primitives << Vfx::Particles.sprites(args.state.sparks)
#
# References: HaxeFlixel's FlxEmitter and LittleJS's ParticleEmitter (both MIT)
# for the set of options; written from scratch for DragonRuby.
# This file stands alone: copy it and require it. It draws sprites/vfx/circle.png
# unless you pass another `path:`.
module Vfx
  module Particles
    # max: the most particles alive at once; beyond it the oldest are dropped.
    def self.new(max: 1000)
      { particles: [], max: [max, 0].max }
    end

    # x, y: where they start. count: how many.
    # angle, spread: direction in degrees (90 is up) and the width of the cone; 360 is all around.
    # speed: pixels per frame. life: frames. size, size_end: diameter at birth and at death.
    # color, color_end: [r, g, b] at birth and at death. alpha: opacity at birth; it fades to 0.
    # gravity: pulled down this much per frame (negative rises). drag: speed kept each frame.
    # spin: degrees per frame. blendmode: 1 normal, 2 additive (fire, sparks, magic).
    def self.emit(emitter, x:, y:, count: 1, angle: 90, spread: 360, speed: 3, life: 40, size: 10, size_end: 0,
                  color: [255, 255, 255], color_end: nil, alpha: 255, gravity: 0, drag: 1.0, spin: 0,
                  path: "sprites/vfx/circle.png", blendmode: 1)
      particles = emitter[:particles]
      count.times do
        direction = (angle + ((rand - 0.5) * spread)) * Math::PI / 180
        pace = pick(speed)
        side = pick(size)
        particles << { x: x, y: y, w: side, h: side, anchor_x: 0.5, anchor_y: 0.5, path: path, blendmode: blendmode,
                       r: color[0], g: color[1], b: color[2], a: alpha, angle: 0,
                       vx: Math.cos(direction) * pace, vy: Math.sin(direction) * pace,
                       age: 0.0, life: pick(life).to_f, size: side, size_end: size_end, color: color,
                       color_end: color_end, alpha: alpha, gravity: gravity, drag: drag, spin: pick(spin) }
      end
      particles.shift while particles.length > emitter[:max]
      emitter
    end

    # Call once a frame: moves, ages and removes particles.
    def self.tick(emitter, time_scale = 1.0)
      emitter[:particles].reject! do |particle|
        particle[:age] += time_scale
        next true if particle[:age] >= particle[:life]

        move(particle, time_scale)
        fade(particle, particle[:age] / particle[:life])
        false
      end
      emitter
    end

    # The live particles, ready for args.outputs.primitives or .sprites.
    def self.sprites(emitter)
      emitter[:particles]
    end

    def self.count(emitter)
      emitter[:particles].length
    end

    def self.move(particle, time_scale)
      particle[:vy] -= particle[:gravity] * time_scale
      drag = particle[:drag]**time_scale
      particle[:vx] *= drag
      particle[:vy] *= drag
      particle[:x] += particle[:vx] * time_scale
      particle[:y] += particle[:vy] * time_scale
      particle[:angle] += particle[:spin] * time_scale
    end

    # Size, opacity and colour for how much of its life a particle has spent,
    # from 0 at birth to 1 at death.
    def self.fade(particle, spent)
      size = particle[:size] + ((particle[:size_end] - particle[:size]) * spent)
      particle[:w] = size
      particle[:h] = size
      particle[:a] = particle[:alpha] * (1 - spent)
      to = particle[:color_end]
      return unless to

      from = particle[:color]
      particle[:r] = from[0] + ((to[0] - from[0]) * spent)
      particle[:g] = from[1] + ((to[1] - from[1]) * spent)
      particle[:b] = from[2] + ((to[2] - from[2]) * spent)
    end

    # A number as it is, or a random point inside a Range.
    def self.pick(value)
      value.is_a?(Range) ? value.begin + (rand * (value.end - value.begin)) : value
    end
  end
end
