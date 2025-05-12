# torch-builder

Set of scripts to build PyTorch wheels for sm_75 (Nvidia Tegra T4).

## Prerequisites

- Docker

- NVIDIA Docker

- NVIDIA GPU with compute capability 7.5 (Tegra T4)

- Ubuntu 22.04

- At least 575 driver version

- CUDA 11.8

## Building container it can be used in

```dockerfile
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/cuda-keyring_1.1-1_all.deb
RUN dpkg -i cuda-keyring_1.1-1_all.deb

RUN apt update

RUN apt install cuda-toolkit-11-8 -y

RUN echo 'export PATH=/usr/local/cuda/bin:$PATH' | tee /etc/profile.d/cuda.sh
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' | tee -a /etc/profile.d/cuda.sh
```
