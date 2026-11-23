# The shader effects' Ruby side: what each hands to the engine. The shaders
# themselves cannot be tested without a window; bin/shots shows them.
require "lib/vfx/pro/crt.rb"
require "lib/vfx/pro/shockwave.rb"
require "lib/vfx/pro/dissolve.rb"
require "lib/vfx/pro/luma_wipe.rb"

def uniform_values(shader)
  shader[:uniforms].map { |uniform| uniform[:value] }
end

def test_pro_crt_passes_its_settings_in_the_shaders_order(_args, assert)
  shader = Vfx::Crt.shader(curve: 0.2, scanlines: 0.5, lines: 300, mask: 0.1, vignette: 0.7, fringe: 2)
  assert.equal! shader[:path], "lib/vfx/pro/crt.frag.hlsl"
  assert.equal! uniform_values(shader), [0.2, 0.5, 0.1, 0.7, 2.0, 300.0]
  assert.true! shader[:uniforms].all? { |uniform| uniform[:type] == :float }
end

def test_pro_shockwave_turns_pixels_into_fractions_of_the_screen(_args, assert)
  shader = Vfx::Shockwave.shader(320, 180, 360, width: 72, strength: 36)
  values = uniform_values(shader)
  assert.equal! values[0..4], [0.25, 0.75, 0.5, 0.1, 0.05]
  assert.true! (values[5] - (1280 / 720.0)).abs < 0.0001
end

def test_pro_dissolve_keeps_progress_in_range_and_scales_the_colour(_args, assert)
  assert.equal! uniform_values(Vfx::Dissolve.shader(7, color: [255, 0, 51]))[0], 1.0
  assert.equal! uniform_values(Vfx::Dissolve.shader(-1))[0], 0.0
  assert.equal! uniform_values(Vfx::Dissolve.shader(0.5, edge: 0.1, grain: 9, seed: 2, color: [255, 0, 51])),
                [0.5, 0.1, 9.0, 2.0, 1.0, 0.0, 0.2]
end

def test_pro_luma_wipe_names_the_new_scene_and_its_pattern(_args, assert)
  shader = Vfx::LumaWipe.shader(:next, 0.25, pattern: :clouds, softness: 0.2)
  assert.equal! shader[:textures], [:next]
  assert.equal! uniform_values(shader)[0..1], [0.25, 0.2]
  assert.equal! shader[:uniforms].last, { type: :int, value: 3 }
  refused = false
  begin
    Vfx::LumaWipe.shader(:next, 0.5, pattern: :spiral)
  rescue ArgumentError
    refused = true
  end
  assert.true! refused
end
