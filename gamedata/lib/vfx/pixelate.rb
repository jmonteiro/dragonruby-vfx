# Pixelate (mosaic) without a shader.
#
# The scene is drawn into a much smaller render target and that small picture
# is stretched back over the screen with no smoothing, so every small pixel
# becomes a big square. Animate the size for a transition, a teleport or a
# censor bar.
#
#   size = 1 + (args.state.blur * 31)        # your own number: 1 is sharp
#   args.outputs.primitives << Vfx::Pixelate.draw(args.outputs, :scene, size)
#
# References: moonshine's pixelate and Phaser's Pixelate filter (both MIT),
# which do it in a shader; the render-target version here is written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module Pixelate
    # path: the render target holding the scene. size: the side of a block in
    # screen pixels; 1 or less leaves the picture as it is.
    # Returns the sprite to draw.
    def self.draw(outputs, path, size, target: :vfx_pixelate, w: 1280, h: 720)
      return { x: 0, y: 0, w: w, h: h, path: path } if size <= 1

      columns, rows = grid(size, w, h)
      small = outputs[target]
      small.w = columns
      small.h = rows
      small.primitives << { x: 0, y: 0, w: columns, h: rows, path: path }
      { x: 0, y: 0, w: w, h: h, path: target, scale_quality_enum: 0 }
    end

    # How many blocks fit across and down. The blocks are stretched to fill
    # the screen exactly, so they are only near `size` when it does not divide
    # the screen: 100 on 1280x720 gives 13x8 blocks of about 98x90.
    def self.grid(size, w, h)
      [(w.to_f / size).ceil, (h.to_f / size).ceil]
    end
  end
end
