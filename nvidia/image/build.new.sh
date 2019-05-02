#!/bin/bash

set -e

# usage() { echo "Usage: $0 [-v image version] [-t <cpu/gpu/all> (default: all)]" 1>&2; exit 1; }
usage() { echo "Usage: $0 [-b base image version (defaul DL_BASE_VERSION)] [-s build scope (all, ml, sp, r, mt, 2, 3)]" 1>&2; exit 1; }

# image version
DL_BASE_VERSION="1.0.2"
MLLIGHT_VERSION="1.0.8"
SPARK_VERSION="1.0.1"
R_VERSION="1.0.1"
TEXT_VERSION="1.0.2"
VERSION=${DL_BASE_VERSION}

# TYPE="all"
while getopts ":b:s:" flag; do
    case "${flag}" in
        b)
            VERSION=${OPTARG}
            ;;            
        s)
            SCOPE=${OPTARG}
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

echo "BASE_VERSION = ${VERSION}"
echo "DL_BASE_VERSION = ${DL_BASE_VERSION}"
echo "MLLIGHT_VERSION = ${MLLIGHT_VERSION}"
echo "SPARK_VERSION = ${SPARK_VERSION}"
echo "R_VERSION = ${R_VERSION}"
echo "TEXT_VERSION = ${TEXT_VERSION}"

if [ "${SCOPE}" == "all" ]; then
sudo docker build -t shcardbdp/dl-base-gpu:${DL_BASE_VERSION} -f Dockerfile.dl-base --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${DL_BASE_VERSION} . && \
sudo docker build -t shcardbdp/mllight-lab-gpu:${MLLIGHT_VERSION} -f Dockerfile.mllight-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${MLLIGHT_VERSION} --build-arg BASE_VERSION=${VERSION} . && \
sudo docker build -t shcardbdp/spark-notebook:${SPARK_VERSION} -f Dockerfile.spark-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${SPARK_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} . && \
sudo docker build -t shcardbdp/r-notebook:${R_VERSION} -f Dockerfile.r-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${R_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} . && \
sudo docker build -t shcardbdp/mllight-text-lab:${TEXT_VERSION} -f Dockerfile.mllight-text-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TEXT_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} .
fi

if [ "${SCOPE}" == "2" ]; then
sudo docker build -t shcardbdp/mllight-lab-gpu:${MLLIGHT_VERSION} -f Dockerfile.mllight-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${MLLIGHT_VERSION} --build-arg BASE_VERSION=${VERSION} .
fi

if [ "${SCOPE}" == "3" ]; then
sudo docker build -t shcardbdp/spark-notebook:${SPARK_VERSION} -f Dockerfile.spark-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${SPARK_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} .
sudo docker build -t shcardbdp/r-notebook:${R_VERSION} -f Dockerfile.r-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${R_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} .
sudo docker build -t shcardbdp/mllight-text-lab:${TEXT_VERSION} -f Dockerfile.mllight-text-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TEXT_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} .
fi

if [ "${SCOPE}" == "ml" ]; then
sudo docker build -t shcardbdp/mllight-lab-gpu:${MLLIGHT_VERSION} -f Dockerfile.mllight-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${MLLIGHT_VERSION} --build-arg BASE_VERSION=${VERSION} .
fi

if [ "${SCOPE}" == "sp" ]; then
sudo docker build -t shcardbdp/spark-notebook:${SPARK_VERSION} -f Dockerfile.spark-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${SPARK_VERSION} --build-arg BASE_VERSION=${VERSION} .
fi

if [ "${SCOPE}" == "r" ]; then
sudo docker build -t shcardbdp/r-notebook:${R_VERSION} -f Dockerfile.r-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${R_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} .
fi

if [ "${SCOPE}" == "mt" ]; then
sudo docker build -t shcardbdp/mllight-text-lab:${TEXT_VERSION} -f Dockerfile.mllight-text-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TEXT_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} .
fi