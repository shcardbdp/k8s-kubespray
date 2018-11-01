#!/bin/bash


set -e

if (( $# != 1 )); then
    echo "Illegal number of parameters"
fi


if (( $1 == "gpu" )); then

