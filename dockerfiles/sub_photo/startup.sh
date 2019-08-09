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
source /opt/ros/${ROS_DISTRO}/setup.bash
source ${HOME}/ros_ws/devel/setup.bash

if [ "${ROS_MASTER_URI}" = "" ] ; then
    echo "[ERROR] Environment variable (ROS_MASTER_URI) is blank." | tee -a ${HOME}/sub_photo.out
    exec bash
fi

#
cd ${HOME}/ros_ws/
rosrun picam_ros sub_photo.py >> ${HOME}/sub_photo.out

# eof
