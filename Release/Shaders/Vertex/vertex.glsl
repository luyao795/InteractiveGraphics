// NOTES ON CONVERTING shader #version 330 TO OPENGL 2.1
//
// In the vertex program, in becomes attribute.
// In the vertex program, out becomes varying.
// There aren't any of the smooth, flat, or perspective keywords.

#version 420

// VBO inputs
//layout ( location = 0 ) in vec4 vertexPosition;
//layout ( location = 1 ) in vec4 vertexNormal;
//layout ( location = 2 ) in vec2 vertexTexCoord;

in vec3 vertexPosition;
in vec3 vertexNormal;
in vec2 vertexTexCoord;

// out parameter going into the fragment shader stage
out vec2 tc;
out vec3 n;
out vec4 vec2Camera;

// uniforms
uniform float time;
uniform float loopDuration;
uniform mat4 perspectiveMatrix;

void main()
{
	// Divide 2*PI by the loopDuration to control movement speed
	float timeScale = 3.14159 * 2.0 / loopDuration;

	// Calculate looptime from [0, loopDuration]
	float currTime = mod(time, loopDuration);

	// Calculate offset position of vertex (COLUMN-MAJOR MATRIX)
	mat4 offset = mat4(
							1.0, 						0.0, 						0.0, 	0.0,
							0.0, 						1.0, 						0.0, 	0.0,
							0.0, 						0.0, 						1.0, 	0.0,
							0.0,						0.0,						-2.0,	1.0
							/*cos(currTime * timeScale), 	sin(currTime * timeScale), 	-5.0, 	1.0*/
						);

	// 
	mat4 rotY = mat4(
						cos(currTime * timeScale),		0.0,	-sin(currTime * timeScale), 0.0,
						0.0,							1.0,						0.0,	0.0,
						sin(currTime * timeScale),		0.0,	cos(currTime * timeScale),	0.0,
						0.0,							0.0,						0.0,	1.0
					);

	mat4 rotX = mat4(
						1.0,							0.0,						0.0, 	0.0,
						0.0,		cos(currTime * timeScale),	sin(currTime * timeScale),	0.0,
						0.0,		-sin(currTime * timeScale),	cos(currTime * timeScale),	0.0,
						0.0,							0.0,						0.0,	1.0
					);

	// Create a matrix describing the transformation of a
	// vertex position from model space to camera (view) space
	mat4 modelViewMatrix = offset * rotY * rotX;

	// Transform the coordinate system to camera space
	vec4 cameraSpacePos = modelViewMatrix * vec4(vertexPosition, 1.0);

	// Save normalized device coordinates to GPU memory
	gl_Position = perspectiveMatrix * cameraSpacePos;


	// BELOW: Prepare some variables for the fragment shader

	// Pass the vertex' color value and texture coordinates
	// (from the Vertex Array Object) to the fragment shader
	tc = vertexTexCoord;

	// The normal matrix is a 3x3 matrix (instead of 4x4)
	// that transforms the normal direction to camera space
	mat3 normalMatrix = mat3(
						modelViewMatrix[0][0], modelViewMatrix[0][1], modelViewMatrix[0][2], 
						modelViewMatrix[1][0], modelViewMatrix[1][1], modelViewMatrix[1][2], 
						modelViewMatrix[2][0], modelViewMatrix[2][1], modelViewMatrix[2][2]
					);
	n = normalize(normalMatrix * vertexNormal);


	vec2Camera = -cameraSpacePos;
}