shader_type spatial;
uniform float strength : hint_range(0, 1);
void fragment() {
	EMISSION = vec3(1.0, 1.0, 1.0);
	ALPHA = strength;
}
