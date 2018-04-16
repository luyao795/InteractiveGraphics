// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Vertex

#version 420

// Input
//======

layout ( location = 0 ) in vec3 i_position;
layout ( location = 1 ) in vec3 i_normal;
layout ( location = 2 ) in vec2 i_texcoord;
layout ( location = 3 ) in vec3 i_tangent;
layout ( location = 4 ) in vec3 i_bitangent;

// Output
//=======

out vec4 positionCamPos;

out vec3 vertex;
out vec3 normal;
out vec2 texcoord;
out vec3 tangent;
out vec3 bitangent;

out vec3 vertex_world;
out vec3 viewDir_camera;
out vec3 lightDir_camera;

out vec3 vertex_tangent;
out vec3 viewDir_tangent;
out vec3 lightDir_tangent;

// Uniform
//========

uniform float g_shininess;
uniform vec3 g_lightSource;
uniform vec3 g_viewer;
uniform vec3 g_diffuseColor;
uniform vec3 g_specularColor;
uniform vec3 g_ambientColor;

uniform mat4 g_normalTransform;
uniform mat4 g_modelTransform; 		// M
uniform mat4 g_modelViewTransform; 	// MV
uniform mat4 g_vertexTransform; 	// MVP

uniform sampler2D diffuseTex;		// Diffuse
uniform sampler2D normalTex;		// Normal
uniform sampler2D displacementTex;	// Displacement
uniform sampler2D specularTex;		// Specular

// Entry Point
//============

void main()
{
	// Output position of the vertex, in clip space: MVP * position
	gl_Position = g_vertexTransform * vec4( i_position, 1.0 );
	positionCamPos = g_modelViewTransform * vec4( i_position, 1.0 );
	normal = i_normal;
	vertex = i_position;
	texcoord = i_texcoord;
	tangent = i_tangent;
	bitangent = i_bitangent;
	
	// Position of the vertex, in worldspace: M * position
	vertex_world = ( g_modelTransform * vec4( i_position, 1.0 ) ).xyz;
	
	// Vector that goes from the vertex to the camera, in camera space.
	// In camera space, the camera is at the origin (0,0,0).
	vec3 vertex_camera = ( g_modelViewTransform * vec4( i_position, 1.0 ) ).xyz;
	viewDir_camera = vec3( 0, 0, 0 ) - vertex_camera;
	
	// Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
	vec3 light_camera = ( g_modelViewTransform * vec4( g_lightSource, 1.0 ) ).xyz;
	lightDir_camera = light_camera - viewDir_camera;
	
	// model to camera = ModelView
	vec3 tangent_camera = mat3( g_modelViewTransform ) * tangent;
	vec3 normal_camera = mat3( g_modelViewTransform ) * normal;
	vec3 bitangent_camera = cross( tangent_camera, normal_camera );
	
	// You can use dot products instead of building this matrix and transposing it.
	mat3 TBN = transpose(
	mat3(
	tangent_camera,
	bitangent_camera,
	normal_camera
	)
	);
	
	vertex_tangent = TBN * ( g_modelViewTransform * vec4( i_position, 1.0 ) ).xyz;
	lightDir_tangent = TBN * lightDir_camera;
	viewDir_tangent = TBN * viewDir_camera;
}
