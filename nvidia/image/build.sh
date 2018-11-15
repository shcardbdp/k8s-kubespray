sudo docker build -t sorididim11/dl-base:cpu -f Dockerfile.dl-base --build-arg ROOT_IMAGE=ubuntu:16.04  .  && \
sudo docker build -t sorididim11/ac52-lab:cpu -f Dockerfile.ac52-lab --build-arg DEVICE_TYPE=cpu . && \
sudo docker build -t sorididim11/hobby-lab:cpu -f Dockerfile.hobby-lab --build-arg DEVICE_TYPE=cpu . && \
sudo docker build -t sorididim11/dev-lab:cpu -f Dockerfile.dev-all --build-arg ROOT_IMAGE=ufoym/deepo:all-py36-jupyter-cpu . && \
sudo docker build -t sorididim11/spark-lab:cpu -f Dockerfile.spark-lab . && \
sudo docker build -t sorididim11/r-lab:cpu -f Dockerfile.r-lab  .



# GPU 
sudo docker build -t sorididim11/dl-base:gpu -f Dockerfile.dl-base   . && \
sudo docker build -t sorididim11/ac52-lab:gpu -f Dockerfile.ac52-lab --build-arg DEVICE_TYPE=gpu .  && \
sudo docker build -t sorididim11/hobby-lab:gpu -f Dockerfile.hobby-lab --build-arg DEVICE_TYPE=gpu .  && \
sudo docker build -t sorididim11/dev-lab:gpu -f Dockerfile.dev-all .


