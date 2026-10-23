shader_type canvas_item;

uniform int SAMPLES = 6;
uniform float WIDTH = 4.0;
uniform vec4 OUTLINE_COLOR : source_color = vec4(0., 0., 0., 1.);
uniform vec2 TEXTURE_SCALE = vec2(0.94);
uniform vec4 TINT_COLOR : source_color = vec4(1., 1., 1., 1.);  // 新增：颜色调制

void fragment() {
    vec2 uv_offset = (1.0 - TEXTURE_SCALE) * 0.5;
    vec2 uv = UV / TEXTURE_SCALE - uv_offset;
    
    vec4 cc = texture(TEXTURE, uv);
    // 裁剪边缘
    if (UV.x < uv_offset.x || UV.x > 1.0 - uv_offset.x) {
        cc.a = 0.0;
    }
    if (UV.y < uv_offset.y || UV.y > 1.0 - uv_offset.y) {
        cc.a = 0.0;
    }
    
    // 应用颜色调制（仅 RGB，保持 Alpha 不变或根据需要调整）
    cc.rgb *= TINT_COLOR.rgb;
    // 如果需要同时改变透明度，可以取消下一行注释
    // cc.a *= TINT_COLOR.a;
    
    // 计算轮廓
    float outlineAlpha = 0.0;
    float angle = 0.0;
    float unit_angle = 1.0 / float(SAMPLES) * 3.14159 * 2.0;
    for (int i = 0; i < SAMPLES; i++) {
        angle += unit_angle;
        vec2 testPoint = vec2(
            (WIDTH * TEXTURE_PIXEL_SIZE.x) * cos(angle),
            (WIDTH * TEXTURE_PIXEL_SIZE.y) * sin(angle)
        );
        testPoint = clamp(testPoint + uv, vec2(0.0), vec2(1.0));
        float sampledAlpha = texture(TEXTURE, testPoint).a;
        outlineAlpha = max(outlineAlpha, sampledAlpha);
    }
    
    vec4 outline = vec4(OUTLINE_COLOR.rgb, OUTLINE_COLOR.a * outlineAlpha);
    // 混合轮廓和纹理（纹理的 alpha 决定显示比例）
    COLOR = mix(outline, cc, cc.a);
}