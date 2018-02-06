// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Fragment

#version 420

// Input
//======

layout ( location = 0 ) in vec4 i_color;

in vec3 normal;
in vec3 vertex;

uniform float g_shininess;
uniform vec3 g_lightSource;
uniform vec3 g_viewer;
uniform vec3 g_diffuseColor;
uniform vec3 g_specularColor;
uniform vec3 g_ambientColor;
uniform mat4 g_modelTransformationMatrix;
uniform mat4 g_normalTransform;

// Output
//=======

out vec4 o_color;

// Entry Point
//============

void main()
{
	// Details for reference: https://paroj.github.io/gltut/Illumination/Tut11%20BlinnPhong%20Model.html
	vec3 vertexPosition = ( g_modelTransformationMatrix * vec4( vertex, 1.0 ) ).xyz;
	vec3 V = normalize( g_viewer - vertexPosition );
	vec3 H = normalize( V + normalize( g_lightSource - vertexPosition ) );
	float HN = dot( H, normalize( ( g_normalTransform * vec4( normal, 1.0 ) ).xyz ) );
	HN = clamp( HN, 0.0, 1.0 );
	float cosine = clamp(dot( normalize( (g_normalTransform * vec4( normal, 1.0 ) ).xyz ), normalize( g_lightSource - vertexPosition ) ), 0.0, 1.0 );
	HN = cosine != 0.0 ? HN : 0.0;
	float HN_power = pow( HN, g_shininess );
	vec3 specular = g_specularColor * HN_power;
	vec3 diffuse = g_diffuseColor * cosine;
	vec3 ambient = g_ambientColor;
	o_color = vec4( diffuse + ambient + specular, 1.0 );
	//o_color = normalize( i_color );
}
