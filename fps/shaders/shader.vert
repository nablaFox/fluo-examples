#version 450

#define VERTEX_SHADER
#include "fluo.glsl"

layout(location = 0) out vec2 frag_uv;

DEF_MATERIAL({
    uint albedo;
    mat4 viewproj;
});

void main() {
    gl_Position = MATERIAL.viewproj * vec4(in_position, 1.0);

    frag_uv = in_uv;
}
