// Luma wipe: one scene gives way to another along the shape of a pattern,
// with a soft edge. See luma_wipe.rb.
Texture2D scene : register(t0, space2);
Texture2D coming : register(t1, space2);
SamplerState scene_sampler : register(s0, space2);
SamplerState coming_sampler : register(s1, space2);

cbuffer Uniforms : register(b0, space3) {
  float progress;  // 0 the old scene, 1 the new one
  float softness;  // how wide the blended edge is
  float aspect;    // the screen's width over its height
  int pattern;     // 0 left to right, 1 circle, 2 diagonal, 3 clouds, 4 clock
};

struct Input {
  float4 tex_color : COLOR0;
  float2 tex_coord : TEXCOORD0;
};

struct Output {
  float4 frag_color : SV_Target;
};

float scatter(float2 corner) {
  return frac(sin(dot(corner, float2(127.1, 311.7))) * 43758.5453);
}

float noise(float2 place) {
  float2 corner = floor(place);
  float2 part = frac(place);
  part = part * part * (3.0 - 2.0 * part);
  return lerp(lerp(scatter(corner), scatter(corner + float2(1.0, 0.0)), part.x),
              lerp(scatter(corner + float2(0.0, 1.0)), scatter(corner + float2(1.0, 1.0)), part.x),
              part.y);
}

// When each place changes over, from 0 (first) to 1 (last).
float order(float2 uv) {
  float2 from_middle = (uv - 0.5) * float2(aspect, 1.0);
  if (pattern == 1) {
    return saturate(length(from_middle) / length(float2(aspect, 1.0) * 0.5));
  }
  if (pattern == 2) {
    return (uv.x + uv.y) * 0.5;
  }
  if (pattern == 3) {
    return noise(uv * float2(aspect, 1.0) * 5.0) * 0.6 + noise(uv * float2(aspect, 1.0) * 13.0 + 7.0) * 0.4;
  }
  if (pattern == 4) {
    return atan2(from_middle.x, -from_middle.y) / 6.2832 + 0.5;
  }
  return uv.x;
}

Output main(Input input) {
  Output output;
  float4 old_color = scene.Sample(scene_sampler, input.tex_coord);
  float4 new_color = coming.Sample(coming_sampler, input.tex_coord);
  float cutoff = progress * (1.0 + softness);
  float changed = saturate((cutoff - order(input.tex_coord)) / max(softness, 0.0001));
  output.frag_color = lerp(old_color, new_color, changed) * input.tex_color;
  return output;
}
