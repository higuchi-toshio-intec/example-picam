#!/usr/bin/python
# -*- coding: utf-8 -*-

import argparse
import cv2
import cv_bridge
from datetime import datetime
import numpy
import os
import rospy
import subprocess
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
    pub_rate = rospy.Rate(30)

    #
    msg = picam_photo()

    #
    print("[INFO] reading... " + file_photo)
    photo_cv2 = cv2.imread(file_photo, cv2.IMREAD_COLOR)

    #
    msg.timestamp = rospy.Time.now()
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
    arg_prs.add_argument("--node_name", type=str)
    arg_prs.add_argument("--interval", type=int, default=20)
    arg_prs.add_argument("--w", type=int, default=640)
    arg_prs.add_argument("--h", type=int, default=480)

    args = arg_prs.parse_args()
    if (args.node_name and args.node_name != ""):
        MyNodeName = args.node_name
    print("[INFO] NodeName is '%s'" % MyNodeName)

    #
    interval = args.interval
    if (interval < 5):
        interval = 5
    elif (30 < interval):
        interval = 30

    #
    count = int(60 / interval)
    if (count < 1):
        count = 1

    #
    pub = create_pub(MyNodeName)

    #
    dir_tmp = "/tmp"
    for i in range(count):
        today = datetime.today()
        yyyymmddhhmmss = datetime.today()

        #
        filename = "%s/photo-%s.jpeg" % (dir_tmp, today.strftime("%Y%m%dT%H%M%S"), )
        cmd = "raspistill -w %d -h %d -o %s" % (args.w, args.h, filename)
        subprocess.call(cmd, shell=True)

        #
        pub_photo(pub, filename)
        os.unlink(filename)

#        if (i == count - 1):
#            break

        #
        d = (datetime.today() - today).seconds
        t = interval - d
        if (0 < t):
            time.sleep(t)

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
