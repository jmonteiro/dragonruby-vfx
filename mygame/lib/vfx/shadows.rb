# Shadow-casting lights: a light that walls block.
#
# From the light, a ray is cast at each end of every wall (and a hair to each
# side of it). Where the rays stop, joined in order around the light, is the
# shape of everything the light can see: the visibility polygon. The light's
# glow is drawn only inside that shape. The same shape answers "what can this
# guard see?".
#
#   walls = [[400, 300, 400, 500], [400, 500, 600, 500]]          # [x1, y1, x2, y2] each
#   lamp = { x: mouse.x, y: mouse.y, radius: 320, r: 255, g: 230, b: 180 }
#   glow = Vfx::Shadows.light(args.outputs, lamp, walls)
#   args.outputs.primitives << Vfx::Lights.draw(args.outputs, [], extra: [glow])   # with lights.rb
#
# `light` returns an additive sprite: put it in a light map, or draw it
# straight over a dark scene.
#
# Technique: the visibility polygon, as explained by Nicky Case's "Sight &
# Light" and Red Blob Games' "2D Visibility". Written from scratch.
# This file stands alone: copy it and require it. It draws sprites/vfx/light.png.
module Vfx
  module Shadows
    # The points of the visibility polygon around (x, y), in order, as [x, y]
    # pairs. walls: [x1, y1, x2, y2] each. Nothing beyond `radius` is seen.
    def self.polygon(x, y, walls, radius)
      blockers = walls + [[x - radius, y - radius, x + radius, y - radius], [x + radius, y - radius, x + radius, y + radius],
                          [x + radius, y + radius, x - radius, y + radius], [x - radius, y + radius, x - radius, y - radius]]
      angles = []
      blockers.each do |wall|
        [Math.atan2(wall[1] - y, wall[0] - x), Math.atan2(wall[3] - y, wall[2] - x)].each do |angle|
          angles << (angle - 0.0001) << angle << (angle + 0.0001)
        end
      end
      angles.sort.map { |angle| cast(x, y, Math.cos(angle), Math.sin(angle), blockers) }
    end

    # Where a ray from (x, y) heading (dx, dy) first meets a wall.
    def self.cast(x, y, dx, dy, walls)
      reach = reach(x, y, dx, dy, walls) || 0
      [x + (dx * reach), y + (dy * reach)]
    end

    # Can (px, py) be seen from (x, y)? For guards, turrets and stealth.
    def self.sees?(x, y, px, py, walls)
      reach = reach(x, y, px - x, py - y, walls)
      reach.nil? || reach >= 1
    end

    # How many times (dx, dy) fits between (x, y) and the first wall that way;
    # nil if there is none.
    def self.reach(x, y, dx, dy, walls)
      nearest = nil
      walls.each do |x1, y1, x2, y2|
        wx = x2 - x1
        wy = y2 - y1
        cross = (dx * wy) - (dy * wx)
        next if cross.abs < 0.000001 # the ray runs alongside this wall

        along_ray = (((x1 - x) * wy) - ((y1 - y) * wx)) / cross
        along_wall = (((x1 - x) * dy) - ((y1 - y) * dx)) / cross
        next if along_ray <= 0 || along_wall < 0 || along_wall > 1

        nearest = along_ray if nearest.nil? || along_ray < nearest
      end
      nearest
    end

    # Builds the light in its own render target and returns the additive
    # sprite that shows it. light: x, y, radius and, if wanted, r, g, b.
    # Give each light its own `target:`.
    def self.light(outputs, light, walls, target: :vfx_shadow_light)
      radius = light[:radius]
      left = light[:x] - radius
      bottom = light[:y] - radius
      lit = outputs[target]
      side = radius * 2
      lit.w = side
      lit.h = side
      lit.background_color = [0, 0, 0, 0]
      lit.primitives << fan(polygon(light[:x], light[:y], walls, radius), radius, left, bottom)
      lit.primitives << { x: 0, y: 0, w: side, h: side, path: "sprites/vfx/light.png", blendmode: inside,
                          r: light[:r] || 255, g: light[:g] || 255, b: light[:b] || 255 }
      { x: left, y: bottom, w: side, h: side, path: target, blendmode: 2 }
    end

    # The polygon as white triangles around the light, in the target's own
    # coordinates (the light is at its centre).
    def self.fan(points, radius, left, bottom)
      Array.new(points.length) do |index|
        from = points[index]
        to = points[(index + 1) % points.length]
        { path: :solid, source_x: 0, source_y: 0, source_x2: 1, source_y2: 0, source_x3: 0, source_y3: 1,
          x: radius, y: radius, x2: from[0] - left, y2: from[1] - bottom, x3: to[0] - left, y3: to[1] - bottom }
      end
    end

    # Draws the glow only where the white polygon already is: colour times
    # what is there, alpha times the alpha that is there.
    def self.inside
      @inside ||= Numeric.compose_blendmode(BLENDFACTOR_DST_COLOR, BLENDFACTOR_ZERO, BLENDOPERATION_ADD,
                                            BLENDFACTOR_DST_ALPHA, BLENDFACTOR_ZERO, BLENDOPERATION_ADD)
    end
  end
end
