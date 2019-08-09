#!/bin/bash

echo "[INFO] Build docker image for 'ros-raspbian'"
cd ros-raspbian
sudo docker build -t "ros-raspbian" .
cd ..

