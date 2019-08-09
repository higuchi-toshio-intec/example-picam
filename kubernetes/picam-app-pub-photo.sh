#!/bin/bash

#
if [ "${HOCKERHUB_ACCOUNT}" = "" ] ; then
    echo "[ERROR]Please set environment variable 'HOCKERHUB_ACCOUNT'"
    exit
fi

#
cat << EoYaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: picam-deploy-pub-photo
  labels:
    app: ros
anchors:
  - var_path_vchiq: &var_path_vchiq "/dev/vchiq"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ros
  template:
    metadata:
      labels:
        app: ros

    spec:
      volumes:
        - name: picam-dev-photo
          hostPath:
             path: *var_path_vchiq
      containers:

#
      - name: roscore
        image: ros:kinetic-ros-base
        tty: true
        args:
        - roscore
        env:
        - name: ROS_HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: ROS_MASTER_URI
          value: "http://\$(ROS_HOSTNAME):11311"

#
      - name: multimaster-fkie-discovery
        image: rdbox/arm.multimaster_fkie:kinetic
        tty: true
        args:
        - roslaunch
        - --screen
        - --wait
        - multimaster_fkie_launch
        - master_discovery_fkie.launch
        env:
        - name: ROS_HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: ROS_MASTER_URI
          value: "http://\$(ROS_HOSTNAME):11311"

#
      - name: multimaster-fkie-sync
        image: rdbox/arm.multimaster_fkie:kinetic
        tty: true
        args:
        - roslaunch
        - --screen
        - --wait
        - multimaster_fkie_launch
        - master_sync_fkie.launch
        env:
        - name: ROS_HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: ROS_MASTER_URI
          value: "http://\$(ROS_HOSTNAME):11311"

#
      - name: picam-app-pub-photo
        image: ${HOCKERHUB_ACCOUNT}/picam_pub_photo
        volumeMounts:
        - mountPath: *var_path_vchiq
          name: picam-dev-photo
        securityContext:
          privileged: true
        tty: true
        stdin: true
        args:
        - /bin/bash
        env:
        - name: ROS_HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: ROS_MASTER_URI
          value: "http://\$(ROS_HOSTNAME):11311"
        - name: PICAM_START
          value: auto

#
      hostNetwork: true
      nodeSelector:
        node.rdbox.com/type: picam

EoYaml
#
