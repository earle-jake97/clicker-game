shader_type canvas_item;

uniform sampler2D grass_overlay_tex: repeat_enable, filter_nearest;
uniform sampler2D lava_overlay_tex: repeat_enable, filter_nearest;
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

	float tol = 0.02;

	// key colors (hex → normalized)
	vec3 key_a = vec3(0.7569, 0.6549, 0.4235); // #c1a76c
	vec3 key_b = vec3(1.0,   0.5019607843137255,   0.0);   // example

	float mA = match_color(COLOR.rgb, key_a, tol);
	float mB = match_color(COLOR.rgb, key_b, tol);

	vec4 texA = texture(grass_overlay_tex, world_position * scale);
	vec4 texB = texture(lava_overlay_tex, world_position * scale);

	// pick one by mask
	vec4 chosen =
		  texA * mA
		+ texB * mB;

	float mask = clamp(mA + mB, 0.0, 1.0);

	COLOR = mix(COLOR, chosen, mask);
}