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
    float linear;
    float quadratic;
};

DEF_FRAME_PARAMS({
    vec3 camera_pos;
    vec3 ambient;
    vec3 light_dir;
    vec3 light_color;
    uint spotlights_count;
    SpotLight spotlights[MAX_POINT_LIGHTS];
});

DEF_MATERIAL({
    uint albedo;
    vec3 diffuse;
    vec3 specular;
    vec3 emissive;
    vec3 transmission;
    float shininess;
    float opacity;
    float ior;
    int illum;
});

vec3 calcSpotLight(SpotLight light, vec3 N, vec3 V, vec3 albedo) {
    vec3 L = normalize(light.position - world_pos);

    float theta = dot(L, normalize(-light.direction));

    if (theta <= light.outer_cutoff) return vec3(0.0);

    float epsilon = light.inner_cutoff - light.outer_cutoff;
    float intensity = clamp((theta - light.outer_cutoff) / epsilon, 0.0, 1.0);

    float dist = length(light.position - world_pos);
    float attenuation = 1.0 / (1.0 + light.linear * dist + light.quadratic * dist * dist);

    float NdotL = max(dot(N, L), 0.0);

    vec3 diffuse = albedo * MATERIAL.diffuse * NdotL * light.color * intensity * attenuation;
    vec3 specular = vec3(0.0);

    if (MATERIAL.illum >= 2) {
        vec3 H = normalize(L + V);
        float NdotH = max(dot(N, H), 0.0);
        float spec = (NdotL > 0.0) ? pow(NdotH, MATERIAL.shininess) : 0.0;
        specular = MATERIAL.specular * spec * light.color * intensity * attenuation;
    }

    return diffuse + specular;
}

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

    vec3 color = (albedo * F_PARAMS.ambient) + diffuse + MATERIAL.emissive;

    for (uint i = 0u; i < F_PARAMS.spotlights_count; i++) {
      color += calcSpotLight(F_PARAMS.spotlights[i], N, V, albedo);
    }

    if (MATERIAL.illum >= 2) {
        vec3 H = normalize(L + V);
        float NdotH = max(dot(N, H), 0.0);
        float spec = (NdotL > 0.0) ? pow(NdotH, MATERIAL.shininess) : 0.0;
        color += MATERIAL.specular * spec * F_PARAMS.light_color;
    }

    if (MATERIAL.opacity < 1.0) {
        color *= MATERIAL.transmission;
    }

    out_color = vec4(color, MATERIAL.opacity);
}
