layout(location = 0) in vec2 uv;

DEF_MATERIAL({
	vec4 outline;
	float thickness;
  uint albedo;
});

void main() {
	if (uv.x < MATERIAL.thickness 
		|| uv.x > 1.0 - MATERIAL.thickness 
		|| uv.y < MATERIAL.thickness 
		|| uv.y > 1.0 - MATERIAL.thickness) {
		out_color = MATERIAL.outline;
		return;
	}

	out_color = TEXTURE(MATERIAL.albedo, uv);
}

