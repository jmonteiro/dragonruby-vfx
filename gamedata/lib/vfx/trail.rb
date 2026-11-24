# Afterimage trail: fading copies of a sprite left behind as it moves.
#
# Every few frames the trail keeps a copy of the sprite where it was. The
# copies fade out. It reads as speed: use it for dashes, fast enemies, thrown
# things.
#
#   args.state.trail ||= Vfx::Trail.new
#   Vfx::Trail.tick(args.state.trail, dashing ? hero : nil)   # nil: stop leaving copies
#   args.outputs.primitives << Vfx::Trail.sprites(args.state.trail, color: [72, 202, 180])
#   args.outputs.primitives << hero
#
# References: HaxeFlixel's FlxTrail (flixel-addons, MIT); written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module Trail
    # life: frames a copy lasts. every: frames between copies.
    def self.new(life: 18, every: 2)
      { ghosts: [], life: [life, 1].max, every: [every, 1].max, clock: 0 }
    end

    # Call once a frame with the sprite as it is drawn now, or nil to let the
    # trail die out. It counts whole frames: skip the call while the game is frozen.
    def self.tick(trail, sprite = nil)
      trail[:ghosts].reject! do |ghost|
        ghost[:age] += 1
        ghost[:age] >= trail[:life]
      end
      trail[:ghosts] << sprite.merge(age: 0) if sprite && trail[:clock] % trail[:every] == 0
      trail[:clock] += 1
      trail
    end

    # The copies, oldest first; draw them before the sprite itself.
    # color: tint every copy [r, g, b]. alpha: opacity of a fresh copy. shrink: 0.5 takes a copy down to half
    # size by the end of its life. A sprite's own `a` carries into its copies.
    def self.sprites(trail, color: nil, alpha: 150, shrink: 0.0)
      trail[:ghosts].map do |ghost|
        left = 1.0 - (ghost[:age].to_f / trail[:life])
        scale = 1.0 - (shrink * (1 - left))
        w = ghost[:w] * scale
        h = ghost[:h] * scale
        copy = ghost.merge(a: alpha * left * (ghost[:a] || 255) / 255.0, w: w, h: h,
                           x: ghost[:x] + ((ghost[:w] - w) / 2), y: ghost[:y] + ((ghost[:h] - h) / 2))
        color ? copy.merge(r: color[0], g: color[1], b: color[2]) : copy
      end
    end
  end
end
