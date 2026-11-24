# 2D lighting with a light map.
#
# A second picture the size of the screen starts as the ambient colour (the
# darkness). Each light is a soft white sprite added onto it. That picture is
# then multiplied over the scene: where it is dark the scene goes dark, where
# a light shines the scene shows through, tinted by the light's colour.
#
#   lights = [{ x: mouse.x, y: mouse.y, radius: 220 },
#             { x: 900, y: 300, radius: 160, r: 255, g: 140, b: 60 }]
#   args.outputs.primitives << scene_sprites
#   args.outputs.primitives << Vfx::Lights.draw(args.outputs, lights, ambient: [20, 22, 40])
#   args.outputs.primitives << hud      # drawn after, so it is not darkened
#
# References: Godot's light2d demos (MIT) and DragonRuby's own lighting sample
# for the render-target approach; written from scratch.
# This file stands alone: copy it, and sprites/light.png beside it, and require it.
module Vfx
  module Lights
    # The pictures sit in a `sprites` folder beside this file, wherever that is.
    SPRITES = "#{__FILE__[0, __FILE__.rindex("/")]}/sprites".freeze

    # Builds the light map in a render target and returns the sprite that lays
    # it over the scene. Draw it after the scene and before the HUD.
    # ambient: [r, g, b] where no light reaches; [0, 0, 0] is pitch black.
    # extra: additive sprites to add to the map as they are, such as the
    # shadow-casting lights from shadows.rb.
    def self.draw(outputs, lights, ambient: [24, 26, 44], target: :vfx_lights, w: 1280, h: 720, extra: [])
      map = outputs[target]
      map.w = w
      map.h = h
      map.background_color = [ambient[0], ambient[1], ambient[2], 255]
      map.primitives << sprites(lights)
      map.primitives << extra
      { x: 0, y: 0, w: w, h: h, path: target, blendmode: 8 }
    end

    # One additive sprite per light. A light is a Hash with x, y, radius and,
    # if wanted, r, g, b (its colour) and a (its strength, up to 255).
    def self.sprites(lights, path: "#{SPRITES}/light.png")
      lights.map do |light|
        radius = light[:radius]
        { x: light[:x] - radius, y: light[:y] - radius, w: radius * 2, h: radius * 2, path: path, blendmode: 2,
          r: light[:r] || 255, g: light[:g] || 255, b: light[:b] || 255, a: light[:a] || 255 }
      end
    end

    # A number wandering around 1, to multiply a torch's radius by.
    # clock: a frame counter. seed: so two torches do not flicker together.
    def self.flicker(clock, seed: 0, amount: 0.06)
      1.0 + (amount * ((Math.sin((clock * 0.37) + seed) * 0.6) + (Math.sin((clock * 0.83) + (seed * 2.3)) * 0.4)))
    end
  end
end
