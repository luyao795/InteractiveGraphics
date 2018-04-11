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
in vec3 view_camera;
in vec3 light_camera;

in vec3 view_tangent;
in vec3 light_tangent;

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
uniform mat4 g_modelViewTransform;

uniform sampler2D diffuseTex;
uniform sampler2D specularTex;
uniform sampler2D ambientTex;

// constant colors
const vec4 white = vec4(1.0, 1.0, 1.0, 1.0);

// Calculates the transformation matrix from camera space to tangent space
// normal:		Comes from the model
// vec2cam:	The vec2cam refers to the vector pointing at the camera
// texCoord:	Comes from the model... the fragments interpolated texture coordinate
// REQUIRES NORMALIZED INPUTS
// Based on: http://hacksoflife.blogspot.se/2009/11/per-pixel-tangent-space-normal-mapping.html
mat3 calcTangentMatrix(vec3 normal, vec3 vec2cam, vec2 texCoord)
{
	// Retrieve the change in texture coordinates and vector position between fragments
	vec3 dpx = dFdx(vec2cam);
	vec3 dpy = dFdy(vec2cam);
	vec2 dtx = dFdx(texCoord);
	vec2 dty = dFdy(texCoord);

	// Do some magical magic (which is: solving a system om equations)
	vec3 tangent 	= normalize( ( dpx * dty.t - dpy * dtx.t ) );
	vec3 bitangent 	= normalize( (-dpx * dty.s + dpy * dtx.s ) );

	return mat3(tangent, bitangent, normal);
}

vec2 calcNewTexCoords(sampler2D displacementMap, vec2 tc, vec3 tsVec2Camera)
{ 
	// Get height from height map
	float height = texture2D(displacementMap, tc).r; // .r because the displacement map is monochromatic

	// Calculate new height based on surface thickness and bias
	float surfaceThickness = 0.015; // Thickness relative to width and height
	float bias = surfaceThickness * -0.5;
	float height_sb = height * surfaceThickness + bias;

	// Calculate new texture coordinate based on viewing angle
	vec2 parallaxTextureOffset = height_sb * tsVec2Camera.xy;

	return parallaxTextureOffset;
}

vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
{ 
    float height =  texture2D(ambientTex, texCoords).r;    
    vec2 p = viewDir.xy / viewDir.z * (height * 0.1);
    return texCoords - p;    
}

// Entry Point
//============

void main()
{
	vec3 vertexPos = ( g_modelTransform * vec4( vertex, 1 ) ).xyz;
	// Calculate the TBN matrix with normalized vectors
	vec3 toCamera = -g_viewer;
	vec3 N = normalize( normal );
	mat3 TBN = calcTangentMatrix( N, toCamera, texcoord );
	mat3 TBN_inverse = transpose( TBN );
	//mat3 TBN_inverse = mat3( // Inverse of TBN = transpose of TBN
	//					TBN[0][0], TBN[1][0], TBN[2][0],
	//					TBN[0][1], TBN[1][1], TBN[2][1],
	//					TBN[0][2], TBN[1][2], TBN[2][2]
	//					);
	
	// Transform to tangent space
	vec3 lightSource_tangent = TBN_inverse * g_lightSource;
	vec3 toCamera_tangent = TBN_inverse * toCamera;
	vec3 vertexPos_tangent = TBN_inverse * vertexPos;
	
	// offset texture coordinates with Parallax Mapping
    vec3 viewDir = normalize(toCamera_tangent - vertexPos_tangent);
    vec2 texCoords = ParallaxMapping(texcoord, viewDir);
	if(texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
        discard;

    // then sample textures with new texture coords
    vec3 color = texture2D(diffuseTex, texCoords).rgb;
    vec3 Norm = texture2D(specularTex, texCoords).rgb;
    Norm = normalize(Norm * 2.0 - 1.0);
	
	vec3 V = normalize( toCamera_tangent - vertexPos_tangent );
	vec3 H = normalize( V + normalize( lightSource_tangent - vertexPos_tangent ) );
	float HN = dot( H, N );
	HN = clamp( HN, 0.0, 1.0 );
	float cosine = clamp(dot( N, normalize( lightSource_tangent - vertexPos_tangent ) ), 0.0, 1.0 );
	HN = cosine != 0.0 ? HN : 0.0;
	float HN_power = pow( HN, g_shininess );
	vec4 diffuse = texture2D( diffuseTex, texCoords );
	vec4 specular = vec4( g_specularColor, 1.0 ) * HN_power;
	vec4 ambient = vec4( g_ambientColor, 1.0 );
	//diffuse = diffuse * vec4( g_diffuseColor, 1.0 );
	o_color = diffuse;
	
	//vec3 ambient = 0.2 * color;
	//vec3 lightDir = normalize(lightSource_tangent - vertexPos_tangent);
	
	//float diff = max(dot(lightDir, Norm), 0.0);
	//vec3 diffuse = diff * color;
	
	//vec3 reflectDir = reflect(-lightDir, Norm);
	//vec3 halfwayDir = normalize(lightDir + viewDir);
	//float spec = pow(max(dot(Norm, halfwayDir), 0.0), 32.0);
	
	//vec3 specular = vec3(0.2) * spec;
	
	//o_color = vec4(ambient + diffuse + specular, 1.0);
	
	// Calculate new texture coordinates
	// Applying this multiple times to enhance the effect
	//vec2 newTexCoord = texcoord + calcNewTexCoords( ambientTex, texcoord, toCamera_tangent );
	//newTexCoord += calcNewTexCoords( ambientTex, texcoord, toCamera_tangent );
	//newTexCoord += calcNewTexCoords( ambientTex, texcoord, toCamera_tangent );
	//newTexCoord += calcNewTexCoords( ambientTex, texcoord, toCamera_tangent );
	
	// Get the surface normal from the normal map and change range from [0,1] to [-1,1]
	//vec3 bump = 2.0 * texture2D(specularTex, newTexCoord.xy).xyz - 1.0;
	
	// Transform surface normal from tangent space to camera space
	//N = normalize( TBN_inverse * bump );
	
	// ... angle of light compared to normal ...
	//float NdotL = max(dot(N, ( g_lightSource )), 0.0);
	
	// Allocate a variable to store final fragment color
	//vec4 color;

	//if(NdotL > 0.0)
	//{
	//	color = NdotL * texture2D(diffuseTex, newTexCoord) * 0.8;
	//}
	
	// Add ambient light
	//color += vec4(0.2, 0.2, 0.2, 1.0) * texture2D(diffuseTex, newTexCoord);
	
	//o_color = color;
	
	// Details for reference: https://paroj.github.io/gltut/Illumination/Tut11%20BlinnPhong%20Model.html
	/*
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
	o_color = diffuse + ambient + specular;
	*/
}
