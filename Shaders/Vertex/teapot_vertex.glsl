// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Vertex

#version 420

// Entry Point
//============

// Input
//======

layout ( location = 0 ) in vec3 i_position;

uniform mat4 g_transform;

// Output
//=======

layout ( location = 0 ) out vec4 o_color;

void main()
{
	gl_Position = g_transform * vec4(i_position, 1.0);
	o_color = vec4(1.0, 0.0, 1.0, 1.0);
}
