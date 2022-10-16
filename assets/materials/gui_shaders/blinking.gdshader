shader_type canvas_item;

uniform vec4 color1 : hint_color = vec4(1.000000, 0.000000, 0.000000, 1.000000);
uniform vec4 color2 : hint_color = vec4(0.566406, 0.000000, 0.000000, 1.000000);
uniform float speed = 5;

void fragment() {
    COLOR = mix(color1, color2, sin(TIME * speed)) * texture(TEXTURE, UV);
}
