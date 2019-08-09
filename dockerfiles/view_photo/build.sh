#!/bin/bash

#
apt update
apt upgrade -y -q
apt install -y -q --no-install-recommends ca-certificates
apt install -y -q --no-install-recommends git python-flask
apt install -y -q --no-install-recommends libopencv-dev python-opencv python-cv-bridge
apt clean
rm -rf /var/lib/apt/lists/*

#
mkdir -p ${HOME}/git
cd ${HOME}/git
git clone https://github.com/higuchi-toshio-intec/example-picam.git
cd example-picam
if [ "${PICAM_GIT_BRANCH}" != "master" ] ; then
    echo "[INFO] checkout '${PICAM_GIT_BRANCH}' branch"
    git checkout ${PICAM_GIT_BRANCH}
fi

#
