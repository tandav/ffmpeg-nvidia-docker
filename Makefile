.PHONY: test
test:
	# test video
	docker run --rm -it --gpus all \
	-v $$PWD:/app \
	tandav/ffmpeg-nvidia \
	ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -extra_hw_frames 4 -i /app/video.mp4 -c:v h264_nvenc /app/output.mp4
	# -extra_hw_frames 4 is used to fix 'No decoder surfaces left' error: https://trac.ffmpeg.org/ticket/7562

.PHONY: build
build:
	docker build -t tandav/ffmpeg-nvidia .

.PHONY: push
push:
	docker push tandav/ffmpeg-nvidia
