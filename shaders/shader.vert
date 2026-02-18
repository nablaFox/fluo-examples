layout(location = 0) out vec2 frag_uv;

DEF_DRAW_PARAMS({
  mat4 viewproj;
  mat4 model;
});

void main() {
    gl_Position = D_PARAMS.viewproj * D_PARAMS.model * vec4(in_position, 1.0);

    frag_uv = in_uv;
}
