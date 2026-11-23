# Hit stop (freeze frames) and slow motion.
#
# When a blow lands, the game holds still for a few frames. The pause gives the
# hit weight: the eye gets time to read the contact before anything flies off.
# `tick` answers with this frame's time scale, 0 while frozen and 1 otherwise;
# multiply movement by it, or skip the update when it is 0. Keep drawing.
#
#   args.state.stop ||= Vfx::HitStop.new
#   Vfx::HitStop.freeze(args.state.stop, 6) if hit
#   scale = Vfx::HitStop.tick(args.state.stop)
#   update_world(scale) if scale > 0
#
# Technique: Jan Willem Nijman (Vlambeer), "The Art of Screenshake" (2013).
# Written from scratch. This file stands alone: copy it and require it.
module Vfx
  module HitStop
    def self.new
      { frozen: 0, slow: 0, slow_scale: 1.0, scale: 1.0 }
    end

    # Holds the game for `frames`. 3-5 for a light hit, 6-10 heavy, 15+ a kill.
    # A longer freeze already running is kept.
    def self.freeze(stop, frames)
      stop[:frozen] = [stop[:frozen], frames].max
      stop
    end

    # Runs the game at `scale` speed for `frames`, after any freeze.
    def self.slow(stop, frames, scale = 0.3)
      stop[:slow] = frames
      stop[:slow_scale] = scale
      stop
    end

    # Call once a frame. Returns the time scale and keeps it in stop[:scale].
    def self.tick(stop)
      stop[:scale] =
        if stop[:frozen] > 0
          stop[:frozen] -= 1
          0.0
        elsif stop[:slow] > 0
          stop[:slow] -= 1
          stop[:slow_scale]
        else
          1.0
        end
    end

    def self.frozen?(stop)
      stop[:frozen] > 0
    end
  end
end
