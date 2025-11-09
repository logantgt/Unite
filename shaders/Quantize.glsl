#version 440
layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;
layout(std140, binding=0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float lighten;
    float saturation;
    float value;
} ubuf;
layout(binding=2) uniform sampler2D source;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 getApproxAverageColor(sampler2D tex, int gridSize) {
    vec3 colorSum = vec3(0.0);
    int totalSamples = 0;
    for (int x = 0; x < gridSize; ++x) {
        for (int y = 0; y < gridSize; ++y) {
            vec2 uv = vec2(float(x) + 0.5, float(y) + 0.5) / float(gridSize);
            vec4 sampleColor = texture(tex, uv);
            float brightness = dot(sampleColor.rgb, vec3(0.299, 0.587, 0.114)); // Luminance
            colorSum += sampleColor.rgb;
            totalSamples += 1;
        }
    }

    if (totalSamples > 0) {
        return colorSum / totalSamples;
    } else {
        return vec3(0.5);
    }
}

void main() {
    vec3 color = getApproxAverageColor(source, 7);

    if(ubuf.saturation != 0) {
        vec3 hsv = rgb2hsv(color);
        hsv.y = ubuf.saturation;
        color = hsv2rgb(hsv);
    }


    if(ubuf.value != 0) {
        vec3 hsv = rgb2hsv(color);
        hsv.z = ubuf.value;
        color = hsv2rgb(hsv);
    }

    fragColor = vec4(color + ubuf.lighten, 1.0) * ubuf.qt_Opacity;
}
