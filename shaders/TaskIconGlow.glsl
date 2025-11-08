#version 440

layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;

layout(std140, binding=0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    vec2 glowOrigin;
    float glowRadius;
    float baseOpacity;
    float glowOpacity;
} ubuf;

layout(binding=1) uniform sampler2D source;
layout(binding=2) uniform sampler2D mask;

vec4 overlay(vec4 base, vec4 blend) {
    vec4 result;
    result.r = base.r < 0.5 ? (2.0 * base.r * blend.r) : (1.0 - 2.0 * (1.0 - base.r) * (1.0 - blend.r));
    result.g = base.g < 0.5 ? (2.0 * base.g * blend.g) : (1.0 - 2.0 * (1.0 - base.g) * (1.0 - blend.g));
    result.b = base.b < 0.5 ? (2.0 * base.b * blend.b) : (1.0 - 2.0 * (1.0 - base.b) * (1.0 - blend.b));
    result.a = base.a;

    return mix(base, result, blend.a);
}

void main() {
    vec2 uv = qt_TexCoord0;
    vec4 base = texture(source, uv);
    vec4 mask = texture(mask, uv);

    // Distance from glow origin
    float dist = distance(uv, ubuf.glowOrigin);

    // Soft center glow
    float centerGlow = exp(-pow(dist / ubuf.glowRadius, 1.0));

    // Edge proximity (how close origin is to edge)
    float edgeProximity = smoothstep(0.0, 0.2, min(min(ubuf.glowOrigin.x, 1.0 - ubuf.glowOrigin.x),
                                                min(ubuf.glowOrigin.y, 1.0 - ubuf.glowOrigin.y)));
    // Directional bias (stretch glow toward center)
    vec2 dir = normalize(uv - ubuf.glowOrigin);
    vec2 biasDir = normalize(vec2(0.5) - ubuf.glowOrigin);
    float directionalBias = smoothstep(-1.0, 1.0, dot(dir, biasDir));

    // Combine layers
    float glow = centerGlow * (1.0 + directionalBias * (1.0 - edgeProximity) * 0.2);

    // Final color
    vec4 final = base * glow;

    fragColor = max(base * ubuf.baseOpacity, final * ubuf.glowOpacity) * mask.a * ubuf.qt_Opacity;
}
