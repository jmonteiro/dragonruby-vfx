# Decals: marks that stay. Scorches, blood, footprints, skid marks, paint.
#
# A render target that is never cleared: each mark is drawn into it once and
# then costs nothing, however many there are. Put the layer between the ground
# and the things that walk on it.
#
#   args.state.decals ||= Vfx::Decals.new
#   Vfx::Decals.stamp(args.state.decals, { x: x - 24, y: y - 24, w: 48, h: 48, path: "sprites/scorch.png", a: 160 }) if exploded
#   args.outputs.primitives << ground
#   args.outputs.primitives << Vfx::Decals.draw(args.outputs, args.state.decals)
#   args.outputs.primitives << characters
#
# Technique: the persistent "splat map" of top-down shooters such as Nuclear
# Throne; DragonRuby's own sample shows a render target that is not cleared.
# Written from scratch. This file stands alone: copy it and require it.
module Vfx
  module Decals
    def self.new
      { waiting: [], wipe: true } # the first draw starts from an empty layer
    end

    # Queues a sprite (or an array of them) to be drawn into the layer.
    def self.stamp(decals, sprite)
      decals[:waiting] << sprite
      decals
    end

    # Empties the layer the next time it is drawn.
    def self.clear(decals)
      decals[:waiting].clear
      decals[:wipe] = true
      decals
    end

    # Call once a frame. Draws the waiting marks into the layer and returns
    # the sprite that shows it. The layer lives in the engine, not in the
    # state: it does not survive a restart or a save.
    def self.draw(outputs, decals, target: :vfx_decals, w: 1280, h: 720)
      layer = outputs[target]
      layer.w = w
      layer.h = h
      layer.background_color = [0, 0, 0, 0]
      layer.clear_before_render = decals[:wipe]
      layer.primitives << decals[:waiting]
      decals[:waiting] = []
      decals[:wipe] = false
      { x: 0, y: 0, w: w, h: h, path: target }
    end
  end
end
