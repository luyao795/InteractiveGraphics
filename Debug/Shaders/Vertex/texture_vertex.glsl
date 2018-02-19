#version 420

// Input vertex data, different for all executions of this shader.
layout(location = 0) in vec3 i_position;
layout(location = 1) in vec2 i_UV;

// Output data ; will be interpolated for each fragment.
out vec2 UV;

uniform mat4 vertexTransform;

void main(){
	gl_Position = vertexTransform * vec4( i_position,1.0 );
	UV = i_UV;
}
