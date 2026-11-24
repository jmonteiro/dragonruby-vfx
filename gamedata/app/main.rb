# The gallery of effects. The library itself is mygame/lib/vfx/: every file there
# stands alone. Everything under app/ exists only to show them.
require "lib/vfx.rb"
require "app/stage.rb"
require "app/demos/shake.rb"
require "app/demos/hit_stop.rb"
require "app/demos/camera_fx.rb"
require "app/demos/squash.rb"
require "app/demos/particles.rb"
require "app/demos/trail.rb"
require "app/demos/transition.rb"
require "app/demos/lights.rb"
require "app/demos/fog.rb"
require "app/demos/rgb_split.rb"
require "app/demos/pixelate.rb"
require "app/demos/film.rb"
require "app/demos/silhouette.rb"
require "app/demos/damage_numbers.rb"
require "app/demos/lightning.rb"
require "app/demos/ribbon.rb"
require "app/demos/decals.rb"
require "app/demos/weather.rb"
require "app/demos/parallax.rb"
require "app/demos/slices.rb"
require "app/demos/warp.rb"
require "app/demos/shadows.rb"
require "app/gallery.rb"

def tick(args)
  Gallery.tick(args)
end
