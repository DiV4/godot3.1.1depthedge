shader_type spatial; //Spatial shader because we need to access the depth buffer
render_mode skip_vertex_transform, unshaded; //Disabling lighting on the quad

uniform float width : hint_range(0.1, 1.0) = 0.3; //This float sets the thickness of the lines

vec2 rand(vec2 p) { //Generating UV noise, based on post by Vortex_ from Shadertoy
	p = vec2(dot(p, vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return fract(sin(p)*43758.5453);
	}

void vertex() {
	POSITION = vec4(vec3(VERTEX.xy, -1.0), 1.0); // Keeps the quad in screen space.
}

void fragment() {
	vec2 uv = SCREEN_UV; //Since the quad always fills the screen, we can use screen UVs
	
	float depth = texture(DEPTH_TEXTURE, uv + 0.001 * (rand(uv) - 0.5)).r; //Sampling red channel of the first depth texture, adding UV noise
	float z = -PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]); //Some matrix magic by BastiaanOlij to "reverse our projection calculation on our z value"
	
	float depth2 = texture(DEPTH_TEXTURE, uv + vec2(width / 100.0) + 0.001 * (rand(uv) - 0.5)).r; //Sampling another texture at a certain offset, also noise
	float z2 = -PROJECTION_MATRIX[3][2] / (depth2 + PROJECTION_MATRIX[2][2]); //Same matrix operation here
	
	vec3 dif = vec3(z / z2 / 1.05); //Getting a gray image with black and white edges
	dif = pow(dif, vec3(25.0)); //Increasing the contrast further
	dif = min(dif, 0.1) * (1.0 - clamp(dif, 0.9, 1.0)); //Extracting extreme values, turning white edges black by substraction from 1.0
	ALBEDO.rgb = vec3(dif) * texture(SCREEN_TEXTURE, uv).rgb * 100.0; //Multiplying the edges on the current frame and 70.0 to fix brightness
}
