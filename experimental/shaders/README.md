# Experimental: fragment-shader effects

Four effects written as HLSL fragment shaders for DragonRuby Pro: CRT,
shockwave, dissolve with burn edge, and luma wipe. They are **not part of the
library** and the gallery does not load them.

## Why they are here and not in `mygame/lib/vfx/`

They were built against DragonRuby 7.25, whose shader support is marked
experimental ("APIs will break"), and they did not behave reliably:

- The effects took hold at random: the same demo sometimes showed the shader
  and sometimes drew the picture untouched, and the dissolve flickered.
- At full progress the dissolve drew the sprite whole instead of gone.
- The luma wipe demo crashed the engine after running for a while.
- With `shaders=true` in the metadata the engine cannot build for the browser
  and cannot run tests without a window.

None of this was traced to a fault in these files, and none of it was ruled
out either.

## What is here

- `<effect>.rb` and `<effect>.frag.hlsl`: the Ruby side and the shader.
- `demos/`: the gallery demos they had, and `pro.rb`, which detected whether
  shaders could run and drew a notice where they could not.
- `docs/`: the page each effect had.
- `tests.rb`: tests of the Ruby side.

Paths inside these files still say `lib/vfx/pro/`, where they used to live.

## Trying them

Copy an effect's two files into a game, add `shaders=true` to
`metadata/game_metadata.txt`, require the `.hlsl` and then the `.rb`, and
follow the usage block at the top of the `.rb` file. Needs a Pro licence.

## What the library offers in their place

- Shockwave: `Vfx::Warp.shockwave`, coarser, runs everywhere.
- Transitions between scenes: `Vfx::Transition`.
- The flat part of the CRT look: `Vfx::Film.vignette` and a tiled scanline
  picture drawn with `blendmode: 8`.
