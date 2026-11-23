# The second wave of effects. Loaded by tests/all.rb.
require "lib/vfx/silhouette.rb"
require "lib/vfx/damage_numbers.rb"
require "lib/vfx/lightning.rb"
require "lib/vfx/ribbon.rb"
require "lib/vfx/decals.rb"
require "lib/vfx/weather.rb"
require "lib/vfx/parallax.rb"
require "lib/vfx/slices.rb"
require "lib/vfx/warp.rb"
require "lib/vfx/shadows.rb"

def test_silhouette_mask_sits_where_the_sprite_is(args, assert)
  mask = Vfx::Silhouette.mask(args.outputs, { x: 10, y: 20, w: 64, h: 48, path: "sprites/vfx/circle.png", angle: 30 }, target: :test_mask)
  assert.equal! mask, { x: 10, y: 20, w: 64, h: 48, path: :test_mask, angle: 30 }
end

def test_silhouette_flash_outline_and_shadow_are_tinted_copies(_args, assert)
  mask = { x: 100, y: 100, w: 50, h: 50, path: :m, angle: 0 }
  assert.equal! Vfx::Silhouette.flash(mask, 0.5)[:a], 127.5
  assert.equal! Vfx::Silhouette.flash(mask, 7)[:a], 255.0
  assert.equal! Vfx::Silhouette.flash(mask, 1, color: [255, 0, 0])[:g], 0

  stamps = Vfx::Silhouette.outline(mask, width: 4, color: [1, 2, 3])
  assert.equal! stamps.length, 8
  assert.true! stamps.all? { |stamp| stamp[:b] == 3 && stamp[:w] == 50 }
  assert.true! stamps.all? { |stamp| (stamp[:x] - 100).abs <= 4 && (stamp[:y] - 100).abs <= 4 && [stamp[:x], stamp[:y]] != [100, 100] }

  shadow = Vfx::Silhouette.shadow(mask, dx: 5, dy: -7, alpha: 90)
  assert.equal! [shadow[:x], shadow[:y], shadow[:r], shadow[:a]], [105, 93, 0, 90]
end

def test_damage_numbers_rise_slow_fade_and_go(_args, assert)
  numbers = Vfx::DamageNumbers.new
  Vfx::DamageNumbers.pop(numbers, x: 100, y: 100, text: 12, life: 20, drift: 0, rise: 3, gravity: 0.1, size: 30)
  shadow, label = Vfx::DamageNumbers.labels(numbers)
  assert.equal! [label[:text], label[:size_px], label[:a]], ["12", 48.0, 255]
  assert.equal! [shadow[:r], shadow[:x]], [0, 102]

  10.times { Vfx::DamageNumbers.tick(numbers) }
  label = Vfx::DamageNumbers.labels(numbers).last
  assert.true! label[:y] > 120 && label[:y] < 130, "it slows as it rises: #{label[:y]}"
  assert.equal! [label[:x], label[:size_px], label[:a]], [100.0, 30.0, 255]
  6.times { Vfx::DamageNumbers.tick(numbers) }
  assert.true! Vfx::DamageNumbers.labels(numbers).last[:a] < 255
  4.times { Vfx::DamageNumbers.tick(numbers) }
  assert.equal! Vfx::DamageNumbers.labels(numbers), []
end

def test_damage_numbers_hold_still_when_time_stops(_args, assert)
  numbers = Vfx::DamageNumbers.new
  Vfx::DamageNumbers.pop(numbers, x: 0, y: 0, text: "x")
  30.times { Vfx::DamageNumbers.tick(numbers, 0.0) }
  assert.equal! numbers[:live].first[:y], 0
end

def test_lightning_joins_its_two_ends_in_an_unbroken_line(_args, assert)
  pieces = Vfx::Lightning.bolt(100, 600, 500, 50, seed: 7, branches: 0)
  assert.equal! pieces.length, 32
  assert.equal! [pieces.first[:x1], pieces.first[:y1], pieces.last[:x2], pieces.last[:y2]], [100, 600, 500, 50]
  pieces.each_cons(2) { |a, b| assert.equal! [a[:x2], a[:y2]], [b[:x1], b[:y1]] }
  assert.true! pieces.any? { |piece| (piece[:x1] - (100 + ((600 - piece[:y1]) * 400 / 550.0))).abs > 5 }, "it is not straight"
end

def test_lightning_seeds_repeat_and_branches_are_thinner(_args, assert)
  assert.equal! Vfx::Lightning.bolt(0, 0, 100, 0, seed: 3), Vfx::Lightning.bolt(0, 0, 100, 0, seed: 3)
  assert.true! Vfx::Lightning.bolt(0, 0, 100, 0, seed: 3) != Vfx::Lightning.bolt(0, 0, 100, 0, seed: 4)
  assert.equal! Vfx::Lightning.bolt(0, 0, 100, 0, detail: 0).length, 1
  weights = Vfx::Lightning.bolt(0, 0, 100, 0, seed: 3, branches: 1.0).map { |piece| piece[:weight] }.uniq.sort
  assert.equal! weights, [0.5, 1.0]
end

def test_lightning_lines_span_their_piece(_args, assert)
  glow, core = Vfx::Lightning.sprites([{ x1: 10, y1: 10, x2: 10, y2: 110, weight: 1.0 }], width: 4, alpha: 200)
  assert.equal! [core[:x], core[:y], core[:w], core[:h], core[:a], core[:blendmode]], [10, 8.0, 100.0, 4.0, 200, 2]
  assert.true! (core[:angle] - 90).abs < 0.001
  assert.true! glow[:h] > core[:h] && glow[:a] < core[:a]
end

def test_ribbon_tapers_from_its_width_to_a_point(_args, assert)
  ribbon = Vfx::Ribbon.new(length: 5, width: 20)
  assert.equal! Vfx::Ribbon.sprites(ribbon), []
  8.times { |frame| Vfx::Ribbon.tick(ribbon, frame * 10, 100) }
  assert.equal! ribbon[:points].length, 5
  edges = Vfx::Ribbon.edges(ribbon)
  assert.equal! edges.first, [70.0, 110.0, 70.0, 90.0]
  assert.equal! edges.last, [30.0, 100.0, 30.0, 100.0]
  shapes = Vfx::Ribbon.sprites(ribbon, alpha: 200)
  assert.equal! shapes.length, 8
  assert.true! shapes.first[:a] > shapes.last[:a]
end

def test_ribbon_runs_out_when_it_is_no_longer_fed(_args, assert)
  ribbon = Vfx::Ribbon.new(length: 4)
  4.times { |frame| Vfx::Ribbon.tick(ribbon, frame, frame) }
  3.times { Vfx::Ribbon.tick(ribbon) }
  assert.equal! Vfx::Ribbon.sprites(ribbon), []
  3.times { Vfx::Ribbon.tick(ribbon) }
  assert.equal! ribbon[:points], []
  3.times { Vfx::Ribbon.tick(ribbon, 5, 5) }
  assert.true! Vfx::Ribbon.edges(ribbon).flatten.none?(&:nan?), "a point that stands still is not divided by zero"
end

def test_decals_are_drawn_once_and_wiped_only_when_asked(args, assert)
  decals = Vfx::Decals.new
  assert.true! decals[:wipe], "the first draw starts from an empty layer"
  Vfx::Decals.stamp(decals, { x: 0, y: 0, w: 5, h: 5, path: :solid })
  layer = Vfx::Decals.draw(args.outputs, decals, target: :test_decals)
  assert.equal! layer, { x: 0, y: 0, w: 1280, h: 720, path: :test_decals }
  assert.equal! [decals[:waiting], decals[:wipe]], [[], false]
  Vfx::Decals.stamp(decals, { x: 0, y: 0, w: 5, h: 5, path: :solid })
  Vfx::Decals.clear(decals)
  assert.equal! [decals[:waiting], decals[:wipe]], [[], true]
end

def test_weather_keeps_every_drop_on_screen(_args, assert)
  [:rain, :snow].each do |kind|
    weather = Vfx::Weather.new(kind, count: 40, w: 400, h: 300)
    600.times { Vfx::Weather.tick(weather) }
    sprites = Vfx::Weather.sprites(weather)
    assert.equal! sprites.length, 40
    assert.true! sprites.all? { |drop| drop[:x] >= 0 && drop[:x] < 400 && drop[:y] > -110 && drop[:y] < 450 }, kind.to_s
  end
end

def test_weather_near_drops_are_bigger_and_fall_faster(_args, assert)
  weather = Vfx::Weather.new(:rain, count: 2, wind: 0)
  near, far = weather[:drops]
  near.merge!(depth: 1.0, y: 500.0, hurry: 1.0)
  far.merge!(depth: 0.5, y: 500.0, hurry: 1.0)
  Vfx::Weather.tick(weather)
  assert.equal! [near[:y], far[:y]], [470.0, 485.0]
  big, small = Vfx::Weather.sprites(weather)
  assert.true! big[:h] > small[:h] && big[:a] > small[:a]
  Vfx::Weather.tick(weather, 0.0)
  assert.equal! near[:y], 470.0
  assert.equal! Vfx::Weather.new(:rain, wind: -14)[:wind], -14
end

# A streak is drawn upright and turned. Rain blown to the left is turned
# clockwise (a negative angle), so its tail trails up and to the right.
def test_weather_rain_points_the_way_it_falls(_args, assert)
  assert.equal! Vfx::Weather.lean(Vfx::Weather.new(:rain, wind: 0)), 0.0
  assert.true! (Vfx::Weather.lean(Vfx::Weather.new(:rain, wind: -30, fall: 30)) + 45).abs < 0.001
  assert.true! (Vfx::Weather.lean(Vfx::Weather.new(:rain, wind: 30, fall: 30)) - 45).abs < 0.001
  assert.equal! Vfx::Weather.lean(Vfx::Weather.new(:snow)), 0
  blown = Vfx::Weather.new(:rain, count: 1, wind: -30, fall: 30)
  assert.true! Vfx::Weather.sprites(blown).first[:angle] < 0
end

def test_weather_rain_lands_on_the_ground_and_splashes(_args, assert)
  weather = Vfx::Weather.new(:rain, count: 30, wind: 0, ground: 200, ground_depth: 70)
  assert.equal! Vfx::Weather.landing(weather, 0.3), 200.0
  assert.equal! Vfx::Weather.landing(weather, 1.0), 130.0
  assert.equal! Vfx::Weather.landing(Vfx::Weather.new(:rain), 1.0), nil
  splashed = 0
  200.times do
    Vfx::Weather.tick(weather)
    splashed = [splashed, weather[:splashes].length].max
    assert.true! weather[:drops].all? { |drop| drop[:y] > 100 }, "no drop falls through the ground"
  end
  assert.true! splashed > 0
  assert.true! weather[:splashes].all? { |splash| splash[:y] <= 200 && splash[:y] >= 130 && splash[:age] < 10 }
  assert.equal! Vfx::Weather.sprites(weather).length, 30 + weather[:splashes].length

  snow = Vfx::Weather.new(:snow, count: 30, ground: 200)
  2000.times { Vfx::Weather.tick(snow) }
  assert.equal! snow[:splashes], [], "snow settles without a splash"
end

def test_parallax_covers_the_screen_and_moves_by_its_factor(_args, assert)
  layers = [{ path: "far.png", w: 500, h: 100, y: 50, factor: 0.5, r: 9 }]
  still = Vfx::Parallax.sprites(layers, 0)
  assert.equal! still.map { |sprite| sprite[:x] }, [0, 500, 1000]
  moved = Vfx::Parallax.sprites(layers, 100)
  assert.equal! moved.map { |sprite| sprite[:x] }, [-50.0, 450.0, 950.0]
  assert.true! moved.last[:x] + 500 >= 1280
  assert.true! moved.all? { |sprite| sprite[:r] == 9 && sprite[:y] == 50 && sprite[:path] == "far.png" }
  assert.equal! Vfx::Parallax.sprites(layers, 1000).first[:x], 0.0
  assert.equal! Vfx::Parallax.sprites([layers.first.merge(factor: 0)], 12_345).first[:x], 0
end

def test_slices_cut_the_region_into_strips_that_show_their_own_rows(_args, assert)
  strips = Vfx::Slices.sprites(:scene, x: 100, y: 200, w: 300, h: 10, slice: 4) { |row| row * 2 }
  assert.equal! strips.length, 3
  assert.equal! strips.map { |strip| [strip[:x], strip[:y], strip[:source_x], strip[:source_y]] },
                [[100, 200, 100, 200], [102, 204, 100, 204], [104, 208, 100, 208]]
  assert.true! strips.all? { |strip| strip[:w] == 300 && strip[:source_w] == 300 && strip[:h] == 4 }
end

def test_slices_wave_reflection_and_glitch(_args, assert)
  wave = Vfx::Slices.wave(:scene, 10, amplitude: 6, h: 400)
  assert.true! wave.all? { |strip| strip[:x].abs <= 6 }
  assert.true! wave.map { |strip| strip[:x] }.max > 5, "the wave reaches its amplitude"

  mirror = Vfx::Slices.reflection(:scene, 0, water_y: 200, depth: 90, slice: 3)
  assert.equal! mirror.length, 30
  assert.equal! [mirror.first[:y], mirror.first[:source_y]], [197, 200]
  assert.equal! [mirror.last[:y], mirror.last[:source_y]], [110, 287]
  assert.true! mirror.all? { |strip| strip[:flip_vertically] }
  assert.true! mirror.first[:a] > mirror.last[:a], "it fades with depth"

  assert.equal! Vfx::Slices.glitch(:scene, 4), Vfx::Slices.glitch(:scene, 4)
  bands = Vfx::Slices.glitch(:scene, 4, bands: 6, shift: 50)
  assert.equal! bands.length, 6
  assert.true! bands.all? { |band| band[:x].abs <= 50 && band[:y] >= 0 && band[:y] + band[:h] <= 720 && band[:y] == band[:source_y] }
end

def test_warp_leaves_the_picture_alone_when_nothing_moves(_args, assert)
  shapes = Vfx::Warp.sprites(:scene, columns: 4, rows: 2) { |_x, _y| [0, 0] }
  assert.equal! shapes.length, 16
  shapes.each do |shape|
    assert.equal! [shape[:x], shape[:y], shape[:x2], shape[:y2], shape[:x3], shape[:y3]],
                  [shape[:source_x], shape[:source_y], shape[:source_x2], shape[:source_y2], shape[:source_x3], shape[:source_y3]]
  end
end

def test_warp_moves_inner_corners_only(_args, assert)
  shapes = Vfx::Warp.sprites(:scene, columns: 2, rows: 2) { |_x, _y| [30, -10] }
  moved = shapes.flat_map { |s| [[s[:x] - s[:source_x], s[:y] - s[:source_y]], [s[:x2] - s[:source_x2], s[:y2] - s[:source_y2]], [s[:x3] - s[:source_x3], s[:y3] - s[:source_y3]]] }
  assert.equal! moved.uniq.sort, [[0.0, 0.0], [30.0, -10.0]]
  assert.equal! moved.count([30.0, -10.0]), 6, "the one inner corner, shared by six triangles"
end

def test_warp_shockwave_pushes_outwards_on_the_ring_only(_args, assert)
  pushes = []
  Vfx::Warp.sprites(:scene) { |x, y|
    pushes << [x, y]
    [0, 0]
  }
  ring = Vfx::Warp.shockwave(:scene, 640, 360, 200, width: 60, amplitude: 20)
  at = lambda do |x, y|
    shape = ring.find { |s| s[:source_x] == x && s[:source_y] == y }
    [shape[:x] - x, shape[:y] - y]
  end
  assert.equal! at.call(640, 360), [0, 0], "the centre is inside the ring"
  dx, dy = at.call(840, 360)
  assert.true! (dx - 20).abs < 0.001 && dy.abs < 0.001, "on the ring: pushed straight out by the full amplitude"
  assert.equal! at.call(1000, 360), [0, 0], "beyond the ring"
  assert.true! pushes.length > 500
end

SQUARE_ROOM = [[400, 300, 600, 300]].freeze # one wall, above the light at (500, 200)

def test_shadows_rays_stop_at_walls(_args, assert)
  hit = Vfx::Shadows.cast(500, 200, 0, 1, SQUARE_ROOM)
  assert.equal! hit, [500.0, 300.0]
  assert.equal! Vfx::Shadows.cast(500, 200, 0, -1, SQUARE_ROOM), [500, 200], "nothing that way"
  assert.true! Vfx::Shadows.sees?(500, 200, 500, 290, SQUARE_ROOM)
  assert.true! !Vfx::Shadows.sees?(500, 200, 500, 310, SQUARE_ROOM), "behind the wall"
  assert.true! Vfx::Shadows.sees?(500, 200, 900, 310, SQUARE_ROOM), "past the end of the wall"
end

def test_shadows_polygon_stays_inside_the_radius_and_behind_no_wall(_args, assert)
  points = Vfx::Shadows.polygon(500, 200, SQUARE_ROOM, 300)
  assert.true! points.length >= 18
  assert.true! points.all? { |x, y| x >= 199.9 && x <= 800.1 && y >= -100.1 && y <= 500.1 }
  above = points.select { |x, y| x > 399 && x < 601 && y > 200 }.map { |_x, y| y }
  assert.true! above.length >= 2 && above.max <= 300.001, "above the light nothing passes the wall: #{above}"
  assert.true! points.any? { |x, y| y > 499 && (x < 300 || x > 700) }, "to either side the light reaches the edge"
  turns = points.map { |x, y| Math.atan2(y - 200, x - 500) }
  assert.equal! turns, turns.sort, "the points go round the light in order"
end

def test_shadows_light_is_an_additive_square_around_the_lamp(args, assert)
  glow = Vfx::Shadows.light(args.outputs, { x: 500, y: 200, radius: 150 }, SQUARE_ROOM, target: :test_shadow)
  assert.equal! glow, { x: 350, y: 50, w: 300, h: 300, path: :test_shadow, blendmode: 2 }
  fan = Vfx::Shadows.fan([[400, 100], [600, 100], [500, 300]], 150, 350, 50)
  assert.equal! fan.length, 3
  assert.equal! [fan.first[:x], fan.first[:y], fan.first[:x2], fan.first[:y2], fan.first[:x3], fan.first[:y3]], [150, 150, 50, 50, 250, 50]
end

def test_lights_take_extra_sprites(args, assert)
  layer = Vfx::Lights.draw(args.outputs, [], target: :test_lights_extra, extra: [{ x: 0, y: 0, w: 10, h: 10, path: :solid, blendmode: 2 }])
  assert.equal! layer[:blendmode], 8
end

def test_weather_refuses_a_kind_it_does_not_know(_args, assert)
  refused = false
  begin
    Vfx::Weather.new(:hail)
  rescue ArgumentError
    refused = true
  end
  assert.true! refused
end
