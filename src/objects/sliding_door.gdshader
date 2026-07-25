shader_type canvas_item;

// World-space Y threshold. Any pixel with world_pos.y < cutoff_y will be discarded.
uniform float cutoff_y = 0.0;

varying vec2 world_pos_v;

void vertex() {
    world_pos_v = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a == 0.0) {
        discard;
    }

    // Discard if above the cutoff (smaller Y)
    if (world_pos_v.y < cutoff_y) {
        discard;
    }

    COLOR = tex_color;
}
