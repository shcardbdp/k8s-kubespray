#!/bin/bash

set -e



usage() { echo "Usage: $0 [-v image version]" 1>&2; exit 1; }

while getopts ":v:" flag; do
    case "${flag}" in
        v)
            VERSION=${OPTARG}
            ;;            
        *)
            echo "invalid args..."
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${VERSION}" ]; then
    usage
fi

echo "VERSION = ${v}"


sudo docker build -t sorididim11/dl-base-cpu:{VERSION} -f Dockerfile.dl-base --build-arg ROOT_IMAGE=ubuntu:16.04  .  && \
sudo docker build -t sorididim11/ac52-lab-cpu:{VERSION} -f Dockerfile.ac52-lab --build-arg DEVICE_TYPE=cpu . && \
sudo docker build -t sorididim11/hobby-lab-cpu:{VERSION} -f Dockerfile.hobby-lab --build-arg DEVICE_TYPE=cpu . && \
sudo docker build -t sorididim11/dev-lab-cpu:{VERSION} -f Dockerfile.dev-all --build-arg ROOT_IMAGE=ufoym/deepo:all-py36-jupyter-cpu . && \
sudo docker build -t sorididim11/spark-lab-cpu:{VERSION} -f Dockerfile.spark-lab . && \
sudo docker build -t sorididim11/r-lab-cpu:{VERSION} -f Dockerfile.r-lab  .



# GPU 
sudo docker build -t sorididim11/dl-base-gpu:{VERSION} -f Dockerfile.dl-base   . && \
sudo docker build -t sorididim11/ac52-lab-gpu:{VERSION} -f Dockerfile.ac52-lab --build-arg DEVICE_TYPE=gpu .  && \
sudo docker build -t sorididim11/hobby-lab-gpu:{VERSION} -f Dockerfile.hobby-lab --build-arg DEVICE_TYPE=gpu .  && \
sudo docker build -t sorididim11/dev-lab-gpu:{VERSION} -f Dockerfile.dev-all .