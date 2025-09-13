FROM ros:humble


ARG DEBIAN_FRONTEND=noninteractive

# Create a non-root user
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

# Delete existing user if it exists
RUN if getent passwd ${USER_UID}; then \
    userdel -r $(getent passwd ${USER_UID} | cut -d: -f1); \
    fi

# Delete existing group if it exists
RUN if getent group ${USER_GID}; then \
    groupdel $(getent group ${USER_GID} | cut -d: -f1); \
    fi

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config

# Set up sudo
RUN apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && rm -rf /var/lib/apt/lists/*

# Install Eigen 3.3.9
RUN apt-get update -y && apt-get install -y --allow-unauthenticated \
    curl

RUN mkdir /home/user/Libraries
RUN mkdir ~/source_code 
RUN cd ~/source_code \
    && curl https://gitlab.com/libeigen/eigen/-/archive/3.3.9/eigen-3.3.9.tar.gz --output eigen.tar.gz \
    && tar -xvzf eigen.tar.gz

RUN cd ~/source_code/eigen-3.3.9 \
    && mkdir build \ 
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && cd ~/

# Install the package dependencies
RUN apt-get update -y && apt-get install -y --allow-unauthenticated \
    software-properties-common \
    clang-14 \
    clang-format-14 \
    clang-tidy-14 \
    python3-pip \
    libpoco-dev \
    ros-humble-control-msgs \
    ros-humble-xacro \
    ros-humble-ament-cmake-clang-format \
    ros-humble-ament-clang-format \
    ros-humble-ament-flake8 \
    ros-humble-ament-cmake-clang-tidy \
    ros-humble-angles \
    ros-humble-ros2-control \
    ros-humble-realtime-tools \
    ros-humble-control-toolbox \    
    ros-humble-controller-manager \
    ros-humble-hardware-interface \
    ros-humble-hardware-interface-testing \
    ros-humble-launch-testing \
    ros-humble-generate-parameter-library \
    ros-humble-controller-interface \
    ros-humble-ros2-control-test-assets \
    ros-humble-controller-manager \
    ros-humble-moveit \
    ros-humble-nav-msgs \
    && rm -rf /var/lib/apt/lists/*


RUN python3 -m pip install -U \
    argcomplete \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \ 
    flake8-deprecated \
    flake8-docstrings \
    flake8-import-order \
    flake8-quotes \
    pytest-repeat \
    pytest-rerunfailures \
    pytest

# Build libfranka
RUN cd ~/source_code && git clone https://github.com/frankaemika/libfranka.git \
    && mkdir /home/user/Libraries/libfranka \
    && cd libfranka \
    && git checkout 0.9.2 \
    && git submodule init \
    && git submodule update \
    && mkdir build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/home/user/Libraries/libfranka .. \
    && cmake --build . \
    && cmake --install .

# Install MuJoCo dependencies first
RUN apt-get update -y && apt-get install -y \
    libglfw3 \
    libglfw3-dev \
    libgl1-mesa-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxi-dev \
    libxkbcommon-dev \
    ninja-build \
    zlib1g-dev \
    clang-12

# Install dqrobotics
RUN add-apt-repository ppa:dqrobotics-dev/release && apt-get update && apt-get install libdqrobotics

# Install MuJoCo from scratch
RUN cd ~/source_code && git clone https://github.com/google-deepmind/mujoco.git \
    && cd mujoco \
    && git checkout 3.2.0 \
    && mkdir ~/source_code/mujoco/build \
    && mkdir /home/user/Libraries/mujoco \
    && cd ~/source_code/mujoco/build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/home/user/Libraries/mujoco \
    && cmake --build . \
    && cmake --install .


# Create workspace directory structure for development
RUN mkdir -p /home/user/humble_ws/src

# Set up the environment variables
RUN echo 'source /opt/ros/humble/setup.bash' >> /home/user/.bashrc
RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/user/Libraries/libfranka/lib:/home/user/Libraries/mujoco/lib' >> /home/user/.bashrc 
RUN echo 'export CMAKE_PREFIX_PATH=~/Libraries/libfranka/lib/cmake:~/Libraries/mujoco/lib/cmake' >> /home/user/.bashrc

RUN chown -R user:user /home/user/

# Clone mujoco_ros_pkgs dependency
RUN cd /home/user/humble_ws/src \
    && git clone https://github.com/tenfoldpaper/mujoco_ros_pkgs

# Switch to user and set working directory
USER user
WORKDIR ~/
SHELL ["/bin/bash", "-c"]

# Update rosdep (will install package deps later in post_create)
RUN source ~/.bashrc \
    && . /opt/ros/humble/setup.sh \
    && cd ~/humble_ws && rosdep update

# Suppress XDG errors when running GUI apps like RVIZ
RUN mkdir /tmp/${UID}
RUN chown -R user:user /tmp/${UID}

ENV XDG_RUNTIME_DIR=/tmp/${UID}
ENV CMAKE_PREFIX_PATH=~/Libraries/libfranka/lib/cmake:~/Libraries/mujoco/lib/cmake
