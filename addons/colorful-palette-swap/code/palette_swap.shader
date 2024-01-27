shader_type canvas_item;
// https://www.reddit.com/r/godot/comments/pqtqmh/palette_swaps_without_making_every_sprite/

uniform sampler2D palette;

void fragment() {
    vec4 input = texture(TEXTURE, UV);
    highp float c = 0.33333333*(input.r+input.g+input.b);
    vec4 output = texture(palette, vec2(c, 0.0));
    output.a = input.a;
    COLOR.rgba = output;
}
