FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# https://github.com/NVIDIA/nvidia-docker/wiki/Usage
# https://github.com/NVIDIA/nvidia-docker/issues/531
ENV NVIDIA_DRIVER_CAPABILITIES compute,video,utility

# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
RUN apt-get update && apt-get --yes --no-install-recommends install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  meson \
  ninja-build \
  pkg-config \
  texinfo \
  wget \
  yasm \
  zlib1g-dev \
  # extra from nvidia docs
  libc6-dev \
  unzip \
  libnuma1 \
  libnuma-dev \
  && rm -rf /var/cache/apt

# https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/

RUN git clone --depth 1 --branch sdk/11.1 https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && \
    make install

RUN git clone --depth 1 --branch release/6.0 https://git.ffmpeg.org/ffmpeg.git && \
    cd ffmpeg && \
    ./configure \
    --enable-nonfree \
    --enable-cuda-nvcc \
    --enable-libnpp \
    --extra-cflags=-I/usr/local/cuda/include \
    --extra-ldflags=-L/usr/local/cuda/lib64 \
    --disable-static \
    --enable-shared && \
    make -j 5 && \
    make install

# note: make -j $(nproc) fails on my 20-core machine. 5 is maximum number of cores I can use without failing

CMD ffmpeg
