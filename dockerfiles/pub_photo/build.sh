#!/bin/bash

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

#
apt update
apt upgrade -y -q
apt install -y -q --no-install-recommends ca-certificates
apt install -y -q --no-install-recommends libraspberrypi-bin
apt install -y -q --no-install-recommends libopencv-dev python-opencv python-cv-bridge
apt install -y -q --no-install-recommends systemd cron
apt clean
rm -rf /var/lib/apt/lists/*

#
mkdir -p ${HOME}/git
cd ${HOME}/git
git clone https://github.com/higuchi-toshio-intec/example-picam.git
cd example-picam
if [ "${PICAM_GIT_BRANCH}" != "master" ] ; then
    echo "[INFO] checkout '${PICAM_GIT_BRANCH}' branch"
    git checkout ${PICAM_GIT_BRANCH}
fi

#
source /opt/ros/${ROS_DISTRO}/setup.bash
mkdir -p ${HOME}/ros_ws/src
cd ${HOME}/ros_ws/src
catkin_create_pkg picam_ros roscpp rospy std_msgs sensor_msgs

#
cd ${HOME}/git/example-picam
tar cvf - ./picam_ros | (cd ${HOME}/ros_ws/src ; tar xvf -)

#
cd ${HOME}/ros_ws
catkin_make

#
crontab ${HOME}/git/example-picam/picam_ros/docker/pub/crontab.user
systemctl enable cron.service

#
