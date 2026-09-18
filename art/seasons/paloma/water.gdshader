shader_type spatial;
render_mode specular_schlick_ggx, cull_disabled;

uniform vec4 deep : source_color = vec4(0.043, 0.431, 0.435, 1.0);
uniform vec4 lagoon : source_color = vec4(0.180, 0.769, 0.714, 1.0);
uniform float speed = 0.35;

void fragment() {
	float w = sin(UV.x * 28.0 + TIME * speed * 2.4) * 0.5 + 0.5;
	float w2 = sin(UV.y * 22.0 - TIME * speed * 1.7 + w) * 0.5 + 0.5;
	ALBEDO = mix(deep.rgb, lagoon.rgb, 0.45 + 0.35 * w2);
	ROUGHNESS = 0.18;
	METALLIC = 0.05;
	EMISSION = lagoon.rgb * 0.08 * w2;
}
