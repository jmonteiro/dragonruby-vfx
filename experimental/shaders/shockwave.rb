# Shockwave: a ring that bends the picture as it spreads. DragonRuby Pro only.
#
# A fragment shader over the finished scene. Each pixel near the ring is read
# from a little nearer the centre, so the picture looks pushed outwards, as
# smoothly as the screen has pixels. Grow `radius` every frame.
#
#   args.outputs[:scene].shader = Vfx::Shockwave.shader(blast_x, blast_y, radius)   # all in pixels
#   args.outputs[:scene].shader = nil when the ring has left the screen
#
# Needs `shaders=true` in metadata/game_metadata.txt and a Pro licence. Shaders
# are experimental in DragonRuby and do not run in web builds. For a coarser
# shockwave that runs everywhere, see warp.rb.
# Technique: radial displacement, as in pixi-filters' ShockwaveFilter (MIT).
# Written from scratch. Copy this file and shockwave.frag.hlsl together.
# Require the shader as well as this file: the engine compiles it then.
#   require "lib/vfx/pro/shockwave.frag.hlsl"
#   require "lib/vfx/pro/shockwave.rb"
module Vfx
  module Shockwave
    PATH = "lib/vfx/pro/shockwave.frag.hlsl".freeze

    # x, y: the centre. radius: where the ring is now. width: its thickness.
    # strength: how far it bends the picture. All in pixels of a w by h screen.
    def self.shader(x, y, radius, width: 80, strength: 24, w: 1280, h: 720)
      values = [x.fdiv(w), 1 - y.fdiv(h), radius.fdiv(h), width.fdiv(h), strength.fdiv(h), w.fdiv(h)]
      { path: PATH, uniforms: values.map { |value| { type: :float, value: value } } }
    end
  end
end
