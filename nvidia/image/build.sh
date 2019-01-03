#!/bin/bash

set -e



usage() { echo "Usage: $0 [-v image version] [-t <cpu/gpu/all> (default: all)]" 1>&2; exit 1; }

TYPE="all"
while getopts ":v:t:" flag; do
    case "${flag}" in
        v)
            VERSION=${OPTARG}
            ;;            
        t)
            TYPE=${OPTARG}
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

echo "VERSION = ${VERSION}"
echo "TYPE = ${TYPE}"

if [ "${TYPE}" == "cpu" -o "${TYPE}" == "all" ]; then
sudo docker build -t shcardbdp/dl-base-cpu:${VERSION} -f Dockerfile.dl-base --build-arg DEVICE_TYPE=cpu --build-arg VERSION=${VERSION} .  && \
sudo docker build -t shcardbdp/mlbasic-lab-cpu:${VERSION} -f Dockerfile.mlbasic-lab --build-arg DEVICE_TYPE=cpu --build-arg VERSION=${VERSION} . && \
sudo docker build -t shcardbdp/bdtf-lab-cpu:${VERSION} -f Dockerfile.bdtf-lab --build-arg DEVICE_TYPE=cpu --build-arg VERSION=${VERSION} . && \
sudo docker build -t shcardbdp/dl-lab-cpu:${VERSION} -f Dockerfile.dl-lab --build-arg ROOT_IMAGE=ufoym/deepo:all-py36-jupyter-cpu --build-arg VERSION=${VERSION} . && \
sudo docker build -t shcardbdp/spark-lab-cpu:${VERSION} -f Dockerfile.spark-lab --build-arg VERSION=${VERSION} . && \
sudo docker build -t shcardbdp/r-lab-cpu:${VERSION} -f Dockerfile.r-lab  --build-arg VERSION=${VERSION} . && \
sudo docker build -t shcardbdp/mllight-lab-cpu:${VERSION} -f Dockerfile.mllight-lab --build-arg DEVICE_TYPE=cpu --build-arg VERSION=${VERSION} .
fi



if [ "${TYPE}" == "gpu" -o "${TYPE}" == "all" ]; then
sudo docker build -t shcardbdp/dl-base-gpu:${VERSION} -f Dockerfile.dl-base --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${VERSION} . && \
sudo docker build -t shcardbdp/mlbasic-lab-gpu:${VERSION} -f Dockerfile.mlbasic-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${VERSION} .  && \
sudo docker build -t shcardbdp/bdtf-lab-gpu:${VERSION} -f Dockerfile.bdtf-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${VERSION} .  && \
sudo docker build -t shcardbdp/dl-lab-gpu:${VERSION} -f Dockerfile.dl-lab --build-arg VERSION=${VERSION} . && \
sudo docker build -t shcardbdp/mllight-lab-gpu:${VERSION} -f Dockerfile.mllight-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${VERSION} .
fi