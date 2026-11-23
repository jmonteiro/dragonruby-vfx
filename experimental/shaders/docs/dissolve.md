# Dissolve with burn edge (Pro)

![Dissolve](../clips/dissolve.webp)

- **Files:** `mygame/lib/vfx/pro/dissolve.rb` and `dissolve.frag.hlsl` (`Vfx::Dissolve`)
- **Needs:** DragonRuby Pro, `shaders=true` in `metadata/game_metadata.txt`, and a desktop build. Shaders are experimental in DragonRuby ("APIs will break") and do not run in web builds.
- **Cost:** one fragment shader pass over the sprite's render target.

## What it is

A sprite eaten away along a noise pattern, with a glowing edge where it is
burning. Noise gives every pixel a number; as `progress` rises, pixels below
it vanish, and those just above it glow. Raise it for a death, lower it for a
spawn.

## Use

```ruby
require "lib/vfx/pro/dissolve.frag.hlsl"
require "lib/vfx/pro/dissolve.rb"

def tick(args)
  args.state.gone ||= 0.0
  args.state.gone = (args.state.gone + 0.01) % 1.2

  ghost = args.outputs[:ghost]          # the thing to dissolve, in its own render target
  ghost.w = 200
  ghost.h = 200
  ghost.background_color = [0, 0, 0, 0]
  ghost.primitives << { x: 0, y: 0, w: 200, h: 200, path: "sprites/vfx/circle.png", r: 72, g: 202, b: 180 }
  ghost.shader = Vfx::Dissolve.shader(args.state.gone)

  args.outputs.background_color = [20, 22, 36]
  args.outputs.primitives << { x: 540, y: 260, w: 200, h: 200, path: :ghost }
end
```

## API

| Call | Does |
|---|---|
| `Vfx::Dissolve.shader(progress, edge: 0.08, grain: 7, seed: 0, color: [255, 140, 40])` | The Hash to assign to a render target's `shader` |

| Parameter | Meaning |
|---|---|
| `progress` | 0 whole, 1 gone. Kept within that range |
| `edge` | Width of the burning band. 0.02 a hairline, 0.2 wide |
| `grain` | How many blotches across the target. Low for big holes, high for a fine crumble |
| `seed` | A different pattern for each number |
| `color` | `[r, g, b]` of the burning edge; it brightens to white at its hottest |

## Notes

- Known issue: in about two of nine runs of the gallery the shader did not take effect on this render target and the sprite was drawn whole. The cause is not found; DragonRuby's shaders are experimental. Check it in your own game before relying on it.
- Each thing dissolving needs its own render target, and its own `seed` if several go at once.
- The pattern is tied to the render target, not the world: it moves with the sprite.
- A cold colour (`[80, 200, 255]`) reads as teleporting or freezing.
- Without Pro, `Vfx::Transition`'s `:tiles` or particles bursting from the sprite are the nearest stand-ins.

## Source

Noise-threshold dissolve with a burn edge, as in godotshaders' "2D dissolve
with burn edge" (CC0). Written from scratch.
