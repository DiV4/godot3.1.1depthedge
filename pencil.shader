shader_type spatial;
render_mode skip_vertex_transform, unshaded;

uniform float width = 0.5;
varying mat4 CAMERA;

void vertex() {
	PROJECTION_MATRIX = mat4(1.0); //Billboard code by BastiaanOlij.
	VERTEX.xy *= 2.0;
}

void fragment() {
	vec2 uv = vec2(UV.x, 1.0 - UV.y); //for some reason UVs are upside down in the quad.
	
	float depth = texture(DEPTH_TEXTURE, uv).r;
	depth = depth * 2.0 - 1.0;
	float z = -PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]); //Depth texture projection code by BastiaanOlij.
	float delta = -(z - VERTEX.z);
	
	float depth2 = texture(DEPTH_TEXTURE, uv + vec2(width / 100.0)).r;
	depth2 = depth2 * 2.0 - 1.0;
	float z2 = -PROJECTION_MATRIX[3][2] / (depth2 + PROJECTION_MATRIX[2][2]);
	float delta2 = -(z2 - VERTEX.z);
	
	float dif = delta / delta2 / 1.05; //Getting a gray image with black and white edges.
	dif = pow(dif, 25.0);
	dif = (1.0 - clamp(dif, 0.5, 1.0)) * clamp(dif, 0.0, 0.1) * 10.0; //Turning the white edges black, combining.
	ALBEDO.rgb = vec3(dif) * texture(SCREEN_TEXTURE, uv).rgb * 2.0;
}