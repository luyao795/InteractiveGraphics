// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Fragment

#version 420

// Input
//======

in vec4 color;
in vec3 normal;
in vec3 vertex;
in vec2 texcoord;

// Output
//=======

out vec4 o_color;

// Uniform
//========

uniform float g_shininess;
uniform vec3 g_lightSource;
uniform vec3 g_viewer;
uniform vec3 g_diffuseColor;
uniform vec3 g_specularColor;
uniform vec3 g_ambientColor;

uniform mat4 g_modelTransform;
uniform mat4 g_normalTransform;

uniform sampler2D diffuseTex;
uniform sampler2D specularTex;
uniform sampler2D ambientTex;

// Entry Point
//============

void main()
{
	// Details for reference: https://paroj.github.io/gltut/Illumination/Tut11%20BlinnPhong%20Model.html
	vec3 vertexPosition = ( g_modelTransform * vec4( vertex, 1 ) ).xyz;
	vec3 V = normalize( g_viewer - vertexPosition );
	vec3 H = normalize( V + normalize( g_lightSource - vertexPosition ) );
	float HN = dot( H, normalize( ( g_normalTransform * vec4( normal, 1.0 ) ).xyz ) );
	HN = clamp( HN, 0.0, 1.0 );
	float cosine = clamp(dot( normalize( (g_normalTransform * vec4( normal, 1.0 ) ).xyz ), normalize( g_lightSource - vertexPosition ) ), 0.0, 1.0 );
	HN = cosine != 0.0 ? HN : 0.0;
	float HN_power = pow( HN, g_shininess );
	vec4 diffuse = texture2D( diffuseTex, texcoord ) * cosine;
	vec4 specular = texture2D( specularTex, texcoord ) * HN_power;
	vec4 ambient = texture2D( ambientTex, texcoord );
	diffuse = diffuse * vec4( g_diffuseColor, 1.0 );
	specular = specular * vec4( g_specularColor, 1.0 );
	ambient = ambient * vec4( g_ambientColor, 1.0 );
	o_color = diffuse + specular + ambient;
}
