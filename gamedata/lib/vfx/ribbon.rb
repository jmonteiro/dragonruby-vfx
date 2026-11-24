# Ribbon trail: a smooth tapering streak behind a moving point.
#
# The trail remembers where the point has been and joins those places into a
# band of triangles, full width at the head and a point at the tail, fading as
# it goes. Use it for sword swings, projectiles and anything that streaks.
#
#   args.state.ribbon ||= Vfx::Ribbon.new
#   Vfx::Ribbon.tick(args.state.ribbon, sword_tip_x, sword_tip_y)   # no x, y: the trail runs out
#   args.outputs.primitives << Vfx::Ribbon.sprites(args.state.ribbon, color: [255, 240, 180])
#
# Technique: the swipe trail made of a triangle strip (as in libGDX finger-swipe
# demos and every engine's "trail renderer"). Written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module Ribbon
    # A triangle of plain colour: the engine's white pixel, with its corners named.
    WHITE = { path: :solid, source_x: 0, source_y: 0, source_x2: 1, source_y2: 0, source_x3: 0, source_y3: 1 }.freeze

    # length: how many past positions are kept (frames of tail). width: at the head, in pixels.
    def self.new(length: 18, width: 26)
      { points: [], length: [length, 2].max, width: width }
    end

    # Call once a frame with where the point is now. Without a position the
    # tail catches up with the head and the ribbon disappears. It counts whole
    # frames: skip the call while the game is frozen.
    def self.tick(ribbon, x = nil, y = nil)
      points = ribbon[:points]
      x ? points.unshift([x, y]) : points.pop
      points.pop while points.length > ribbon[:length]
      ribbon
    end

    # Two triangles for each stretch of the trail. blendmode 2 makes it glow.
    def self.sprites(ribbon, color: [255, 255, 255], alpha: 230, blendmode: 1)
      edges = edges(ribbon)
      last = edges.length - 1
      shapes = []
      last.times do |index|
        near = edges[index]
        far = edges[index + 1]
        ink = WHITE.merge(r: color[0], g: color[1], b: color[2], blendmode: blendmode,
                          a: alpha * (1 - (index.to_f / last)))
        shapes << ink.merge(x: near[0], y: near[1], x2: near[2], y2: near[3], x3: far[0], y3: far[1])
        shapes << ink.merge(x: near[2], y: near[3], x2: far[2], y2: far[3], x3: far[0], y3: far[1])
      end
      shapes
    end

    # For each remembered position, the two sides of the band there:
    # [left x, left y, right x, right y]. The band narrows to nothing at the tail.
    def self.edges(ribbon)
      points = ribbon[:points]
      last = points.length - 1
      return [] if last < 1

      nx = 0.0
      ny = 0.0
      Array.new(points.length) do |index|
        ahead = points[[index - 1, 0].max]
        behind = points[[index + 1, last].min]
        dx = ahead[0] - behind[0]
        dy = ahead[1] - behind[1]
        length = Math.sqrt((dx * dx) + (dy * dy))
        if length > 0 # standing still keeps the last direction
          nx = -dy / length
          ny = dx / length
        end
        half = ribbon[:width] / 2.0 * (1 - (index.to_f / last))
        x, y = points[index]
        [x + (nx * half), y + (ny * half), x - (nx * half), y - (ny * half)]
      end
    end
  end
end
