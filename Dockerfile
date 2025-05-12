FROM swarmui

ENTRYPOINT []

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/cuda-keyring_1.1-1_all.deb
RUN dpkg -i cuda-keyring_1.1-1_all.deb

RUN apt update

RUN apt install cuda-toolkit-11-8 -y

RUN echo 'export PATH=/usr/local/cuda/bin:$PATH' | tee /etc/profile.d/cuda.sh
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' | tee -a /etc/profile.d/cuda.sh

RUN apt install python3-virtualenv libpng-dev libjpeg-dev cuda-nvtx-11-8 libopenblas-dev -y

RUN apt install ccache -y
ENV USE_CCACHE=1

RUN apt-get install gcc-11 g++-11 -y

COPY build.sh /
