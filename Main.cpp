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

// Gloabl variables
namespace
{
	cy::TriMesh * mesh = nullptr;
	cy::Point3f * meshData = nullptr;
	GLuint gVertexCount; // Number of vertices in the mesh
	GLuint VAO, VBO; // Vertex Array Object and Vertex Buffer Object
	GLuint shaderProgramID;
	GLuint vertexShaderID, fragmentShaderID;
	char vertexShaderPath[FILE_PATH_BUFFER_SIZE] = "Shaders/Vertex/";
	char fragmentShaderPath[FILE_PATH_BUFFER_SIZE] = "Shaders/Fragment/";
	cy::GLSLShader * vertexShader = nullptr;
	cy::GLSLShader * fragmentShader = nullptr;
	cy::GLSLProgram * shaderProgram = nullptr;
	GLuint gTransform; // MVP transformation matrix
	cy::Point3f cameraPos = cy::Point3f(0.0f, 0.0f, 10.0f);
	cy::Point3f targetPos = cy::Point3f(0.0f, 0.0f, 0.0f);
	float rotY, rotZ = 0.0f;
	float transX, transY = 0.0f;
	float transDistance = 0.0f;
	bool leftDown;
	bool rightDown;
	// MVP matrices
	cy::Matrix4f modelMat;
	cy::Matrix4f viewMat;
	cy::Matrix4f projectionMat;
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
}

void SetupGLUTContextEnvironment(int OpenGLMajorVersion, int OpenGLMinorVersion,
		int OpenGLProfile)
{
	glutInitContextVersion(OpenGLMajorVersion, OpenGLMinorVersion); // This tells the program to use corresponding OpenGL version
	glutInitContextProfile(OpenGLProfile); // This tells the program to use a specific profile of OpenGL
}

void CreateWindowWithSpecifiedSizePositionTitle(int sizeX, int sizeY, int posX,
		int posY, const char * title)
{
	glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE); // Initialize GLUT display mode
	glutInitWindowSize(sizeX, sizeY); // Set the window's initial width & height
	glutInitWindowPosition(posX, posY); // Position the window's initial top-left corner
	glutCreateWindow(title); // Create a window with provided window title
}

void LoadMeshFileWithName(const char * filename)
{
	mesh = new cy::TriMesh();
	bool isFileLoaded = mesh->LoadFromFileObj(filename);
	if (!isFileLoaded)
	{
		fprintf(stderr, "Cannot open specified file.\n");
		exit(-1);
	}
}

void UnloadMeshFile()
{
	if (mesh)
	{
		delete mesh;
		//mesh = nullptr;
	}
	if (meshData)
	{
		delete[] meshData;
		meshData = nullptr;
	}
}

void UnloadShaderHandler()
{
	vertexShader->Delete();
	fragmentShader->Delete();
	shaderProgram->Delete();
}

void CleanUpShaders()
{
	UnloadShaderHandler();
	if (vertexShader)
	{
		delete vertexShader;
		vertexShader = nullptr;
	}
	if (fragmentShader)
	{
		delete fragmentShader;
		fragmentShader = nullptr;
	}
	if (shaderProgram)
	{
		delete shaderProgram;
		shaderProgram = nullptr;
	}
}

void InitializeGLEW()
{
	// Initialize GLEW library
	{
		GLenum result = glewInit();
		if (result != GLEW_OK)
		{
			fprintf(stderr, "Error: '%s'\n", glewGetErrorString(result));
			exit(-1); // Either use exit() or return to terminate the program
		}
	}
}

void ProcessVertexData()
{
	const auto vertexCount = mesh->NV();
	gVertexCount = vertexCount;
	meshData = new cy::Point3f[gVertexCount];
	for (size_t i = 0; i < vertexCount; i++)
	{
		meshData[i].x = mesh->V(i).x;
		meshData[i].y = mesh->V(i).y;
		meshData[i].z = mesh->V(i).z;
	}
}

void GenerateAndBindVertexBufferObjectAndVertexArrayObject(cy::Point3f * data)
{
	// General steps are provided by http://www.swiftless.com/tutorials/opengl4/4-opengl-4-vao.html
	glGenVertexArrays(1, &VAO); // Generate Vertex Array Object
	glBindVertexArray(VAO); // Bind Vertex Array Object so it's ready to use
	glGenBuffers(1, &VBO); //Generate Vertex Buffer Object
	glBindBuffer(GL_ARRAY_BUFFER, VBO); // Bind Vertex Buffer Object so it's ready to use
	glBufferData(GL_ARRAY_BUFFER, sizeof(cy::Point3f) * gVertexCount, data,
	GL_STATIC_DRAW); // Send drawing data to Vertex Buffer Object
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0); // Set up Vertex Attribute Pointer for position
	glEnableVertexAttribArray(0); // Disable Vertex Array Object
	glBindVertexArray(0); // Disable Vertex Buffer Object
}

void CleanUpVertexBufferObjectAndVertexArrayObject()
{
	glDeleteBuffers(1, &VBO);
	glDeleteVertexArrays(1, &VAO);
}

void CompileShaders(const char * vertexShaderPath,
		const char * fragmentShaderPath)
{
	bool result = vertexShader->CompileFile(vertexShaderPath, GL_VERTEX_SHADER);
	if (!result)
	{
		fprintf(stderr, "Cannot compile vertex shader.\n");
		exit(-1);
	}
	vertexShaderID = vertexShader->GetID();
	shaderProgram->AttachShader(vertexShaderID);
	result = fragmentShader->CompileFile(fragmentShaderPath,
	GL_FRAGMENT_SHADER);
	if (!result)
	{
		fprintf(stderr, "Cannot compile fragment shader.\n");
		exit(-1);
	}
	fragmentShaderID = fragmentShader->GetID();
	shaderProgram->Build(vertexShader, fragmentShader);
	shaderProgramID = shaderProgram->GetID();
	shaderProgram->Bind();
	gTransform = glGetUniformLocation(shaderProgramID, "g_transform");
	assert(gTransform != 0xFFFFFFFF);
}

void CompileAndBindShaders(const char * vertexShaderFileName,
		const char * fragmentShaderFileName)
{
	strcat(vertexShaderPath, vertexShaderFileName);
	strcat(fragmentShaderPath, fragmentShaderFileName);
	shaderProgram = new cy::GLSLProgram();
	vertexShader = new cy::GLSLShader();
	fragmentShader = new cy::GLSLShader();
	CompileShaders(vertexShaderPath, fragmentShaderPath); // Compile vertex and fragment shaders from file
}

void RecompileShaders()
{
	UnloadShaderHandler();
	CompileShaders(vertexShaderPath, fragmentShaderPath);
}

void ProcessTransformation()
{
	// Matrices setup reference: http://www.opengl-tutorial.org/beginners-tutorials/tutorial-3-matrices/#the-model-view-and-projection-matrices
	mesh->ComputeBoundingBox();

	modelMat = cy::Matrix4f::MatrixIdentity();
	modelMat.AddTrans((mesh->GetBoundMax() + mesh->GetBoundMin()) / 2 * -1.0f);
	viewMat = cy::Matrix4f::MatrixView(cy::Point3f(0.0f, 20.0f, -20.0f),
			cy::Point3f(0.0f, 0.0f, 0.0f), cy::Point3f(0.0f, 1.0f, 0.0f))
			* cy::Matrix4f::MatrixRotationY(rotY)
			* cy::Matrix4f::MatrixRotationX(rotZ);
	viewMat.AddTrans(cy::Point3f(0.0f, 0.0f, transDistance));
	projectionMat = cy::Matrix4f::MatrixPerspective(ToRadian(90.0f), 1.0f, 0.1f,
			100.0f);

	cy::Matrix4f transformMat = projectionMat * viewMat * modelMat;

	glUniformMatrix4fv(gTransform, 1, GL_FALSE, &transformMat.data[0]);
}

void DrawGeometry()
{
	glBindVertexArray(VAO); // Bind Vertex Array Object so it's ready to use
	glDrawArrays(GL_POINTS, 0, gVertexCount); // Draw elements in vertex buffer
	glBindVertexArray(0); // Disable Vertex Buffer Object
}

void CleanUp()
{
	CleanUpVertexBufferObjectAndVertexArrayObject(); // Clean Up Vertex Buffer and Array Objects
	CleanUpShaders();
	UnloadMeshFile();
}

void ProcessKeyPress(GLubyte key, GLint x, GLint y)
{
	// This section is for exiting the application with Esc key
	if (key == KeyCodes::Escape)
	{
		glutLeaveMainLoop(); // Exit the infinitely event-processing loop
		CleanUp();
	}
}

void ProcessFunctionKeyPress(GLint key, GLint x, GLint y)
{
	// This section is for recompiling shaders with F6 key
	if (key == GLUT_KEY_F6)
		RecompileShaders();
}

void ProcessMouseButtonPress(GLint button, GLint state, GLint x, GLint y)
{
	if (button == GLUT_LEFT_BUTTON && state == GLUT_DOWN)
		leftDown = true;
	else
		leftDown = false;
	if (button == GLUT_RIGHT_BUTTON && state == GLUT_DOWN)
		rightDown = true;
	else
		rightDown = false;
	// Keep track of mouse position
	{
		transX = x;
		transY = y;
	}
}

void ProcessMouseDragMovement(GLint x, GLint y)
{
	if (leftDown)
	{
		rotY += y * 0.0001f;
		rotZ += x * 0.0001f;
	}
	if (rightDown)
	{
		transDistance += (transX - x) * 0.01f;
		transDistance += (transY - y) * 0.01f;
		transX = x;
		transY = y;
	}
}

void DisplayContent()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // Clear front buffer
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f); // Reset background color to black
	ProcessTransformation(); // Calculate MVP matrix for transformation
	GenerateAndBindVertexBufferObjectAndVertexArrayObject(meshData); // Creation and using Vertex Array Object and Vertex Buffer Object
	DrawGeometry(); // Draw geometry onto the screen
	glutSwapBuffers(); // Swap front and back buffer
}

void Idle()
{
	glutPostRedisplay();
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

	ProcessVertexData(); // Store vertex data into memory

	CompileAndBindShaders("teapot_vertex.glsl", "teapot_color.glsl"); // Compile and bind shaders to the program

	glutDisplayFunc(DisplayContent); // Register display callback handler for window re-paint

	glutIdleFunc(Idle);	// Register idle callback handler for window re-paint

	glutKeyboardFunc(ProcessKeyPress); // Register key press callback handler for actions bound to key press

	glutSpecialFunc(ProcessFunctionKeyPress); // Register special key press callback handler for actions bound to special key press

	glutMouseFunc(ProcessMouseButtonPress); // Register mouse button press callback handler for actions bound to mouse buttons

	glutMotionFunc(ProcessMouseDragMovement); // Register mouse drag movement callback handler for actions bound to mouse movements

	glutMainLoop();	// Enter the infinitely event-processing loop

	return 0;
}
