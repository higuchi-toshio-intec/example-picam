#!/bin/bash

if [ "${PICAM_DATA}" = "" ] ; then
    export PICAM_DATA=/opt/picam_data
fi

if [ "${PICAM_PORT}" = "" ] ; then
    export PICAM_PORT=8080
fi

#
cd app
python picam_viewer.py

#
