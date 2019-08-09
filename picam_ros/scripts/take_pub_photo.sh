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
source /opt/ros/$ROS_DISTRO}/setup.bash
source ${HOME}/ros_ws/devel/setup.bash

#
cd ${HOME}/ros_ws
rosrun picam_ros take_pub_photo.py 
