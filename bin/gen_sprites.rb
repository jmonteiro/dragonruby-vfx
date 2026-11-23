#!/usr/bin/env ruby
# Draws the few white shapes the effects and the gallery use, with ordinary
# Ruby and no gems. Run from the repository root: ruby bin/gen_sprites.rb
# The output is committed; rerun only to change a shape.
require "zlib"

def png(path, size, opaque: false)
  rows = (0...size).map do |y|
    row = (0...size).map do |x|
      r, g, b, a = yield((x + 0.5) / size, (y + 0.5) / size)
      pixel = [r, g, b].map { |v| (v.clamp(0.0, 1.0) * 255).round }
      pixel << (a.clamp(0.0, 1.0) * 255).round unless opaque
      pixel.pack("C*")
    end
    "\x00".b + row.join
  end
  chunk = lambda do |type, data|
    [data.bytesize].pack("N") + type + data + [Zlib.crc32(type + data)].pack("N")
  end
  header = [size, size, 8, opaque ? 2 : 6, 0, 0, 0].pack("NNCCCCC")
  File.binwrite(path, "\x89PNG\r\n\x1a\n".b + chunk.call("IHDR", header) +
                      chunk.call("IDAT", Zlib::Deflate.deflate(rows.join, 9)) + chunk.call("IEND", ""))
  puts path
end

# Distance from the centre, 0 at the centre and 1 at the edge of the image.
def radius(u, v)
  Math.sqrt(((u - 0.5)**2) + ((v - 0.5)**2)) * 2
end

# 1 inside `edge`, 0 outside, with a soft step `soft` wide for antialiasing.
def inside(distance, edge, soft)
  ((edge - distance) / soft).clamp(0.0, 1.0)
end

dir = "mygame/sprites/vfx"

png("#{dir}/circle.png", 128) { |u, v| [1, 1, 1, inside(radius(u, v), 0.97, 0.03)] }

png("#{dir}/glow.png", 128) do |u, v|
  falloff = (1 - radius(u, v)).clamp(0.0, 1.0)
  [1, 1, 1, falloff * falloff]
end

png("#{dir}/ring.png", 256) do |u, v|
  d = radius(u, v)
  [1, 1, 1, inside(d, 0.97, 0.015) * inside(-d, -0.85, 0.015)]
end

# A light: full strength in the middle, falling smoothly to nothing at the edge.
png("#{dir}/light.png", 256) do |u, v|
  t = ((radius(u, v) - 0.15) / 0.85).clamp(0.0, 1.0)
  [1, 1, 1, 1 - (t * t * (3 - (2 * t)))]
end

# The opposite of a circle: a filled square with a round hole, for the iris.
png("#{dir}/hole.png", 512) { |u, v| [1, 1, 1, 1 - inside(radius(u, v), 0.995, 0.01)] }

# Clear in the middle, opaque towards the corners (which are 1.41 from the centre).
png("#{dir}/vignette.png", 256) do |u, v|
  t = ((radius(u, v) - 0.55) / 0.85).clamp(0.0, 1.0)
  [1, 1, 1, t * t * (3 - (2 * t))]
end

# Film grain: every pixel a random grey. Seeded, so the file never changes.
noise = Random.new(1)
png("#{dir}/grain.png", 256, opaque: true) do
  grey = noise.rand
  [grey, grey, grey, 1]
end

# A raindrop's streak: brightest at the bottom (the drop itself), fading up its
# tail, soft at the sides. Drawn tall and thin.
png("#{dir}/streak.png", 64) do |u, v|
  across = (1 - ((u - 0.5).abs * 2)).clamp(0.0, 1.0)
  [1, 1, 1, across * (v**1.6)]
end

# --- pictures for the gallery's demos only ---------------------------------
demo = "mygame/sprites/demo"

# A round creature with ears, in several colours, so that a silhouette of it
# is plainly a shape and not a rectangle.
png("#{demo}/critter.png", 128) do |u, v|
  body = inside(Math.sqrt(((u - 0.5)**2) + (((v - 0.58) * 1.1)**2)) * 2, 0.74, 0.02)
  ears = [0.3, 0.7].map { |ex| inside(Math.sqrt(((u - ex)**2) + ((v - 0.2)**2)) * 2, 0.26, 0.02) }.max
  belly = inside(Math.sqrt(((u - 0.5)**2) + ((v - 0.72)**2)) * 2, 0.36, 0.02)
  eyes = [0.38, 0.62].map { |ex| inside(Math.sqrt(((u - ex)**2) + ((v - 0.48)**2)) * 2, 0.1, 0.02) }.max
  shape = [body, ears].max
  r = (0.28 * (1 - belly)) + (0.85 * belly)
  g = (0.79 * (1 - belly)) + (0.95 * belly)
  b = (0.71 * (1 - belly)) + (0.9 * belly)
  [(r * (1 - eyes)) + (0.09 * eyes), (g * (1 - eyes)) + (0.11 * eyes), (b * (1 - eyes)) + (0.17 * eyes), shape]
end

# Three rows of hills that repeat sideways, white so each can be tinted.
{ "far" => [0.55, 0.16, 1, 3], "middle" => [0.45, 0.2, 2, 5], "near" => [0.3, 0.14, 3, 7] }.each do |name, (base, tall, one, two)|
  png("#{demo}/hills_#{name}.png", 512) do |u, v|
    top = base + (tall * ((Math.sin(u * one * 6.2832) * 0.6) + (Math.sin((u * two * 6.2832) + 1.3) * 0.4)))
    [1, 1, 1, inside(1 - v, top, 0.004)]
  end
end

# The gallery's icon: a spark with a ring around it on the gallery's dark blue.
png("mygame/metadata/icon.png", 1024, opaque: true) do |u, v|
  d = radius(u, v)
  angle = Math.atan2(v - 0.5, u - 0.5)
  rays = (Math.cos(angle * 4).abs**12) * (1 - (d / 0.62)).clamp(0.0, 1.0)
  core = (1 - (d / 0.3)).clamp(0.0, 1.0)**2
  ring = inside(d, 0.78, 0.01) * inside(-d, -0.72, 0.01)
  light = [rays + core + (ring * 0.9), 1.0].min
  [0.07 + (light * 0.93), 0.09 + (light * 0.72), 0.16 + (light * 0.2), 1]
end
