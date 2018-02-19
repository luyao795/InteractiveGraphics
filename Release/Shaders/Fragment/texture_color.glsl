#version 420

// Input
//======

in vec2 texcoord;

// Output
//=======

out vec3 color;

// Uniform
//========

uniform sampler2D renderedTexture;

// Entry Point
//============

void main()
{
	color = texture2D( renderedTexture, texcoord ).rgb;
}
