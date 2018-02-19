#version 420

// Input
//======

layout(location = 0) in vec3 i_position;
layout(location = 1) in vec2 i_texcoord;

// Output
//=======

out vec2 texcoord;

// Uniform
//========

uniform mat4 vertexTransform;

// Entry Point
//============

void main()
{
	gl_Position = vertexTransform * vec4( i_position,1.0 );
	texcoord = i_texcoord;
}
