#! /bin/bash
echo "Starting initial setup for Jetson Nano"

echo "------------------- [ UPDATING JETSON NANO ] -------------------"
sudo apt-get update && sudo apt-get upgrade

echo "------------------- [ INSTALLING TP-LINK T3U ADAPTER ] -------------------"
# Install tp-link wifi T3U adapter
lsusbsudo apt install git dkms
git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git && cd rtl8812au
sudo make dkms_install

echo "------------------- [ BUILDING VIM FROM SOURCE ] -------------------"

# Building VIM from source
# Reference link: https://solarianprogrammer.com/2016/09/24/raspberry-pi-raspbian-building-installing-vim-8/
cd ~
sudo apt-get install ncurses-dev
git clone https://github.com/vim/vim.git vim-master
cd vim-master
cd src
./configure
make -j 4
sudo make install

# E: Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)
sudo killall apt apt-get
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a

echo "------------------- [ INSTALLING OPENCV WITH CUDA ] -------------------"
#!/bin/bash
set -e

echo "Installing OpenCV 4.7.0 on your Jetson Nano"
echo "It will take 3.5 hours !"

# reveal the CUDA location
cd ~
sudo sh -c "echo '/usr/local/cuda/lib64' >> /etc/ld.so.conf.d/nvidia-tegra.conf"
sudo ldconfig

# install the dependencies
sudo apt-get install -y build-essential cmake git unzip pkg-config zlib1g-dev
sudo apt-get install -y libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev libpng-dev libtiff-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libglew-dev
sudo apt-get install -y libgtk2.0-dev libgtk-3-dev libcanberra-gtk*
sudo apt-get install -y python-dev python-numpy python-pip
sudo apt-get install -y python3-dev python3-numpy python3-pip
sudo apt-get install -y libxvidcore-dev libx264-dev libgtk-3-dev
sudo apt-get install -y libtbb2 libtbb-dev libdc1394-22-dev libxine2-dev
sudo apt-get install -y gstreamer1.0-tools libv4l-dev v4l-utils qv4l2 
sudo apt-get install -y libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev
sudo apt-get install -y libavresample-dev libvorbis-dev libxine2-dev libtesseract-dev
sudo apt-get install -y libfaac-dev libmp3lame-dev libtheora-dev libpostproc-dev
sudo apt-get install -y libopencore-amrnb-dev libopencore-amrwb-dev
sudo apt-get install -y libopenblas-dev libatlas-base-dev libblas-dev
sudo apt-get install -y liblapack-dev liblapacke-dev libeigen3-dev gfortran
sudo apt-get install -y libhdf5-dev protobuf-compiler
sudo apt-get install -y libprotobuf-dev libgoogle-glog-dev libgflags-dev

# remove old versions or previous builds
cd ~ 
sudo rm -rf opencv*
# download the latest version
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.7.0.zip 
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.7.0.zip 
# unpack
unzip opencv.zip 
unzip opencv_contrib.zip 
# some administration to make live easier later on
mv opencv-4.7.0 opencv
mv opencv_contrib-4.7.0 opencv_contrib
# clean up the zip files
rm opencv.zip
rm opencv_contrib.zip

# set install dir
cd ~/opencv
mkdir build
cd build

# run cmake
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr \
-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
-D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
-D WITH_OPENCL=OFF \
-D WITH_CUDA=ON \
-D CUDA_ARCH_BIN=5.3 \
-D CUDA_ARCH_PTX="" \
-D WITH_CUDNN=ON \
-D WITH_CUBLAS=ON \
-D ENABLE_FAST_MATH=ON \
-D CUDA_FAST_MATH=ON \
-D OPENCV_DNN_CUDA=ON \
-D ENABLE_NEON=ON \
-D WITH_QT=OFF \
-D WITH_OPENMP=ON \
-D BUILD_TIFF=ON \
-D WITH_FFMPEG=ON \
-D WITH_GSTREAMER=ON \
-D WITH_TBB=ON \
-D BUILD_TBB=ON \
-D BUILD_TESTS=OFF \
-D WITH_EIGEN=ON \
-D WITH_V4L=ON \
-D WITH_LIBV4L=ON \
-D OPENCV_ENABLE_NONFREE=ON \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_EXAMPLES=OFF ..

# run make
FREE_MEM="$(free -m | awk '/^Swap/ {print $2}')"
# Use "-j 4" only swap space is larger than 5.5GB
if [[ "FREE_MEM" -gt "5500" ]]; then
  NO_JOB=4
else
  echo "Due to limited swap, make only uses 1 core"
  NO_JOB=1
fi
make -j ${NO_JOB} 

sudo rm -r /usr/include/opencv4/opencv2
sudo make install
sudo ldconfig

# cleaning (frees 320 MB)
make clean
#sudo apt-get update

echo "Congratulations!"
echo "You've successfully installed OpenCV 4.7.0 on your Jetson Nano"


echo "------------------- [ INSTALLING XRDP / XFCE4 ] -------------------"

# XRDP / XFCE4
sudo apt install -y xrdp
sudo apt install -y python3-pip
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev

# Change myUserName to whatever username you're using
sudo adduser ctnano ssl-cert
sudo apt install -y xfce4
sudo chmod 777 /etc/xrdp/startwm.sh
sudo apt-get install -y xfce4-terminal
sudo update-alternatives --config x-terminal-emulator

sudo apt update -y && sudo apt upgrade -y

echo "Use the following commadn : sudo nano /etc/xrdp/startwm.sh"
echo "Comment out the last two lines"
echo "Add 'startxfce4 at the bottom of the file"
echo "Then copy/paste in the terminal :  sudo service xrdp restart"