layout(location = 0) out vec2 frag_uv;

DEF_PARAMS({
  mat4 viewproj;
  mat4 model;
});

void main() {
    gl_Position = PARAMS.viewproj * PARAMS.model * vec4(in_position, 1.0);

    frag_uv = in_uv;
}
