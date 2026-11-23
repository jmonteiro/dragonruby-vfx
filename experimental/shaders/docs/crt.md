# CRT (Pro)

![CRT](../clips/crt.webp)

- **Files:** `mygame/lib/vfx/pro/crt.rb` and `crt.frag.hlsl` (`Vfx::Crt`)
- **Needs:** DragonRuby Pro, `shaders=true` in `metadata/game_metadata.txt`, and a desktop build. Shaders are experimental in DragonRuby ("APIs will break") and do not run in web builds.
- **Cost:** one full-screen fragment shader pass.

## What it is

The look of an old television, as a fragment shader over the finished scene:
the glass bulges, rows of pixels are split by dark scanlines, columns carry
red, green and blue stripes, colours fringe at the edges and the corners go
dark.

## Use

```ruby
require "lib/vfx/pro/crt.frag.hlsl"   # the engine compiles the shader when it is required
require "lib/vfx/pro/crt.rb"

def tick(args)
  scene = args.outputs[:scene]
  scene.w = 1280
  scene.h = 720
  scene.background_color = [40, 44, 70]
  scene.primitives << { x: 560, y: 280, w: 160, h: 160, path: :solid, r: 255, g: 204, b: 77 }
  scene.shader = Vfx::Crt.shader(curve: 0.15)

  args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
end
```

## API

| Call | Does |
|---|---|
| `Vfx::Crt.shader(curve: 0.12, scanlines: 0.35, lines: 240, mask: 0.15, vignette: 0.6, fringe: 1.5)` | The Hash to assign to a render target's `shader` |

| Parameter | Meaning |
|---|---|
| `curve` | How much the glass bulges. 0 flat, 0.3 a fishbowl |
| `scanlines` | 0 none, 1 black gaps between rows |
| `lines` | How many scanlines down the screen |
| `mask` | Strength of the red, green, blue stripes |
| `vignette` | How dark the corners are |
| `fringe` | How far red and blue part, in thousandths of the screen's width |

## Notes

- Draw the HUD into the same render target if it should sit behind the glass too.
- The curve moves what is drawn: a click at a screen position no longer lands on what is shown there. Keep `curve` small in games played with a pointer.
- A scanline count that does not divide the window's height evenly can shimmer; try 180, 240 or 360 on a 720-line screen.
- Without Pro, `Vfx::Film.vignette` plus a tiled scanline picture drawn with `blendmode: 8` gives the flat part of this look.

## Source

Timothy Lottes' public-domain CRT shader set the recipe (curve, scanlines,
mask); moonshine's `crt` and `scanlines` (MIT) are the simple version
followed here. Written from scratch.
