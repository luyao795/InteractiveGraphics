// This is a fragment shader for OpenGL, to view fragment shaders for both OpenGL and Direct3D,
// please visit: https://github.com/luyao795/Graphics-Application/tree/master/Engine/Content/Shaders/Fragment

#version 420

// Input
//======

in vec4 positionCamPos;

in vec3 vertex;
in vec3 normal;
in vec2 texcoord;
in vec3 tangent;
in vec3 bitangent;

in vec3 vertex_world;
in vec3 viewDir_camera;
in vec3 lightDir_camera;

in vec3 vertex_tangent;
in vec3 viewDir_tangent;
in vec3 lightDir_tangent;

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
	// Light emission properties
	vec3 lightColor = white.rgb;
	float lightPower = g_shininess;
	
	// Material properties
	vec3 diffuseColor = texture2D( diffuseTex , texcoord ).rgb;
	vec3 ambientColor = g_ambientColor * diffuseColor;
	vec3 specularColor = texture2D( specularTex, texcoord ).rgb;
	
	// Local normal, in tangent space. V tex coordinate is inverted because normal map is in TGA (not in DDS) for better quality
	vec3 normal_tangent = normalize( texture2D( normalTex, vec2( texcoord.x, -texcoord.y ) ).rgb * 2.0 - 1.0 );
	
	// Distance to the light
	float distance = length( g_lightSource - vertex_world );
	
	// Normal of the computed fragment, in camera space
	vec3 N = normal_tangent;
	
	// Direction of the light (from the fragment to the light)
	vec3 L = normalize( lightDir_tangent - vertex_tangent );
	
	// Cosine of the angle between the normal and the light direction, 
	// clamped above 0
	//  - light is at the vertical of the triangle -> 1
	//  - light is perpendicular to the triangle -> 0
	//  - light is behind the triangle -> 0
	float cosTheta = clamp( dot( N, L ), 0, 1 );
	
	// Eye vector (towards the camera)
	vec3 E = normalize( viewDir_tangent - vertex_tangent );
	
	// Direction in which the triangle reflects the light
	vec3 R = reflect( -L, N );
	
	// Cosine of the angle between the Eye vector and the Reflect vector,
	// clamped to 0
	//  - Looking into the reflection -> 1
	//  - Looking elsewhere -> < 1
	float cosAlpha = clamp( dot( E, R ), 0, 1 );
	
	//o_color = vec4( diffuseColor, 1.0 );
	o_color = vec4( ambientColor + 
	diffuseColor * lightColor * lightPower * cosTheta / ( distance * distance ) + 
	specularColor * lightColor * lightPower * pow( cosAlpha, 5 ) / ( distance * distance ), 1.0 );
	
	o_color = normalize( o_color );
}
