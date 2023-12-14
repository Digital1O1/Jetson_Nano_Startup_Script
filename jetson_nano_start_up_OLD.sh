#! /bin/bash
echo "Starting initial setup for Jetson Nano"

echo "------------------- [ UPDATING JETSON NANO ] -------------------"
sudo apt-get -y update  && sudo apt-get -y upgrade 

# echo "------------------- [ INSTALLING GCC V8 FOR OPENCV ] -------------------"

sudo apt install -y gcc-8 g++-8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8
sudo update-alternatives --config gcc
gcc --version
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all

echo "------------------- [ INSTALLING NANO ] -------------------"
sudo apt install -y nano

echo "------------------- [ INSTALLING JETSON STATS ] -------------------"

sudo apt install -y python3-pip
sudo pip3 install -U jetson-stats

echo "------------------- [ BUILDING VIM FROM SOURCE ] -------------------"
cd ~
sudo apt-get install -y ncurses-dev
git clone https://github.com/vim/vim.git vim-master
cd vim-master/src
./configure
make -j 4
sudo make install

echo "------------------- [ INSTALLING OPENCV WITH CUDA ] -------------------"
#!/bin/bash
set -e

echo "Installing OpenCV 4.8.0 on your Jetson Nano"

# reveal the CUDA location
cd ~
sudo sh -c "echo '/usr/local/cuda/lib64' >> /etc/ld.so.conf.d/nvidia-tegra.conf"
sudo ldconfig

# install the dependencies
sudo apt-get install -y build-essential git unzip pkg-config zlib1g-dev
sudo apt-get install -y python3-dev python3-numpy
sudo apt-get install -y python-dev python-numpy python3-pip  # Modified this line
sudo apt-get install -y gstreamer1.0-tools libgstreamer-plugins-base1.0-dev
sudo apt-get install -y libgstreamer-plugins-good1.0-dev
sudo apt-get install -y libtbb2 libgtk-3-dev libxine2-dev
sudo apt-get install -y libeigen3-dev
sudo apt-get install -y libgstreamer-plugins-base1.0-dev
sudo apt-get install -y build-essential cmake git unzip pkg-config zlib1g-dev
sudo apt-get install -y libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev libpng-dev libtiff-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libglew-dev
sudo apt-get install -y libgtk2.0-dev libgtk-3-dev libcanberra-gtk*
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
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.8.0.zip 
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.8.0.zip 
# unpack
unzip opencv.zip 
unzip opencv_contrib.zip 
# some administration to make live easier later on
mv opencv-4.8.0 opencv
mv opencv_contrib-4.8.0 opencv_contrib
# clean up the zip files
rm opencv.zip
rm opencv_contrib.zip

# set install dir
cd ~/opencv
mkdir build
cd build

# run cmake
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D MAKE_C_COMPILER=/usr/bin/gcc-8 \
-D MAKE_CXX_COMPILER=/usr/bin/g++-8 \
-D CMAKE_INSTALL_PREFIX=/usr \
-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
-D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
-D WITH_OPENCL=OFF \
-D WITH_CUDA=ON \
-D CUDA_ARCH_BIN=5.3 \
-D CUDA_ARCH_PTX="sm_53 \
-D WITH_CUDNN=ON \
-D WITH_CUBLAS=ON \
-D ENABLE_FAST_MATH=ON \
-D CUDA_FAST_MATH=ON \
-D OPENCV_DNN_CUDA=ON \
-D ENABLE_NEON=ON \
-D WITH_QT=ON \
-D WITH_OPENMP=ON \
-D BUILD_TIFF=ON \
-D WITH_FFMPEG=ON \
-D WITH_GSTREAMER=ON \
-D WITH_TBB=ON \
-D BUILD_TBB=ON \
-D BUILD_opencv_python3=ON \
-D BUILD_TESTS=OFF \
-D WITH_EIGEN=ON \
-D WITH_V4L=ON \
-D WITH_LIBV4L=ON \
-D OPENCV_ENABLE_NONFREE=ON \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=ON \
-D PYTHON3_PACKAGES_PATH=/usr/lib/python3.8/site-packages \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D WITH_ONNX=ON \
-D BUILD_EXAMPLES=ON ..
# run make
# FREE_MEM="$(free -m | awk '/^Swap/ {print $2}')"
# # Use "-j 4" only swap space is larger than 5.5GB
# if [[ "FREE_MEM" -gt "5500" ]]; then
#   NO_JOB=4
# else
#   echo "Due to limited swap, make only uses 1 core"
#   NO_JOB=1
# fi
make -j 4

sudo rm -r /usr/include/opencv4/opencv2
sudo make install
sudo ldconfig

# cleaning (frees 320 MB)
make clean
sudo apt-get update

echo "Congratulations!"
echo "You've successfully installed OpenCV 4.8.0 on your Jetson Nano"

echo "------------------- [ INSTALLING XRDP / XFCE4 ] -------------------"
# Reference link : https://raspberry-valley.azurewebsites.net/NVIDIA-Jetson-Nano/

# XRDP / XFCE4
sudo apt install -y xrdp
sudo apt install -y python3-pip
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev
sudo apt install -y curl
echo "------------------- [ INSTALLING TIGHTVNC ] -------------------"
sudo apt-get install -y xfce4 xfce4-goodies
sudo apt-get install -y tightvncserver

# Start TightVNC server to set up initial configuration
tightvncserver

# Stop TightVNC server
tightvncserver -kill :1

# Configure TightVNC server to start on boot
echo "#!/bin/sh
### BEGIN INIT INFO
# Provides:          tightvncserver
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start TightVNC server at boot time
# Description:       Start TightVNC server at boot time.
### END INIT INFO

# /etc/init.d/tightvncserver
tightvncserver -geometry 1920x1080 -depth 24 :1
" | sudo tee -a /etc/init.d/tightvncserver

# Set executable permissions for the init script
sudo chmod +x /etc/init.d/tightvncserver

# Register the init script to run on boot
sudo update-rc.d tightvncserver defaults

# Start TightVNC server
sudo /etc/init.d/tightvncserver start

echo "TightVNC server installed and configured. You can now connect to your Jetson Nano using a VNC viewer on the IP address followed by :1 (e.g., 192.168.1.100:1)"

echo "------------------- [ ENABLE VNC/REMOTE DESKTOP ] -------------------"
echo "Reference link: https://raspberry-valley.azurewebsites.net/NVIDIA-Jetson-Nano/"
echo "Use the following command: sudo nano /usr/share/glib-2.0/schemas/org.gnome.Vino.gschema.xml"
echo "Add this after the first 'entry'"
echo "<key name='enabled' type='b'>
   <summary>Enable remote access to the desktop</summary>
   <description>
   If true, allows remote access to the desktop via the RFB
   protocol. Users on remote machines may then connect to the
   desktop using a VNC viewer.
   </description>
   <default>false</default>
</key>"
echo "Then: sudo glib-compile-schemas /usr/share/glib-2.0/schemas"
echo "gsettings set org.gnome.Vino require-encryption false"
echo "gsettings set org.gnome.Vino prompt-enabled false"
sudo reboot now


