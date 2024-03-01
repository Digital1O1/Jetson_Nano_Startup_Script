#! /bin/bash
echo "Starting initial setup for Jetson Nano"

echo "------------------- [ UPDATING JETSON NANO ] -------------------"
sudo apt-get -y update  && sudo apt-get -y upgrade 

# echo "------------------- [ INSTALLING GCC V8 FOR OPENCV ] -------------------"

sudo apt install -y gcc-8 g++-8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8
sudo update-alternatives --set gcc /usr/bin/gcc-8
gcc --version
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all

echo "------------------- [ INSTALLING NANO ] -------------------"
sudo apt install -y nano

echo "------------------- [ INSTALLING GPARTED ] -------------------"

sudo apt install -y gparted

echo "------------------- [ INSTALLING XORG for X11 FORWARDING ] -------------------"
sudo apt install xorg
startx
echo 'export DISPLAY=localhost:10.0' >> ~/.zshrc && source ~/.zshrc

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

echo "------------------- [ INSTALLING OPENCV WITH CUDA ] -------------------"

  echo "Installing OpenCV 4.8.0 on your Nano"
  echo "It will take 3.5 hours !"
  
  # reveal the CUDA location
  cd ~
  sudo sh -c "echo '/usr/local/cuda/lib64' >> /etc/ld.so.conf.d/nvidia-tegra.conf"
  sudo ldconfig
  
  # install the Jetson Nano dependencies first
  if [[ $model == *"Jetson Nano"* ]]; then
    sudo apt-get install -y build-essential git unzip pkg-config zlib1g-dev
    sudo apt-get install -y python3-dev python3-numpy
    sudo apt-get install -y python-dev python-numpy python-pip
    sudo apt-get install -y gstreamer1.0-tools libgstreamer-plugins-base1.0-dev
    sudo apt-get install -y libgstreamer-plugins-good1.0-dev
    sudo apt-get install -y libtbb2 libgtk-3-dev v4l2ucp libxine2-dev
  fi
  # install the common dependencies
  sudo apt-get install -y cmake
  sudo apt-get install -y libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev
  sudo apt-get install -y libpng-dev libtiff-dev libglew-dev
  sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
  sudo apt-get install -y libgtk2.0-dev libgtk-3-dev libcanberra-gtk*
  sudo apt-get install -y python3-pip
  sudo apt-get install -y libxvidcore-dev libx264-dev
  sudo apt-get install -y libtbb-dev libdc1394-22-dev libxine2-dev
  sudo apt-get install -y libv4l-dev v4l-utils qv4l2
  sudo apt-get install -y libtesseract-dev libpostproc-dev
  sudo apt-get install -y libavresample-dev libvorbis-dev
  sudo apt-get install -y libfaac-dev libmp3lame-dev libtheora-dev
  sudo apt-get install -y libopencore-amrnb-dev libopencore-amrwb-dev
  sudo apt-get install -y libopenblas-dev libatlas-base-dev libblas-dev
  sudo apt-get install -y liblapack-dev liblapacke-dev libeigen3-dev gfortran
  sudo apt-get install -y libhdf5-dev libprotobuf-dev protobuf-compiler
  sudo apt-get install -y libgoogle-glog-dev libgflags-dev
 
  # remove old versions or previous builds
  cd ~ 
  sudo rm -rf opencv*
  # download the latest version
  git clone --depth=1 https://github.com/opencv/opencv.git
  git clone --depth=1 https://github.com/opencv/opencv_contrib.git
  
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
  -D CUDA_ARCH_BIN=5.3 \
  -D CUDA_ARCH_PTX="sm_53" \
  -D WITH_CUDA=ON \
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
  -D BUILD_TESTS=OFF \
  -D WITH_EIGEN=ON \
  -D WITH_V4L=ON \
  -D WITH_LIBV4L=ON \
  -D WITH_PROTOBUF=ON \
  -D OPENCV_ENABLE_NONFREE=ON \
  -D INSTALL_C_EXAMPLES=ON \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D PYTHON_EXECUTABLE=$(which python3) \
  -D PYTHON_INCLUDE_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_paths()['include'])") \
  -D OPENCV_PYTHON3_INSTALL_PATH=/usr/lib/python3/dist-packages \
  -D PYTHON_LIBRARY=lib/aarch64-linux-gnu/libpython3.8.so.1.0 \
  -D PYTHON3_PACKAGES_PATH=$(python3 -m site --user-site) \
  -D PYTHON3_NUMPY_INCLUDE_DIRS=$(python3 -c "import numpy; print(numpy.get_include())") \
  -D OPENCV_GENERATE_PKGCONFIG=ON \
  -D BUILD_EXAMPLES=ON ..
 
  make -j4
  
  directory="/usr/include/opencv4/opencv2"
  if [ -d "$directory" ]; then
    # Directory exists, so delete it
    sudo rm -rf "$directory"
  fi
  
  sudo make install
  sudo ldconfig
  
  # cleaning (frees 320 MB)
  make clean
  sudo apt-get update
  
  echo "Congratulations!"
  echo "You've successfully installed OpenCV 4.9.0 on your Nano"


# echo "------------------- [ INSTALLING ZSH AND PLUGINS/THEMES ] -------------------"
#!/bin/bash

# Install Zsh
echo "Installing Zsh..."
sudo apt-get update && sudo apt-get install -y zsh

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone Powerlevel10k theme
echo "Cloning Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Set Zsh theme to Powerlevel10k
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Install recommended plugins
echo "Installing recommended plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Install additional plugins
echo "Installing additional plugins..."
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
git clone https://github.com/wting/autojump.git
cd autojump
./install.py
cd ..
git clone https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# Update .zshrc to include plugins
echo "Updating .zshrc file..."
echo "plugins=(" >> ~/.zshrc
echo "  git" >> ~/.zshrc
echo "  zsh-autosuggestions" >> ~/.zshrc
echo "  zsh-syntax-highlighting" >> ~/.zshrc
echo "  zsh-completions" >> ~/.zshrc
echo "  autojump" >> ~/.zshrc
echo "  docker" >> ~/.zshrc
echo ")" >> ~/.zshrc

echo "Zsh, Powerlevel10k, and recommended plugins installed successfully."
echo "Please restart your terminal to apply the changes."




sudo reboot now


