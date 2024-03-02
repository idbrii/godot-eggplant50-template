// If you're worried about sticking to the colors, you can add a canvas layer
// with a color rect and apply a shader to it. It will force everything to
// adhere to the palette.
//
// From Kevin: https://discord.com/channels/690388280767807518/807007411977715743/1213225146161041459
shader_type canvas_item;

// Insert a palette from lospec for instance
uniform sampler2D palette : hint_black; 
uniform int palette_size = 16;

void fragment(){ 
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 new_color = vec4(.0);
    
    for (int i = 0; i < palette_size; i++) {
        vec4 palette_color = texture(palette, vec2(1.0 / float(palette_size) * (float(i) + 0.5), .0));
        if (distance(palette_color, color) < distance(new_color, color)) {
            new_color = palette_color;
        }
    }
    
    COLOR = new_color;
    COLOR.a = color.a;
}
