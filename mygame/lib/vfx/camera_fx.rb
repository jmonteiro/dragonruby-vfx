# Camera effects: flash, fade, zoom punch and kick.
#
# The scene is drawn to a render target, and the effects change how that one
# sprite is put on screen. Flash and fade are a coloured rectangle over it.
#
#   args.state.cam ||= Vfx::CameraFx.new
#   Vfx::CameraFx.flash(args.state.cam) if explosion
#   Vfx::CameraFx.punch(args.state.cam, 0.06) if hit
#   Vfx::CameraFx.tick(args.state.cam)
#   args.outputs.primitives << Vfx::CameraFx.sprite(args.state.cam, :scene)
#   args.outputs.primitives << Vfx::CameraFx.overlay(args.state.cam)
#
# References: Phaser's camera effects (Fade, Flash, Zoom) and HaxeFlixel's
# FlxCamera, both MIT; written from scratch for DragonRuby.
# This file stands alone: copy it and require it.
module Vfx
  module CameraFx
    def self.new
      { zoom: 1.0, x: 0.0, y: 0.0, flash: nil, fade: nil, fade_alpha: 0.0, fade_color: [0, 0, 0],
        punch: nil, kick: nil }
    end

    # A full-screen burst of colour that fades away. strength 1 is opaque.
    def self.flash(cam, frames: 14, color: [255, 255, 255], strength: 0.9)
      cam[:flash] = { at: 0, frames: frames, color: color, strength: strength }
      cam
    end

    # Moves the fade towards `to`: 1 covers the screen, 0 clears it.
    def self.fade(cam, to:, frames: 30, color: [0, 0, 0])
      cam[:fade_color] = color
      cam[:fade] = { at: 0, frames: [frames, 1].max, from: cam[:fade_alpha], to: to }
      cam
    end

    def self.fade_out(cam, frames: 30, color: [0, 0, 0])
      fade(cam, to: 1.0, frames: frames, color: color)
    end

    def self.fade_in(cam, frames: 30)
      fade(cam, to: 0.0, frames: frames, color: cam[:fade_color])
    end

    # true while a fade is still moving; use it to change scene when it ends.
    def self.fading?(cam)
      !cam[:fade].nil?
    end

    # Zooms in by `amount` at once (0.05 is 5%) and eases back. A new punch,
    # kick or flash replaces one still running.
    def self.punch(cam, amount = 0.06, frames: 16)
      cam[:punch] = { at: 0, frames: frames, amount: amount }
      cam
    end

    # Shoves the camera `distance` pixels towards `angle` degrees and eases
    # back. Kick opposite to a shot for recoil, or along a blow for impact.
    def self.kick(cam, angle, distance = 14, frames: 12)
      cam[:kick] = { at: 0, frames: frames, dx: Math.cos(angle * Math::PI / 180) * distance,
                     dy: Math.sin(angle * Math::PI / 180) * distance }
      cam
    end

    # Call once a frame. It counts whole frames: skip the call while the game
    # is frozen, or keep calling it so a fade runs on through a pause.
    def self.tick(cam)
      cam[:flash] = advance(cam[:flash])
      cam[:punch] = advance(cam[:punch])
      cam[:kick] = advance(cam[:kick])

      cam[:zoom] = cam[:punch] ? 1.0 + (cam[:punch][:amount] * left(cam[:punch])) : 1.0
      cam[:x] = cam[:kick] ? cam[:kick][:dx] * left(cam[:kick]) : 0.0
      cam[:y] = cam[:kick] ? cam[:kick][:dy] * left(cam[:kick]) : 0.0

      fade = cam[:fade]
      if fade
        fade[:at] += 1
        progress = (fade[:at].to_f / fade[:frames]).clamp(0.0, 1.0)
        cam[:fade_alpha] = fade[:from] + ((fade[:to] - fade[:from]) * progress)
        cam[:fade] = nil if progress >= 1.0
      end
      cam
    end

    # The render target `path` as a screen sprite, zoomed about the centre and
    # kicked. Pass a Vfx::Shake hash (anything with :x, :y, :angle) to add it.
    def self.sprite(cam, path, w: 1280, h: 720, shake: { x: 0, y: 0, angle: 0 })
      zoomed_w = w * cam[:zoom]
      zoomed_h = h * cam[:zoom]
      { x: ((w - zoomed_w) / 2) + cam[:x] + shake[:x], y: ((h - zoomed_h) / 2) + cam[:y] + shake[:y],
        w: zoomed_w, h: zoomed_h, path: path, angle: shake[:angle] }
    end

    # The flash and fade rectangles, to draw over the scene. May be empty.
    def self.overlay(cam, w: 1280, h: 720)
      layers = []
      if cam[:fade_alpha] > 0
        r, g, b = cam[:fade_color]
        layers << { x: 0, y: 0, w: w, h: h, path: :solid, r: r, g: g, b: b, a: cam[:fade_alpha] * 255 }
      end
      flash = cam[:flash]
      if flash
        r, g, b = flash[:color]
        layers << { x: 0, y: 0, w: w, h: h, path: :solid, r: r, g: g, b: b, a: flash[:strength] * left(flash) * 255 }
      end
      layers
    end

    def self.advance(effect)
      return nil unless effect

      effect[:at] += 1
      effect[:at] > effect[:frames] ? nil : effect
    end

    # How much of an effect is left, easing out. `at` counts ticks, so the
    # first tick (at 1) is the peak, and the tick after the last is 0.
    def self.left(effect)
      rest = (1.0 - ((effect[:at] - 1).to_f / effect[:frames])).clamp(0.0, 1.0)
      rest * rest
    end
  end
end
