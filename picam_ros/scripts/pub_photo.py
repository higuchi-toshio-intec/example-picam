#!/usr/bin/python
# -*- coding: utf-8 -*-

import argparse
import cv2
import cv_bridge
from datetime import datetime
import numpy
import os
import rospy
import sys
import time

from picam_ros.msg import picam_photo

###############################################################################
# Global Variable
GV_cv_bridge = cv_bridge.CvBridge()

MyNodeName = "my_node_name"


###############################################################################
#
def create_pub(node_name):
    rospy.init_node(MyNodeName, anonymous=True)
    staLatch = True
#    staLatch = False
    pub = rospy.Publisher('example_picam_photo', picam_photo, queue_size=100, latch=staLatch)

    return pub

###############################################################################
#
def pub_photo(pub, file_photo):

    #
    pub_rate = rospy.Rate(5)

    #
    msg = picam_photo()

    #
    print("[INFO] reading... " + file_photo)
    photo_cv2 = cv2.imread(file_photo, cv2.IMREAD_COLOR)

    #
    msg.timestamp = rospy.Time.now()

    #
    msg.edge_id = MyNodeName

    #
    msg.picam_photo = GV_cv_bridge.cv2_to_imgmsg(photo_cv2)

    #
    pub.publish(msg)
    pub_rate.sleep()

###############################################################################
#
if (__name__ == '__main__'):

    #
    arg_prs = argparse.ArgumentParser()
    arg_prs.add_argument('file_photo', type=str, nargs='+')
    arg_prs.add_argument("--node_name", type=str)

    args = arg_prs.parse_args()
    if (args.node_name and args.node_name != ""):
        MyNodeName = args.node_name
    print("[INFO] NodeName is '%s'" % MyNodeName)

    pub = create_pub(MyNodeName)
    for file in args.file_photo:
        pub_photo(pub, file)

###############################################################################
# [SETUP raspberry pi]
# * Camera
# ** Enable
#   $ sudo raspi-config nonint do_camera 0
# ** Disable
#   $ sudo raspi-config nonint do_camera 1
#
# **
#   $ raspistill -w 1920 -h 1080 -o filename.jpg
#
###############################################################################

# eof
