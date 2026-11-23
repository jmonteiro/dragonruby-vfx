# Dissolve: a sprite eaten away along a noise pattern, its edge burning.
# DragonRuby Pro only.
#
# A fragment shader over a render target that holds the thing to dissolve.
# Raise `progress` from 0 to 1 for a death, lower it from 1 to 0 for a spawn.
#
#   ghost = args.outputs[:ghost]                     # draw the enemy into its own target
#   ghost.w = 96
#   ghost.h = 96
#   ghost.background_color = [0, 0, 0, 0]
#   ghost.primitives << enemy.merge(x: 0, y: 0)
#   ghost.shader = Vfx::Dissolve.shader(args.state.dying)   # 0 whole, 1 gone
#   args.outputs.primitives << { x: enemy.x, y: enemy.y, w: 96, h: 96, path: :ghost }
#
# Needs `shaders=true` in metadata/game_metadata.txt and a Pro licence. Shaders
# are experimental in DragonRuby and do not run in web builds.
# Technique: noise-threshold dissolve with a burn edge, as in godotshaders'
# "2D dissolve with burn edge" (CC0). Written from scratch.
# Copy this file and dissolve.frag.hlsl together.
# Require the shader as well as this file: the engine compiles it then.
#   require "lib/vfx/pro/dissolve.frag.hlsl"
#   require "lib/vfx/pro/dissolve.rb"
module Vfx
  module Dissolve
    PATH = "lib/vfx/pro/dissolve.frag.hlsl".freeze

    # progress: 0 whole, 1 gone. edge: width of the burning band (0.02 a hairline, 0.2 wide).
    # grain: how many blotches across the target. seed: a different pattern for each number.
    # color: [r, g, b] of the burning edge.
    def self.shader(progress, edge: 0.08, grain: 7, seed: 0, color: [255, 140, 40])
      values = [progress.clamp(0.0, 1.0), edge, grain, seed, color[0] / 255.0, color[1] / 255.0, color[2] / 255.0]
      { path: PATH, uniforms: values.map { |value| { type: :float, value: value.to_f } } }
    end
  end
end
