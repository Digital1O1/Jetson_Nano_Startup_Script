cmake_minimum_required(VERSION 3.0)
project(OpenCV_CUDA_Test)

# Windows path, comment out if using Linux
# set(OpenCV_DIR "E:/Coding Folder/OpenCV Source Folder/build/install/x64/vc16/lib")

# Find OpenCV package
find_package(OpenCV REQUIRED)

# Check if OpenCV is compiled with CUDA support
if (OpenCV_CUDA_VERSION)
    message(STATUS "OpenCV was built with CUDA support.")
else ()
    message(STATUS "OpenCV was not built with CUDA support.")
endif ()

# Add executable
add_executable(OpenCV_CUDA_Test check_cuda.cpp)

# Link OpenCV libraries
target_link_libraries(OpenCV_CUDA_Test PRIVATE ${OpenCV_LIBS})
