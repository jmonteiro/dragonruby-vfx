# Vignette and film grain: two overlays that set a mood for almost nothing.
#
# The vignette darkens the corners and pulls the eye to the middle. Grain is a
# noise picture laid over the screen at a new random position every frame, so
# flat colours shimmer like film.
#
#   args.outputs.primitives << scene_sprites
#   args.outputs.primitives << Vfx::Film.grain(strength: 0.1)
#   args.outputs.primitives << Vfx::Film.vignette(strength: 0.7)
#
# References: moonshine's vignette and filmgrain and pixi-filters' OldFilmFilter
# (all MIT), which do it in a shader; the sprite version here is written from scratch.
# This file stands alone: copy it and require it. It draws sprites/vfx/vignette.png
# and sprites/vfx/grain.png.
module Vfx
  module Film
    # One sprite over the whole screen. strength: 0 nothing, 1 black corners.
    # color: [r, g, b]; red for low health, white for a dream.
    def self.vignette(strength: 0.6, color: [0, 0, 0], w: 1280, h: 720)
      { x: 0, y: 0, w: w, h: h, path: "sprites/vfx/vignette.png",
        r: color[0], g: color[1], b: color[2], a: strength * 255 }
    end

    # Tiles of noise covering the screen, shifted at random on every call.
    # strength: 0 nothing; 0.08 is subtle, 0.25 is an old film. tile: the size
    # each copy of the noise is drawn at; larger makes coarser grain.
    def self.grain(strength: 0.1, tile: 256, w: 1280, h: 720)
      return [] if strength <= 0 || tile <= 0

      shift_x = rand * tile
      shift_y = rand * tile
      sprites = []
      (-shift_x).step(w, tile) do |x|
        (-shift_y).step(h, tile) do |y|
          sprites << { x: x, y: y, w: tile, h: tile, path: "sprites/vfx/grain.png", a: strength * 255 }
        end
      end
      sprites
    end
  end
end
