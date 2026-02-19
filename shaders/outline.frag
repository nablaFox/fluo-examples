layout(location = 0) in vec2 uv;

DEF_MATERIAL({
    vec3 outline;
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

    vec4 outline = vec4(MATERIAL.outline, 1.0);

    out_color = mix(outline, tex, edge);
}
