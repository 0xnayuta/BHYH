shader_type canvas_item;
// 显示进度：0完全隐藏，1完全显示
uniform float reveal : hint_range(0.0, 1.0) = 0.0;
// 羽化过渡宽度，0=硬边，0.1~0.3柔和渐变
uniform float feather : hint_range(0.0, 0.5) = 0.15;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    // UV.y：底部=0，顶部=1，自下而上显示
    float mask = smoothstep(reveal - feather, reveal, UV.y);
    COLOR.a = tex.a * mask;
    COLOR.rgb = tex.rgb;
}