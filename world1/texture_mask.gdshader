shader_type canvas_item;

uniform sampler2D overlay_tex: repeat_enable, filter_nearest;
uniform float scale = 0.006944444; // calculated by 1/texture size e.g. 1/144
varying vec2 world_position;

void vertex(){
	// calculate the world position for use in the fragment shader
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float match_color(vec3 a, vec3 b, float tol) {
	return step(distance(a, b), tol);
}
void fragment() {

	float tol = 0.01;

	// key colors (hex → normalized)
	vec3 key_a = vec3(0.7764705882352941, 0.47843137254901963, 0.25882352941176473); // #c1a76c

	float mA = match_color(COLOR.rgb, key_a, tol);

	vec4 texA = texture(overlay_tex, world_position * scale);

	// pick one by mask
	vec4 chosen =
		  texA * mA;

	float mask = clamp(mA, 0.0, 1.0);

	COLOR = mix(COLOR, chosen, mask);
}