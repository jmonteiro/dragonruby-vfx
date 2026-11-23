# Luma wipe: one scene gives way to another along a pattern, with a soft edge.
# DragonRuby Pro only.
#
# Both scenes are drawn to render targets. A fragment shader on the old one
# reads the new one and, point by point, swaps them in the order a pattern
# gives: left to right, a growing circle, a diagonal, clouds, or a clock hand.
#
#   args.outputs[:old].shader = Vfx::LumaWipe.shader(:new, progress, pattern: :clouds)   # progress 0 to 1
#   args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :old }
#
# Needs `shaders=true` in metadata/game_metadata.txt and a Pro licence. Shaders
# are experimental in DragonRuby and do not run in web builds. For transitions
# that run everywhere, see transition.rb.
# Technique: the gradient ("luma") wipe of video editing; gl-transitions (MIT)
# collects hundreds. The patterns here are computed, not read from a picture.
# Written from scratch. Copy this file and luma_wipe.frag.hlsl together.
# Require the shader as well as this file: the engine compiles it then.
#   require "lib/vfx/pro/luma_wipe.frag.hlsl"
#   require "lib/vfx/pro/luma_wipe.rb"
module Vfx
  module LumaWipe
    PATH = "lib/vfx/pro/luma_wipe.frag.hlsl".freeze
    PATTERNS = [:left, :circle, :diagonal, :clouds, :clock].freeze

    # coming: the render target holding the new scene. progress: 0 the old
    # scene, 1 the new. pattern: one of PATTERNS. softness: width of the
    # blended edge (0 a hard line, 0.3 very soft).
    def self.shader(coming, progress, pattern: :left, softness: 0.12, w: 1280, h: 720)
      number = PATTERNS.index(pattern)
      raise ArgumentError, "unknown pattern #{pattern.inspect}; use one of #{PATTERNS.inspect}" unless number

      { path: PATH, textures: [coming],
        uniforms: [{ type: :float, value: progress.clamp(0.0, 1.0).to_f }, { type: :float, value: softness.to_f },
                   { type: :float, value: w.fdiv(h) }, { type: :int, value: number }] }
    end
  end
end
