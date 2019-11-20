#!/bin/bash

set -e

# usage() { echo "Usage: $0 [-v image version] [-t <cpu/gpu/all> (default: all)]" 1>&2; exit 1; }
usage() { echo "Usage: $0 [-h help] [-s build scope (a[ll], a[ll] u[se], b[ase], sp[ark], t[ext])]" 1>&2; exit 1; }

echo "Declare Version"

# image version
DATALAB_BASE_VERSION="1.0.5"
SPARK_VERSION="2.0.9"
TEXT_VERSION="1.0.7"
R_VERSION="2.0.8"
TF2_VERSION="1.0.2"

echo "Assign Scope"

# TYPE="all"
while getopts ":s:h:" flag; do
    case "${flag}" in
        s)
            SCOPE=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            echo "invalid args..."
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${DATALAB_BASE_VERSION}" ]; then
    echo "DATALAB_BASE_VERSION is not assigned"
    usage
fi

if [ -z "${SCOPE}" ]; then
    usage
fi

echo "DATALAB_BASE_VERSION = ${DATALAB_BASE_VERSION}"
echo "SPARK_VERSION = ${SPARK_VERSION}"
echo "TEXT_VERSION = ${TEXT_VERSION}"
echo "R_VERSION = ${R_VERSION}"
echo "TF2_VERSION = ${TF2_VERSION}"

if [ "${SCOPE}" == "a" ]; then
sudo docker build -t shcardbdp/datalab-base-gpu:${DATALAB_BASE_VERSION} -f Dockerfile.dl-base2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${DATALAB_BASE_VERSION} . && \
sudo docker build -t shcardbdp/spark-notebook:${SPARK_VERSION} -f Dockerfile.spark-notebook2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${SPARK_VERSION} --build-arg BASE_VERSION=${DATALAB_BASE_VERSION} . && \
sudo docker build -t shcardbdp/text-notebook:${TEXT_VERSION} -f Dockerfile.text-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TEXT_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} . && \
sudo docker build -t shcardbdp/r-notebook:${R_VERSION} -f Dockerfile.r-notebook2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${R_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} .
fi

echo "1"

if [ "${SCOPE}" == "au" ]; then
sudo docker build -t shcardbdp/spark-notebook:${SPARK_VERSION} -f Dockerfile.spark-notebook2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${SPARK_VERSION} --build-arg BASE_VERSION=${DATALAB_BASE_VERSION} . && \
sudo docker build -t shcardbdp/text-notebook:${TEXT_VERSION} -f Dockerfile.text-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TEXT_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} . && \
sudo docker build -t shcardbdp/r-notebook:${R_VERSION} -f Dockerfile.r-notebook2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${R_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} .
fi

echo "2"

if [ "${SCOPE}" == "b" ]; then
sudo docker build -t shcardbdp/datalab-base-gpu:${DATALAB_BASE_VERSION} -f Dockerfile.dl-base2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${DATALAB_BASE_VERSION} .
fi

echo "3"

if [ "${SCOPE}" == "sp" ]; then
sudo docker build -t shcardbdp/spark-notebook:${SPARK_VERSION} -f Dockerfile.spark-notebook2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${SPARK_VERSION} --build-arg BASE_VERSION=${DATALAB_BASE_VERSION} .
fi

echo "4"

if [ "${SCOPE}" == "t" ]; then
sudo docker build -t shcardbdp/text-notebook:${TEXT_VERSION} -f Dockerfile.text-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TEXT_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} .
fi

echo "5"

if [ "${SCOPE}" == "r" ]; then
sudo docker build -t shcardbdp/r-notebook:${R_VERSION} -f Dockerfile.r-notebook2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${R_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} .
fi

echo "6"

if [ "${SCOPE}" == "tf" ]; then
sudo docker build -t shcardbdp/text-notebook.tf2:${TF2_VERSION} -f Dockerfile.text-notebook.t2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TF2_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} .
fi
