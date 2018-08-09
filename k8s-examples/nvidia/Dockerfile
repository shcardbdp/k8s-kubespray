# ==================================================================
# module list
# ------------------------------------------------------------------
# anaconda3     5.2.0
# python        3.6    
# ==================================================================

FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=/opt/conda/bin:$PATH
# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion \
    libfreetype6-dev libhdf5-serial-dev libpng12-dev libzmq3-dev pkg-config \
    rsync software-properties-common unzip 


# anaconda3 install
COPY Anaconda3-5.2.0-Linux-x86_64.sh /data/Anaconda3-5.2.0-Linux-x86_64.sh
RUN bash /data/Anaconda3-5.2.0-Linux-x86_64.sh -b -p /opt/conda && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    rm -rf /data/Anaconda3-5.2.0-Linux-x86_64.sh

#downgrade? pandas(0.22), current(0.23.4)
#downgrade? matplotlib(2.2.0), current(2.2.2)
#downgrade? beautifulsoup4(4.4.0), current(4.6.0)
#downgrade? notebook(5.3.0), notebook(5.5.0)
# conda opencv(3.4.2), current(3.4.1)
# ==================================================================
# conda package install
# ------------------------------------------------------------------
COPY conda-requirements.txt /data/conda-requirements.txt
RUN conda install -y --file /data/conda-requirements.txt

# ==================================================================
# conda package install
# ------------------------------------------------------------------
COPY requirements.txt /data/requirements.txt
RUN pip install --upgrade pip && pip install -r /data/requirements.txt

# ==================================================================
# Mini install to protect form zombie process
# ------------------------------------------------------------------
RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean



# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/
COPY notebooks /notebooks
COPY run_jupyter.sh /

EXPOSE 8888 6006

WORKDIR "/notebooks"

CMD [ "/run_jupyter.sh", "--no-browser", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token="]
