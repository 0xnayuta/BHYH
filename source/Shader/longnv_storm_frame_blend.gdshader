shader_type canvas_item;

uniform vec2 next_frame_uv_offset = vec2(0.0);
uniform float frame_blend : hint_range(0.0, 1.0) = 0.0;
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec4 current_frame = texture(TEXTURE, UV);
	vec4 next_frame = texture(TEXTURE, UV + next_frame_uv_offset);
	COLOR = mix(current_frame, next_frame, frame_blend) * vertex_tint;
}
