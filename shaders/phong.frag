layout(location = 0) in vec2 uv;
layout(location = 1) in vec3 world_pos;
layout(location = 2) in vec3 world_normal;

const int MAX_POINT_LIGHTS = 16;

struct SpotLight {
    vec3 position;
    vec3 direction;
    vec3 color;
    float inner_cutoff;
    float outer_cutoff; 
};

DEF_FRAME_PARAMS({
    vec3 camera_pos;
    vec3 ambient;
    vec3 light_dir;
    vec3 light_color;
    uint spot_lights_count;
    SpotLight spot_lights[MAX_POINT_LIGHTS];
});

DEF_MATERIAL({
    uint  albedo;
    vec3  diffuse;
    vec3  specular;
    vec3  emissive;
    vec3  trasmission;
    float shininess;
    float opacity;
    float ior;
    int   illum;
});

void main() {
    vec3 N = normalize(world_normal);
    vec3 L = normalize(F_PARAMS.light_dir);
    vec3 V = normalize(F_PARAMS.camera_pos - world_pos);

    vec3 albedo = TEXTURE(MATERIAL.albedo, uv).rgb;

    if (MATERIAL.illum == 0) {
        out_color = vec4(albedo * MATERIAL.diffuse, MATERIAL.opacity);
        return;
    }

    float NdotL = max(dot(N, L), 0.0);

    vec3 diffuse = albedo * MATERIAL.diffuse * NdotL * F_PARAMS.light_color;

    vec3 specular = vec3(0.0);

    if (MATERIAL.illum >= 2) {
        vec3 H = normalize(L + V);
        float NdotH = max(dot(N, H), 0.0);
        float spec = (NdotL > 0.0) ? pow(NdotH, MATERIAL.shininess) : 0.0;
        specular = MATERIAL.specular * spec * F_PARAMS.light_color;
    }

    vec3 color = (albedo * F_PARAMS.ambient) + diffuse + specular + MATERIAL.emissive;

    if (MATERIAL.opacity < 1.0) {
        color *= MATERIAL.trasmission;
    }

    out_color = vec4(color, MATERIAL.opacity);
}
