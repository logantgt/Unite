#version 440

layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;

layout(std140, binding=0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 baseColor;
    float curveRadius;
    int curveOrientation; // 0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right
} ubuf;

layout(binding=1) uniform sampler2D source;

void main() {
    vec2 uv = qt_TexCoord0;
    vec2 corner;

    // Determine which corner the curve is carved from
    if (ubuf.curveOrientation == 0) {
        corner = vec2(0.0, 0.0); // top-left
    } else if (ubuf.curveOrientation == 1) {
        corner = vec2(1.0, 0.0); // top-right
    } else if (ubuf.curveOrientation == 2) {
        corner = vec2(0.0, 1.0); // bottom-left
    } else {
        corner = vec2(1.0, 1.0); // bottom-right
    }

    // Compute distance from the selected corner
    float dist = distance(uv, corner);

    // Fixed edge width for anti-aliasing
    float edgeWidth = 0.1; // tweak this value for smoother or sharper edges

    // Anti-aliased circular mask: transparent inside the radius, filled outside
    float mask = smoothstep(ubuf.curveRadius - edgeWidth, ubuf.curveRadius + edgeWidth, dist);

    // Apply base color and opacity, modulated by the mask
    fragColor = ubuf.baseColor * (ubuf.qt_Opacity * mask);
}
