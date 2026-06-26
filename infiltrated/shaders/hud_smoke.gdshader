shader_type canvas_item;

// Opaque, full-screen smoky environment drawn behind the world tiles.
// Dark base with lighter drifting wisps -> creepy, ghostly fog.
uniform vec3 color_dark : source_color = vec3(0.05, 0.05, 0.06);
uniform vec3 color_smoke : source_color = vec3(0.32, 0.32, 0.35);
uniform float speed = 0.22;
// Strength of the wispy tendril warping.
uniform float wisp = 0.7;
// How much of the screen the wisps cover (higher = thicker fog).
uniform float density : hint_range(0.0, 1.0) = 0.88;
// Pixelation grid: lower = chunkier pixels.
uniform float pixels = 250.0;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	// 4 octaves: pixelation hides finer detail, so this stays cheap.
	for (int i = 0; i < 4; i++) {
		v += amp * noise(p);
		p = p * 2.0 + vec2(11.3, 7.1);
		amp *= 0.5;
	}
	return v;
}

void fragment() {
	// Snap to a grid first -> chunky, pixel-art smoke.
	vec2 uv = floor(UV * pixels) / pixels;
	float t = TIME * speed;

	// Fog drifts slowly upward and sways sideways.
	vec2 drift = vec2(sin(t * 0.3) * 0.15, -t);

	// Domain warp -> organic, ghostly tendrils across the whole screen.
	vec2 q = vec2(
		fbm(uv * 3.0 + drift),
		fbm(uv * 3.0 + vec2(5.2, 1.3) - drift)
	);
	float smoke = fbm(uv * 3.5 + q * wisp + drift);

	// Map density -> how much fog shows. Higher density = thicker coverage.
	smoke = smoothstep(1.0 - density, 1.0, smoke);

	// Slow eerie "breathing" so the fog feels alive.
	float breathe = 0.9 + 0.1 * sin(TIME * 0.6);

	vec3 col = mix(color_dark, color_smoke, smoke * breathe);
	COLOR = vec4(col, 1.0);
}
