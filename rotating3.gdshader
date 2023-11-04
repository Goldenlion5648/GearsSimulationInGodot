shader_type canvas_item;

//uniform float rotation_angle : hint_range(0, 360);

void fragment() {
    vec2 center = vec2(0.5, 0.5);
	float rotation_angle = TIME;
    vec2 uv_rotated = vec2(
        cos(rotation_angle) * (UV.x - center.x) + sin(rotation_angle) * (UV.y - center.y) + center.x,
        cos(rotation_angle) * (UV.y - center.y) - sin(rotation_angle) * (UV.x - center.x) + center.y
    );
    COLOR = texture(TEXTURE, uv_rotated);
	COLOR.r = 0.8;
	COLOR.g = 0.1;
	COLOR.b = 0.1;
}