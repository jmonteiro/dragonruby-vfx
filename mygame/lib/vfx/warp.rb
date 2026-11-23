# Mesh warp: bend the picture. Shockwaves, lens bulges, wobbles.
#
# The scene is drawn as a grid of small triangles instead of one rectangle.
# Each corner of the grid can be moved, and the picture stretches to follow:
# move the corners around a growing ring and it is a shockwave. It is coarser
# than a shader (the bend is only as fine as the grid) but it runs everywhere.
#
#   args.outputs.primitives << Vfx::Warp.shockwave(:scene, blast_x, blast_y, radius)   # radius grows each frame
#   args.outputs.primitives << Vfx::Warp.bulge(:scene, mouse.x, mouse.y, 220, strength: 0.5)
#
# `path` is a render target the size of the screen holding the scene; draw the
# warp instead of the scene, not over it.
#
# Technique: grid deformation, as in cocos2d's grid actions (Ripple3D, Lens3D);
# pixi-filters' ShockwaveFilter (MIT) shows the same look with a shader.
# Written from scratch. This file stands alone: copy it and require it.
module Vfx
  module Warp
    # The scene as columns x rows cells of two triangles each. The block is
    # given a grid corner's x, y and answers [dx, dy], how far to move it.
    # Corners on the outer edge stay put, so the picture's border never opens.
    def self.sprites(path, columns: 32, rows: 18, w: 1280, h: 720)
      corners = Array.new(rows + 1) do |row|
        Array.new(columns + 1) do |column|
          x = w * column.to_f / columns
          y = h * row.to_f / rows
          edge = column == 0 || row == 0 || column == columns || row == rows
          dx, dy = edge ? [0, 0] : yield(x, y)
          [x, y, x + dx, y + dy]
        end
      end
      shapes = []
      rows.times do |row|
        columns.times do |column|
          a = corners[row][column]
          b = corners[row][column + 1]
          c = corners[row + 1][column]
          d = corners[row + 1][column + 1]
          shapes << triangle(path, a, b, c) << triangle(path, b, d, c)
        end
      end
      shapes
    end

    # A ring that pushes the picture outwards as it passes. radius: where the
    # ring is now. width: how thick it is. amplitude: the push, in pixels.
    def self.shockwave(path, x, y, radius, width: 90, amplitude: 26, columns: 32, rows: 18, w: 1280, h: 720)
      sprites(path, columns: columns, rows: rows, w: w, h: h) do |px, py|
        dx = px - x
        dy = py - y
        distance = Math.sqrt((dx * dx) + (dy * dy))
        off = (distance - radius) / width
        next [0, 0] if off.abs >= 1 || distance == 0

        push = Math.cos(off * Math::PI / 2) * amplitude
        [dx / distance * push, dy / distance * push]
      end
    end

    # A lens. strength above 0 swells what is inside `radius` (a fish-eye);
    # below 0 pinches it. Keep it between -0.8 and 0.8.
    def self.bulge(path, x, y, radius, strength: 0.5, columns: 32, rows: 18, w: 1280, h: 720)
      sprites(path, columns: columns, rows: rows, w: w, h: h) do |px, py|
        dx = px - x
        dy = py - y
        near = 1 - (Math.sqrt((dx * dx) + (dy * dy)) / radius)
        near > 0 ? [dx * near * strength, dy * near * strength] : [0, 0]
      end
    end

    # One triangle: drawn at the corners' moved positions, showing the piece
    # of the picture that lies between their original ones.
    def self.triangle(path, a, b, c)
      { path: path, x: a[2], y: a[3], x2: b[2], y2: b[3], x3: c[2], y3: c[3],
        source_x: a[0], source_y: a[1], source_x2: b[0], source_y2: b[1], source_x3: c[0], source_y3: c[1] }
    end
  end
end
