layout(location = 0) out vec2 frag_uv;
layout(location = 1) out vec3 frag_world_pos;
layout(location = 2) out vec3 frag_world_normal;

DEF_FRAME_PARAMS({
  mat4 viewproj;
});

DEF_DRAW_PARAMS({
  mat4 model;
});

void main() {
    vec4 world_pos4 = D_PARAMS.model * vec4(in_position, 1.0);
    frag_world_pos = world_pos4.xyz;

    mat3 normal_mat = transpose(inverse(mat3(D_PARAMS.model)));
    frag_world_normal = normalize(normal_mat * in_normal);

    gl_Position = F_PARAMS.viewproj * world_pos4;

    frag_uv = in_uv;
}
