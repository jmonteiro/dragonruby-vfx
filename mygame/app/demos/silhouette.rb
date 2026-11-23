module Demos
  # One white shape of the creature, used three ways.
  module Silhouette
    ID = "silhouette".freeze
    TITLE = "Hit flash, outline, shadow".freeze
    BLURB = "The sprite's shape as one flat colour, from a blend mode instead of a shader. Tint it and stamp it.".freeze
    CONTROLS = "Click or SPACE: hit".freeze
    SHOT_AT = 24

    def self.setup
      { clock: 0, hurt: 0.0 }
    end

    def self.tick(args, demo, input)
      demo[:clock] += 1
      demo[:hurt] = 1.0 if input[:action] || (input[:auto] && demo[:clock] % 50 == 20)
      Stage.draw(args.outputs)

      flashing = critter(280, demo[:hurt] > 0.5 ? 8 : 0)
      mask = Vfx::Silhouette.mask(args.outputs, flashing, target: :mask_flash)
      args.outputs.primitives << flashing
      args.outputs.primitives << Vfx::Silhouette.flash(mask, demo[:hurt])
      demo[:hurt] = [demo[:hurt] - 0.12, 0.0].max

      outlined = critter(560, 0)
      mask = Vfx::Silhouette.mask(args.outputs, outlined, target: :mask_outline)
      width = 4 + (Math.sin(demo[:clock] * 0.1) * 2)
      args.outputs.primitives << Vfx::Silhouette.outline(mask, width: width, color: Stage::YELLOW)
      args.outputs.primitives << outlined

      lift = Math.sin(demo[:clock] * 0.08).abs * 70
      shadowed = critter(840, lift)
      mask = Vfx::Silhouette.mask(args.outputs, shadowed, target: :mask_shadow)
      # The higher it jumps, the further its shadow falls away.
      args.outputs.primitives << Vfx::Silhouette.shadow(mask, dx: 14 + (lift * 0.4), dy: -10 - lift)
      args.outputs.primitives << shadowed

      [[360, "flash"], [640, "outline"], [920, "shadow"]].each do |x, name|
        args.outputs.primitives << Stage.text(x, 150, name, color: Stage::GREY, align: 0.5)
      end
    end

    def self.critter(x, lift)
      { x: x, y: Stage::GROUND + 40 + lift, w: 160, h: 160, path: "sprites/demo/critter.png" }
    end
  end
end
