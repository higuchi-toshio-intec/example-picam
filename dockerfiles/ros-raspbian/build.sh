#!/bin/bash

#
echo 'Etc/UTC' > /etc/timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime
apt update
apt install -y -q --no-install-recommends tzdata
rm -rf /var/lib/apt/lists/*

# install packages
apt update
apt install -y -q --no-install-recommends dirmngr gnupg2 lsb-release
rm -rf /var/lib/apt/lists/*

#
rel_sc=`lsb_release -sc`
if [ "${rel_sc}" = "stretch" ] ; then
    export ROS_DISTRO=kinetic
elif [ "${rel_sc}" = "buster" ] ; then
    export ROS_DISTRO=melodic
else
    echo "[Warning] '${rel_sc}' is Unknown OS type."
fi
echo "[INFO] ROS_DISTRO is '${ROS_DISTRO}'."

# setup keys
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
apt update
apt install -y -q --no-install-recommends ca-certificates
apt install -y -q --no-install-recommends python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential cmake
rm -rf /var/lib/apt/lists/*

# setup environment
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# bootstrap rosdep
rosdep init
rosdep update

#
mkdir /ros_catkin_ws
cd /ros_catkin_ws
rosinstall_generator ros_comm common_msgs --rosdistro ${ROS_DISTRO} --deps --wet-only --tar > ${ROS_DISTRO}-ros_comm-wet.rosinstall
wstool init src ${ROS_DISTRO}-ros_comm-wet.rosinstall

#
apt update
rosdep install -y --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -r --os=debian:${rel_sc}
rm -rf /var/lib/apt/lists/*

#
./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/${ROS_DISTRO} -j2

#
