layout(location = 0) in vec2 uv;

DEF_MATERIAL({
    vec4 outline;
    float thickness;
    uint albedo;
});

void main() {
    vec4 tex = TEXTURE(MATERIAL.albedo, uv);

    float dist = min(
        min(uv.x, 1.0 - uv.x),
        min(uv.y, 1.0 - uv.y)
    );

    float fw = fwidth(dist);
    float edge = smoothstep(MATERIAL.thickness - fw, MATERIAL.thickness + fw, dist);

    out_color = mix(MATERIAL.outline, tex, edge);
}
