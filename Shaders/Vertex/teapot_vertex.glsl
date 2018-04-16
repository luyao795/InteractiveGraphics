// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Vertex

#version 420

#define textureSize 	256.0
#define texelSize 		1.0 / 256.0

// Input
//======

layout ( location = 0 ) in vec3 i_position;
layout ( location = 1 ) in vec3 i_normal;
layout ( location = 2 ) in vec2 i_texcoord;
layout ( location = 3 ) in vec3 i_tangent;
layout ( location = 4 ) in vec3 i_bitangent;

// Output
//=======

out vec3 vertex;
out vec3 normal;
out vec2 texcoord;
out vec3 tangent;
out vec3 bitangent;

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

vec4 texture2D_bilinear( sampler2D tex, vec2 uv )
{
	vec2 f = fract( uv.xy * textureSize );
	vec4 t00 = texture2D( tex, uv );
	vec4 t10 = texture2D( tex, uv + vec2( texelSize, 0.0 ));
	vec4 tA = mix( t00, t10, f.x );
	vec4 t01 = texture2D( tex, uv + vec2( 0.0, texelSize ) );
	vec4 t11 = texture2D( tex, uv + vec2( texelSize, texelSize ) );
	vec4 tB = mix( t01, t11, f.x );
	return mix( tA, tB, f.y );
}

// Entry Point
//============

void main()
{	
	normal = i_normal;
	vertex = i_position;
	texcoord = i_texcoord;
	tangent = i_tangent;
	bitangent = i_bitangent;
	
	vec3 Norm = ( g_normalTransform * vec4( normal, 1.0 ) ).xyz;
	
	vec4 dv = texture2D_bilinear( displacementTex, texcoord );
	
	float df = 0.25 * dv.x + 0.25 * dv.y + 0.5 * dv.z;
	
	vec3 newVertexPos = Norm * df + vertex;
	
	// Output position of the vertex, in clip space: MVP * position
	gl_Position = g_vertexTransform * vec4( newVertexPos, 1.0 );
}
