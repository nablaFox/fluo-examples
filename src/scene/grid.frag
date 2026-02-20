layout (location = 0) in vec2 uv;
layout (location = 1) in vec3 world_pos;
layout (location = 2) in vec3 world_normal;

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
    SpotLight spotlights[16];
});

DEF_MATERIAL({
  vec3 color;
  vec3 grid_color;
  float spacing;
  float thickness;
});

vec3 calcSpotLight(SpotLight light, vec3 N) {
    vec3 L = normalize(light.position - world_pos);
    float theta = dot(L, normalize(-light.direction));
    if (theta <= light.outer_cutoff) return vec3(0.0);
    float epsilon = light.inner_cutoff - light.outer_cutoff;
    float intensity = clamp((theta - light.outer_cutoff) / epsilon, 0.0, 1.0);
    float dist = length(light.position - world_pos);
    float attenuation = 1.0 / (1.0 + light.linear * dist + light.quadratic * dist * dist);
    float NdotL = max(dot(N, L), 0.0);
    return NdotL * light.color * intensity * attenuation;
}

float filteredGridAxis(float uv1d, float period, float lineHW) {
    float fw = length(vec2(dFdx(uv1d), dFdy(uv1d)));

    float p  = uv1d / period;
    float d  = (abs(fract(p + 0.5) - 0.5)) * period - lineHW;

    float edgeCoverage = 1.0 - smoothstep(-fw, fw, d);

    float dutyCycle = clamp((lineHW * 2.0) / period, 0.0, 1.0);

    float blend = smoothstep(0.5, 2.0, fw / period);

    return mix(edgeCoverage, dutyCycle, blend);
}

float filteredGrid(vec2 uv, float spacing, float lineWidth) {
    float hw = lineWidth * 0.5;
    float gx = filteredGridAxis(uv.x, spacing, hw);
    float gy = filteredGridAxis(uv.y, spacing, hw);
    return gx + gy - gx * gy;
}

void main() {
  float line = filteredGrid(uv, MATERIAL.spacing,   MATERIAL.thickness);
  float sub_line = filteredGrid(uv, MATERIAL.spacing / 3.0, MATERIAL.thickness * 0.5);

  vec3 c = MATERIAL.color;

  c = mix(c, MATERIAL.grid_color, sub_line * 0.4);
  c = mix(c, MATERIAL.grid_color, line);

  vec3 N = -normalize(world_normal);
  vec3 light = normalize(-F_PARAMS.light_dir);
  float diff = max(dot(N, light), 0.0);

  vec3 lighting = F_PARAMS.ambient + F_PARAMS.light_color * diff;

  for (uint i = 0u; i < F_PARAMS.spotlights_count; i++) {
      lighting += calcSpotLight(F_PARAMS.spotlights[i], N);
  }

  c *= lighting;

  out_color = vec4(c, 1.0);
}
