#!/bin/bash

set -e

# usage() { echo "Usage: $0 [-v image version] [-t <cpu/gpu/all> (default: all)]" 1>&2; exit 1; }
usage() { echo "Usage: $0 [-h help] [-s build scope (a[ll], b[ase])]" 1>&2; exit 1; }

# image version
DATALAB_BASE_VERSION="1.0.1"
# SPARK_VERSION="1.0.10"
# R_VERSION="1.0.3"
# TEXT_VERSION="1.0.14"

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
# echo "SPARK_VERSION = ${SPARK_VERSION}"
# echo "R_VERSION = ${R_VERSION}"
# echo "TEXT_VERSION = ${TEXT_VERSION}"

if [ "${SCOPE}" == "a" ]; then
sudo docker build -t shcardbdp/datalab-base-gpu:${DATALAB_BASE_VERSION} -f Dockerfile.dl-base2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${DATALAB_BASE_VERSION} .
fi

if [ "${SCOPE}" == "b" ]; then
sudo docker build -t shcardbdp/datalab-base-gpu:${DATALAB_BASE_VERSION} -f Dockerfile.dl-base2 --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${DATALAB_BASE_VERSION} .
fi



# if [ "${SCOPE}" == "4" ]; then
# sudo docker build -t shcardbdp/r-notebook:${R_VERSION} -f Dockerfile.r-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${R_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} . && \
# sudo docker build -t shcardbdp/mllight-text-lab:${TEXT_VERSION} -f Dockerfile.mllight-text-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TEXT_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} .
# fi

# if [ "${SCOPE}" == "ml" ]; then
# sudo docker build -t shcardbdp/mllight-lab-gpu:${MLLIGHT_VERSION} -f Dockerfile.mllight-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${MLLIGHT_VERSION} --build-arg BASE_VERSION=${VERSION} .
# fi

# if [ "${SCOPE}" == "sp" ]; then
# sudo docker build -t shcardbdp/spark-notebook:${SPARK_VERSION} -f Dockerfile.spark-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${SPARK_VERSION} --build-arg BASE_VERSION=${MLLIGHT_VERSION} .
# fi

# if [ "${SCOPE}" == "r" ]; then
# sudo docker build -t shcardbdp/r-notebook:${R_VERSION} -f Dockerfile.r-notebook --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${R_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} .
# fi

# if [ "${SCOPE}" == "mt" ]; then
# sudo docker build -t shcardbdp/mllight-text-lab:${TEXT_VERSION} -f Dockerfile.mllight-text-lab --build-arg DEVICE_TYPE=gpu --build-arg VERSION=${TEXT_VERSION} --build-arg BASE_VERSION=${SPARK_VERSION} .
# fi
