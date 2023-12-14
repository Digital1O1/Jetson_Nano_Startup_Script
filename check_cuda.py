import cv2

def check_opencv_cuda_support():
    # Check if OpenCV is compiled with CUDA support
    if cv2.cuda.getCudaEnabledDeviceCount() == 0:
        print("OpenCV was not built with CUDA support.")
    else:
        print("OpenCV was built with CUDA support.")

if __name__ == "__main__":
    check_opencv_cuda_support()
