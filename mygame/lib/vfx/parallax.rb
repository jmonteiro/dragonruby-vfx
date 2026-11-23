# Parallax: background layers that scroll slower the further away they are.
#
# Each layer is a picture that repeats sideways and a factor: 0 never moves
# (the sky), 1 moves with the camera (the ground the hero stands on), and
# anything between looks that far away.
#
#   LAYERS = [{ path: "sprites/mountains.png", w: 512, h: 256, y: 200, factor: 0.2 },
#             { path: "sprites/trees.png",     w: 512, h: 256, y: 140, factor: 0.6 }]
#   args.outputs.primitives << Vfx::Parallax.sprites(LAYERS, camera_x)
#
# Technique: parallax scrolling, in games since Moon Patrol (1982).
# Written from scratch. This file stands alone: copy it and require it.
module Vfx
  module Parallax
    # layers: far to near. Each is a Hash with path, w, h (the size one copy is
    # drawn at), y, factor, and any other sprite keys (r, g, b, a) to pass on.
    # camera_x: how far the camera has travelled, in pixels. screen_w: the view's
    # width (not `w`, which here is a layer's own).
    def self.sprites(layers, camera_x, screen_w: 1280)
      layers.flat_map do |layer|
        start = -((camera_x * layer[:factor]) % layer[:w])
        copies = ((screen_w - start) / layer[:w].to_f).ceil
        Array.new(copies) { |index| layer.merge(x: start + (index * layer[:w])) }
      end
    end
  end
end
