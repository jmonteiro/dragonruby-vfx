module Demos
  # Three rows of hills and a road scroll past at different speeds.
  module Parallax
    ID = "parallax".freeze
    TITLE = "Parallax".freeze
    BLURB = "Each layer moves by the camera's distance times its factor: 0.15 for the far hills, 1 for the road.".freeze
    CONTROLS = "Move the pointer left and right: speed".freeze
    SHOT_AT = 30

    LAYERS = [{ path: "sprites/demo/hills_far.png", w: 640, h: 420, y: 200, factor: 0.15, r: 44, g: 54, b: 92 },
              { path: "sprites/demo/hills_middle.png", w: 640, h: 380, y: 200, factor: 0.4, r: 56, g: 72, b: 116 },
              { path: "sprites/demo/hills_near.png", w: 640, h: 340, y: 200, factor: 0.7, r: 72, g: 96, b: 140 }].freeze

    def self.setup
      { camera: 0.0 }
    end

    def self.tick(args, demo, input)
      demo[:camera] += input[:pointer] ? (input[:pointer][:x] - 640) / 40.0 : 5
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 24, g: 28, b: 44 }
      args.outputs.primitives << Vfx::Parallax.sprites(LAYERS, demo[:camera])
      args.outputs.primitives << { x: 0, y: 0, w: 1280, h: Stage::GROUND, path: :solid, r: 46, g: 56, b: 86 }
      # Posts along the road move with the camera itself: factor 1.
      posts = Array.new(8) { |index| { x: (index * 200) - (demo[:camera] % 200), y: Stage::GROUND, w: 12, h: 70, path: :solid, r: 150, g: 160, b: 190 } }
      args.outputs.primitives << posts
      args.outputs.primitives << Stage.blob({ x: 595, y: Stage::GROUND, w: 90, h: 90 }, Stage::TEAL)
    end
  end
end
