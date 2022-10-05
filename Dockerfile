FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

# https://github.com/NVIDIA/nvidia-docker/wiki/Usage
# https://github.com/NVIDIA/nvidia-docker/issues/531
ENV NVIDIA_DRIVER_CAPABILITIES compute,video,utility


RUN apt-get update && \
    apt-get install -y git make pkg-config && \
    # https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/
    git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && make install && cd - && \
    git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/ && cd ffmpeg && \
    apt-get install -y build-essential yasm cmake libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev && \
    ./configure \
    --enable-nonfree \
    --enable-cuda-nvcc \
    --enable-libnpp \
    --extra-cflags=-I/usr/local/cuda/include \
    --extra-ldflags=-L/usr/local/cuda/lib64 \
    --disable-static \
    --enable-shared && \
    make -j $(nproc) && \
    make install

CMD ffmpeg
