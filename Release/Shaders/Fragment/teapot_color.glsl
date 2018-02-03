// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Fragment

#version 420

// Entry Point
//============

// Input
//======

layout ( location = 0 ) in vec4 i_color;

in vec3 normal;

uniform float g_shininess;
uniform vec3 g_lightSource;
uniform vec3 g_halfway;
uniform vec3 g_ambientLightSource;
uniform vec3 g_diffuseColor;
uniform vec3 g_specularColor;
uniform vec3 g_ambientColor;

// Output
//=======

out vec4 o_color;

void main()
{
	// Details for reference: https://paroj.github.io/gltut/Illumination/Tut11%20BlinnPhong%20Model.html
	float HN = dot( g_halfway, normal );
	HN = clamp( HN, 0, 1 );
	float cosine = dot( normal, g_lightSource );
	HN = cosine != 0.0 ? HN : 0.0;
	float HN_power = pow( HN, g_shininess );
	vec3 specular = g_specularColor * HN_power;
	vec3 diffuse = g_diffuseColor * cosine;
	vec3 ambient = g_ambientLightSource * g_ambientColor;
	//o_color = vec4( specular, 1.0 );
	o_color = vec4( normalize( diffuse + ambient + specular ), 1.0 );
	//o_color = normalize( i_color );
}
