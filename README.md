# ffmpeg-nvidia-docker

This is a docker image for building a container with ffmpeg and nvidia hardware acceleration.

test that encoding and decoding works:
```shell
docker run --rm --gpus all -v $PWD:/app tandav/ffmpeg-nvidia \
ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -extra_hw_frames 4 -i /app/video.mp4 -c:v h264_nvenc /app/output.mp4
```
`-extra_hw_frames 4` is used to fix 'No decoder surfaces left' error: https://trac.ffmpeg.org/ticket/7562

[Image on DockerHub](https://hub.docker.com/r/tandav/ffmpeg-nvidia)
