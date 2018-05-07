################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../LodePNG/lodepng.cpp 

OBJS += \
./LodePNG/lodepng.o 

CPP_DEPS += \
./LodePNG/lodepng.d 


# Each subdirectory must supply rules for building sources it contributes
LodePNG/%.o: ../LodePNG/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -D_RELEASE -U_DEBUG -O3 -Wall -c -fmessage-length=0 -std=c++11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


