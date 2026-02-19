layout(location = 0) out vec2 uv;
layout(location = 1) out vec3 world_pos;
layout(location = 2) out vec3 world_normal;

DEF_DRAW_PARAMS({
  mat4 viewproj;
  mat4 model;
});

void main() {
    vec4 world_pos4 = D_PARAMS.model * vec4(in_position, 1.0);
    world_pos = world_pos4.xyz;

    mat3 normal_mat = transpose(inverse(mat3(D_PARAMS.model)));
    world_normal = normalize(normal_mat * in_normal);

    gl_Position = D_PARAMS.viewproj * world_pos4;

    uv = in_uv;
}
