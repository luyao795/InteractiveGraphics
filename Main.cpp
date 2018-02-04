/*
 * Main.cpp
 *
 *  Created on: Jan 18, 2018
 *  Modified on: Jan 26, 2018
 *      Author: Luyao Tian
 */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <GL/glew.h>
#include <GL/freeglut.h>
// This library was obtained from http://www.cemyuksel.com/cyCodeBase/code.html
#include "cyCodeBase/cyTriMesh.h"
#include "cyCodeBase/cyGL.h"
#include "cyCodeBase/cyMatrix.h"
// This file was obtained from https://github.com/triplepointfive/ogldev/blob/master/tutorial21/math_3d.h
#include "math_3d.h"

#define FILE_PATH_BUFFER_SIZE 1024

// Global Constants
//=================
namespace
{
	constexpr auto gc_numberOfVerticesPerTriangle = 3;
	const auto gc_initialLightSourceLocation = cy::Point3f(0.0f, 5.0f, 10.0f);
	constexpr auto gc_inputControlScaleParameter = 0.01f;
}

// Gloabl Variables
//=================
namespace
{
	cy::TriMesh * g_mesh = nullptr;
	cy::Point3f * g_meshVertexData = nullptr;
	GLuint * g_meshIndexData = nullptr;
	cy::Point3f * g_meshNormalData = nullptr;

	// Number of vertices, indices and normals in the mesh
	GLuint g_meshVertexCount, g_meshIndexCount, g_meshNormalCount;

	// Vertex Array Object, Vertex Buffer Object, Index Buffer Object and Normal Buffer Object
	GLuint g_vertexArrayObject, g_vertexBufferObject, g_indexBufferObject,
			g_normalBufferObject;

	GLuint g_shaderProgramID;
	GLuint g_vertexShaderID, g_fragmentShaderID;

	char g_vertexShaderPath[FILE_PATH_BUFFER_SIZE] = "Shaders/Vertex/";
	char g_fragmentShaderPath[FILE_PATH_BUFFER_SIZE] = "Shaders/Fragment/";

	cy::GLSLShader * g_vertexShader = nullptr;
	cy::GLSLShader * g_fragmentShader = nullptr;
	cy::GLSLProgram * g_shaderProgram = nullptr;

	cy::Point3f g_cameraPosition = cy::Point3f(0.0f, 10.0f, 30.0f);
	cy::Point3f g_targetPosition = cy::Point3f(0.0f, 0.0f, 0.0f);

	// Variables for controlling camera rotation in X and Z directions
	float g_rotationDeltaX, g_rotationDeltaZ = 0.0f;
	float g_rotationAmountX, g_rotationAmountZ = 0.0f;

	// Variables for controlling camera zoom in/out in Z direction
	float g_translationDeltaX, g_translationDeltaY = 0.0f;
	float g_translationDistance = 0.0f;

	// Variables for controlling light movement in X and Y direction
	float g_lightTranslationDeltaX, g_lightTranslationDeltaY = 0.0f;
	float g_lightTranslationDistanceX, g_lightTranslationDistanceY = 0.0f;

	// Variables for controlling light rotation in Z direction
	float g_lightRotationDeltaX, g_lightRotationDeltaY = 0.0f;
	float g_lightRotationAmountX, g_lightRotationAmountY = 0.0f;

	// Flags for whether left and right mouse buttons are down
	bool g_leftMouseButtonDown = false;
	bool g_rightMouseButtonDown = false;

	// Flags for whether certain keys are down
	bool g_controlDown = false;

	// MVP matrices
	cy::Matrix4f g_modelTransformationMatrix;
	cy::Matrix4f g_viewTransformationMatrix;
	cy::Matrix4f g_projectionTransmationMatrix;

	GLuint g_vertexTransformationMatrixID; // MVP transformation matrix ID
	GLuint g_normalTransformationMatrixID; // Normal transformation matrix ID
	GLuint g_modelTransformationMatrixID; // Model transformation matrix ID

	// Parameters for Blinn Shading
	cy::Point3f g_lightSource = gc_initialLightSourceLocation, g_viewer =
			g_cameraPosition, g_halfway;
	cy::Point3f g_diffuseColor = cy::Point3f(1.0f, 0.0f, 1.0f),
			g_specularColor = cy::Point3f(0.0f, 1.0f, 1.0f), g_ambientColor =
					cy::Point3f(0.2f, 0.2f, 0.2f);
	GLfloat g_shininess = 50.0f;

	GLuint g_lightSourceID, g_viewerID;
	GLuint g_diffuseColorID, g_specularColorID, g_ambientColorID;
	GLuint g_shininessID;

	// Obtained from https://github.com/luyao795/Graphics-Application/blob/44bb4ef70675d127be293d2424a1853493547d0a/Engine/UserInput/UserInput.h
	enum KeyCodes
	{
		Left = 0x25,
		Up = 0x26,
		Right = 0x27,
		Down = 0x28,

		Space = 0x20,

		Escape = 0x1b,

		Shift = 0x10,
		Control = 0x11,
		Alt = 0x12,

		Tab = 0x09,
		CapsLock = 0x14,

		BackSpace = 0x08,
		Enter = 0x0d,
		Delete = 0x2e,

		PageUp = 0x21,
		PageDown = 0x22,
		End = 0x23,
		Home = 0x24,

		F1 = 0x70,
		F2 = 0x71,
		F3 = 0x72,
		F4 = 0x73,
		F5 = 0x74,
		F6 = 0x75,
		F7 = 0x76,
		F8 = 0x77,
		F9 = 0x78,
		F10 = 0x79,
		F11 = 0x7a,
		F12 = 0x7b,
	};

	enum SpecialKeyCodes
	{
		LeftShift = 0x70, RightShift = 0x71,

		LeftControl = 0x72, RightControl = 0x73,

		LeftAlt = 0x74, RightAlt = 0x75,
	};
}

// Initialization/Cleanup
//=======================
namespace
{
	// Initialization
	//---------------

	// Set the specific OpenGL version and profile to be used by this program
	void SetupGLUTContextEnvironment(int OpenGLMajorVersion,
			int OpenGLMinorVersion, int OpenGLProfile)
	{
		glutInitContextVersion(OpenGLMajorVersion, OpenGLMinorVersion); // This tells the program to use corresponding OpenGL version
		glutInitContextProfile(OpenGLProfile); // This tells the program to use a specific profile of OpenGL
	}

	// Create an OpenGL window with given size, position and title
	void CreateWindowWithSpecifiedSizePositionTitle(int i_sizeX, int i_sizeY,
			int i_posX, int i_posY, const char * i_windowTitle)
	{
		glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE); // Initialize GLUT display mode
		glutInitWindowSize(i_sizeX, i_sizeY); // Set the window's initial width & height
		glutInitWindowPosition(i_posX, i_posY); // Position the window's initial top-left corner
		glutCreateWindow(i_windowTitle); // Create a window with provided window title
		glEnable(GL_DEPTH_TEST); // Enable depth buffer
	}

	// Initialize GLEW library
	void InitializeGLEW()
	{
		GLenum result = glewInit();
		if (result != GLEW_OK)
		{
			fprintf(stderr, "Error: '%s'\n", glewGetErrorString(result));
			exit(-1); // Either use exit() or return to terminate the program
		}
	}

	// Initialize vertex normals for the mesh
	void GenerateVertexNormals()
	{
		if (!g_mesh->HasNormals())
			g_mesh->ComputeNormals();
	}

	// Initialize vertex buffer
	void GenerateAndBindVertexBuffer(cy::Point3f * i_meshVertexData)
	{
		glGenBuffers(1, &g_vertexBufferObject); //Generate Vertex Buffer Object
		glBindBuffer(GL_ARRAY_BUFFER, g_vertexBufferObject); // Bind Vertex Buffer Object so it's ready to use
		glBufferData(GL_ARRAY_BUFFER, sizeof(cy::Point3f) * g_meshVertexCount,
				i_meshVertexData, GL_STATIC_DRAW); // Send drawing data to Vertex Buffer Object
		glVertexAttribPointer(0, gc_numberOfVerticesPerTriangle, GL_FLOAT,
		GL_FALSE, 0, 0); // Set up Vertex Attribute Pointer for position
		glEnableVertexAttribArray(0); // Enable Vertex Buffer Object
	}

	// Initialize index buffer
	void GenerateAndBindIndexBuffer(GLuint * i_meshIndexData)
	{
		glGenBuffers(1, &g_indexBufferObject); // Generate Index Buffer Object
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_indexBufferObject); // Bind Index Buffer Object so it's ready to use
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint) * g_meshIndexCount,
				i_meshIndexData, GL_STATIC_DRAW); // Send drawing data to Index Buffer Object
	}

	void GenerateAndBindNormalBuffer(cy::Point3f * i_meshNormalData)
	{
		glGenBuffers(1, &g_normalBufferObject);
		glBindBuffer(GL_ARRAY_BUFFER, g_normalBufferObject);
		glBufferData(GL_ARRAY_BUFFER, sizeof(cy::Point3f) * g_meshNormalCount,
				i_meshNormalData, GL_STATIC_DRAW);
		glVertexAttribPointer(1, gc_numberOfVerticesPerTriangle, GL_FLOAT,
		GL_FALSE, 0, 0); // Set up Vertex Attribute Pointer for position
		glEnableVertexAttribArray(1); // Enable Normal Buffer Object
	}

	// Initialize buffers needed for the program
	void GenerateAndBindBuffers(cy::Point3f * i_meshVertexData,
			GLuint * i_meshIndexData, cy::Point3f * i_meshNormalData)
	{
		// General steps are provided by http://www.swiftless.com/tutorials/opengl4/4-opengl-4-vao.html
		glGenVertexArrays(1, &g_vertexArrayObject); // Generate Vertex Array Object
		glBindVertexArray(g_vertexArrayObject); // Bind Vertex Array Object so it's ready to use
		GenerateAndBindVertexBuffer(i_meshVertexData);
		GenerateAndBindIndexBuffer(i_meshIndexData);
		GenerateAndBindNormalBuffer(i_meshNormalData);
		glBindVertexArray(0); // Unbind Vertex Array Object
	}

	// Bind transformation matrices to uniform variables in shaders
	void BindTransformations()
	{
		g_vertexTransformationMatrixID = glGetUniformLocation(g_shaderProgramID,
				"g_vertexTransform");
		g_normalTransformationMatrixID = glGetUniformLocation(g_shaderProgramID,
				"g_normalTransform");
		g_modelTransformationMatrixID = glGetUniformLocation(g_shaderProgramID,
				"g_modelTransformationMatrix");

	}

	// Bind Blinn Shading parameters to uniform variables in shaders
	void BindBlinnShadingParameters()
	{
		g_shininessID = glGetUniformLocation(g_shaderProgramID, "g_shininess");
		g_lightSourceID = glGetUniformLocation(g_shaderProgramID,
				"g_lightSource");
		g_viewerID = glGetUniformLocation(g_shaderProgramID, "g_viewer");
		g_diffuseColorID = glGetUniformLocation(g_shaderProgramID,
				"g_diffuseColor");
		g_specularColorID = glGetUniformLocation(g_shaderProgramID,
				"g_specularColor");
		g_ambientColorID = glGetUniformLocation(g_shaderProgramID,
				"g_ambientColor");
	}

	// Cleanup
	//--------

	// Release memory being used by storing mesh data
	void UnloadMeshFile()
	{
		if (g_meshVertexData)
		{
			delete[] g_meshVertexData;
			g_meshVertexData = nullptr;
		}
		if (g_meshIndexData)
		{
			delete[] g_meshIndexData;
			g_meshIndexData = nullptr;
		}
		if (g_meshNormalData)
		{
			delete[] g_meshNormalData;
			g_meshNormalData = nullptr;
		}
		if (g_mesh)
		{
			delete g_mesh;
			//g_mesh = nullptr;
		}
	}

	// Unload shaders being used by the program
	void UnloadShaderHandler()
	{
		g_vertexShader->Delete();
		g_fragmentShader->Delete();
		g_shaderProgram->Delete();
	}

	// Release memory being used by storing shaders
	void CleanUpShaders()
	{
		if (g_vertexShader)
		{
			delete g_vertexShader;
			g_vertexShader = nullptr;
		}
		if (g_fragmentShader)
		{
			delete g_fragmentShader;
			g_fragmentShader = nullptr;
		}
		if (g_shaderProgram)
		{
			delete g_shaderProgram;
			g_shaderProgram = nullptr;
		}
	}

	// Cleanup buffers being used by the program
	void CleanUpBuffers()
	{
		glDeleteBuffers(1, &g_vertexBufferObject);
		glDeleteBuffers(1, &g_indexBufferObject);
		glDeleteBuffers(1, &g_normalBufferObject);
		glDeleteVertexArrays(1, &g_vertexArrayObject);
	}

	// Final cleanup function
	void CleanUp()
	{
		UnloadMeshFile();
		CleanUpShaders();
		CleanUpBuffers(); // Clean Up Vertex Buffer and Array Objects
	}
}

// Compilation
//============
namespace
{
	// Compile shaders with given file paths
	void CompileShaders(const char * i_vertexShaderPath,
			const char * i_fragmentShaderPath)
	{
		bool result = g_vertexShader->CompileFile(i_vertexShaderPath,
		GL_VERTEX_SHADER);
		if (!result)
		{
			fprintf(stderr, "Cannot compile vertex shader.\n");
			exit(-1);
		}
		g_vertexShaderID = g_vertexShader->GetID();
		g_shaderProgram->AttachShader(g_vertexShaderID);
		result = g_fragmentShader->CompileFile(i_fragmentShaderPath,
		GL_FRAGMENT_SHADER);
		if (!result)
		{
			fprintf(stderr, "Cannot compile fragment shader.\n");
			exit(-1);
		}
		g_fragmentShaderID = g_fragmentShader->GetID();
		g_shaderProgram->Build(g_vertexShader, g_fragmentShader);
		g_shaderProgramID = g_shaderProgram->GetID();
		g_shaderProgram->Bind();

		BindTransformations();
		BindBlinnShadingParameters();
	}

	// Process filenames to compile and bind shaders
	void CompileAndBindShaders(const char * i_vertexShaderFileName,
			const char * i_fragmentShaderFileName)
	{
		strcat(g_vertexShaderPath, i_vertexShaderFileName);
		strcat(g_fragmentShaderPath, i_fragmentShaderFileName);
		g_shaderProgram = new cy::GLSLProgram();
		g_vertexShader = new cy::GLSLShader();
		g_fragmentShader = new cy::GLSLShader();
		CompileShaders(g_vertexShaderPath, g_fragmentShaderPath); // Compile vertex and fragment shaders from file
	}

	// Recompile shaders at runtime
	void RecompileShaders()
	{
		UnloadShaderHandler();
		CompileShaders(g_vertexShaderPath, g_fragmentShaderPath);
	}
}

// Implementation
//===============
namespace
{
	// Load mesh file with given filename into memory
	void LoadMeshFileWithName(const char * i_filename)
	{
		g_mesh = new cy::TriMesh();
		bool isFileLoaded = g_mesh->LoadFromFileObj(i_filename);
		if (!isFileLoaded)
		{
			fprintf(stderr, "Cannot open specified file.\n");
			exit(-1);
		}
	}

	// Store vertex data into memory
	void ProcessVertexData()
	{
		const auto vertexCount = g_mesh->NV();
		g_meshVertexCount = vertexCount;
		g_meshVertexData = new cy::Point3f[g_meshVertexCount];
		for (size_t i = 0; i < vertexCount; i++)
		{
			g_meshVertexData[i].x = g_mesh->V(i).x;
			g_meshVertexData[i].y = g_mesh->V(i).y;
			g_meshVertexData[i].z = g_mesh->V(i).z;
		}
	}

	// Store index data into memory
	void ProcessIndexData()
	{
		const auto triangleCount = g_mesh->NF();
		const auto indexCount = triangleCount * gc_numberOfVerticesPerTriangle;
		g_meshIndexCount = indexCount;
		g_meshIndexData = new GLuint[g_meshIndexCount];
		for (size_t currentTriangleIndex = 0;
				currentTriangleIndex < triangleCount; currentTriangleIndex++)
		{
			for (size_t currentIndexInTriangle = 0;
					currentIndexInTriangle < gc_numberOfVerticesPerTriangle;
					currentIndexInTriangle++)
			{
				g_meshIndexData[currentTriangleIndex
						* gc_numberOfVerticesPerTriangle
						+ currentIndexInTriangle] = g_mesh->F(
						currentTriangleIndex).v[currentIndexInTriangle];
			}
		}
	}

	void ProcessNormalData()
	{
		GenerateVertexNormals();
		const auto normalCount = g_mesh->NVN();
		g_meshNormalCount = normalCount;
		g_meshNormalData = new cy::Point3f[g_meshNormalCount];
		for (size_t i = 0; i < normalCount; i++)
		{
			g_meshNormalData[i].x = g_mesh->VN(i).x;
			g_meshNormalData[i].y = g_mesh->VN(i).y;
			g_meshNormalData[i].z = g_mesh->VN(i).z;
		}
	}

	// Store mesh related data into memory
	void ProcessMeshData()
	{
		ProcessVertexData(); // Store vertex data into memory
		ProcessIndexData(); // Store index data into memory
		ProcessNormalData(); // Store normal data into memory
	}

	void ProcessVertexTransformation()
	{
		// Matrices setup reference: http://www.opengl-tutorial.org/beginners-tutorials/tutorial-3-matrices/#the-model-view-and-projection-matrices
		g_mesh->ComputeBoundingBox();

		g_modelTransformationMatrix = cy::Matrix4f::MatrixIdentity();
		g_modelTransformationMatrix.AddTrans(
				(g_mesh->GetBoundMax() + g_mesh->GetBoundMin()) / 2 * -1.0f);
		g_viewTransformationMatrix = cy::Matrix4f::MatrixView(g_cameraPosition,
				g_targetPosition, cy::Point3f(0.0f, 1.0f, 0.0f));
		g_viewTransformationMatrix *= cy::Matrix4f::MatrixRotationX(
				ToRadian(-90.0f));
		g_viewTransformationMatrix *= cy::Matrix4f::MatrixRotationZ(
				g_rotationAmountZ);
		g_viewTransformationMatrix *= cy::Matrix4f::MatrixRotationX(
				g_rotationAmountX);
		g_viewTransformationMatrix.AddTrans(
				cy::Point3f(0.0f, 0.0f, g_translationDistance));
		g_projectionTransmationMatrix = cy::Matrix4f::MatrixPerspective(
				ToRadian(90.0f), 1.0f, 0.1f, 100.0f);

		cy::Matrix4f transformMat = g_projectionTransmationMatrix
				* g_viewTransformationMatrix * g_modelTransformationMatrix;

		// Bind MVP transformation matrix for shaders to use
		glUniformMatrix4fv(g_vertexTransformationMatrixID, 1, GL_FALSE,
				&transformMat.data[0]);

		// Bind model transformation matrix for shaders to use
		glUniformMatrix4fv(g_modelTransformationMatrixID, 1, GL_FALSE,
				&g_modelTransformationMatrix.data[0]);
	}

	// Calculate transformation matrix for normals
	void ProcessNormalTransformation()
	{
		cy::Matrix3f normalTransformationMatrix =
				g_viewTransformationMatrix.GetSubMatrix3()
						* g_modelTransformationMatrix.GetSubMatrix3();
		normalTransformationMatrix.Invert();
		normalTransformationMatrix.Transpose();
		cy::Matrix4f normalTransformMat = cy::Matrix4f(
				normalTransformationMatrix);

		glUniformMatrix4fv(g_normalTransformationMatrixID, 1, GL_FALSE,
				&normalTransformMat.data[0]);
	}

	void ProcessLightTransformation()
	{
		g_lightSource = cy::Point3f(g_lightTranslationDistanceX,
				g_lightTranslationDistanceY, 0.0f)
				+ gc_initialLightSourceLocation;
		g_lightSource = cy::Matrix3f::MatrixRotationX(g_lightRotationAmountX)
				* g_lightSource;
		g_lightSource = cy::Matrix3f::MatrixRotationY(g_lightRotationAmountY)
				* g_lightSource;
	}

	// Calculate transformation matrices
	void ProcessTransformation()
	{
		ProcessVertexTransformation();
		ProcessNormalTransformation();
		ProcessLightTransformation();
	}

	// Calculate and bind parameters for Blinn Shading
	void ProcessBlinnShading()
	{
		// Calculation
		//------------
		g_halfway = (g_lightSource + g_viewer)
				/ (g_lightSource + g_viewer).Length();

		// Bind
		//-----
		glUniform1f(g_shininessID, g_shininess);
		glUniform3fv(g_lightSourceID, 1, &g_lightSource[0]);
		glUniform3fv(g_viewerID, 1, &g_viewer[0]);
		glUniform3fv(g_diffuseColorID, 1, &g_diffuseColor[0]);
		glUniform3fv(g_specularColorID, 1, &g_specularColor[0]);
		glUniform3fv(g_ambientColorID, 1, &g_ambientColor[0]);
	}

	// Render geometries onto screen
	void DrawGeometry()
	{
		glBindVertexArray(g_vertexArrayObject); // Bind Vertex Array Object so it's ready to use
		glDrawElements(GL_TRIANGLES, g_meshIndexCount, GL_UNSIGNED_INT, 0); // Draw elements using index buffer
		glBindVertexArray(0); // Disable Vertex Array Object
	}

	// Display content onto screen
	void DisplayContent()
	{
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // Clear front buffer
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f); // Reset background color to black
		ProcessTransformation(); // Calculate MVP matrix for transformation
		ProcessBlinnShading();
		DrawGeometry(); // Draw geometry onto the screen
		glutSwapBuffers(); // Swap front and back buffer
	}

	// Refresh content once initialization is complete
	void Idle()
	{
		glutPostRedisplay();
	}
}

// Input Handling
//===============
namespace
{
	// Handler for regular key press events
	void ProcessKeyPress(GLubyte i_key, GLint i_x, GLint i_y)
	{
		// This section is for exiting the application with Esc key
		if (i_key == KeyCodes::Escape)
		{
			CleanUp();
			glutLeaveMainLoop(); // Exit the infinitely event-processing loop
		}
	}

	// Handler for functional key press events
	void ProcessFunctionKeyPress(GLint i_key, GLint i_x, GLint i_y)
	{
		// This section is for moving light source with Control keys pressed and held
		if (i_key == SpecialKeyCodes::LeftControl
				|| i_key == SpecialKeyCodes::RightControl)
			g_controlDown = true;

		// This section is for recompiling shaders with F6 key
		if (i_key == GLUT_KEY_F6)
			RecompileShaders();
	}

	void ProcessFunctionKeyRelease(GLint i_key, GLint i_x, GLint i_y)
	{
		// This section is for releasing control on light source with Control keys released
		if (i_key == SpecialKeyCodes::LeftControl
				|| i_key == SpecialKeyCodes::RightControl)
			g_controlDown = false;
	}

	// Handler for mouse button click events
	void ProcessMouseButtonPress(GLint i_button, GLint i_state, GLint i_x,
			GLint i_y)
	{
		if (i_button == GLUT_LEFT_BUTTON && i_state == GLUT_DOWN)
			g_leftMouseButtonDown = true;
		else
			g_leftMouseButtonDown = false;

		if (i_button == GLUT_RIGHT_BUTTON && i_state == GLUT_DOWN)
			g_rightMouseButtonDown = true;
		else
			g_rightMouseButtonDown = false;

		// Keep track of mouse position
		{
			g_translationDeltaX = i_x;
			g_translationDeltaY = i_y;
			g_rotationDeltaX = i_y;
			g_rotationDeltaZ = i_x;
			g_lightTranslationDeltaX = i_x;
			g_lightTranslationDeltaY = i_y;
			g_lightRotationDeltaX = i_x;
			g_lightRotationDeltaY = i_y;
		}
	}

	// Handler for mouse drag movement events
	void ProcessMouseDragMovement(GLint i_x, GLint i_y)
	{
		if (g_leftMouseButtonDown)
		{
			// Object Rotation
			if (!g_controlDown)
			{
				g_rotationAmountX += (g_rotationDeltaX - i_y)
						* gc_inputControlScaleParameter;
				g_rotationAmountZ += (g_rotationDeltaZ - i_x)
						* gc_inputControlScaleParameter;
				g_rotationDeltaX = i_y;
				g_rotationDeltaZ = i_x;
			}
			// Light Rotation
			else
			{
				g_lightRotationAmountX += (g_lightRotationDeltaX - i_x)
						* gc_inputControlScaleParameter;
				g_lightRotationAmountY += (g_lightRotationDeltaY - i_y)
						* gc_inputControlScaleParameter;
				g_lightRotationDeltaX = i_x;
				g_lightRotationDeltaY = i_y;

			}
		}
		if (g_rightMouseButtonDown)
		{
			// Object Translation
			if (!g_controlDown)
			{
				g_translationDistance += (g_translationDeltaX - i_x)
						* gc_inputControlScaleParameter;
				g_translationDistance += (g_translationDeltaY - i_y)
						* gc_inputControlScaleParameter;
				g_translationDeltaX = i_x;
				g_translationDeltaY = i_y;
			}
			// Light Translation
			else
			{
				g_lightTranslationDistanceX += (g_lightTranslationDeltaX - i_x)
						* gc_inputControlScaleParameter;
				g_lightTranslationDistanceY += (g_lightTranslationDeltaY - i_y)
						* gc_inputControlScaleParameter;
				g_lightTranslationDeltaX = i_x;
				g_lightTranslationDeltaY = i_y;
			}
		}
	}
}

int main(int argc, char** argv)
{
	glutInit(&argc, argv); // Initialize GLUT

	SetupGLUTContextEnvironment(4, 2, GLUT_CORE_PROFILE); // Setup OpenGL Context Environment for freeglut and GLEW to use

	CreateWindowWithSpecifiedSizePositionTitle(480, 480, 50, 50,
			"CS6610 Project - Luyao Tian"
#ifdef _DEBUG
					" [Debug]"
#elif _RELEASE
			" [Release]"
#endif
)	; // Create an OpenGL window with specified size, position and title

	LoadMeshFileWithName(argv[1]); // Pass in the filename as first command line argument
								   // Note that argv[0] is the name of the program itself
								   // and therefore the first command line argument is argv[1]

	InitializeGLEW(); // Initialize GLEW library

	ProcessMeshData(); // Store related mesh data into memory

	CompileAndBindShaders("teapot_vertex.glsl", "teapot_color.glsl"); // Compile and bind shaders to the program

	GenerateAndBindBuffers(g_meshVertexData, g_meshIndexData, g_meshNormalData); // Creation and using Vertex Array Object and Vertex Buffer Object

	glutDisplayFunc(DisplayContent); // Register display callback handler for window re-paint

	glutIdleFunc(Idle);	// Register idle callback handler for window re-paint

	glutKeyboardFunc(ProcessKeyPress); // Register key press callback handler for actions bound to key press

	glutSpecialFunc(ProcessFunctionKeyPress); // Register special key press callback handler for actions bound to special key press

	glutSpecialUpFunc(ProcessFunctionKeyRelease); // Register special key release callback handler for actions bound to special key release

	glutMouseFunc(ProcessMouseButtonPress); // Register mouse button press callback handler for actions bound to mouse buttons

	glutMotionFunc(ProcessMouseDragMovement); // Register mouse drag movement callback handler for actions bound to mouse movements

	glutMainLoop();	// Enter the infinitely event-processing loop

	return 0;
}
