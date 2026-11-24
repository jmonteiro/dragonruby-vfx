# Weather: rain or snow falling at several depths.
#
# Every drop has a depth. Near ones are larger, faster and brighter; far ones
# small, slow and faint, which is what makes a flat picture look deep. Rain is
# drawn as soft streaks that lean the way they travel, and where it meets the
# ground it leaves a small splash.
#
#   args.state.rain ||= Vfx::Weather.new(:rain, ground: 200)   # the ground's top edge is at y 200
#   Vfx::Weather.tick(args.state.rain)
#   args.outputs.primitives << scene
#   args.outputs.primitives << Vfx::Weather.sprites(args.state.rain)
#
# Technique: layered particle fields, velocity-aligned streaks and ground
# splashes, as in most 2D engines' rain tutorials. Written from scratch.
# This file stands alone: copy it, and sprites/streak.png, ring.png and
# circle.png beside it, and require it.
module Vfx
  module Weather
    # The pictures sit in a `sprites` folder beside this file, wherever that is.
    SPRITES = "#{__FILE__[0, __FILE__.rindex("/")]}/sprites".freeze

    KINDS = {
      rain: { fall: 30.0, wind: -7.0, sway: 0.0, wide: 3, long: 70, alpha: 130, color: [190, 215, 255],
              path: "#{SPRITES}/streak.png" },
      snow: { fall: 2.4, wind: -0.6, sway: 1.0, wide: 7, long: 7, alpha: 235, color: [255, 255, 255],
              path: "#{SPRITES}/circle.png" }
    }.freeze
    SPLASH_FRAMES = 10
    FAR = 0.3 # the depth of the furthest drops; the nearest are 1

    # kind: :rain or :snow. count: how many drops.
    # ground: the y of the ground's far edge; drops land on the ground from
    # there down to `ground_depth` pixels below it, the near ones lowest.
    # Leave it out and drops fall through the whole screen.
    # Any key of KINDS can be overridden: Vfx::Weather.new(:rain, wind: -16, count: 500) is a storm.
    def self.new(kind = :rain, count: 300, w: 1280, h: 720, ground: nil, ground_depth: 120, **changes)
      raise ArgumentError, "unknown weather #{kind.inspect}; use one of #{KINDS.keys.inspect}" unless KINDS[kind]

      weather = KINDS[kind].merge(changes).merge(kind: kind, w: w, h: h, ground: ground, ground_depth: ground_depth,
                                                 clock: 0.0, splashes: [])
      weather[:drops] = Array.new(count) { drop(weather, rand * h) }
      weather
    end

    # Call once a frame.
    def self.tick(weather, time_scale = 1.0)
      weather[:clock] += time_scale
      weather[:drops].each { |drop| fall(weather, drop, time_scale) }
      weather[:splashes].reject! do |splash|
        splash[:age] += time_scale
        splash[:age] >= SPLASH_FRAMES
      end
      weather
    end

    # The drops, then the splashes.
    def self.sprites(weather)
      r, g, b = weather[:color]
      lean = lean(weather)
      drops = weather[:drops].map do |drop|
        depth = drop[:depth]
        { x: drop[:x], y: drop[:y], w: weather[:wide] * depth, h: weather[:long] * depth, anchor_x: 0.5, anchor_y: 0.5,
          path: weather[:path], angle: lean, r: r, g: g, b: b, a: weather[:alpha] * depth }
      end
      drops + weather[:splashes].map { |splash| ring(splash, r, g, b, weather[:alpha]) }
    end

    # How far a drop's picture is turned so that it points the way it falls,
    # in degrees. Snow is round and is not turned.
    def self.lean(weather)
      weather[:kind] == :snow ? 0 : Math.atan2(weather[:wind], weather[:fall]) * 180 / Math::PI
    end

    # Where a drop of this depth meets the ground; nil if there is none.
    def self.landing(weather, depth)
      weather[:ground] && (weather[:ground] - (weather[:ground_depth] * (depth - FAR) / (1 - FAR)))
    end

    # A new drop somewhere across the screen, at height y.
    def self.drop(weather, y)
      { x: rand * weather[:w], y: y, depth: FAR + (rand * (1 - FAR)), phase: rand * 2 * Math::PI, hurry: 0.85 + (rand * 0.3) }
    end

    def self.fall(weather, drop, time_scale)
      pace = drop[:depth] * drop[:hurry] * time_scale
      sway = Math.sin((weather[:clock] * 0.05) + drop[:phase]) * weather[:sway]
      drop[:x] = (drop[:x] + ((weather[:wind] + sway) * pace)) % weather[:w]
      drop[:y] -= weather[:fall] * pace
      floor = landing(weather, drop[:depth]) || -weather[:long]
      return if drop[:y] > floor

      if weather[:ground] && weather[:kind] == :rain
        weather[:splashes] << { x: drop[:x], y: floor, depth: drop[:depth], age: 0.0 }
      end
      drop.merge!(drop(weather, weather[:h] + (rand * weather[:long] * 2)))
    end

    # A splash: a flat ring that widens and fades.
    def self.ring(splash, r, g, b, alpha)
      spent = splash[:age] / SPLASH_FRAMES
      wide = (6 + (spent * 26)) * splash[:depth]
      { x: splash[:x], y: splash[:y], w: wide, h: wide * 0.35, anchor_x: 0.5, anchor_y: 0.5,
        path: "#{SPRITES}/ring.png", r: r, g: g, b: b, a: alpha * 1.4 * (1 - spent) * splash[:depth] }
    end
  end
end
