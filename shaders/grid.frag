layout (location = 0) in vec2 uv;
layout (location = 2) in vec3 world_normal;

const int MAX_POINT_LIGHTS = 16;

struct SpotLight {
    vec3 position;
    vec3 direction;
    float inner_cutoff;
    float outer_cutoff; 
};

DEF_FRAME_PARAMS({
    vec3 camera_pos;
    vec3 ambient;
    vec3 light_dir;
    vec3 light_color;
});

DEF_MATERIAL({
  vec3 color;
  vec3 grid_color;
  float spacing;
  float thickness;
});

void main() {
  float sub_spacing = MATERIAL.spacing / 3.0;
  float sub_thickness = MATERIAL.thickness * 0.5;

  vec2 p = uv / MATERIAL.spacing + 0.5;
  vec2 a = abs(fract(p) - 0.5);

  float d = min(a.x, a.y);
  float t = (MATERIAL.thickness / MATERIAL.spacing) * 0.5;
  float fw = fwidth(d);
  float line = 1.0 - smoothstep(t - fw, t + fw, d);

  vec2 sp = uv / sub_spacing + 0.5;
  vec2 sa = abs(fract(sp) - 0.5);

  float sd = min(sa.x, sa.y);
  float st = (sub_thickness / sub_spacing) * 0.5;
  float sfw = fwidth(sd);
  float sub_line = 1.0 - smoothstep(st - sfw, st + sfw, sd);

  vec3 c = MATERIAL.color;

  c = mix(c, MATERIAL.grid_color, sub_line * 0.4);
  c = mix(c, MATERIAL.grid_color, line);

  vec3 normal = normalize(world_normal);
  vec3 light = normalize(-F_PARAMS.light_dir);

  float diff = max(dot(normal, light), 0.0);

  vec3 lighting = F_PARAMS.ambient + F_PARAMS.light_color * diff;
  c *= lighting;

  out_color = vec4(c, 1.0);
}
