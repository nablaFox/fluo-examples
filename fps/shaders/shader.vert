#version 450

#define VERTEX_SHADER
#include "fluo.glsl"

layout(location = 0) out vec2 frag_uv;

DEF_MATERIAL({
    uint albedo;
    mat4 proj;
    vec3 position;
    vec3 rotation;
});

void main() {
    float cx = cos(MATERIAL.rotation.x), sx = sin(MATERIAL.rotation.x);
    float cy = cos(MATERIAL.rotation.y), sy = sin(MATERIAL.rotation.y);
    float cz = cos(MATERIAL.rotation.z), sz = sin(MATERIAL.rotation.z);

    mat3 Rx = mat3(
        1,  0,   0,
        0,  cx, -sx,
        0,  sx,  cx
    );

    mat3 Ry = mat3(
         cy, 0, sy,
          0, 1,  0,
        -sy, 0, cy
    );

    mat3 Rz = mat3(
        cz, -sz, 0,
        sz,  cz, 0,
         0,   0, 1
    );

    mat3 R = Rz * Ry * Rx;

    mat3 Vrot = transpose(R);

    vec3 Vpos = -(Vrot * MATERIAL.position);

    mat4 View = mat4(
        vec4(Vrot[0], 0.0),
        vec4(Vrot[1], 0.0),
        vec4(Vrot[2], 0.0),
        vec4(Vpos,    1.0)
    );

    mat4 ViewProj = MATERIAL.proj * View;

    gl_Position = ViewProj * vec4(in_position, 1.0);

    frag_uv = in_uv;
}
