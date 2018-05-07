# Interactive Graphics

## Credit
- **cyCodeBase** by *Cem Yuksel*, it can be obtained **[here](https://github.com/cemyuksel/cyCodeBase "cyCodeBase source code")** and documentations can be found **[here](http://www.cemyuksel.com/cyCodeBase/code.html "cyCodeBase documentation")**, it has been slightly modified to be compatible with Linux environment
- **math_3d.h** by *OGLDev*, this specific version can be obtained **[here](https://github.com/triplepointfive/ogldev/blob/master/tutorial21/math_3d.h "math_3d.h source code")**

## Introduction
 This is a simple interactive graphics application utilizing *OpenGL* using **freeglut**, **GLEW** and **cyCodeBase**.
 This application is being developed in **Eclipse** on *Linux*.
 Please make sure the following settings are configured correctly before doing any modification.

## Configuration Steps
### 0. Install freeglut and GLEW on your system and rename the project
  - You should be able to install them from your distro repository. Otherwise, try installing them from their official websites
  - Rename the project from **InteractiveGraphics** to **CS6610Project** (If you want to keep the project name as **InteractiveGraphics**, you have to open the project and change every single instance of **CS6610Project** to **InteractiveGraphics** from all settings)
 
### 1. Check configuration setttings for the project
  - Go to **Project→Properties**
  - Select **C/C++ Build→Settings** from left column
  - Select **Tool Settings** tab and highlight **GCC C++ Compiler→Preprocessor** entry
  - Set configuration to **Debug**, make sure defined symbols list contains **_DEBUG** and undefined symbols list contains **_RELEASE**
  - Set configuration to **Release**, make sure defined symbols list contains **_RELEASE** and undefined symbols list contains **_DEBUG**
  - From the same tab, highlight **GCC C++ Compiler→Miscellaneous** entry
  - Set configuration to **All configurations**
  - Add **-std=c++11** at the end of **Other flags** section

### 2. Link libraries to the project
  - In the same window, highlight **GCC C++ Linker→Libraries** entry
  - Set configuration to **All configurations**
  - Make sure the **Libraries** section contains at least the following 4 values: **GL, GLU, GLEW, glut**
  
### 3. Modify build steps for the project
  - In the same window, switch to **Build Steps** tab
  - Set configuration to **All configurations**
  - Make sure the command **cp -r ${ProjDirPath}/Assets ${PWD}; cp -r ${ProjDirPath}/Shaders ${PWD}** is in **Post-build steps command** section
  - This command will copy all files in **Assets** and **Shaders** folders from project directory to build directory
  
### 4. Add build arguments for the project
  - In the same window, select **Run/Debug Settings** from left column
  - Select **CS6610Project** from center column and click **Edit...** on the right
  - Under **Main** tab make sure the command **${config_name:${project_name}}/CS6610Project** has been set in **C/C++ Application** section
  - Change **Build Configuration** to **Use Active**
  - Switch to **Arguments** tab
  - Make sure the command **${project_loc}/${config_name:${project_name}}/Assets/Meshes/teapot.obj** is in **Program arguments** section if you want to test the project using default teapot object
  - If you would like to use other objects in the project, make sure you modify the command so it reads the correct object file
  
### 5. Rebuild index for the project
  - In Eclipse, right click on the project from **Project Explorer** panel on the left
  - Select **Index→Rebuild**
  - This should resolve all incompatibility issues
