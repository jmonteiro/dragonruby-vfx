# Contributing

The library is `mygame/lib/vfx/`; everything under `mygame/app/` is the gallery
that demonstrates it.

## Rules

- The engine is licensed and never committed (its own `docs/` shares our folder;
  only `docs/effects/`, `docs/shots/` and `docs/clips/` are ours). `.gitignore` allows only the
  listed paths; do not widen it to engine files.
- An effect file stands alone: it requires nothing, not even another effect.
  Effects combine through plain Hash keys (see `shake:` in `camera_fx.rb`).
- State is a plain Hash returned by `Vfx::<Effect>.new`; functions are module
  methods taking that Hash first; `tick` runs once a frame and returns the
  Hash. Two exceptions: `outputs` leads when a function fills a render target
  (`draw`, `mask`, `light`), and `HitStop.tick` returns the time scale.
- Names mean the same thing in every file: `color: [r, g, b]`; `alpha:` up to
  255; `strength:` from 0 to 1; `amplitude:` in pixels; `w:`, `h:` the screen.
  Colour and alpha are given to the call that returns sprites, not kept in
  the state. At most one optional positional argument; the rest are keywords.
- Effects that move by speed take a `time_scale`; effects that count whole
  frames do not, and say so above `tick`.
- Effects are written from scratch. Record the technique's source in the
  file's header, its docs page and `CREDITS.md`. Never copy code from a source
  whose licence is not MIT, zlib, CC0 or similar, and never from Shadertoy,
  The Book of Shaders or lygia.
- Sprites are drawn by code, in `bin/gen_sprites.rb`. An effect's pictures go
  in `mygame/lib/vfx/sprites/` and are found through the file's own `SPRITES`
  constant, never by a fixed path, so the folder works wherever it is copied.
- No shaders in the library. DragonRuby's shaders are Pro-only, experimental,
  and behaved unreliably when tried; see `experimental/shaders/README.md`.

## Changes and releases

Any change a user of the library would notice (a new effect, a renamed or
removed option, a fix) adds a line under "Unreleased" in `CHANGELOG.md`, in the
same commit. `bin/release <version>` turns that section into a version, tags it
and creates the GitHub release; its header explains the numbering.

## Adding an effect

1. `mygame/lib/vfx/<id>.rb` with a header comment: what it is, a usage block, the source.
   Add it to `mygame/lib/vfx.rb`.
2. `mygame/app/demos/<id>.rb` (a demo may show two small related effects): `ID`, `TITLE`, `BLURB`, `CONTROLS`, `SHOT_AT`,
   `setup`, `tick(args, demo, input)`. It must play by itself when
   `input[:auto]` is true. Add it to `Gallery::DEMOS` and the requires in `main.rb`.
3. Tests in `mygame/tests/` (`all.rb` loads the other files; keep each file short).
4. `docs/effects/<id>.md` following the existing pages, and a line in
   `README.md`, `llms.txt` and `CREDITS.md`.
5. A line in `CHANGELOG.md`.
6. `bin/lint` and `bin/test`, then `bin/shots` and `bin/clips`, and look at the pictures.

New sprites are added to `bin/gen_sprites.rb`, never drawn by hand or taken
from the engine's samples.

## Commands

`bin/run`, `bin/test`, `bin/lint`, `bin/shots`, `bin/clips`,
`bin/web` (browser build only), `bin/serve`, `bin/pages` (publishes the
gallery), `bin/release` and `bin/build` (every platform);
see `README.md`.

GitHub Actions runs the lint and the tests on every push. The tests there use
an unofficial mirror of the engine's executable
(`kfischer-okarin/download-dragonruby`); if it goes away, `bin/test` on your
own copy of the engine remains the judge.

## Engine traps

- A triangle of plain colour is a sprite with `path: :solid` and source
  corners (see `ribbon.rb`); `primitive_marker: :solid` is deprecated.
- mruby has no `Regexp`; `Integer#/` may return a Float (use `idiv`/`fdiv`);
  `Array#shift` takes no count. `bin/test` is the judge, not ordinary Ruby.
- A screenshot saves one colour as transparent, black unless told otherwise.
  `Gallery.shoot` names a colour no demo draws; keep it that way.
- Never edit files under `mygame/` while an engine process runs, and never
  run two engines at once (`pgrep -fl dragonruby`).
- `--test` with a wrong path opens a window and waits forever.
- `docs/api/outputs.md` in the engine describes an old GLSL shader API. The
  current one is HLSL per render target; see `samples/14_shaders`.
