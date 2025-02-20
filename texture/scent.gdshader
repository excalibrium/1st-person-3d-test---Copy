shader_type spatial;
render_mode cull_disabled;
uniform sampler2D normal_texture;
uniform sampler2D crack_texture;
uniform sampler2D curve;  // For controlling the height/width distribution
uniform sampler2D curve_domain;  // For controlling the height/width distribution
uniform float fade_height = 1.0;
uniform float width_scale = 1.0;
uniform sampler2D texture_a;
uniform float noise_threshold = 0.5; // Add threshold control
uniform float noise_smoothness = 0.5;
uniform float test = 0.5;
void fragment() {
    // Sample your curve texture to get height variation
	vec4 curve_tex = texture(curve, UV);
	vec4 crack = texture(crack_texture, vec2(UV.x * width_scale + TIME / 5.0, UV.y + curve_tex.r));
    // Use it to modify your alpha

	vec4 color = texture(texture_a, vec2(UV.x, UV.y ));
	ALBEDO = crack.xyz * color.xyz;
	EMISSION = crack.xyz / 5.0;
}

void vertex(){

	vec4 curve_tex = texture(curve, UV);
	vec4 crack = texture(crack_texture, vec2(UV.x * width_scale + TIME / 5.0, UV.y + curve_tex.r));
	vec4 normal = texture(normal_texture, vec2(UV.x * width_scale + TIME / 5.0, UV.y + curve_tex.r));
	vec4 cd = texture(curve_domain, UV);
	VERTEX.xyz += cd.xyz;
	NORMAL = normal.rgb;
	//VERTEX.xz += NORMAL.xz * curve_tex.xz;
}