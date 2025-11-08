#!/bin/bash
qsb-qt6 --glsl 100es,120,150 --hlsl 50 --msl 12 -o TaskIconGlow.frag TaskIconGlow.glsl 
qsb-qt6 --glsl 100es,120,150 --hlsl 50 --msl 12 -o Quantize.frag Quantize.glsl 
qsb-qt6 --glsl 100es,120,150 --hlsl 50 --msl 12 -o InverseCorner.frag InverseCorner.glsl
