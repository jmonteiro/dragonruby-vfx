# Changelog

## Unreleased

- Removed `experimental/shaders/`, the four shader effects that were never
  part of the library. They remain in the history at tag `v0.1.1`.

## 0.1.1 (2026-11-23)

- The clips in the docs no longer smear: they were encoded in a way that let
  errors pile up behind anything that moved.
- A release now publishes the gallery too.
- `bin/serve` uses Ruby's own web server in place of Python's.

## 0.1.0 (2026-11-23)

Twenty-two effects that need no shader:

- Trauma screen shake (`shake.rb`)
- Hit stop and slow motion (`hit_stop.rb`)
- Camera flash, fade, zoom punch and kick (`camera_fx.rb`)
- Squash and stretch (`squash.rb`)
- Particles (`particles.rb`)
- Afterimage trail (`trail.rb`)
- Scene transitions: fade, wipe, iris, tiles, blinds (`transition.rb`)
- Light map (`lights.rb`)
- Fog of war (`fog.rb`)
- RGB split (`rgb_split.rb`)
- Pixelate (`pixelate.rb`)
- Vignette and film grain (`film.rb`)

- Hit flash, outline and shadow (`silhouette.rb`)
- Damage numbers (`damage_numbers.rb`)
- Lightning (`lightning.rb`)
- Ribbon trail (`ribbon.rb`)
- Decals (`decals.rb`)
- Rain and snow (`weather.rb`)
- Parallax (`parallax.rb`)
- Row slices: reflection, haze, glitch (`slices.rb`)
- Mesh warp: shockwave, lens (`warp.rb`)
- Shadow-casting light and line of sight (`shadows.rb`)

And the gallery that shows them all, which also builds for the browser.

`lib/vfx.rb` requires every effect, and `drenv.toml` lets drenv install the
library.
