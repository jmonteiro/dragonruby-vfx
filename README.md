# dragonruby-vfx

Visual effects for the [DragonRuby Game Toolkit](https://dragonruby.org),
ported from techniques that are standard in other engines. Each effect is one
Ruby file with no dependencies: copy it into your game and require it.

**[Try the gallery in your browser](https://www.jmonteiro.com/dragonruby-vfx/)**: every effect, playing, with nothing to install.

Not affiliated with DragonRuby LLC. MIT licence; the sprites are CC0.

## Effects

| Effect | File | What it does | Docs |
|---|---|---|---|
| Trauma screen shake | `lib/vfx/shake.rb` | Hits add trauma; the screen sways by trauma squared, on smooth noise | [shake](docs/effects/shake.md) |
| Hit stop | `lib/vfx/hit_stop.rb` | Freezes or slows the game for a few frames when a blow lands | [hit_stop](docs/effects/hit_stop.md) |
| Camera flash, fade, punch, kick | `lib/vfx/camera_fx.rb` | Full-screen flash and fade, zoom punch, directional kick | [camera_fx](docs/effects/camera_fx.md) |
| Squash and stretch | `lib/vfx/squash.rb` | Deforms a sprite on a spring while keeping its area | [squash](docs/effects/squash.md) |
| Particles | `lib/vfx/particles.rb` | Bursts and streams: sparks, smoke, fire, fountains | [particles](docs/effects/particles.md) |
| Afterimage trail | `lib/vfx/trail.rb` | Fading copies of a sprite left behind as it moves | [trail](docs/effects/trail.md) |
| Scene transitions | `lib/vfx/transition.rb` | Fade, wipe, iris, tiles and blinds, with a midpoint to swap the scene | [transition](docs/effects/transition.md) |
| Light map | `lib/vfx/lights.rb` | Coloured lights in darkness, by multiplying a light picture over the scene | [lights](docs/effects/lights.md) |
| Fog of war | `lib/vfx/fog.rb` | Unseen, seen and in-view cells with soft edges | [fog](docs/effects/fog.md) |
| RGB split | `lib/vfx/rgb_split.rb` | Chromatic aberration by drawing the scene in red, green and blue | [rgb_split](docs/effects/rgb_split.md) |
| Pixelate | `lib/vfx/pixelate.rb` | Mosaic by drawing the scene small and stretching it back | [pixelate](docs/effects/pixelate.md) |
| Vignette and film grain | `lib/vfx/film.rb` | Dark corners and shimmering noise as overlays | [film](docs/effects/film.md) |
| Hit flash, outline, shadow | `lib/vfx/silhouette.rb` | A sprite's shape in one colour, by a blend mode: flash it, outline it, shadow it | [silhouette](docs/effects/silhouette.md) |
| Damage numbers | `lib/vfx/damage_numbers.rb` | Numbers that pop, rise, slow and fade | [damage_numbers](docs/effects/damage_numbers.md) |
| Lightning | `lib/vfx/lightning.rb` | Jagged bolts with branches, by midpoint displacement | [lightning](docs/effects/lightning.md) |
| Ribbon trail | `lib/vfx/ribbon.rb` | A tapering band of triangles behind a moving point | [ribbon](docs/effects/ribbon.md) |
| Decals | `lib/vfx/decals.rb` | Marks that stay, drawn once into a layer that is never cleared | [decals](docs/effects/decals.md) |
| Rain and snow | `lib/vfx/weather.rb` | Drops at several depths that wrap around the screen | [weather](docs/effects/weather.md) |
| Parallax | `lib/vfx/parallax.rb` | Background layers that scroll by depth | [parallax](docs/effects/parallax.md) |
| Row slices | `lib/vfx/slices.rb` | Reflection, heat haze and glitch from horizontal strips | [slices](docs/effects/slices.md) |
| Mesh warp | `lib/vfx/warp.rb` | Shockwave and lens by moving the corners of a triangle grid | [warp](docs/effects/warp.md) |
| Shadow-casting light | `lib/vfx/shadows.rb` | Lights that walls block, and line of sight | [shadows](docs/effects/shadows.md) |

All twenty-two work on every DragonRuby licence tier and in web builds. None
uses a shader. Some draw a picture from the `sprites/` folder beside them; each file's header
says which.

## Gallery

![Trauma screen shake](docs/clips/shake.webp)

Each picture opens that effect's page, which shows it moving.

| | | | |
|---|---|---|---|
| [![shake](docs/shots/shake.png)](docs/effects/shake.md) | [![hit_stop](docs/shots/hit_stop.png)](docs/effects/hit_stop.md) | [![camera_fx](docs/shots/camera_fx.png)](docs/effects/camera_fx.md) | [![squash](docs/shots/squash.png)](docs/effects/squash.md) |
| [![particles](docs/shots/particles.png)](docs/effects/particles.md) | [![trail](docs/shots/trail.png)](docs/effects/trail.md) | [![transition](docs/shots/transition.png)](docs/effects/transition.md) | [![lights](docs/shots/lights.png)](docs/effects/lights.md) |
| [![fog](docs/shots/fog.png)](docs/effects/fog.md) | [![rgb_split](docs/shots/rgb_split.png)](docs/effects/rgb_split.md) | [![pixelate](docs/shots/pixelate.png)](docs/effects/pixelate.md) | [![film](docs/shots/film.png)](docs/effects/film.md) |
| [![silhouette](docs/shots/silhouette.png)](docs/effects/silhouette.md) | [![damage_numbers](docs/shots/damage_numbers.png)](docs/effects/damage_numbers.md) | [![lightning](docs/shots/lightning.png)](docs/effects/lightning.md) | [![ribbon](docs/shots/ribbon.png)](docs/effects/ribbon.md) |
| [![decals](docs/shots/decals.png)](docs/effects/decals.md) | [![weather](docs/shots/weather.png)](docs/effects/weather.md) | [![parallax](docs/shots/parallax.png)](docs/effects/parallax.md) | [![slices](docs/shots/slices.png)](docs/effects/slices.md) |
| [![warp](docs/shots/warp.png)](docs/effects/warp.md) | [![shadows](docs/shots/shadows.png)](docs/effects/shadows.md) | | |

## Use an effect

1. Copy the file from `mygame/lib/vfx/` into your game, e.g. `mygame/lib/vfx/shake.rb`.
   If its header names a picture, copy that into a `sprites/` folder beside it.
   Or copy the whole `lib/vfx/` folder and take what you need.
2. `require "lib/vfx/shake.rb"` in your `main.rb`.
3. Follow the usage block at the top of the file.

### With drenv

[drenv](https://github.com/Nitemaeric/drenv) can vendor the whole library into
your game and keep it pinned:

    drenv add github:jmonteiro/dragonruby-vfx@v0.1.0 -n vfx

That puts the effects and their pictures in `mygame/vendor/vfx/` and requires
them all through `app/drenv_bundle.rb`. Leave out `@v0.1.0` to follow `main`;
[the releases](https://github.com/jmonteiro/dragonruby-vfx/releases) list the versions.

### How an effect is used

Effects that keep state follow the same shape:

```ruby
args.state.shake ||= Vfx::Shake.new        # a plain Hash holding the state
Vfx::Shake.add(args.state.shake, 0.4)      # trigger it
Vfx::Shake.tick(args.state.shake)          # once a frame
sprite = Vfx::Shake.apply(args.state.shake, sprite)  # use the result
```

State is a Hash, so it can live in `args.state` and survives saving and hot
reload. The functions are module methods and keep nothing between calls.
Effects that only rearrange a finished picture (RGB split, pixelate, vignette,
light map) have no state at all: one call returns the sprites to draw.

During a hit stop or a pause, shake, squash, particles, damage numbers and
weather take a time scale
(`tick(state, 0)` holds them still). The others advance whenever `tick` is
called: skip the call to freeze them, or keep calling it so that a fade or a
transition runs on while the game is paused.

## Run the gallery

The gallery is a DragonRuby game that shows every effect with a description
and controls. The engine is licensed and is not in this repository: unzip your
own copy of DragonRuby and copy this repository's files over it, so
`./dragonruby` sits beside `mygame/`.

    bin/run                  # open the gallery
    bin/run --demo hit_stop  # open it on one effect
    bin/test                 # the tests, inside the engine, without a window
    bin/lint                 # RuboCop, fitted to the engine's Ruby; bin/lint -a autoformats
    bin/shots                # save one screenshot per effect to docs/shots/
    bin/clips                # film every effect into docs/clips/ (needs ImageMagick and img2webp)
    bin/clips weather        # film one effect
    bin/web                  # build the gallery for the browser into builds/
    bin/serve                # build for the browser and serve it at http://localhost:4000
    bin/pages                # build for the browser and publish it to GitHub Pages
    bin/release 0.2.0        # release a version: changelog, tag, GitHub release
    bin/build                # package every platform into builds/
    ruby bin/gen_sprites.rb  # redraw the library's and the gallery's sprites, and the icon

## Related work

Other places to look, and how this library differs from each:

- **DragonRuby's bundled samples** (`samples/` in the engine's zip, MIT) show
  several of these techniques one at a time: `07_shake_camera`, `13_lighting`,
  `21_line_of_sight`, `05_particles`, `05_scene_transitions` and
  `12_render_target_noclear`. They are lessons to read; the files here are
  effects to copy in and call.
- [conjuration](https://github.com/Nitemaeric/conjuration) (MIT) is a scene and
  camera framework with camera shake, hit stop, parallax and transitions built
  in. Choose it for a structure to build a game inside; choose this for single
  effects with no framework.
- [Zif](https://github.com/danhealy/dragonruby-zif) (MIT) is a larger framework
  with tweening actions, a camera and layers.
- [dragonruby-toolbox](https://github.com/kfischer-okarin/dragonruby-toolbox)
  (MIT) has damage number animations, a low-resolution canvas and colour tools.
- [dr-particles](https://github.com/owenbutler/dr-particles) and
  [dragonruby-particle-explosions](https://github.com/oeloeloel/dragonruby-particle-explosions)
  are small particle libraries.
- [ruby-shadowcasting](https://github.com/xenobrain/ruby-shadowcasting)
  (Unlicense) is an optimised shadow caster.

Nothing here is copied from them; `CREDITS.md` says where each technique comes
from.

## Layout

- `mygame/lib/vfx/`: the library. One effect per file, each standing alone. `mygame/lib/vfx.rb` requires them all.
- `drenv.toml`: makes the library installable with drenv.
- `mygame/lib/vfx/sprites/`: the white shapes some effects draw. They find them beside themselves, wherever the folder is put.
- `mygame/sprites/demo/`: pictures the gallery alone uses.
- `mygame/app/`: the gallery. `demos/` has one short demo per effect.
- `mygame/tests/all.rb`: tests of the effects' arithmetic.
- `docs/effects/`: one page per effect; `llms.txt` is a plain-text index of them.
- `experimental/shaders/`: four fragment-shader effects that are not part of the library; its README says why.
- `CONTRIBUTING.md`: the rules and how to add an effect. `CHANGELOG.md`: what changed.
- `CREDITS.md`: where each technique comes from.
