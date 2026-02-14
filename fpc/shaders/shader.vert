layout(location = 0) out vec2 frag_uv;

DEF_FRAME_PARAMS({
  mat4 viewproj;
});

DEF_DRAW_PARAMS({
  mat4 model;
});

void main() {
    gl_Position = F_PARAMS.viewproj * D_PARAMS.model * vec4(in_position, 1.0);

    frag_uv = in_uv;
}
