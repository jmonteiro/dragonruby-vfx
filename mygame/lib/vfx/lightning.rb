# Lightning: a jagged bolt between two points, with branches.
#
# Midpoint displacement: take the straight line, push its middle sideways by a
# random amount, and do the same to each half, again and again. `bolt` returns
# the pieces; `sprites` draws them as glowing additive lines. A bolt is a still
# picture: make a new one every two or three frames while the strike lasts and
# it crackles.
#
#   pieces = Vfx::Lightning.bolt(640, 700, target_x, target_y)
#   args.outputs.primitives << Vfx::Lightning.sprites(pieces, alpha: 255 * args.state.strike)
#
# Technique: midpoint displacement, as in Michael Hoffman's "How to Generate
# Shockingly Good 2D Lightning Effects" (2013). Written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module Lightning
    # jagged: how far a middle is pushed, as a fraction of its piece (0.1 nearly
    # straight, 0.35 wild). detail: how many times pieces are halved; 5 gives 32.
    # branches: chance, 0 to 1, that a joint grows a side bolt.
    # seed: a whole number for the same bolt every time; leave out for a new one.
    # Returns Hashes with x1, y1, x2, y2 and weight (1 the main bolt, less for branches).
    def self.bolt(x1, y1, x2, y2, jagged: 0.22, detail: 5, branches: 0.25, seed: nil)
      pieces = []
      grow(pieces, x1, y1, x2, y2, detail, jagged, branches, 1.0, seed ? dice(seed) : -> { rand })
      pieces
    end

    # Two additive lines per piece: a thin core and a wide faint glow.
    def self.sprites(pieces, width: 4, color: [190, 220, 255], alpha: 255)
      pieces.flat_map do |piece|
        thick = width * piece[:weight]
        [line(piece, thick * 5, color, alpha * 0.2), line(piece, thick, color, alpha)]
      end
    end

    def self.grow(pieces, x1, y1, x2, y2, detail, jagged, branches, weight, random)
      if detail <= 0
        pieces << { x1: x1, y1: y1, x2: x2, y2: y2, weight: weight }
        return
      end

      dx = x2 - x1
      dy = y2 - y1
      push = (random.call - 0.5) * 2 * jagged
      mx = ((x1 + x2) / 2.0) - (dy * push)
      my = ((y1 + y2) / 2.0) + (dx * push)
      grow(pieces, x1, y1, mx, my, detail - 1, jagged, branches, weight, random)
      grow(pieces, mx, my, x2, y2, detail - 1, jagged, branches, weight, random)
      return unless random.call < branches

      # A side bolt: from the joint, onwards and a little to one side, thinner.
      turn = (random.call - 0.5) * 1.2
      bx = mx + (((dx * Math.cos(turn)) - (dy * Math.sin(turn))) * 0.45)
      by = my + (((dx * Math.sin(turn)) + (dy * Math.cos(turn))) * 0.45)
      grow(pieces, mx, my, bx, by, detail - 1, jagged, 0, weight * 0.5, random)
    end

    # A solid rectangle from one end of the piece to the other.
    def self.line(piece, thick, color, alpha)
      dx = piece[:x2] - piece[:x1]
      dy = piece[:y2] - piece[:y1]
      { x: piece[:x1], y: piece[:y1] - (thick / 2.0), w: Math.sqrt((dx * dx) + (dy * dy)), h: thick,
        angle: Math.atan2(dy, dx) * 180 / Math::PI, angle_anchor_x: 0, angle_anchor_y: 0.5,
        path: :solid, r: color[0], g: color[1], b: color[2], a: alpha, blendmode: 2 }
    end

    # Repeatable random numbers from 0 to 1 (Park-Miller).
    def self.dice(seed)
      state = (seed % 2_147_483_646) + 1
      lambda do
        state = (state * 48_271) % 2_147_483_647
        state / 2_147_483_647.0
      end
    end
  end
end
