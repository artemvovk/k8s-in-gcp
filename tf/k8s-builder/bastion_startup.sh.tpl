#!/bin/bash
yum update -y -q && \
    yum install -y -q \
    ansible \
    device-mapper-persistent-data \
    epel-release \
    yum-utils

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

python get-pip.py

pip install \
    google-auth \
    requests

mkdir -p /home/artem/.config/gcloud
chown -R artem /home/artem/
