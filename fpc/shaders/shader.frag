layout(location = 0) in vec2 uv;

DEF_MATERIAL({
    uint albedo;
});

void main() {
    out_color = TEXTURE(MATERIAL.albedo, uv);
}
