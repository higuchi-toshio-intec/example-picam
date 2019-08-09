#!/bin/bash
set -e

# setup ros environment
rel_sc=`lsb_release -sc`
if [ "${rel_sc}" = "stretch" ] ; then
    export ROS_DISTRO=kinetic
elif [ "${rel_sc}" = "buster" ] ; then
    export ROS_DISTRO=melodic
else
    echo "[Warning] '${rel_sc}' is Unknown OS type."
fi
echo "[INFO] ROS_DISTRO is '${ROS_DISTRO}'."
if [ "${ROS_DISTRO}" != "" ] ; then
    source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi
exec "$@"
