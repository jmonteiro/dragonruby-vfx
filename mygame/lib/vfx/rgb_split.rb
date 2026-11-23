# RGB split (chromatic aberration) without a shader.
#
# The scene is drawn three times, once in red, once in green and once in blue,
# and the three are added together. Lined up they give back the original
# picture; slid apart, every edge grows a red and a blue fringe. A short pulse
# of it on a hit or a glitch goes a long way.
#
#   offset = args.state.jolt * 12            # your own number, pixels
#   args.outputs.primitives << Vfx::RgbSplit.sprites(:scene, offset)
#
# References: pixi-filters' RGBSplitFilter and moonshine's chromasep (both MIT),
# which do it in a shader; the three-pass version here is written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module RgbSplit
    # path: the render target holding the scene. offset: how far red and blue
    # slide, in pixels, in opposite directions. angle: the direction, in degrees.
    # Returns a black backdrop and the three coloured copies; draw them in order.
    # The backdrop makes the result opaque, so this is for a whole scene, not
    # for a sprite with transparent parts. At offset 0 the scene comes back as it is.
    def self.sprites(path, offset, angle: 0, x: 0, y: 0, w: 1280, h: 720)
      return [{ x: x, y: y, w: w, h: h, path: path }] if offset == 0

      dx = Math.cos(angle * Math::PI / 180) * offset
      dy = Math.sin(angle * Math::PI / 180) * offset
      layer = { x: x, y: y, w: w, h: h, path: path, blendmode: 2 }
      [{ x: x, y: y, w: w, h: h, path: :solid, r: 0, g: 0, b: 0 },
       layer.merge(x: x - dx, y: y - dy, r: 255, g: 0, b: 0),
       layer.merge(r: 0, g: 255, b: 0),
       layer.merge(x: x + dx, y: y + dy, r: 0, g: 0, b: 255)]
    end
  end
end
