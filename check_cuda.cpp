#include <opencv2/opencv.hpp>
#include <opencv2/cudaarithm.hpp>

int main() {
    // Check if OpenCV is compiled with CUDA support
    if (cv::cuda::getCudaEnabledDeviceCount() == 0) {
        std::cout << "OpenCV was not built with CUDA support." << std::endl;
    } else {
        std::cout << "OpenCV was built with CUDA support." << std::endl;
    }

    return 0;
}
// For windows machine 
// cmake -G "Visual Studio 16 2019" .. ;  cmake --build . --config Release
