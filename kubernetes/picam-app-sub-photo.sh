#!/bin/bash

#
if [ "${HOCKERHUB_ACCOUNT}" = "" ] ; then
    echo "[ERROR]Please set environment variable 'HOCKERHUB_ACCOUNT'"
    exit
fi

#
if [ "${PICAM_DATA}" = "" ] ; then
    echo "[ERROR]Please set environment variable 'PICAM_DATA'"
    exit
fi

#
if [ "${PICAM_PORT}" = "" ] ; then
    echo "[ERROR]Please set environment variable 'PICAM_PORT'"
    exit
fi

#
cat << EoYaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: picam-deploy-sub-photo
  labels:
    app: ros
anchors:
  - var_path_data: &var_path_data "${PICAM_DATA}"
  - var_flask_port_int: &var_flask_port_int  ${PICAM_PORT}
  - var_flask_port_str: &var_flask_port_str "${PICAM_PORT}"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ros
  template:
    metadata:
      labels:
        app: ros
        app-picam: picam-app-sub-photo

    spec:
      volumes:
        - name: picam-data
          hostPath:
             path: *var_path_data
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
        image: rdbox/amd64.multimaster_fkie:kinetic
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
        image: rdbox/amd64.multimaster_fkie:kinetic
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
      - name: picam-app-sub-photo
        image: ${HOCKERHUB_ACCOUNT}/picam_sub_photo
        volumeMounts:
        - mountPath: *var_path_data
          name: picam-data
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
        - name: PICAM_DATA
          value: *var_path_data

#
      - name: picam-app-view-photo
        image: ${HOCKERHUB_ACCOUNT}/picam_view_photo
        ports:
        - containerPort: *var_flask_port_int
          protocol: TCP
        volumeMounts:
        - mountPath: *var_path_data
          name: picam-data
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
        - name: PICAM_DATA
          value: *var_path_data
        - name: PICAM_PORT
          value: *var_flask_port_str

#
      hostNetwork: true
      nodeSelector:
        node.rdbox.com/type: picam-data

EoYaml
