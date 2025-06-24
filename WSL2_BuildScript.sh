#!/bin/bash
set -e

echo "------------------- [ INSTALLING LATEST OPENCV WITH CUDA + PYTHON SUPPORT ] -------------------"

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential cmake git unzip pkg-config zlib1g-dev \
    libjpeg-dev libpng-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev v4l-utils libxvidcore-dev libx264-dev libgtk-3-dev \
    libatlas-base-dev gfortran python3-dev python3-pip python3-numpy \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libtbb2 libtbb-dev \
    libeigen3-dev libprotobuf-dev protobuf-compiler libopenblas-dev \
    liblapack-dev liblapacke-dev libhdf5-dev libcanberra-gtk* \
    libxine2-dev libdc1394-22-dev libglew-dev libfaac-dev libmp3lame-dev \
    libtheora-dev libvorbis-dev libpostproc-dev libopencore-amrnb-dev libopencore-amrwb-dev \
    libtesseract-dev libgflags-dev libgoogle-glog-dev

# Remove previous builds
cd ~
rm -rf opencv opencv_contrib opencv*.zip

# Get latest OpenCV version number
echo "Fetching latest OpenCV version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/opencv/opencv/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
echo "Latest OpenCV version: $LATEST_VERSION"

wget -O opencv.zip https://github.com/opencv/opencv/archive/$LATEST_VERSION.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/$LATEST_VERSION.zip
unzip opencv.zip
unzip opencv_contrib.zip

# Rename for simplicity
mv opencv-$LATEST_VERSION opencv
mv opencv_contrib-$LATEST_VERSION opencv_contrib
rm opencv.zip opencv_contrib.zip

# Set Python paths (assumes you're in a virtual environment)
VENV_DIR="$VIRTUAL_ENV"
PYTHON_EXEC=$(which python3)
PYTHON_LIB=$(find "$VENV_DIR/lib" -name "libpython3*.so" | head -n 1)
PYTHON_INCLUDE=$(find "$VENV_DIR/include" -type d -name "python3*" | head -n 1)
NUMPY_INCLUDE=$(python3 -c "import numpy; print(numpy.get_include())")

# Build OpenCV
cd ~/opencv
mkdir -p build && cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr \
  -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
  -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
  -D WITH_CUDA=ON \
  -D WITH_CUDNN=ON \
  -D CUDA_ARCH_BIN=7.5 \
  -D CUDA_ARCH_PTX="sm_75" \
  -D ENABLE_FAST_MATH=ON \
  -D CUDA_FAST_MATH=ON \
  -D OPENCV_DNN_CUDA=ON \
  -D WITH_CUBLAS=ON \
  -D WITH_OPENMP=ON \
  -D WITH_FFMPEG=ON \
  -D WITH_GSTREAMER=ON \
  -D WITH_TBB=ON \
  -D WITH_V4L=ON \
  -D WITH_QT=ON \
  -D BUILD_opencv_cudacodec=ON \
  -D WITH_OPENCL=OFF \
  -D OPENCV_ENABLE_NONFREE=ON \
  -D BUILD_TESTS=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D BUILD_DOCS=OFF \
  -D BUILD_EXAMPLES=ON \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D PYTHON_EXECUTABLE=${PYTHON_EXEC} \
  -D PYTHON_INCLUDE_DIR=${PYTHON_INCLUDE} \
  -D PYTHON_LIBRARY=${PYTHON_LIB} \
  -D PYTHON3_NUMPY_INCLUDE_DIRS=${NUMPY_INCLUDE} \
  -D OPENCV_PYTHON3_INSTALL_PATH=${VENV_DIR}/lib/python3*/site-packages \
  -D OPENCV_GENERATE_PKGCONFIG=ON ..

make -j$(nproc)
sudo rm -rf /usr/include/opencv4/opencv2
sudo make install
sudo ldconfig
make clean

echo "OpenCV installation complete!"
python3 -c "import cv2; print('CUDA available:' if cv2.cuda.getCudaEnabledDeviceCount() > 0 else 'No CUDA support')"
# python3 -c "import cv2; print(cv2.__version__); print(cv2.getBuildInformation())"
