# The plain scene and drawing helpers the demos share, so each demo file shows
# little more than the effect itself. Nothing here is part of the library.
module Stage
  W = 1280
  H = 720
  GROUND = 200

  YELLOW = [255, 204, 77].freeze
  RED = [239, 98, 108].freeze
  TEAL = [72, 202, 180].freeze
  WHITE = [255, 255, 255].freeze
  GREY = [150, 160, 190].freeze

  SKYLINE = [[90, 120, 170], [260, 80, 110], [470, 150, 240], [860, 110, 150], [1040, 140, 210]].freeze

  # Sky, a faint grid (so movement of the whole picture is easy to see), a
  # skyline and the ground. `out` is args.outputs or a render target.
  def self.draw(out)
    out.primitives << backdrop
  end

  def self.backdrop
    @backdrop ||= begin
      list = [{ x: 0, y: 0, w: W, h: H, path: :solid, r: 24, g: 28, b: 44 }]
      0.step(W, 80) { |x| list << { x: x, y: GROUND, w: 1, h: H - GROUND, path: :solid, r: 255, g: 255, b: 255, a: 14 } }
      GROUND.step(H, 80) { |y| list << { x: 0, y: y, w: W, h: 1, path: :solid, r: 255, g: 255, b: 255, a: 14 } }
      SKYLINE.each { |x, w, h| list << { x: x, y: GROUND, w: w, h: h, path: :solid, r: 36, g: 43, b: 68 } }
      list << { x: 0, y: 0, w: W, h: GROUND, path: :solid, r: 46, g: 56, b: 86 }
      list << { x: 0, y: GROUND - 4, w: W, h: 4, path: :solid, r: 86, g: 104, b: 150 }
      list
    end
  end

  # The backdrop and the cast drawn into a render target, for the effects that
  # work on a finished picture. Returns the target.
  def self.scene(args, clock, name = :scene)
    scene = args.outputs[name]
    scene.w = W
    scene.h = H
    draw(scene)
    scene.primitives << cast(clock)
    scene
  end

  # Something to look at: stars, two creatures and a ball that never stops.
  def self.cast(clock)
    ball_x = 640 + (Math.sin(clock * 0.021) * 300)
    ball_y = GROUND + 30 + (Math.sin(clock * 0.06).abs * 260)
    [stars,
     blob({ x: 300, y: GROUND, w: 90, h: 90 }, TEAL),
     blob({ x: 900, y: GROUND, w: 110, h: 110 }, RED),
     circle(ball_x, ball_y, 30, YELLOW)]
  end

  def self.stars
    @stars ||= Array.new(28) do |index|
      { x: (index * 197) % W, y: 420 + ((index * 83) % 220), w: 4, h: 4, path: :solid, r: 255, g: 240, b: 200, a: 170 }
    end
  end

  # A square creature with two eyes, drawn inside `rect` (x, y, w, h), so it
  # deforms with whatever the rect does.
  def self.blob(rect, color)
    eye = { y: rect[:y] + (rect[:h] * 0.56), w: rect[:w] * 0.16, h: rect[:h] * 0.22, path: :solid, r: 24, g: 28, b: 44 }
    [rect.merge(path: :solid, r: color[0], g: color[1], b: color[2]),
     eye.merge(x: rect[:x] + (rect[:w] * 0.2)),
     eye.merge(x: rect[:x] + (rect[:w] * 0.64))]
  end

  def self.circle(x, y, radius, color, alpha = 255)
    { x: x - radius, y: y - radius, w: radius * 2, h: radius * 2, path: "sprites/vfx/circle.png",
      r: color[0], g: color[1], b: color[2], a: alpha }
  end

  # align: 0 left, 0.5 centred, 1 right. y is the middle of the line.
  def self.text(x, y, string, size: 22, color: WHITE, align: 0, alpha: 255)
    { x: x, y: y, text: string, size_px: size, anchor_x: align, anchor_y: 0.5,
      r: color[0], g: color[1], b: color[2], a: alpha, primitive_marker: :label }
  end

  # A labelled meter; `value` runs from 0 to 1.
  def self.bar(x, y, name, value, color)
    [text(x, y + 9, name, size: 18, color: GREY),
     { x: x + 170, y: y, w: 240, h: 18, path: :solid, r: 255, g: 255, b: 255, a: 30 },
     { x: x + 170, y: y, w: 240 * value.clamp(0.0, 1.0), h: 18, path: :solid, r: color[0], g: color[1], b: color[2] }]
  end
end
