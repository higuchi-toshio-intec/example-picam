#!/bin/bash

if [ "${HOCKERHUB_ACCOUNT}" = "" ] ; then
    echo "[ERROR] Environment variable 'HOCKERHUB_ACCOUNT' is blank."
    exit
fi

BUILD_OPTS="--no-cache --build-arg PICAM_GIT_BRANCH=${PICAM_GIT_BRANCH}"

echo "[INFO] Build docker image for 'picam_pub_photo'"
cd pub_photo
sudo docker build -t "${HOCKERHUB_ACCOUNT}/picam_pub_photo" ${BUILD_OPTS} .
sudo docker push "${HOCKERHUB_ACCOUNT}/picam_pub_photo"
cd ..

echo "[INFO] Build docker image for 'picam_sub_photo'"
cd sub_photo
sudo docker build -t "${HOCKERHUB_ACCOUNT}/picam_sub_photo" ${BUILD_OPTS} .
sudo docker push "${HOCKERHUB_ACCOUNT}/picam_sub_photo"
cd ..

echo "[INFO] Build docker image for 'picam_view_photo'"
cd view_photo
sudo docker build -t "${HOCKERHUB_ACCOUNT}/picam_view_photo" ${BUILD_OPTS} .
sudo docker push "${HOCKERHUB_ACCOUNT}/picam_view_photo"
cd ..
