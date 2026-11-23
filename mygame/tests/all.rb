# Run from the repository root: bin/test
require "lib/vfx/shake.rb"
require "lib/vfx/hit_stop.rb"
require "lib/vfx/camera_fx.rb"
require "lib/vfx/squash.rb"

def test_shake_stays_within_its_limits_and_dies_out(_args, assert)
  shake = Vfx::Shake.new(max_x: 20, max_y: 10, max_angle: 2, decay: 1.0)
  Vfx::Shake.add(shake, 5)
  assert.equal! shake[:trauma], 1.0
  moved = false
  60.times do
    Vfx::Shake.tick(shake)
    moved ||= shake[:x].abs > 1
    assert.true! shake[:x].abs <= 20 && shake[:y].abs <= 10 && shake[:angle].abs <= 2
  end
  assert.true! moved, "a full shake moves the screen"
  Vfx::Shake.tick(shake)
  assert.equal! [shake[:trauma], shake[:x], shake[:y], shake[:angle]], [0.0, 0.0, 0.0, 0.0]
end

def test_shake_is_trauma_squared(_args, assert)
  shake = Vfx::Shake.new
  Vfx::Shake.add(shake, 0.5)
  Vfx::Shake.tick(shake)
  assert.equal! shake[:amount], 0.25
end

def test_shake_noise_is_smooth(_args, assert)
  steps = (0...400).map { |i| Vfx::Shake.noise(i * 0.05, 0) }
  assert.true! steps.all? { |value| value >= -1 && value <= 1 }
  jumps = steps.each_cons(2).map { |a, b| (a - b).abs }
  assert.true! jumps.max < 0.2, "largest step #{jumps.max}"
end

def test_hit_stop_freezes_then_slows_then_runs(_args, assert)
  stop = Vfx::HitStop.new
  Vfx::HitStop.freeze(stop, 3)
  Vfx::HitStop.freeze(stop, 2)
  Vfx::HitStop.slow(stop, 2, 0.5)
  assert.true! Vfx::HitStop.frozen?(stop)
  scales = (0...7).map { Vfx::HitStop.tick(stop) }
  assert.equal! scales, [0.0, 0.0, 0.0, 0.5, 0.5, 1.0, 1.0]
end

def test_camera_punch_and_kick_return_to_rest(_args, assert)
  cam = Vfx::CameraFx.new
  Vfx::CameraFx.punch(cam, 0.1, frames: 10)
  Vfx::CameraFx.kick(cam, 0, 20, frames: 10)
  Vfx::CameraFx.tick(cam)
  assert.true! cam[:zoom] > 1.05 && cam[:x] > 10
  sprite = Vfx::CameraFx.sprite(cam, :scene)
  assert.true! sprite[:w] > 1280 && sprite[:x] + (sprite[:w] / 2) > 640
  10.times { Vfx::CameraFx.tick(cam) }
  assert.equal! [cam[:zoom], cam[:x], cam[:y]], [1.0, 0.0, 0.0]
end

def test_camera_flash_and_fade_draw_a_rectangle_while_they_last(_args, assert)
  cam = Vfx::CameraFx.new
  assert.equal! Vfx::CameraFx.overlay(cam), []
  Vfx::CameraFx.flash(cam, frames: 4)
  Vfx::CameraFx.tick(cam)
  assert.equal! Vfx::CameraFx.overlay(cam).length, 1
  4.times { Vfx::CameraFx.tick(cam) }
  assert.equal! Vfx::CameraFx.overlay(cam), []

  Vfx::CameraFx.fade_out(cam, frames: 5, color: [10, 0, 0])
  5.times { Vfx::CameraFx.tick(cam) }
  assert.true! !Vfx::CameraFx.fading?(cam)
  assert.equal! Vfx::CameraFx.overlay(cam).first[:a], 255
  assert.equal! Vfx::CameraFx.overlay(cam).first[:r], 10
  Vfx::CameraFx.fade_in(cam, frames: 5)
  5.times { Vfx::CameraFx.tick(cam) }
  assert.equal! Vfx::CameraFx.overlay(cam), []
end

def test_squash_keeps_the_area_and_the_feet_and_settles(_args, assert)
  body = Vfx::Squash.new
  Vfx::Squash.squash(body, 0.5)
  sprite = Vfx::Squash.apply(body, { x: 100, y: 50, w: 80, h: 80 })
  assert.true! (sprite[:w] * sprite[:h] - 6400).abs < 0.001
  assert.true! sprite[:w] > 80 && sprite[:h] < 80
  assert.equal! sprite[:y], 50
  assert.true! (sprite[:x] + (sprite[:w] / 2) - 140).abs < 0.001
  crossed = false
  120.times do
    Vfx::Squash.tick(body)
    crossed ||= body[:value] < 0
  end
  assert.true! crossed, "the spring overshoots into a stretch"
  assert.true! body[:value].abs < 0.001
end

# --- particles -------------------------------------------------------------
require "lib/vfx/particles.rb"
require "lib/vfx/trail.rb"
require "lib/vfx/transition.rb"
require "lib/vfx/lights.rb"
require "lib/vfx/fog.rb"
require "lib/vfx/rgb_split.rb"
require "lib/vfx/pixelate.rb"
require "lib/vfx/film.rb"

def test_particles_are_born_within_their_ranges(_args, assert)
  emitter = Vfx::Particles.new
  Vfx::Particles.emit(emitter, x: 100, y: 200, count: 50, angle: 90, spread: 20, speed: 2..4, life: 10..20, size: 6..8)
  assert.equal! Vfx::Particles.count(emitter), 50
  Vfx::Particles.sprites(emitter).each do |particle|
    speed = Math.sqrt((particle[:vx]**2) + (particle[:vy]**2))
    assert.true! speed >= 2 && speed <= 4.0001, "speed #{speed}"
    assert.true! particle[:vy] > 0, "a narrow cone around 90 degrees points up"
    assert.true! particle[:life] >= 10 && particle[:life] <= 20
    assert.true! particle[:w] >= 6 && particle[:w] <= 8
    assert.equal! [particle[:x], particle[:y]], [100, 200]
  end
end

def test_particles_move_fade_shrink_change_colour_and_die(_args, assert)
  emitter = Vfx::Particles.new
  Vfx::Particles.emit(emitter, x: 0, y: 0, angle: 0, spread: 0, speed: 2, life: 10, size: 20, size_end: 0,
                               color: [255, 0, 0], color_end: [0, 0, 255], gravity: 1)
  5.times { Vfx::Particles.tick(emitter) }
  particle = Vfx::Particles.sprites(emitter).first
  assert.true! (particle[:x] - 10).abs < 0.001
  assert.true! particle[:y] < 0, "gravity pulls it down"
  assert.equal! [particle[:w], particle[:a], particle[:r], particle[:b]], [10.0, 127.5, 127.5, 127.5]
  5.times { Vfx::Particles.tick(emitter) }
  assert.equal! Vfx::Particles.count(emitter), 0
end

def test_particles_drop_the_oldest_beyond_the_maximum(_args, assert)
  emitter = Vfx::Particles.new(max: 10)
  Vfx::Particles.emit(emitter, x: 1, y: 0, count: 8)
  Vfx::Particles.emit(emitter, x: 2, y: 0, count: 8)
  assert.equal! Vfx::Particles.count(emitter), 10
  assert.equal! Vfx::Particles.sprites(emitter).count { |particle| particle[:x] == 2 }, 8
end

def test_particles_stand_still_when_time_stops(_args, assert)
  emitter = Vfx::Particles.new
  Vfx::Particles.emit(emitter, x: 5, y: 5, speed: 3, life: 10)
  20.times { Vfx::Particles.tick(emitter, 0.0) }
  particle = Vfx::Particles.sprites(emitter).first
  assert.equal! [particle[:x], particle[:y], particle[:age]], [5, 5, 0.0]
end

# --- trail -----------------------------------------------------------------

def test_trail_keeps_fading_copies_and_lets_them_die(_args, assert)
  trail = Vfx::Trail.new(life: 6, every: 2)
  6.times { |frame| Vfx::Trail.tick(trail, { x: frame * 10, y: 0, w: 20, h: 20, path: :solid }) }
  ghosts = Vfx::Trail.sprites(trail, alpha: 120)
  assert.equal! ghosts.map { |ghost| ghost[:x] }, [0, 20, 40]
  assert.true! ghosts[0][:a] < ghosts[1][:a] && ghosts[1][:a] < ghosts[2][:a], "older copies are fainter"
  assert.true! ghosts.all? { |ghost| ghost[:a] <= 120 }
  6.times { Vfx::Trail.tick(trail) }
  assert.equal! Vfx::Trail.sprites(trail), []
end

def test_trail_tints_and_shrinks_about_the_centre(_args, assert)
  trail = Vfx::Trail.new(life: 10, every: 1)
  Vfx::Trail.tick(trail, { x: 100, y: 100, w: 40, h: 40, path: :solid, r: 1, g: 2, b: 3 })
  5.times { Vfx::Trail.tick(trail) }
  ghost = Vfx::Trail.sprites(trail, color: [9, 8, 7], shrink: 0.5).first
  assert.equal! [ghost[:r], ghost[:g], ghost[:b]], [9, 8, 7]
  assert.equal! [ghost[:w], ghost[:h]], [30.0, 30.0]
  assert.equal! [ghost[:x] + (ghost[:w] / 2), ghost[:y] + (ghost[:h] / 2)], [120.0, 120.0]
end

# --- transition ------------------------------------------------------------

def test_transition_covers_fully_exactly_once_and_then_ends(_args, assert)
  Vfx::Transition::KINDS.each do |kind|
    transition = Vfx::Transition.new
    assert.equal! Vfx::Transition.overlay(transition), []
    Vfx::Transition.start(transition, kind, frames: 20)
    midpoints = 0
    covers = []
    21.times do
      Vfx::Transition.tick(transition)
      midpoints += 1 if Vfx::Transition.midpoint?(transition)
      covers << Vfx::Transition.cover(transition)
    end
    assert.equal! midpoints, 1, "#{kind} swaps the scene once"
    assert.equal! covers.max, 1.0
    assert.equal! covers.index(1.0), 9
    assert.true! !Vfx::Transition.active?(transition)
    assert.equal! Vfx::Transition.overlay(transition), []
  end
end

# Adds up the area of the shapes; at the midpoint it must be the whole screen.
def test_transition_shapes_cover_the_whole_screen_at_the_midpoint(_args, assert)
  [:fade, :wipe, :tiles, :blinds].each do |kind|
    transition = Vfx::Transition.new
    Vfx::Transition.start(transition, kind, frames: 20)
    10.times { Vfx::Transition.tick(transition) }
    area = Vfx::Transition.overlay(transition).sum { |shape| shape[:w] * shape[:h] }
    assert.true! (area - (1280 * 720)).abs < 1, "#{kind} covers #{area}"
  end
end

def test_transition_iris_closes_on_its_point(_args, assert)
  transition = Vfx::Transition.new
  Vfx::Transition.start(transition, :iris, frames: 20, x: 300, y: 200)
  Vfx::Transition.tick(transition)
  hole = Vfx::Transition.overlay(transition).first
  assert.equal! [hole[:x] + (hole[:w] / 2), hole[:y] + (hole[:h] / 2)], [300.0, 200.0]
  assert.true! hole[:w] / 2 > 900, "it starts beyond the furthest corner"
  9.times { Vfx::Transition.tick(transition) }
  shapes = Vfx::Transition.overlay(transition)
  assert.true! shapes.none? { |shape| shape[:path] == "sprites/vfx/hole.png" }, "closed: no hole left"
  assert.true! shapes.sum { |shape| shape[:w] * shape[:h] } >= 1280 * 720
end

def test_transition_wipe_enters_from_the_left_and_leaves_to_the_right(_args, assert)
  transition = Vfx::Transition.new
  Vfx::Transition.start(transition, :wipe, frames: 20)
  5.times { Vfx::Transition.tick(transition) }
  entering = Vfx::Transition.overlay(transition).first
  assert.equal! [entering[:x], entering[:w]], [0, 640.0]
  10.times { Vfx::Transition.tick(transition) }
  leaving = Vfx::Transition.overlay(transition).first
  assert.equal! [leaving[:x], leaving[:w]], [640.0, 640.0]
end

# --- lights ----------------------------------------------------------------

def test_lights_become_additive_sprites_centred_on_the_light(_args, assert)
  sprites = Vfx::Lights.sprites([{ x: 100, y: 200, radius: 50 }, { x: 0, y: 0, radius: 10, r: 255, g: 100, b: 0, a: 128 }])
  assert.equal! [sprites[0][:x], sprites[0][:y], sprites[0][:w], sprites[0][:h]], [50, 150, 100, 100]
  assert.equal! [sprites[0][:r], sprites[0][:g], sprites[0][:b], sprites[0][:a]], [255, 255, 255, 255]
  assert.equal! [sprites[1][:g], sprites[1][:a]], [100, 128]
  assert.true! sprites.all? { |sprite| sprite[:blendmode] == 2 }
end

def test_lights_draw_returns_a_multiply_layer_over_the_screen(args, assert)
  layer = Vfx::Lights.draw(args.outputs, [{ x: 10, y: 10, radius: 5 }], target: :test_lights)
  assert.equal! layer, { x: 0, y: 0, w: 1280, h: 720, path: :test_lights, blendmode: 8 }
end

def test_lights_flicker_stays_close_to_one(_args, assert)
  values = (0...300).map { |clock| Vfx::Lights.flicker(clock, seed: 3, amount: 0.1) }
  assert.true! values.min >= 0.9 && values.max <= 1.1
  assert.true! values.max - values.min > 0.1, "and it does move"
end

# --- fog -------------------------------------------------------------------

def test_fog_clears_what_is_in_view_and_dims_what_was(_args, assert)
  fog = Vfx::Fog.new(columns: 10, rows: 10, cell: 10, dim: 100, speed: 0.5)
  assert.true! !Vfx::Fog.seen?(fog, 25, 25)
  30.times do
    Vfx::Fog.reveal(fog, 25, 25, 12)
    Vfx::Fog.tick(fog)
  end
  assert.true! Vfx::Fog.visible?(fog, 25, 25) && Vfx::Fog.seen?(fog, 25, 25)
  assert.true! !Vfx::Fog.visible?(fog, 85, 85) && !Vfx::Fog.seen?(fog, 85, 85)
  near = fog[:cells][(2 * 10) + 2][:alpha]
  far = fog[:cells][(8 * 10) + 8][:alpha]
  assert.true! near < 1 && far == 255.0

  30.times { Vfx::Fog.tick(fog) }
  assert.true! !Vfx::Fog.visible?(fog, 25, 25), "nobody is looking any more"
  assert.true! Vfx::Fog.seen?(fog, 25, 25)
  assert.true! (fog[:cells][(2 * 10) + 2][:alpha] - 100).abs < 1, "seen before: dimmed, not black"
end

def test_fog_reveal_is_a_circle_and_ignores_what_is_off_the_map(_args, assert)
  fog = Vfx::Fog.new(columns: 10, rows: 10, cell: 10, x: 100, y: 50)
  Vfx::Fog.reveal(fog, 100, 50, 25)
  Vfx::Fog.reveal(fog, -500, -500, 30)
  Vfx::Fog.tick(fog)
  assert.true! Vfx::Fog.visible?(fog, 105, 55)
  assert.true! !Vfx::Fog.visible?(fog, 125, 75), "the corner of the square around the circle"
  assert.true! !Vfx::Fog.visible?(fog, 50, 50), "left of the map"
  assert.equal! fog[:cells].count { |cell| cell[:visible] }, 4
end

def test_fog_draws_one_pixel_per_cell_that_is_not_clear(args, assert)
  fog = Vfx::Fog.new(columns: 4, rows: 3, cell: 50, x: 20, y: 10, speed: 1.0)
  Vfx::Fog.reveal(fog, 45, 35, 10)
  Vfx::Fog.tick(fog)
  cells = Vfx::Fog.pixels(fog, [1, 2, 3])
  assert.equal! cells.length, 11
  assert.true! cells.none? { |cell| cell[:x] == 0 && cell[:y] == 0 }
  assert.true! cells.all? { |cell| cell[:w] == 1 && cell[:a] == 255.0 && cell[:b] == 3 }
  layer = Vfx::Fog.draw(args.outputs, fog, target: :test_fog)
  assert.equal! [layer[:x], layer[:y], layer[:w], layer[:h], layer[:path]], [20, 10, 200, 150, :test_fog]
end

# --- rgb split, pixelate, film --------------------------------------------

def test_rgb_split_slides_red_and_blue_apart_and_leaves_green(_args, assert)
  backdrop, red, green, blue = Vfx::RgbSplit.sprites(:scene, 10, angle: 0)
  assert.equal! [backdrop[:path], backdrop[:r], backdrop[:g], backdrop[:b]], [:solid, 0, 0, 0]
  assert.equal! [red[:x], green[:x], blue[:x]], [-10.0, 0, 10.0]
  assert.equal! [[red[:r], red[:g], red[:b]], [green[:r], green[:g], green[:b]], [blue[:r], blue[:g], blue[:b]]],
                [[255, 0, 0], [0, 255, 0], [0, 0, 255]]
  assert.true! [red, green, blue].all? { |layer| layer[:blendmode] == 2 && layer[:path] == :scene }
  up = Vfx::RgbSplit.sprites(:scene, 10, angle: 90)
  assert.true! (up[1][:y] + 10).abs < 0.001 && up[1][:x].abs < 0.001
end

def test_pixelate_shrinks_the_scene_and_leaves_size_one_alone(args, assert)
  assert.equal! Vfx::Pixelate.grid(16, 1280, 720), [80, 45]
  assert.equal! Vfx::Pixelate.grid(100, 1280, 720), [13, 8]
  assert.equal! Vfx::Pixelate.grid(5000, 1280, 720), [1, 1]
  assert.equal! Vfx::Pixelate.draw(args.outputs, :scene, 1), { x: 0, y: 0, w: 1280, h: 720, path: :scene }
  blocky = Vfx::Pixelate.draw(args.outputs, :scene, 16, target: :test_pixelate)
  assert.equal! blocky, { x: 0, y: 0, w: 1280, h: 720, path: :test_pixelate, scale_quality_enum: 0 }
end

def test_film_vignette_is_one_sprite_and_grain_covers_the_screen(_args, assert)
  vignette = Vfx::Film.vignette(strength: 0.5, color: [200, 0, 0])
  assert.equal! [vignette[:w], vignette[:h], vignette[:r], vignette[:a]], [1280, 720, 200, 127.5]
  10.times do
    tiles = Vfx::Film.grain(strength: 0.2, tile: 256)
    assert.true! tiles.all? { |tile| tile[:a] == 51.0 }
    assert.true! tiles.map { |tile| tile[:x] }.min <= 0 && tiles.map { |tile| tile[:x] + 256 }.max >= 1280
    assert.true! tiles.map { |tile| tile[:y] }.min <= 0 && tiles.map { |tile| tile[:y] + 256 }.max >= 720
  end
end

# --- edge cases ------------------------------------------------------------

def test_transition_of_any_length_swaps_once_and_ends_uncovered(_args, assert)
  [0, 1, 2, 3, 5, 7].each do |frames|
    transition = Vfx::Transition.new
    Vfx::Transition.start(transition, :wipe, frames: frames)
    assert.equal! Vfx::Transition.cover(transition), 0.0
    midpoints = 0
    covers = []
    while Vfx::Transition.active?(transition)
      Vfx::Transition.tick(transition)
      midpoints += 1 if Vfx::Transition.midpoint?(transition)
      covers << Vfx::Transition.cover(transition) if Vfx::Transition.active?(transition)
    end
    assert.equal! midpoints, 1, "#{frames} frames"
    assert.equal! covers.max, 1.0
    assert.equal! covers.last, 0.0, "#{frames} frames end uncovered: #{covers}"
  end
end

def test_transition_refuses_a_kind_it_does_not_know(_args, assert)
  transition = Vfx::Transition.new
  refused = false
  begin
    Vfx::Transition.start(transition, :iriss)
  rescue ArgumentError
    refused = true
  end
  assert.true! refused
  assert.true! !Vfx::Transition.active?(transition)
end

def test_camera_pulses_are_at_full_strength_on_their_first_tick(_args, assert)
  cam = Vfx::CameraFx.new
  Vfx::CameraFx.flash(cam, frames: 1, strength: 0.5)
  Vfx::CameraFx.punch(cam, 0.1)
  Vfx::CameraFx.kick(cam, 0, 20)
  Vfx::CameraFx.tick(cam)
  assert.equal! Vfx::CameraFx.overlay(cam).first[:a], 127.5
  assert.true! (cam[:zoom] - 1.1).abs < 0.0001 && (cam[:x] - 20).abs < 0.0001
  Vfx::CameraFx.tick(cam)
  assert.equal! Vfx::CameraFx.overlay(cam), [], "a one-frame flash lasts one frame"
end

def test_a_pause_changes_nothing_in_shake_squash_or_particles(_args, assert)
  shake = Vfx::Shake.new
  Vfx::Shake.add(shake, 0.8)
  3.times { Vfx::Shake.tick(shake) }
  before = shake.dup
  5.times { Vfx::Shake.tick(shake, 0) }
  assert.equal! shake, before

  body = Vfx::Squash.new
  Vfx::Squash.pop(body, 0.2)
  5.times { Vfx::Squash.tick(body, 0.0) }
  assert.equal! [body[:value], body[:velocity]], [0.0, 0.2]

  emitter = Vfx::Particles.new
  Vfx::Particles.emit(emitter, x: 0, y: 0, angle: 0, spread: 0, speed: 10, drag: 0.5, life: 10)
  5.times { Vfx::Particles.tick(emitter, 0.0) }
  assert.true! (Vfx::Particles.sprites(emitter).first[:vx] - 10).abs < 0.0001
end

def test_odd_settings_do_not_break_anything(args, assert)
  body = Vfx::Squash.new
  Vfx::Squash.stretch(body, 5)
  wide, tall = Vfx::Squash.scale(body)
  assert.true! (wide - 0.2).abs < 0.0001 && (tall - 5).abs < 0.0001

  trail = Vfx::Trail.new(life: 0, every: 0)
  3.times { Vfx::Trail.tick(trail, { x: 0, y: 0, w: 10, h: 10, a: 128 }) }
  assert.true! Vfx::Trail.sprites(trail).all? { |ghost| ghost[:a] >= 0 && ghost[:a] <= 128 }

  emitter = Vfx::Particles.new(max: -5)
  Vfx::Particles.emit(emitter, x: 0, y: 0, count: 3)
  assert.equal! Vfx::Particles.count(emitter), 0

  assert.equal! Vfx::Film.grain(strength: 0), []
  assert.equal! Vfx::Film.grain(tile: 0), []
  assert.equal! Vfx::RgbSplit.sprites(:scene, 0), [{ x: 0, y: 0, w: 1280, h: 720, path: :scene }]
  assert.equal! Vfx::Lights.sprites([]), []
  assert.equal! Vfx::Transition.overlay(Vfx::Transition.new), []
  assert.equal! Vfx::Pixelate.draw(args.outputs, :scene, 0)[:path], :scene
end
require "tests/wave_two.rb"
