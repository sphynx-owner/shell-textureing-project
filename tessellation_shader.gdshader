shader_type spatial;

render_mode specular_schlick_ggx, diffuse_lambert, shadows_disabled;

uniform float height = 0; 

uniform vec3 color : source_color;

uniform sampler3D wind_noise_x;

uniform sampler3D wind_noise_y;

uniform sampler2D domain_warp_noise_x;
uniform sampler2D domain_warp_noise_y;

varying vec3 normal;

vec4 noise(vec2 uv)
{
	return vec4(vec2(sin(uv.x), sin(uv.y)) / 4., cos(uv.x), cos(-uv.y));
}

void vertex() {
	normal = NORMAL;
}

void fragment() {
	float noise_sample_x = (texture(wind_noise_x, vec3(UV, 0) + vec3(TIME / 20.)).x - 0.5) * height / 40.;
	float noise_sample_y = (texture(wind_noise_y, vec3(UV, 0) + vec3(TIME / 20.)).x - 0.5) * height / 40.;
	vec2 winded_uv = UV + vec2(noise_sample_x, noise_sample_y);
	float domain_warp_sample_x = texture(domain_warp_noise_x, winded_uv).x;
	float domain_warp_sample_y = texture(domain_warp_noise_y, winded_uv).x;
	vec2 warped_uv = winded_uv + vec2(domain_warp_sample_x, domain_warp_sample_y) / 100.;
	vec4 noise_result = noise(warped_uv * 4000.);
	float opacity = pow(noise_result.x + noise_result.y + 0.5, 2) - height;
	if (opacity < 0.5)
		discard;
	float grass_brightness = pow(height, 2);
	NORMAL_MAP = vec3(normalize(-vec2(noise_result.z, -noise_result.w)), 0);
	ALBEDO = vec3(grass_brightness + 0.01) * color;//vec3(height);//
	ROUGHNESS = 1.;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
