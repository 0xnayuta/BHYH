shader_type canvas_item;

void fragment() {
    vec4 pixel = texture(TEXTURE, UV);
    float seam = 0.5;
    float half_width = TEXTURE_PIXEL_SIZE.x * 4.0;
    if (abs(UV.x - seam) < half_width) {
        vec4 left_pixel = texture(TEXTURE, vec2(seam - half_width, UV.y));
        vec4 right_pixel = texture(TEXTURE, vec2(seam + half_width, UV.y));
        float blend = smoothstep(seam - half_width, seam + half_width, UV.x);
        pixel = mix(left_pixel, right_pixel, blend);
    }
    COLOR = pixel;
}
