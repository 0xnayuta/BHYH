shader_type canvas_item;
// Mobile utils.boneBlendFuncObj: ONE / ONE_MINUS_SRC_COLOR.
// Account for PNG alpha and per-bone opacity before the screen composite.
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
varying vec4 bone_color;

void vertex() {
    bone_color = COLOR;
}

void fragment() {
    vec4 source = texture(TEXTURE, UV) * bone_color;
    vec3 background = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
    vec3 screened = source.rgb + background * (vec3(1.0) - source.rgb);
    COLOR = vec4(screened, source.a);
}
