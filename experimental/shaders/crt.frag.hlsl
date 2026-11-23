// CRT: a curved tube with scanlines, a colour mask, colour fringing and dark corners.
// Applied to a render target holding the finished scene. See crt.rb.
Texture2D scene : register(t0, space2);
SamplerState scene_sampler : register(s0, space2);

cbuffer Uniforms : register(b0, space3) {
  float curve;      // how much the glass bulges
  float scanlines;  // how dark the gaps between lines are
  float mask;       // how strong the red, green, blue stripes are
  float vignette;   // how dark the corners are
  float fringe;     // how far red and blue part, in thousandths of the width
  float lines;      // how many scanlines down the screen
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

  // Bulge: push each point outwards by more the further it is from the middle.
  float2 centred = input.tex_coord * 2.0 - 1.0;
  centred += centred * (centred.yx * centred.yx) * curve;
  float2 uv = centred * 0.5 + 0.5;

  // Beyond the edge of the glass there is only the black of the case.
  if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
    output.frag_color = float4(0.0, 0.0, 0.0, 1.0);
    return output;
  }

  // Red and blue are read a little to either side.
  float2 apart = float2(fringe * 0.001, 0.0);
  float3 color = float3(scene.Sample(scene_sampler, uv + apart).r,
                        scene.Sample(scene_sampler, uv).g,
                        scene.Sample(scene_sampler, uv - apart).b);

  // Scanlines: dark gaps between bright rows, with the rows lifted to compensate.
  float row = 0.5 + 0.5 * cos(uv.y * lines * 6.2832);
  color *= 1.0 - scanlines * (1.0 - row);
  color *= 1.0 + scanlines * 0.5;

  // The mask: every third column of the tube favours one colour.
  float column = frac(uv.x * lines * 1.7778);
  float3 stripes = float3(column < 0.333 ? 1.0 : 0.0,
                          (column >= 0.333 && column < 0.666) ? 1.0 : 0.0,
                          column >= 0.666 ? 1.0 : 0.0);
  color *= lerp(float3(1.0, 1.0, 1.0), stripes * 1.6 + 0.4, mask);

  // Dark corners.
  float middle = (1.0 - centred.x * centred.x) * (1.0 - centred.y * centred.y);
  color *= lerp(1.0, pow(saturate(middle), 0.35), vignette);

  output.frag_color = float4(color, 1.0) * input.tex_color;
  return output;
}
