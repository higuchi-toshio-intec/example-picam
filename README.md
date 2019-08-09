# example-picam

1. pre-setup
   1. You finished to setup RDBOX(RDBOX-HQ, RDBOX and ROBOT with pi-camera)
   1. Labeled on your raspberry pi with pi-camera
      ```
      # e.g. hostname is 'PICAM01'
      $ sudo kubectl --kubeconfig /etc/kubernetes/admin.conf label node PICAM01 node.rdbox.com/type=picam
      ```
   1. Labele and make a photo directory on your k8s node
      ```
      # e.g. hostname is 'NODE01'
      $ sudo kubectl --kubeconfig /etc/kubernetes/admin.conf label node NODE01 node.rdbox.com/type=picam-data
      $ ssh -i YourKeyFile ubuntu@NODE01 sudo bash -c "mkdir -p /opt/picam_data/photo & chmod 777 /opt/picam_data/photo"
      ```
   1. You finished to setup cross-build environment.
      See. https://github.com/rdbox-intec/rdbox/wiki/tutorials-en#tutorials

1. Login to docker hub.
Set a environment variable 'HOCKERHUB_ACCOUNT' and login. This environment variable will be used later.
```
$ export HOCKERHUB_ACCOUNT="YourDockerHubAccount"
$ sudo docker login --username "${HOCKERHUB_ACCOUNT}"
```

1. Clone a repository from github.
```
$ mkdir -p ${HOME}/git
$ cd ${HOME}/git
$ git clone https://github.com/higuchi-toshio-intec/example-picam
```

1. Build some docker images and push.
```
$ cd ${HOME}/git/example-picam/dockerfiles
$ cd ros-raspbian
$ sudo docker build -t "ros-raspbian" .

$ cd ../pub_photo
$ sudo docker build -t "${HOCKERHUB_ACCOUNT}/picam_pub_photo" .
$ sudo docker push "${HOCKERHUB_ACCOUNT}/picam_pub_photo"

$ cd ../sub_photo
$ sudo docker build -t "${HOCKERHUB_ACCOUNT}/picam_sub_photo" .
$ sudo docker push "${HOCKERHUB_ACCOUNT}/picam_sub_photo"

$ cd ../view_photo
$ sudo docker build -t "${HOCKERHUB_ACCOUNT}/picam_view_photo" .
$ sudo docker push "${HOCKERHUB_ACCOUNT}/picam_view_photo"

```

1. Login Kubernetes Dashboard on your RDBOX
   1. Create some YAML files for kubernetes resources.
      - ${HOME}/git/example-picam/kubernetes/picam-service-flask.sh
      - ${HOME}/git/example-picam/kubernetes/picam-app-pub-photo.sh
      - ${HOME}/git/example-picam/kubernetes/picam-app-sub-photo.sh
   1. Create a resource for service.
   1. Create a resource for photo publisher.
   1. Create a resource for photo subscriber and viewer.

