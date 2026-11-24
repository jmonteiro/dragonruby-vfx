# Credits

Every effect here is written from scratch for DragonRuby. No code was copied
from the references; they are where the technique was learned or checked.

| Effect | Technique from | Also consulted |
|---|---|---|
| Trauma screen shake | Squirrel Eiserloh, "Math for Game Programmers: Juicing Your Cameras With Math", GDC 2016 | Phaser camera Shake (MIT); DragonRuby's shake camera sample |
| Hit stop | Jan Willem Nijman (Vlambeer), "The Art of Screenshake", 2013 | |
| Camera flash, fade, punch, kick | Phaser camera effects (MIT), HaxeFlixel FlxCamera (MIT) | |
| Squash and stretch | Martin Jonasson and Petri Purho, "Juice it or lose it", 2012 | |
| Particles | HaxeFlixel FlxEmitter (MIT), LittleJS ParticleEmitter (MIT) | |
| Afterimage trail | HaxeFlixel flixel-addons FlxTrail (MIT) | |
| Scene transitions | HaxeFlixel flixel-addons transitions (MIT), Nez Graphics/Transitions (MIT) | |
| Light map | Godot 2D light demos (MIT) | DragonRuby's lighting sample |
| Fog of war | raylib textures_fog_of_war example (zlib) | |
| RGB split | pixi-filters RGBSplitFilter (MIT), moonshine chromasep (MIT) | |
| Pixelate | moonshine pixelate (MIT), Phaser Pixelate filter (MIT) | |
| Vignette and film grain | moonshine vignette and filmgrain (MIT), pixi-filters OldFilmFilter (MIT) | |
| Hit flash, outline, shadow | The stamped-silhouette technique; godotshaders "Hit flash" and raylib's outline example show it with a shader | |
| Damage numbers | Convention of action RPGs | |
| Lightning | Michael Hoffman, "How to Generate Shockingly Good 2D Lightning Effects", 2013 | |
| Ribbon trail | Triangle-strip trail renderers | |
| Decals | Persistent splat maps (Nuclear Throne) | DragonRuby's no-clear render target sample |
| Rain and snow | Layered wrap-around particle fields | |
| Parallax | Parallax scrolling (Moon Patrol, 1982) | |
| Row slices | Console raster effects | pixi-filters ReflectionFilter and GlitchFilter (MIT) |
| Mesh warp | cocos2d grid actions | pixi-filters ShockwaveFilter (MIT) |
| Shadow-casting light | Nicky Case, "Sight & Light"; Red Blob Games, "2D Visibility" | |

DragonRuby's bundled samples (MIT, DragonRuby LLP) taught the engine's side of
several effects: drawing a scene to a render target and moving it, blend modes
for lighting, the render target that is not cleared, and textured triangles.

The sprites in `mygame/lib/vfx/sprites/` and `mygame/sprites/demo/`, and the icon, are drawn by
`bin/gen_sprites.rb` and are released under CC0.

The gallery is built with the DragonRuby Game Toolkit, which is commercial
software and is not part of this repository.
