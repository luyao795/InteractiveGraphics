// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Vertex

#version 420

// Entry Point
//============

// Input
//======

layout ( location = 0 ) in vec3 i_position;
layout ( location = 1 ) in vec3 i_normal;

uniform mat4 g_vertexTransform;
uniform mat4 g_normalTransform;

// Output
//=======

layout ( location = 0 ) out vec4 o_color;

out vec3 normal;

void main()
{
	gl_Position = g_vertexTransform * vec4( i_position, 1.0 );
	o_color = g_normalTransform * vec4( i_normal, 1.0 );
	normal = i_normal;
}
