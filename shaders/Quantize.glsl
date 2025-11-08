#version 440

layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;

layout(std140, binding=0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float saturation;
} ubuf;

layout(binding=2) uniform sampler2D source;

const float minAlpha = 0.05;     // Ignore nearly transparent pixels
const float minBrightness = 0.05; // Ignore near-black
const float maxBrightness = 0.95; // Ignore near-white

vec3 saturateColor(vec3 color, float saturationBoost) {
    // Convert RGB to HSL
    float maxC = max(max(color.r, color.g), color.b);
    float minC = min(min(color.r, color.g), color.b);
    float delta = maxC - minC;

    float lightness = (maxC + minC) * 0.5;

    float saturation = 0.0;
    if (delta > 0.0) {
        saturation = delta / (1.0 - abs(2.0 * lightness - 1.0));
    }

    // Hue calculation
    float hue = 0.0;
    if (delta > 0.0) {
        if (maxC == color.r) {
            hue = mod((color.g - color.b) / delta, 6.0);
        } else if (maxC == color.g) {
            hue = (color.b - color.r) / delta + 2.0;
        } else {
            hue = (color.r - color.g) / delta + 4.0;
        }
        hue /= 6.0;
    }

    // Boost saturation
    saturation = clamp(saturation * saturationBoost, 0.0, 1.0);

    // Convert HSL back to RGB
    float c = (1.0 - abs(2.0 * lightness - 1.0)) * saturation;
    float x = c * (1.0 - abs(mod(hue * 6.0, 2.0) - 1.0));
    float m = lightness - c * 0.5;

    vec3 rgb;
    if (0.0 <= hue && hue < 1.0/6.0) rgb = vec3(c, x, 0.0);
    else if (1.0/6.0 <= hue && hue < 2.0/6.0) rgb = vec3(x, c, 0.0);
    else if (2.0/6.0 <= hue && hue < 3.0/6.0) rgb = vec3(0.0, c, x);
    else if (3.0/6.0 <= hue && hue < 4.0/6.0) rgb = vec3(0.0, x, c);
    else if (4.0/6.0 <= hue && hue < 5.0/6.0) rgb = vec3(x, 0.0, c);
    else rgb = vec3(c, 0.0, x);

    return rgb + vec3(m);
}


vec3 getApproxAverageColor(sampler2D tex, int gridSize) {
    vec3 colorSum = vec3(0.0);
    int totalSamples = 0;

    for (int x = 0; x < gridSize; ++x) {
        for (int y = 0; y < gridSize; ++y) {
            vec2 uv = vec2(float(x) + 0.5, float(y) + 0.5) / float(gridSize);
            vec4 sampleColor = texture(tex, uv);

            float brightness = dot(sampleColor.rgb, vec3(0.299, 0.587, 0.114)); // Luminance

            if (sampleColor.a > minAlpha &&
                brightness > minBrightness &&
                brightness < maxBrightness) {
                colorSum += sampleColor.rgb;
                totalSamples += 1;
            }
        }
    }
    
    if (totalSamples > 0) {
        return colorSum / totalSamples;
    } else {
        return vec3(0.5);
    }
}

void main() {
    fragColor = vec4(saturateColor(getApproxAverageColor(source, 7), ubuf.saturation), 1.0) * ubuf.qt_Opacity;
}
