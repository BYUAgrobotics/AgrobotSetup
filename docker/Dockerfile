FROM ros:humble-ros-base

# Check architecture
ARG TARGETARCH

# Update and upgrade
RUN apt update && apt upgrade -y

# Add tytools (as root)
RUN mkdir -p -m0755 /etc/apt/keyrings
RUN apt update && apt install -y curl \
    wget \
    unzip
RUN curl https://download.koromix.dev/debian/koromix-archive-keyring.gpg -o /etc/apt/keyrings/koromix-archive-keyring.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/koromix-archive-keyring.gpg] https://download.koromix.dev/debian stable main" > /etc/apt/sources.list.d/koromix.dev-stable.list
RUN apt update && apt install -y tytools

# Set up a new user
RUN useradd -ms /bin/bash agrobot
RUN usermod -aG sudo agrobot
RUN usermod -aG dialout agrobot
RUN echo 'agrobot:agrobot' | chpasswd
USER agrobot
WORKDIR /home/agrobot

# Install PlatformIO
USER root
RUN apt install -y python3-venv
USER agrobot

RUN curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
RUN python3 get-platformio.py
RUN rm get-platformio.py

# Set up PlatformIO shell commands
RUN mkdir -p /usr/local/bin

USER root
RUN ln -s /home/agrobot/.platformio/penv/bin/platformio /usr/local/bin/platformio
RUN ln -s /home/agrobot/.platformio/penv/bin/pio /usr/local/bin/pio
RUN ln -s /home/agrobot/.platformio/penv/bin/piodebuggdb /usr/local/bin/piodebuggdb
USER agrobot

# Set up ROS sourcing
RUN echo "source /opt/ros/humble/setup.bash" >> /home/agrobot/.bashrc

# Install the micro-ROS agent
RUN mkdir microros_ws

WORKDIR /home/agrobot/microros_ws
RUN git clone -b humble https://github.com/micro-ROS/micro_ros_setup.git src/micro_ros_setup
RUN rosdep update

USER root
RUN rosdep install --from-paths src --ignore-src -y
USER agrobot

SHELL ["/bin/bash", "-c"] 
RUN source /opt/ros/humble/setup.bash \
    && colcon build
RUN source /opt/ros/humble/setup.bash \
    && source install/setup.bash \
    && ros2 run micro_ros_setup create_agent_ws.sh
RUN source /opt/ros/humble/setup.bash \
    && source install/setup.bash \
    && ros2 run micro_ros_setup build_agent.sh
SHELL ["/bin/sh", "-c"]

WORKDIR /home/agrobot

# Install development dependencies (some of these are left over from the CougUV project)
USER root
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    apt update && apt install -y \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxrandr-dev \
    qtbase5-dev \
    libqt5x11extras5 \
    python3-gi \
    gir1.2-gtk-3.0 \
    x11-apps \
    ros-humble-rqt* \
    ros-humble-plotjuggler-ros \
    ros-humble-turtlesim \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*; \
    fi
USER agrobot

# Install general dependencies (some of these are left over from the CougUV project)
USER root
RUN apt update && apt install -y \
    python3-pip \
    vim \
    psmisc \
    network-manager \
    systemd \
    libgps-dev \
    python3-libgpiod \
    ros-humble-rosbag2-storage-mcap \
    netcat-openbsd
USER agrobot

# Development python dependencies
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    pip3 install --no-cache-dir PyQt5; \
    fi

# General python dependencies
RUN pip3 install numpy==1.26.0 \
    scipy \
    matplotlib \
    pyproj
RUN echo "export PATH=$PATH:/home/agrobot/.local/bin" >> /home/agrobot/.bashrc

# Update and upgrade
USER root
RUN apt update && apt upgrade -y
USER agrobot
