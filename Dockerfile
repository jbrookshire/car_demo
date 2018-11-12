FROM nvidia/cudagl:9.0-base-ubuntu16.04

LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN apt-get update \
 && apt-get install -y \
    wget \
    lsb-release \
    sudo \
    mesa-utils \
    net-tools \
 && apt-get clean

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    emacs \
    && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y \
    ros-kinetic-desktop && \
    rm -rf /var/lib/apt/lists/*

# Get gazebo binaries
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list \
 && wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - \
 && apt-get update \
 && apt-get install -y \
    gazebo8 \
    libgazebo8-dev \
    ros-kinetic-gazebo8-ros-pkgs \
    ros-kinetic-fake-localization \
    ros-kinetic-joy && \
    apt-get clean

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    locate && \
    apt-get clean
    
#FROM osrf/ros:kinetic-desktop
#
#LABEL com.nvidia.volumes.needed="nvidia_driver"
#ENV PATH /usr/local/nvidia/bin:${PATH}
#ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
#
#RUN apt-get update \
# && apt-get install -y \
#    wget \
#    lsb-release \
#    sudo \
#    mesa-utils \
# && apt-get clean
#
#
## Get gazebo binaries
#RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu `lsb_release -cs` main" >###### /etc/apt/sources.list.d/gazebo-stable.list \
# && wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - \
# && apt-get update \
# && apt-get install -y \
#    gazebo8 \
#    ros-kinetic-gazebo8-ros-pkgs \
#    ros-kinetic-fake-localization \
#    ros-kinetic-joy \
# && apt-get clean


RUN mkdir -p /tmp/workspace/src
COPY prius_description /tmp/workspace/src/prius_description
COPY prius_msgs /tmp/workspace/src/prius_msgs
COPY car_demo /tmp/workspace/src/car_demo
RUN /bin/bash -c 'cd /tmp/workspace \
 && source /opt/ros/kinetic/setup.bash \
 &&   catkin_make'


CMD ["/bin/bash", "-c", "source /opt/ros/kinetic/setup.bash && source /tmp/workspace/devel/setup.bash && roslaunch car_demo demo.launch"]
