shader_type spatial; //Spatial shader because we need to access the depth buffer
render_mode skip_vertex_transform, unshaded; //Disabling lighting on the quad

uniform float width : hint_range(0.1, 1.0) = 0.5; //This float sets the thickness of the lines

void vertex() {
	PROJECTION_MATRIX = mat4(1.0); //This line makes the quad always look at the camera
}

void fragment() {
	vec2 uv = SCREEN_UV; //Since the quad always fills the screen, we can use screen UVs
	
	float depth = texture(DEPTH_TEXTURE, uv).r; //Sampling the first depth texture as float, because it's black and white
	float z = -PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]); //Some matrix magic by BastiaanOlij to "reverse our projection calculation on our z value"
	
	float depth2 = texture(DEPTH_TEXTURE, uv + vec2(width / 100.0)).r; //Sampling another texture at a certain offset
	float z2 = -PROJECTION_MATRIX[3][2] / (depth2 + PROJECTION_MATRIX[2][2]); //Same matrix operation here
	
	float dif = z / z2 / 1.05; //Getting a gray image with black and white edges
	dif = pow(dif, 25.0); //Increasing the contrast further
	dif = (1.0 - clamp(dif, 0.5, 1.0)) * clamp(dif, 0.0, 0.1) * 10.0; //Clamping the most dark and light values, making the latter dark by substracting from 1.0
	ALBEDO.rgb = vec3(dif) * texture(SCREEN_TEXTURE, uv).rgb * 2.0; //Multiplying the edges on the current frame and 2.0 to fix brightness
}
