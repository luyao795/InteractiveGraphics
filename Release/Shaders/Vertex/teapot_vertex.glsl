// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Vertex

#version 420

// Input
//======

layout ( location = 0 ) in vec3 i_position;
layout ( location = 1 ) in vec3 i_normal;
layout ( location = 2 ) in vec2 i_texcoord;

// Output
//=======

out vec4 color;
out vec3 normal;
out vec3 vertex;
out vec2 texcoord;

// Uniform
//========

uniform mat4 g_vertexTransform;
uniform mat4 g_normalTransform;

// Entry Point
//============

void main()
{
	gl_Position = g_vertexTransform * vec4( i_position, 1.0 );
	color = g_normalTransform * vec4( i_normal, 1.0 );
	normal = i_normal;
	vertex = i_position;
	texcoord = i_texcoord;
}
