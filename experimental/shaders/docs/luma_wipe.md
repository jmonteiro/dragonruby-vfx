# Luma wipe (Pro)

![Luma wipe](../clips/luma_wipe.webp)

- **Files:** `mygame/lib/vfx/pro/luma_wipe.rb` and `luma_wipe.frag.hlsl` (`Vfx::LumaWipe`)
- **Needs:** DragonRuby Pro, `shaders=true` in `metadata/game_metadata.txt`, and a desktop build. Shaders are experimental in DragonRuby ("APIs will break") and do not run in web builds.
- **Cost:** both scenes drawn to render targets, and one full-screen fragment shader pass.

## What it is

One scene gives way to another along a pattern, with a soft edge. Both scenes
are drawn to render targets; the shader on the old one reads the new one and
swaps them point by point, in the order the pattern gives. Unlike
`Vfx::Transition`, the two scenes are both on screen during the change and
nothing is covered.

## Use

```ruby
require "lib/vfx/pro/luma_wipe.frag.hlsl"
require "lib/vfx/pro/luma_wipe.rb"

def tick(args)
  args.state.progress ||= 0.0
  args.state.progress = (args.state.progress + 0.01) % 1.3

  day = args.outputs[:day]
  day.w = 1280
  day.h = 720
  day.background_color = [120, 170, 220]
  night = args.outputs[:night]
  night.w = 1280
  night.h = 720
  night.background_color = [20, 22, 50]

  day.shader = Vfx::LumaWipe.shader(:night, args.state.progress, pattern: :clouds)
  args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :day }
end
```

## API

| Call | Does |
|---|---|
| `Vfx::LumaWipe.shader(coming, progress, pattern: :left, softness: 0.12, w: 1280, h: 720)` | The Hash to assign to the old scene's `shader`. `coming` is the new scene's render target |
| `Vfx::LumaWipe::PATTERNS` | `[:left, :circle, :diagonal, :clouds, :clock]` |

| Parameter | Meaning |
|---|---|
| `progress` | 0 the old scene, 1 the new one. Kept within that range |
| `softness` | Width of the blended edge. 0 a hard line, 0.3 very soft |
| `pattern` | The order points change in; an unknown one raises `ArgumentError` |

| Pattern | Looks like |
|---|---|
| `:left` | A soft edge crossing from left to right |
| `:circle` | A circle growing from the middle |
| `:diagonal` | From the top-left corner to the bottom-right |
| `:clouds` | Blotches that spread and join |
| `:clock` | A hand sweeping round from twelve |

## Notes

- When `progress` reaches 1, make the new scene the current one and set `shader = nil`.
- The patterns are computed in the shader. To use a picture as the pattern, the classic luma wipe, pass it as a second texture and read it in `order()` in the `.hlsl` file.
- `:clouds` with a low `softness` is close to a dissolve between two scenes.

## Source

The gradient ("luma") wipe of video editing; gl-transitions (MIT) collects
hundreds. Written from scratch.
