// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Fragment

#version 420

// Entry Point
//============

// Input
//======

layout ( location = 0 ) in vec4 i_color;

// Output
//=======

out vec4 o_color;

void main() {
	o_color = i_color;
}
