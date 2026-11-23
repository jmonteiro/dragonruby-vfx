# Silhouette: a sprite's shape in one flat colour. Hit flash, outline, shadow.
#
# `mask` draws the sprite into a small render target with a blend mode that
# keeps its shape (alpha) and throws its colours away, leaving it white. That
# white shape can then be tinted and stamped: over the sprite for a hit flash,
# around it for an outline, beside it for a shadow.
#
#   mask = Vfx::Silhouette.mask(args.outputs, hero)              # once a frame per sprite
#   args.outputs.primitives << Vfx::Silhouette.shadow(mask)
#   args.outputs.primitives << Vfx::Silhouette.outline(mask, width: 3, color: [255, 220, 80])
#   args.outputs.primitives << hero
#   args.outputs.primitives << Vfx::Silhouette.flash(mask, args.state.hurt)   # 1 just hit, falling to 0
#
# Technique: the standard "flash white" and stamped outline, done in other
# engines with a shader (godotshaders "Hit flash", raylib's outline example);
# here with a custom blend mode. Written from scratch.
# This file stands alone: copy it and require it.
module Vfx
  module Silhouette
    # The eight directions an outline is stamped in.
    AROUND = [[-1, 0], [1, 0], [0, -1], [0, 1], [-0.7, -0.7], [0.7, -0.7], [-0.7, 0.7], [0.7, 0.7]].freeze

    # Builds the white shape of `sprite` in a render target and returns it as
    # a sprite in the same place. Give each sprite on screen its own `target:`.
    def self.mask(outputs, sprite, target: :vfx_silhouette)
      shape = outputs[target]
      shape.w = sprite[:w].ceil
      shape.h = sprite[:h].ceil
      shape.background_color = [255, 255, 255, 0]
      shape.primitives << sprite.merge(x: 0, y: 0, angle: 0, r: 255, g: 255, b: 255, a: 255, blendmode: keep_shape)
      { x: sprite[:x], y: sprite[:y], w: sprite[:w], h: sprite[:h], path: target, angle: sprite[:angle] || 0 }
    end

    # The mask over the sprite. strength: 1 solid colour, 0 nothing.
    def self.flash(mask, strength, color: [255, 255, 255])
      mask.merge(r: color[0], g: color[1], b: color[2], a: strength.clamp(0.0, 1.0) * 255)
    end

    # Eight copies of the mask around the sprite; draw them before it.
    def self.outline(mask, width: 3, color: [255, 255, 255], alpha: 255)
      ink = mask.merge(r: color[0], g: color[1], b: color[2], a: alpha)
      AROUND.map { |dx, dy| ink.merge(x: mask[:x] + (dx * width), y: mask[:y] + (dy * width)) }
    end

    # One dark copy of the mask, moved aside; draw it before the sprite.
    def self.shadow(mask, dx: 8, dy: -8, color: [0, 0, 0], alpha: 110)
      mask.merge(x: mask[:x] + dx, y: mask[:y] + dy, r: color[0], g: color[1], b: color[2], a: alpha)
    end

    # Colour: keep what is there (the white background). Alpha: take the sprite's.
    def self.keep_shape
      @keep_shape ||= Numeric.compose_blendmode(BLENDFACTOR_ZERO, BLENDFACTOR_ONE, BLENDOPERATION_ADD,
                                                BLENDFACTOR_ONE, BLENDFACTOR_ZERO, BLENDOPERATION_ADD)
    end
  end
end
