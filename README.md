# Interactive Graphics

## Credit
- **cyCodeBase** by *Cem Yuksel*, it can be obtained **[here](https://github.com/cemyuksel/cyCodeBase "cyCodeBase source code")** and documentations can be found **[here](http://www.cemyuksel.com/cyCodeBase/code.html "cyCodeBase documentation")**, it has been slightly modified to be compatible with Linux environment
- **math_3d.h** by *OGLDev*, this specific version can be obtained **[here](https://github.com/triplepointfive/ogldev/blob/master/tutorial21/math_3d.h "math_3d.h source code")**

## Introduction
 This is a simple interactive graphics application utilizing *OpenGL* using **freeglut**, **GLEW** and **cyCodeBase**.
 This application is being developed in **Eclipse** on *Linux*. The specific distro for development is *PCLinuxOS*.
 Please make sure the following settings are configured correctly before doing any modification.

## Configuration Steps
### 0. Install freeglut and GLEW on your system
  - You should be able to install them from your distro repository. Otherwise, try installing them from their official websites
 
### 1. Check configuration setttings for the project
  - Go to **Project→Properties**
  - Select **C/C++ Build→Settings** from left column
  - Select **Tool Settings** tab and highlight **GCC C++ Compiler→Preprocessor** entry
  - Set configuration to **Debug**, make sure defined symbols list contains **_DEBUG** and undefined symbols list contains **_RELEASE**
  - Set configuration to **Release**, make sure defined symbols list contains **_RELEASE** and undefined symbols list contains **_DEBUG**

### 2. Link libraries to the project
  - In the same window, highlight **GCC C++ Linker→Libraries** entry
  - Set configuration to **All configurations**
  - Make sure the **Libraries** section contains at least the following 4 values: **GL, GLU, GLEW, glut**
  
### 3. Modify build steps for the project
  - In the same window, switch to **Build Steps** tab
  - Set configuration to **All configurations**
  - Make sure the command **cp -r ${ProjDirPath}/Assets ${PWD}; cp -r ${ProjDirPath}/Shaders ${PWD}** is in **Post-build steps command** section
  - This command will copy all files in **Assets** and **Shaders** folders from project directory to build directory
  
### 4. Rebuild index for the project
  - In Eclipse, right click on the project from **Project Explorer** panel on the left
  - Select **Index→Rebuild**
  - This should resolve all incompatibility issues
