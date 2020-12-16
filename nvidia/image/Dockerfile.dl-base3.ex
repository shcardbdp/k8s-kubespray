# shinhan-os:cpu - ubuntu:16.04
# shinhan-os:gpu - nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04 # docker pull nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04

ARG DEVICE_TYPE=gpu
ARG VERSION

FROM shcardbdp/shinhan-os:$DEVICE_TYPE

ARG DEVICE_TYPE
ARG VERSION
LABEL version=$VERSION device_type=$DEVICE_TYPE

USER root
# ==================================================================
# base tools/libs
# ------------------------------------------------------------------
RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/g' /etc/apt/sources.list && \
    APT_INSTALL="apt-get install -y --no-install-recommends" && \
    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \
    sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \
    apt-get update && \
# ==================================================================
# tools
# ------------------------------------------------------------------
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        ca-certificates \
        cmake \
        unzip grep sed dpkg bzip2 rsync \
        zip \
        libglib2.0-0 libxext6 libsm6 libxrender1 \
        libfreetype6-dev libhdf5-serial-dev libpng12-dev libzmq3-dev pkg-config \
        curl \
        wget \
        git \
        vim \
        build-essential \
        unixodbc \
        unixodbc-dev \
        libsasl2-dev \
        alien \
        libaio1 \
        libaio-dev \
        default-jdk \ 
        sudo \
        locales \
        net-tools \
        telnet \
        convmv \
            && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN  TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

# ==================================================================
# Connector base
# ------------------------------------------------------------------
# ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
#     ORACLE_HOME=/usr/lib/oracle/12.2/client64  

# ENV SHELL=/bin/bash \
#     PATH=$JAVA_HOME/bin:$ORACLE_HOME/bin:$PATH \
#     LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$ORACLE_HOME/lib:/home/jovyan/notebooks/src/shcPython/wisenut \
#     LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libodbcinst.so 

# COPY odbcinst.ini /etc/odbcinst.ini
# COPY odbc.ini /etc/odbc.ini
# COPY cloudera/ /data/
# COPY connector/datalake.properties /etc/datalake/datalake.properties
# COPY oracle/ /data/
# COPY oracle/tnsnames.ora $ORACLE_HOME/network/admin/
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    SHELL=/bin/bash \
    PATH=$JAVA_HOME/bin:$PATH \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libodbcinst.so 

COPY connector/datalake.properties /etc/datalake/datalake.properties

# # ==================================================================
# # cloudera hive/impala - odbc/jdbc
# # ------------------------------------------------------------------
# RUN apt-get install -y -f --no-install-recommends /data/clouderahiveodbc_2.5.25.1020-2_amd64.deb && \
#     apt-get install -y -f --no-install-recommends /data/clouderaimpalaodbc_2.5.42.1031-2_amd64.deb && \
#     rm -rf /opt/cloudera/hiveodbc/lib/64/cloudera.*.ini && \    
#     rm -rf /opt/cloudera/impalaodbc/lib/64/cloudera.*.ini && \    
#     cp /data/cloudera.*.ini /etc/ && \
#     cp /data/HiveJDBC41.jar /data/ImpalaJDBC41.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext
# # ==================================================================
# # Oracle sqlplus, odbc/jdbc
# # ------------------------------------------------------------------
# RUN alien -i /data/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm && \
#     alien -i /data/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm && \
#     alien -i /data/oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm && \
#     alien -i /data/oracle-instantclient12.2-odbc-12.2.0.1.0-2.x86_64.rpm && \
#     alien -i /data/oracle-instantclient12.2-jdbc-12.2.0.1.0-1.x86_64.rpm && \
#     cp /usr/lib/oracle/12.2/client64/lib/ojdbc8.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext

# ==================================================================
# Hive JDBC CLI client
# ------------------------------------------------------------------
RUN chmod -R 777 /etc/datalake

# ==================================================================
# User, Home, UID/GID
# ------------------------------------------------------------------
ADD fix-permissions /usr/local/bin/fix-permissions

ENV CONDA_DIR=/opt/conda \    
    NB_USER=jovyan \
    HOME=/home/jovyan \
    NB_UID=1000 \
    NB_GID=100 

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group && \
    rm -rf /home/$NB_USER/.rpmdb && \
    fix-permissions $CONDA_DIR  && \
    fix-permissions $HOME

# Configure environment
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    PATH=$CONDA_DIR/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Setup work directory for backward-compatibility
USER $NB_UID

RUN mkdir /home/$NB_USER/notebooks && \
    cp $ORACLE_HOME/network/admin/tnsnames.ora /home/$NB_USER/.tnsnames.ora && \
    cp /etc/odbc.ini /home/$NB_USER/.odbc.ini && \
    echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> /home/$NB_USER/.bashrc && \
    echo "export PATH=$PATH" >> /home/$NB_USER/.bashrc && \
    fix-permissions /home/$NB_USER 

# Install conda as jovyan and check the md5 sum provided on the download site
ENV MINICONDA_VERSION 4.3.30
LABEL MINICONDA=$MINICONDA_VERSION
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "0b80a152332a4ce5250f3c09589c7a81 *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    conda clean -tipsy && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# ADD connector/dbi.py /opt/conda/lib/python3.6/site-packages/shcard/    

# Install Jupyter Notebook and Hub
RUN conda install --quiet --yes \
        python==3.6.11 \
        jupyter \
        notebook==6.1.5 \    
        jupyterlab==2.2.9 \        
    && conda clean -afy && \    
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete

# ==================================================================
# Spark Setting
# ------------------------------------------------------------------
USER root

# # Spark dependencies
# ENV APACHE_SPARK_VERSION=2.4.4 \
#     HADOOP_VERSION=2.7

# # install automake 1.11 for mecab dictionary
# RUN apt-get update && \
#     apt-get install --no-install-recommends -y \
#             openjdk-8-jre-headless \
#             ca-certificates-java \
#             automake1.11 && \ 
#     rm -rf /var/lib/apt/lists/*

# RUN cd /tmp && \
#     wget -q https://archive.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
#     echo "2E3A5C853B9F28C7D4525C0ADCB0D971B73AD47D5CCE138C85335B9F53A6519540D3923CB0B5CEE41E386E49AE8A409A51AB7194BA11A254E037A848D0C4A9E5 *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
#     tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local --owner root --group root --no-same-owner && \
#     rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
# RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

# # Spark and Mesos config
# ENV SPARK_HOME=/usr/local/spark \
#     PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:/home/$NB_USER/notebooks/src/shcPython/common:/shc_pkg/wisenut \
#     # PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:/home/$NB_USER/notebooks/src/shcPython-prd:/home/$NB_USER/notebooks/src/shcPython/wisenut \
#     SPARK_OPTS=--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

# # ==================================================================
# # mecab analyzer from bitbucket
# # ------------------------------------------------------------------
# RUN wget --quiet http://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz -O mecab.tar.gz && \
#     tar -zxf mecab.tar.gz && \
#     cd mecab-0.996-ko-0.9.2 && \
#     ./configure && \
#     make && \ 
#     make check && \
#     make install && \
#     ldconfig && \
#     rm -rf ../mecab.tar.gz ../mecab-0.996-ko-0.9.2

# # ==================================================================
# # mecab dictionary from bitbucket 
# # ------------------------------------------------------------------
# RUN cd ~ && \
#     wget --quiet http://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.1.1-20180720.tar.gz -O mecab-dic.tar.gz && \
#     tar -zxf mecab-dic.tar.gz && \
#     chown -R root:root mecab-ko-dic-2.1.1-20180720 && \ 
#     cd mecab-ko-dic-2.1.1-20180720 && \
#     ./autogen.sh  && \
#     ./configure && \
#     make && \
#     make check && \
#     make install && \
#     ldconfig && \
#     rm -rf ../mecab-dic.tar.gz && \
#     mv ~/mecab-ko-dic-2.1.1-20180720/ ~/.mecab-ko-dic-2.1.1-20180720/

WORKDIR /home/$NB_USER
COPY entrypoint_spark.sh /usr/local/bin/

RUN  if [ "$DEVICE_TYPE" = "gpu" ] ; then ln -s /usr/local/cuda-9.2/lib64/libcurand.so.9.2 /usr/local/cuda-9.2/lib64/libcurand.so.8.0 ; fi
# Set up our notebook config.
COPY  jupyter/spark/jupyter_notebook_config.py /etc/jupyter/
COPY  run_jupyter.sh /usr/local/bin/
RUN rm -rf /home/$NB_USER/work && \
    fix-permissions /etc/jupyter/

EXPOSE 8888 6006

ENTRYPOINT [ "/usr/bin/tini", "--", "entrypoint_spark.sh"]
CMD [ "/usr/local/bin/run_jupyter.sh", "--no-browser", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token="]

# Add fonts for NHN fonts
COPY fonts/ /usr/share/fonts/

USER $NB_UID
