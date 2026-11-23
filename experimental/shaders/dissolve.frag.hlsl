// Dissolve: the picture is eaten away along a noise pattern, with a glowing
// edge where it is burning. See dissolve.rb.
Texture2D scene : register(t0, space2);
SamplerState scene_sampler : register(s0, space2);

cbuffer Uniforms : register(b0, space3) {
  float progress;  // 0 whole, 1 gone
  float edge;      // how wide the burning edge is
  float grain;     // how many blotches across
  float seed;      // a different pattern for each number
  float edge_r;    // the edge's colour
  float edge_g;
  float edge_b;
};

struct Input {
  float4 tex_color : COLOR0;
  float2 tex_coord : TEXCOORD0;
};

struct Output {
  float4 frag_color : SV_Target;
};

// A repeatable random number for a grid corner.
float scatter(float2 corner) {
  return frac(sin(dot(corner, float2(127.1, 311.7))) * 43758.5453);
}

// Smooth noise: the four corners around a place, blended.
float noise(float2 place) {
  float2 corner = floor(place);
  float2 part = frac(place);
  part = part * part * (3.0 - 2.0 * part);
  return lerp(lerp(scatter(corner), scatter(corner + float2(1.0, 0.0)), part.x),
              lerp(scatter(corner + float2(0.0, 1.0)), scatter(corner + float2(1.0, 1.0)), part.x),
              part.y);
}

Output main(Input input) {
  Output output;
  float4 color = scene.Sample(scene_sampler, input.tex_coord) * input.tex_color;

  // Large blotches with smaller ones on top.
  float2 spot = input.tex_coord * grain + seed * 17.0;
  float height = noise(spot) * 0.65 + noise(spot * 2.7 + 5.0) * 0.35;

  // Everything below the cutoff is gone; a band just above it is burning.
  float cutoff = progress * (1.0 + edge);
  if (height < cutoff - edge) {
    output.frag_color = float4(0.0, 0.0, 0.0, 0.0);
  } else if (height < cutoff) {
    float heat = 1.0 - (cutoff - height) / edge;
    float3 burn = lerp(float3(edge_r, edge_g, edge_b), float3(1.0, 1.0, 1.0), heat * heat);
    output.frag_color = float4(burn * color.a, color.a);
  } else {
    output.frag_color = color;
  }
  return output;
}
