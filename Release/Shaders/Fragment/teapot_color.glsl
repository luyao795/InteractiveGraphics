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

// Function
//=========
//~ vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
//~ { 
	//~ float heightScale = 0.1;
    //~ // number of depth layers
    //~ const float minLayers = 8;
    //~ const float maxLayers = 32;
    //~ float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0, 0.0, 1.0), viewDir)));  
    //~ // calculate the size of each layer
    //~ float layerDepth = 1.0 / numLayers;
    //~ // depth of current layer
    //~ float currentLayerDepth = 0.0;
    //~ // the amount to shift the texture coordinates per layer (from vector P)
    //~ vec2 P = viewDir.xy / viewDir.z * heightScale; 
    //~ vec2 deltaTexCoords = P / numLayers;
  
    //~ // get initial values
    //~ vec2  currentTexCoords     = texcoord;
    //~ float currentDepthMapValue = texture2D(displacementTex, currentTexCoords).r;
      
    //~ while(currentLayerDepth < currentDepthMapValue)
    //~ {
        //~ // shift texture coordinates along direction of P
        //~ currentTexCoords -= deltaTexCoords;
        //~ // get depthmap value at current texture coordinates
        //~ currentDepthMapValue = texture2D(displacementTex, currentTexCoords).r;  
        //~ // get depth of next layer
        //~ currentLayerDepth += layerDepth;  
    //~ }
    
    //~ return currentTexCoords;
//~ }

vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
{ 
	float heightScale = 0.1;
    float height =  texture2D(displacementTex, texCoords).r;    
    vec2 p = viewDir.xy / viewDir.z * (height * heightScale);
    return texCoords - p;    
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

// Entry Point
//============

void main()
{
	// offset texture coordinates with Parallax Mapping
	vec3 viewDir = normalize( viewDir_tangent - vertex_tangent );
	vec2 texcoords = ParallaxMapping( texcoord, viewDir );
	//~ if(texcoords.x > 1.0 || texcoords.y > 1.0 || texcoords.x < 0.0 || texcoords.y < 0.0)
        //~ discard;
	
	// obtain normal from normal map
	vec3 normals = texture2D( normalTex, vec2( texcoords.x, -texcoords.y ) ).rgb;
	normals = normalize( normals * 2.0 - 1.0 );
	
	// get diffuse color
	vec3 diffuses = texture2D( diffuseTex, texcoords ).rgb;
	
	// Ambient component
	vec3 Ambient = 0.1 * diffuses * g_ambientColor;
	
	// Diffuse component
	vec3 lightDir = normalize( lightDir_tangent - vertex_tangent );
	float diff = max( dot( lightDir, normals ), 0.0 );
	vec3 Diffuse = diff * diffuses * g_diffuseColor;
	
	// Specular component
	vec3 reflectDir = reflect( -lightDir, normals );
	vec3 halfwayDir = normalize( lightDir - viewDir );
	float spec = pow( max( dot( normals, halfwayDir ), 0.0 ), g_shininess );
	vec3 Specular = spec * g_specularColor;
	
	o_color = vec4( Ambient + Specular + Diffuse, 1.0 );
	
	//~ vec2 newTexCoord = ParallaxMapping( texcoord, normalize( viewDir_tangent - vertex_tangent ) );
	//~ // Light emission properties
	//~ vec3 lightColor = white.rgb;
	//~ float lightPower = g_shininess;
	
	//~ // Material properties
	//~ vec3 diffuseColor = texture2D( diffuseTex , newTexCoord ).rgb;
	//~ vec3 ambientColor = g_ambientColor * diffuseColor;
	
	//~ // Local normal, in tangent space. V tex coordinate is inverted because normal map is in TGA (not in DDS) for better quality
	//~ vec3 normal_tangent = normalize( texture2D( normalTex, vec2( newTexCoord.x, -newTexCoord.y ) ).rgb * 2.0 - 1.0 );
	
	//~ // Distance to the light
	//~ float distance = length( g_lightSource - vertex_world );
	
	//~ // Normal of the computed fragment, in camera space
	//~ vec3 N = normal_tangent;
	
	//~ // Direction of the light (from the fragment to the light)
	//~ vec3 L = normalize( lightDir_tangent - vertex_tangent );
	
	//~ // Cosine of the angle between the normal and the light direction, 
	//~ // clamped above 0
	//~ //  - light is at the vertical of the triangle -> 1
	//~ //  - light is perpendicular to the triangle -> 0
	//~ //  - light is behind the triangle -> 0
	//~ float cosTheta = clamp( dot( N, L ), 0, 1 );
	
	//~ // Eye vector (towards the camera)
	//~ vec3 E = normalize( viewDir_tangent - vertex_tangent );
	
	//~ // Direction in which the triangle reflects the light
	//~ vec3 R = reflect( -L, N );
	
	//~ // Cosine of the angle between the Eye vector and the Reflect vector,
	//~ // clamped to 0
	//~ //  - Looking into the reflection -> 1
	//~ //  - Looking elsewhere -> < 1
	//~ float cosAlpha = clamp( dot( E, R ), 0, 1 );
	
	//~ //o_color = vec4( diffuseColor, 1.0 );
	//~ o_color = vec4( ambientColor + diffuseColor * lightColor * lightPower * cosTheta / ( distance * distance ), 1.0 );
}
