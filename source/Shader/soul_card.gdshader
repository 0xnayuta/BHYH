// 7.4 魂卡闪卡着色器；来源与许可见 THIRD_PARTY_NOTICES.md（RuiC Card Skill）。
// Adapted from HRuiCcc/RuiC-card-skill, MIT. See THIRD_PARTY_NOTICES.md.
shader_type spatial;
render_mode unshaded, cull_back, shadows_disabled;

uniform sampler2D subject_texture : source_color, filter_linear, repeat_disable;
uniform sampler2D background_texture : source_color, filter_linear, repeat_disable;
uniform vec4 background_region = vec4(0.0, 0.0, 1.0, 1.0);
uniform sampler2D effects_texture : source_color, filter_linear, repeat_disable;
uniform sampler2D line_texture : filter_linear, repeat_disable;
uniform sampler2D typography_texture : source_color, filter_linear, repeat_disable;
uniform vec3 card_view = vec3(0.0, 0.0, 1.0);
uniform vec2 subject_fit = vec2(0.36, 0.54);
uniform vec4 subject_source_rect = vec4(0.0, 0.0, 1.0, 1.0);
uniform float foil : hint_range(0.0, 1.0) = 0.52;
uniform float subject_scale = 1.25;
uniform float subject_depth = 0.4;
uniform float background_depth = -0.25;
uniform float effects_depth = 0.5;
uniform float safe_scale = 1.12;
uniform vec2 safe_offset = vec2(-0.06, -0.035);
uniform int finish = 0;
uniform bool back_face = false;
uniform bool has_line = true;

float hash21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float inside(vec2 p) { return step(0.0,p.x)*step(0.0,p.y)*step(p.x,1.0)*step(p.y,1.0); }
float rounded_edge_distance(vec2 uv) {
    vec2 q = abs((uv-0.5)*vec2(2.8,4.2)) - (vec2(1.4,2.1)-vec2(0.09));
    return -(length(max(q,vec2(0.0))) + min(max(q.x,q.y),0.0) - 0.09);
}
vec2 parallax(vec2 uv, float depth) {
    return uv + card_view.xy / max(abs(card_view.z), 0.4) * depth * 0.10;
}
vec4 sample_layer(sampler2D image, vec2 web_uv) {
    // Three.js flips the uploaded PNG and the glTF V coordinate. Its material
    // formulas therefore use V-up; Godot's PNG samples use V-down.
    return texture(image, vec2(web_uv.x, 1.0-web_uv.y));
}
vec3 film(vec2 uv) {
    float phase = uv.x * 0.85 + uv.y * 0.55 + card_view.x * 1.5 - card_view.y * 0.9;
    if (finish == 3) {
        float hi = 0.5 + 0.5 * sin(phase * 6.28318);
        float glint = 0.5 + 0.5 * cos((phase + 0.25) * 6.28318);
        return mix(vec3(0.72,0.50,0.20), vec3(1.0,0.90,0.60), hi * 0.7 + glint * 0.3);
    }
    vec3 color = 0.66 + 0.25 * cos(6.28318 * (phase + vec3(0.0,0.33,0.67)));
    return finish == 1 ? vec3(dot(color, vec3(0.2126,0.7152,0.0722))) : color;
}
void fragment() {
    vec2 uv = vec2(UV.x, 1.0-UV.y);
    vec2 subject_local = (parallax(uv, subject_depth) - 0.5) * subject_scale / max(subject_fit, vec2(0.01)) + 0.5;
    vec2 subject_uv = subject_source_rect.xy + subject_local * subject_source_rect.zw;
    vec2 su = subject_uv * safe_scale + safe_offset;
    vec4 subject = sample_layer(subject_texture, clamp(su, vec2(0.0), vec2(1.0)));
    subject.a *= inside(su) * inside(subject_local) * inside(subject_uv);
    vec2 background_uv = clamp(parallax(uv, background_depth), vec2(0.0), vec2(1.0));
    background_uv.y = 1.0-background_uv.y;
    vec3 col = texture(background_texture, background_region.xy + background_uv * background_region.zw).rgb;
    col = mix(col, subject.rgb, subject.a);
    vec2 eu = parallax(uv, effects_depth);
    vec4 fx = sample_layer(effects_texture, clamp(eu, vec2(0.0), vec2(1.0)));
    col = mix(col, fx.rgb, fx.a * inside(eu));
    if (back_face) { col = vec3(0.028,0.045,0.042); }
    if (finish == 3) { col = col * vec3(1.02,0.95,0.78) + vec3(0.05,0.012,0.0); }
    float amount = finish == 2 ? 0.0 : foil;
    vec3 spectrum = film(uv);
    float band = pow(0.5+0.5*sin((uv.x*0.72+uv.y*0.45+card_view.x*1.2+card_view.y*0.6)*6.283),10.0);
    float luminance = dot(col,vec3(0.2126,0.7152,0.0722));
    col *= 1.0 - amount*0.21*(1.0-spectrum)*(0.2+band*0.8);
    col += spectrum*amount*band*(finish == 3 ? 1.7 : 1.0)*(0.065+0.11*(1.0-luminance));
    float edge_distance = rounded_edge_distance(uv);
    float edge = 1.0-smoothstep(0.012,0.065,edge_distance);
    col = mix(col,spectrum*0.75+0.21,edge*amount*0.42);
    vec2 cell = floor(uv*vec2(480.0,720.0));
    float flake = step(0.994,hash21(cell))*pow(0.5+0.5*sin(hash21(cell+8.0)*30.0+card_view.x*20.0+TIME*0.6),10.0);
    col += spectrum*flake*amount*0.13;
    if (!back_face && has_line) {
        float line = 1.0-smoothstep(0.06,0.25,sample_layer(line_texture,clamp(su,vec2(0.0),vec2(1.0))).r);
        col += line*inside(su)*subject.a*band*amount*0.055;
    }
    vec4 typography = sample_layer(typography_texture,uv);
    col = mix(clamp(col,vec3(0.0),vec3(1.0)),typography.rgb,typography.a);
    // A narrow foil rim follows the physical rounded silhouette, not a printed frame.
    float aa = max(fwidth(edge_distance),0.0005);
    float rim = 1.0-smoothstep(0.021-aa,0.021+aa,edge_distance);
    vec3 rim_color = mix(vec3(0.66,0.56,0.34),spectrum*0.72+0.25,amount);
    col = mix(col,rim_color,rim);
    float inner_line = 1.0-smoothstep(0.0015,0.0015+aa,abs(edge_distance-0.037));
    ALBEDO = mix(col,vec3(0.78,0.63,0.32),inner_line*0.75);
}
