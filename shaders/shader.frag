layout(location = 0) in vec2 uv;
layout(location = 1) in vec3 world_pos;
layout(location = 2) in vec3 world_normal;

DEF_MATERIAL({
    uint albedo;
    vec3 kd;
    vec3 ks;   
    float shininess;
});

DEF_FRAME_PARAMS({
    vec3 camera_pos;
    vec3 light_dir;
    vec3 light_color;
    vec3 ambient;
});

void main() {
    vec3 N = normalize(world_normal);
    vec3 L = normalize(F_PARAMS.light_dir);
    vec3 V = normalize(F_PARAMS.camera_pos - world_pos);

    float NdotL = max(dot(N, L), 0.0);

    vec3 R = reflect(-L, N);
    float spec = (NdotL > 0.0) ? pow(max(dot(R, V), 0.0), MATERIAL.shininess) : 0.0;

    vec3 albedo = TEXTURE(MATERIAL.albedo, uv).rgb;

    vec3 diffuse  = albedo * MATERIAL.kd * NdotL * F_PARAMS.light_color;
    vec3 specular = MATERIAL.ks * spec * F_PARAMS.light_color;
    vec3 ambient  = albedo * F_PARAMS.ambient;

    vec3 color = ambient + diffuse + specular;

    out_color = vec4(color, 1.0);
}
