module Demos
  # Runs the four camera effects one after the other over the same scene.
  module CameraFx
    ID = "camera_fx".freeze
    TITLE = "Camera flash, fade, punch, kick".freeze
    BLURB = "The scene is one render target; the camera effects change how that sprite is drawn, plus a rectangle over it.".freeze
    CONTROLS = "Click or SPACE: next effect    1 flash   2 punch   3 kick   4 fade".freeze
    SHOT_AT = 25
    FILM_FOR = 340

    ORDER = [:flash, :punch, :kick, :fade].freeze
    CALLS = { flash: "Vfx::CameraFx.flash(cam)", punch: "Vfx::CameraFx.punch(cam, 0.1)",
              kick: "Vfx::CameraFx.kick(cam, angle, 30)", fade: "Vfx::CameraFx.fade_out(cam), then fade_in(cam)" }.freeze

    def self.setup
      { cam: Vfx::CameraFx.new, clock: 0, next: 0, last: nil, kicks: 0 }
    end

    def self.tick(args, demo, input)
      cam = demo[:cam]
      demo[:clock] += 1
      chosen = input[:number] && ORDER[input[:number] - 1]
      chosen ||= ORDER[demo[:next]] if input[:action] || (input[:auto] && demo[:clock] % 80 == 20)
      trigger(demo, chosen) if chosen
      # A fade that has covered the screen comes straight back.
      Vfx::CameraFx.fade_in(cam, frames: 24) if cam[:fade_alpha] >= 1.0 && !Vfx::CameraFx.fading?(cam)
      Vfx::CameraFx.tick(cam)

      scene = args.outputs[:scene]
      scene.w = Stage::W
      scene.h = Stage::H
      Stage.draw(scene)
      scene.primitives << Stage.blob({ x: 420, y: Stage::GROUND, w: 90, h: 90 }, Stage::TEAL)
      scene.primitives << Stage.blob({ x: 760, y: Stage::GROUND, w: 110, h: 110 }, Stage::RED)
      scene.primitives << Stage.circle(640, 470, 30, Stage::YELLOW)

      args.outputs.primitives << Vfx::CameraFx.sprite(cam, :scene)
      args.outputs.primitives << Vfx::CameraFx.overlay(cam)
      args.outputs.primitives << Stage.text(40, 628, CALLS[demo[:last]], color: Stage::YELLOW) if demo[:last]
    end

    def self.trigger(demo, name)
      cam = demo[:cam]
      demo[:last] = name
      demo[:next] = (ORDER.index(name) + 1) % ORDER.length
      case name
      when :flash then Vfx::CameraFx.flash(cam)
      when :punch then Vfx::CameraFx.punch(cam, 0.1)
      when :fade then Vfx::CameraFx.fade_out(cam, frames: 24)
      when :kick
        demo[:kicks] += 1
        Vfx::CameraFx.kick(cam, demo[:kicks] * 135, 30)
      end
    end
  end
end
