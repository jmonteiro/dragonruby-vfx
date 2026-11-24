# Scene transitions: fade, wipe, iris, tiles and blinds.
#
# Each one covers the screen, then uncovers it. On the one frame the screen is
# fully covered, `midpoint?` is true: change the scene there and nobody sees
# the swap. Everything is drawn with rectangles (and one sprite for the iris).
#
#   args.state.transition ||= Vfx::Transition.new
#   Vfx::Transition.start(args.state.transition, :iris, x: hero_x, y: hero_y) if door_opened
#   Vfx::Transition.tick(args.state.transition)
#   args.state.scene = :cave if Vfx::Transition.midpoint?(args.state.transition)
#   draw_scene(args)
#   args.outputs.primitives << Vfx::Transition.overlay(args.state.transition)
#
# References: HaxeFlixel's flixel-addons transitions and Nez's Graphics/Transitions
# (both MIT) for the set of shapes; written from scratch.
# This file stands alone: copy it and require it. The iris also needs
# sprites/hole.png beside it.
module Vfx
  module Transition
    # The pictures sit in a `sprites` folder beside this file, wherever that is.
    SPRITES = "#{__FILE__[0, __FILE__.rindex("/")]}/sprites".freeze

    KINDS = [:fade, :wipe, :iris, :tiles, :blinds].freeze
    TILE = 80   # the side of a tile, in pixels
    BLINDS = 12 # how many bars

    def self.new
      { kind: nil, at: 0, frames: 0 }
    end

    # kind: one of KINDS. frames: the whole length, there and back (2 at least).
    # color: [r, g, b] of the cover. x, y: where the iris closes; the middle of
    # the screen if left out.
    def self.start(transition, kind, frames: 50, color: [0, 0, 0], x: nil, y: nil)
      raise ArgumentError, "unknown transition #{kind.inspect}; use one of #{KINDS.inspect}" unless KINDS.include?(kind)

      transition.merge!(kind: kind, at: 0, frames: [frames, 2].max, color: color, x: x, y: y)
    end

    # Call once a frame. It counts whole frames: skip the call while the game
    # is frozen, or keep calling it so the transition runs on through a pause.
    def self.tick(transition)
      return transition unless transition[:kind]

      transition[:at] += 1
      transition[:kind] = nil if transition[:at] > transition[:frames]
      transition
    end

    def self.active?(transition)
      !transition[:kind].nil?
    end

    # true on the single frame the screen is fully covered.
    def self.midpoint?(transition)
      active?(transition) && transition[:at] == closing(transition)
    end

    # The frames spent covering; the rest are spent uncovering.
    def self.closing(transition)
      transition[:frames].idiv(2)
    end

    # How much of the screen is covered: 0, up to 1 at the midpoint, back to 0.
    def self.cover(transition)
      return 0.0 unless active?(transition)

      at = transition[:at]
      closing = closing(transition)
      return at.to_f / closing if at <= closing

      1.0 - ((at - closing).to_f / (transition[:frames] - closing))
    end

    # The shapes to draw over the scene. Empty when no transition is running.
    def self.overlay(transition, w: 1280, h: 720)
      return [] unless active?(transition)

      cover = cover(transition)
      leaving = transition[:at] > closing(transition)
      r, g, b = transition[:color]
      ink = { path: :solid, r: r, g: g, b: b }
      case transition[:kind]
      when :fade then [ink.merge(x: 0, y: 0, w: w, h: h, a: cover * 255)]
      when :wipe then [ink.merge(x: leaving ? w * (1 - cover) : 0, y: 0, w: w * cover, h: h)]
      when :iris then iris(transition, cover, ink, w, h)
      when :tiles then tiles(cover, ink, w, h)
      when :blinds then blinds(cover, ink, w, h)
      end
    end

    # A round hole that closes on (x, y): the hole sprite, and four rectangles
    # for everything outside it.
    def self.iris(transition, cover, ink, w, h)
      x = transition[:x] || (w / 2.0)
      y = transition[:y] || (h / 2.0)
      reach = [x, w - x].max
      rise = [y, h - y].max
      radius = Math.sqrt((reach * reach) + (rise * rise)) * (1 - cover)
      [ink.merge(x: x - radius, y: y - radius, w: radius * 2, h: radius * 2, path: "#{SPRITES}/hole.png"),
       ink.merge(x: 0, y: 0, w: x - radius, h: h),
       ink.merge(x: x + radius, y: 0, w: w - x - radius, h: h),
       ink.merge(x: 0, y: 0, w: w, h: y - radius),
       ink.merge(x: 0, y: y + radius, w: w, h: h - y - radius)].reject { |shape| shape[:w] <= 0 || shape[:h] <= 0 }
    end

    # Squares that grow from nothing, the bottom-left corner first.
    def self.tiles(cover, ink, w, h)
      side = TILE
      columns = (w.to_f / side).ceil
      rows = (h.to_f / side).ceil
      shapes = []
      columns.times do |column|
        rows.times do |row|
          grown = ((cover * 2) - ((column + row).to_f / (columns + rows))).clamp(0.0, 1.0)
          next if grown <= 0

          size = side * grown
          gap = (side - size) / 2
          shapes << ink.merge(x: (column * side) + gap, y: (row * side) + gap, w: size, h: size)
        end
      end
      shapes
    end

    # Horizontal bars that thicken until they meet.
    def self.blinds(cover, ink, w, h)
      bar = h.to_f / BLINDS
      Array.new(BLINDS) { |index| ink.merge(x: 0, y: index * bar, w: w, h: bar * cover) }
    end
  end
end
