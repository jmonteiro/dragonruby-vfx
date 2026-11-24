# Fog of war on a grid.
#
# The map is a grid of cells. A cell is unseen (black), seen before (dimmed) or
# in view right now (clear). The fog is drawn one pixel per cell into a tiny
# render target and stretched over the map, so the engine's smoothing turns
# the hard grid into soft edges for free.
#
#   args.state.fog ||= Vfx::Fog.new(columns: 32, rows: 18, cell: 40)
#   Vfx::Fog.reveal(args.state.fog, hero_x, hero_y, 160)   # every frame, for everyone who sees
#   Vfx::Fog.tick(args.state.fog)
#   args.outputs.primitives << map_sprites
#   args.outputs.primitives << Vfx::Fog.draw(args.outputs, args.state.fog)
#
# References: raylib's textures_fog_of_war example (zlib) for the small-texture
# trick; written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module Fog
    # cell: the side of a cell in pixels. x, y: the bottom-left corner of the map.
    # dim: how dark a seen-before cell is, 0 to 255. speed: how fast cells change, 0 to 1.
    def self.new(columns:, rows:, cell:, x: 0, y: 0, dim: 150, speed: 0.15)
      { columns: columns, rows: rows, cell: cell, x: x, y: y, dim: dim, speed: speed,
        cells: Array.new(columns * rows) { { alpha: 255.0, seen: false, looking: false, visible: false } } }
    end

    # Marks the cells whose centre is within `radius` pixels of (x, y) as in
    # view this frame. Use a radius of a cell or more, or nothing may qualify.
    def self.reveal(fog, x, y, radius)
      side = fog[:cell]
      first_column = [((x - radius - fog[:x]) / side).floor, 0].max
      last_column = [((x + radius - fog[:x]) / side).floor, fog[:columns] - 1].min
      first_row = [((y - radius - fog[:y]) / side).floor, 0].max
      last_row = [((y + radius - fog[:y]) / side).floor, fog[:rows] - 1].min
      first_row.upto(last_row) do |row|
        first_column.upto(last_column) do |column|
          dx = fog[:x] + ((column + 0.5) * side) - x
          dy = fog[:y] + ((row + 0.5) * side) - y
          next if (dx * dx) + (dy * dy) > radius * radius

          cell = fog[:cells][(row * fog[:columns]) + column]
          cell[:looking] = true
          cell[:seen] = true
        end
      end
      fog
    end

    # Call once a frame, after every `reveal`. Eases each cell towards clear,
    # dim or black, and forgets who was looking. It counts whole frames: skip
    # the call while the game is frozen.
    def self.tick(fog)
      fog[:cells].each do |cell|
        target = if cell[:looking] then 0.0
                 elsif cell[:seen] then fog[:dim]
                 else 255.0
                 end
        cell[:alpha] += (target - cell[:alpha]) * fog[:speed]
        cell[:visible] = cell[:looking]
        cell[:looking] = false
      end
      fog
    end

    # Is the point in view right now? Use it to hide enemies in the dim part.
    def self.visible?(fog, x, y)
      cell = cell_at(fog, x, y)
      cell ? cell[:visible] : false
    end

    # Has the point ever been in view?
    def self.seen?(fog, x, y)
      cell = cell_at(fog, x, y)
      cell ? cell[:seen] : false
    end

    # Builds the fog in a render target and returns the sprite that lays it
    # over the map. color: [r, g, b] of the fog.
    def self.draw(outputs, fog, color: [8, 10, 18], target: :vfx_fog)
      map = outputs[target]
      map.w = fog[:columns]
      map.h = fog[:rows]
      map.background_color = [0, 0, 0, 0]
      map.primitives << pixels(fog, color)
      { x: fog[:x], y: fog[:y], w: fog[:columns] * fog[:cell], h: fog[:rows] * fog[:cell],
        path: target, scale_quality_enum: 2 }
    end

    # One 1x1 rectangle per cell that is not clear. blendmode 0 writes the
    # colour and alpha as they are instead of mixing them with the empty target.
    def self.pixels(fog, color)
      shapes = []
      fog[:cells].each_with_index do |cell, index|
        next if cell[:alpha] < 1

        shapes << { x: index % fog[:columns], y: index.idiv(fog[:columns]), w: 1, h: 1, path: :solid,
                    r: color[0], g: color[1], b: color[2], a: cell[:alpha], blendmode: 0 }
      end
      shapes
    end

    # The cell under a point; nil off the map.
    def self.cell_at(fog, x, y)
      column = ((x - fog[:x]) / fog[:cell]).floor
      row = ((y - fog[:y]) / fog[:cell]).floor
      return nil if column < 0 || row < 0 || column >= fog[:columns] || row >= fog[:rows]

      fog[:cells][(row * fog[:columns]) + column]
    end
  end
end
