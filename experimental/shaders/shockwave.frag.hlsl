// Shockwave: a ring that bends the picture as it passes. See shockwave.rb.
Texture2D scene : register(t0, space2);
SamplerState scene_sampler : register(s0, space2);

cbuffer Uniforms : register(b0, space3) {
  float centre_x;  // where the blast is, 0 to 1 across
  float centre_y;  // 0 to 1 down from the top
  float radius;    // where the ring is now, in screen heights
  float width;     // how thick the ring is, in screen heights
  float strength;  // how far it bends the picture, in screen heights
  float aspect;    // the screen's width over its height
};

struct Input {
  float4 tex_color : COLOR0;
  float2 tex_coord : TEXCOORD0;
};

struct Output {
  float4 frag_color : SV_Target;
};

Output main(Input input) {
  Output output;
  float2 uv = input.tex_coord;

  // Measure in screen heights both ways, so the ring is round.
  float2 away = (uv - float2(centre_x, centre_y)) * float2(aspect, 1.0);
  float distance = length(away);
  float off = (distance - radius) / width;
  float glint = 0.0;

  if (abs(off) < 1.0 && distance > 0.0) {
    // Strongest in the middle of the ring, nothing at its edges.
    float bend = cos(off * 1.5708);
    // Reading from nearer the centre makes the picture look pushed outwards.
    uv -= (away / distance) * bend * strength / float2(aspect, 1.0);
    glint = bend * bend * strength * 2.0;
  }

  float4 color = scene.Sample(scene_sampler, clamp(uv, 0.0, 1.0));
  color.rgb += glint;
  output.frag_color = color * input.tex_color;
  return output;
}
