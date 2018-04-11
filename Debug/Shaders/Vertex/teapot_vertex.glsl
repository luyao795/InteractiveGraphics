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
out vec3 normal;
out vec3 vertex;
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
uniform mat4 g_modelTransform;
uniform mat4 g_modelViewTransform;
uniform mat4 g_vertexTransform;

uniform sampler2D diffuseTex;
uniform sampler2D specularTex;
uniform sampler2D ambientTex;

// Entry Point
//============

void main()
{
	gl_Position = g_vertexTransform * vec4( i_position, 1.0 );
	positionCamPos = g_modelViewTransform * vec4( i_position, 1.0 );
	normal = i_normal;
	vertex = i_position;
	texcoord = i_texcoord;
	tangent = i_tangent;
	bitangent = i_bitangent;
}
