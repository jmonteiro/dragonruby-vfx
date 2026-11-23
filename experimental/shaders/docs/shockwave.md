# Shockwave (Pro)

![Shockwave](../clips/shockwave.webp)

- **Files:** `mygame/lib/vfx/pro/shockwave.rb` and `shockwave.frag.hlsl` (`Vfx::Shockwave`)
- **Needs:** DragonRuby Pro, `shaders=true` in `metadata/game_metadata.txt`, and a desktop build. Shaders are experimental in DragonRuby ("APIs will break") and do not run in web builds.
- **Cost:** one full-screen fragment shader pass while a ring is on screen.

## What it is

A ring that bends the picture as it spreads. Each pixel near the ring is read
from a little nearer the centre, so the picture looks pushed outwards, as
smoothly as the screen has pixels. `Vfx::Warp.shockwave` is the coarser
version that runs everywhere.

## Use

```ruby
require "lib/vfx/pro/shockwave.frag.hlsl"
require "lib/vfx/pro/shockwave.rb"

def tick(args)
  scene = args.outputs[:scene]
  scene.w = 1280
  scene.h = 720
  scene.background_color = [40, 44, 70]
  12.times { |i| scene.primitives << { x: i * 110, y: 0, w: 4, h: 720, path: :solid, r: 255, g: 255, b: 255, a: 60 } }

  mouse = args.inputs.mouse
  args.state.wave = { x: mouse.x, y: mouse.y, radius: 0 } if mouse.click
  wave = args.state.wave
  if wave && wave[:radius] < 900
    wave[:radius] += 14
    scene.shader = Vfx::Shockwave.shader(wave[:x], wave[:y], wave[:radius])
  else
    scene.shader = nil
  end
  args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
end
```

## API

| Call | Does |
|---|---|
| `Vfx::Shockwave.shader(x, y, radius, width: 80, strength: 24, w: 1280, h: 720)` | The Hash to assign to a render target's `shader`. Everything is in pixels |

| Parameter | Meaning |
|---|---|
| `x`, `y` | The centre of the blast |
| `radius` | Where the ring is now; grow it every frame |
| `width` | How thick the ring is |
| `strength` | How far it bends the picture |

## Notes

- One ring per render target. For two blasts at once, the second replaces the first, or use `Vfx::Warp`, whose pushes can be added up in one block.
- Set `shader = nil` when the ring has gone, or the pass keeps running.
- Fade `strength` as the radius grows.

## Source

Radial displacement, as in pixi-filters' ShockwaveFilter (MIT). Written from
scratch.
