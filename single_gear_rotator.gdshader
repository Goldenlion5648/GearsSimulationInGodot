shader_type canvas_item;

uniform vec3 gear_color;
uniform bool counter_clockwise = false;
uniform float rotation_speed_mult = 1.0;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
	float rotation_angle = TIME * mix(1.0, -1.0, float(counter_clockwise)) * rotation_speed_mult +
									mix(0.6, 0, float(counter_clockwise));
    vec2 uv_rotated = vec2(
        cos(rotation_angle) * (UV.x - center.x) + sin(rotation_angle) * (UV.y - center.y) + center.x,
        cos(rotation_angle) * (UV.y - center.y) - sin(rotation_angle) * (UV.x - center.x) + center.y
    );
    COLOR = texture(TEXTURE, uv_rotated);
	COLOR.rgb = gear_color;
}
