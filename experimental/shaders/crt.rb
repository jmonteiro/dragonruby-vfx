# CRT: the look of an old television. DragonRuby Pro only.
#
# A fragment shader over the finished scene: the glass bulges, rows of pixels
# are split by dark scanlines, columns carry red, green and blue stripes,
# colours fringe at the edges and the corners go dark.
#
#   args.outputs[:scene].shader = Vfx::Crt.shader          # the scene's render target
#   args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
#
# Needs `shaders=true` in metadata/game_metadata.txt and a Pro licence. Shaders
# are experimental in DragonRuby and do not run in web builds.
# Technique: Timothy Lottes' public-domain CRT shader set the recipe (curve,
# scanlines, mask); moonshine's crt and scanlines (MIT) are the simple version
# followed here. Written from scratch.
# Copy this file and crt.frag.hlsl together.
# Require the shader as well as this file: the engine compiles it then.
#   require "lib/vfx/pro/crt.frag.hlsl"
#   require "lib/vfx/pro/crt.rb"
module Vfx
  module Crt
    PATH = "lib/vfx/pro/crt.frag.hlsl".freeze

    # curve: how much the glass bulges (0 flat, 0.3 a fishbowl).
    # scanlines: 0 none, 1 black gaps. lines: how many down the screen.
    # mask: strength of the colour stripes. vignette: how dark the corners are.
    # fringe: how far red and blue part, in thousandths of the screen's width.
    def self.shader(curve: 0.12, scanlines: 0.35, lines: 240, mask: 0.15, vignette: 0.6, fringe: 1.5)
      { path: PATH,
        uniforms: [curve, scanlines, mask, vignette, fringe, lines].map { |value| { type: :float, value: value.to_f } } }
    end
  end
end
