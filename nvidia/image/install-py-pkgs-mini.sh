#!/bin/bash



set -e

if (( $# != 1 )); then
    echo "Illegal number of parameters"
fi


if [ $1 == "gpu" ]; then 
# ==================================================================
# conda package install
# ------------------------------------------------------------------
    echo "start to install GPU related pkgs"
#    ln -s /usr/local/cuda-9.0/lib64/libcurand.so.9.0 /usr/local/cuda-9.0/lib64/libcurand.so.8.0

    conda install --yes --quiet  \
        pytorch==0.4.0 \        
        tensorflow-gpu==1.9.0 \
        tensorboard==1.9.0 \
        keras==2.2.4 \
    && \
    conda clean -tipsy 

elif [ $1 == "cpu" ]; then 
# ==================================================================
# conda package install
# ------------------------------------------------------------------
    conda install --yes --quiet  \
        pytorch==0.4.0 \
        tensorflow==1.9.0 \
        tensorboard==1.9.0 \
        keras==2.2.4 \
    && \
    conda clean -tipsy



else
  echo "Illegal parameter... the parameter is cpu or gpu"
fi

