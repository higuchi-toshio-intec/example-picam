#!/bin/bash

#
cd ${HOME}/ros_ws
source devel/setup.bash
rosrun picam_ros sub_photo.py

# eof
