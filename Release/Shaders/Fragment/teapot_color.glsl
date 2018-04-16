// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Fragment

#version 420

// Input
//======

in vec3 vertex;
in vec3 normal;
in vec2 texcoord;
in vec3 tangent;
in vec3 bitangent;

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

uniform mat4 g_normalTransform;
uniform mat4 g_modelTransform; 		// M
uniform mat4 g_modelViewTransform;	// MV
uniform mat4 g_vertexTransform;		// MVP

uniform sampler2D diffuseTex;		// Diffuse
uniform sampler2D normalTex;		// Normal
uniform sampler2D displacementTex;	// Displacement
uniform sampler2D specularTex;		// Specular

// Constant
//=========
const vec4 white = vec4(1.0, 1.0, 1.0, 1.0);

// Entry Point
//============

void main()
{
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
	vec4 ambient = vec4( 0.2 );
	diffuse = diffuse * vec4( g_diffuseColor, 1.0 );
	specular = specular * vec4( g_specularColor, 1.0 );
	ambient = ambient * vec4( g_ambientColor, 1.0 );
	o_color = diffuse + ambient + specular;
}
