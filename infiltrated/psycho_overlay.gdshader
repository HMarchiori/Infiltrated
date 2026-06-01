shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	float t = TIME * 0.2;

	// Very subtle wave distortion
	float wave_x = sin(uv.y * 5.0 + t * 0.9) * 0.0022;
	float wave_y = cos(uv.x * 4.0 + t * 0.6) * 0.00015;
	vec2 warped = uv + vec2(wave_x, wave_y);

	// Light chromatic aberration
	float aberr = 0.0015;
	float r = texture(screen_texture, warped + vec2(aberr, 0.0)).r;
	float g = texture(screen_texture, warped).g;
	float b = texture(screen_texture, warped - vec2(aberr, 0.0)).b;
	vec3 col = vec3(r, g, b);

	// Very faint blood tint
	float blood = sin(t * 1.8) * 0.012 + 0.03;
	col.r += blood;
	col.g -= blood * 0.3;
	col.b -= blood * 0.4;

	COLOR = vec4(col, 1.0);
}
