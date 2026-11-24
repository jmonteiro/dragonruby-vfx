# Row slices: the scene redrawn as thin horizontal strips, each moved sideways.
#
# This is the oldest screen trick there is (consoles did it between scanlines)
# and it needs no shader. Shift the strips along a sine and the picture ripples:
# heat haze, underwater, a dream. Mirror them below a line and it is a
# reflection in water. Shift a few thick bands at random and it is a glitch.
#
#   args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
#   args.outputs.primitives << Vfx::Slices.wave(:scene, clock, y: 0, h: 300, amplitude: 5)       # haze over the ground
#   args.outputs.primitives << Vfx::Slices.reflection(:scene, clock, water_y: 200, depth: 200)   # water below y 200
#   args.outputs.primitives << Vfx::Slices.glitch(:scene, clock.idiv(4)) if glitching
#
# `path` is a render target the size of the screen holding the scene.
#
# Technique: per-scanline offsets ("raster effects"); pixi-filters'
# ReflectionFilter and GlitchFilter (MIT) show the same looks with a shader.
# Written from scratch. This file stands alone: copy it and require it.
module Vfx
  module Slices
    # The strips of one region, each `slice` pixels tall. The block is given a
    # strip's number, counted from the bottom, and answers how far to move it.
    def self.sprites(path, x: 0, y: 0, w: 1280, h: 720, slice: 4)
      rows = (h.to_f / slice).ceil
      Array.new(rows) do |row|
        bottom = y + (row * slice)
        { x: x + yield(row), y: bottom, w: w, h: slice, path: path,
          source_x: x, source_y: bottom, source_w: w, source_h: slice }
      end
    end

    # A ripple. amplitude: how far strips move, in pixels. wavelength: the
    # height of one wave. speed: how fast it travels. Draw it over the scene.
    def self.wave(path, clock, amplitude: 6, wavelength: 60, speed: 0.12, x: 0, y: 0, w: 1280, h: 720, slice: 4)
      sprites(path, x: x, y: y, w: w, h: h, slice: slice) do |row|
        Math.sin((row * slice * 2 * Math::PI / wavelength) + (clock * speed)) * amplitude
      end
    end

    # What lies above `water_y`, mirrored below it for `depth` pixels, rippling
    # more and fading the deeper it goes. color: the water's.
    def self.reflection(path, clock, water_y:, depth:, amplitude: 6, wavelength: 36, speed: 0.1,
                        color: [130, 175, 235], alpha: 170, x: 0, w: 1280, slice: 3)
      rows = (depth.to_f / slice).ceil
      Array.new(rows) do |row|
        deep = row.to_f / rows
        shift = Math.sin((row * slice * 2 * Math::PI / wavelength) + (clock * speed)) * amplitude * deep
        { x: x + shift, y: water_y - ((row + 1) * slice), w: w, h: slice, path: path, flip_vertically: true,
          source_x: x, source_y: water_y + (row * slice), source_w: w, source_h: slice,
          r: color[0], g: color[1], b: color[2], a: alpha * (1 - (deep * 0.7)) }
      end
    end

    # A few thick bands thrown sideways. seed: a whole number; the same seed
    # gives the same bands, so change it every few frames, not every frame.
    def self.glitch(path, seed, bands: 5, shift: 70, w: 1280, h: 720)
      Array.new(bands) do |band|
        tall = 12 + (scatter(seed, band) * 60)
        bottom = scatter(seed, band + 100) * (h - tall)
        { x: (scatter(seed, band + 200) - 0.5) * 2 * shift, y: bottom, w: w, h: tall, path: path,
          source_x: 0, source_y: bottom, source_w: w, source_h: tall }
      end
    end

    # A repeatable number from 0 to 1 for a seed and a slot.
    def self.scatter(seed, slot)
      value = Math.sin((seed * 127.1) + (slot * 311.7)) * 43_758.5453
      value - value.floor
    end
  end
end
