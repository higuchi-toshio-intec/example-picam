#!/bin/bash

#
if [ "${PICAM_PORT}" = "" ] ; then
    echo "[ERROR]Please set environment variable 'PICAM_PORT'"
    exit
fi

#
cat << EoYaml
apiVersion: v1
kind: Service
anchors:
  - var_flask_port: &var_flask_port ${PICAM_PORT}
metadata:
  name: picam-service-flask
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: *var_flask_port
      nodePort: 30080
  selector:
    app-picam: picam-app-sub-photo

EoYaml
