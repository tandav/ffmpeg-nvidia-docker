ffmpeg -y -loglevel info \
-extra_hw_frames 4 \
-hwaccel cuda -hwaccel_output_format cuda -i video.mp4  \
-hwaccel cuda -hwaccel_output_format cuda -i video.mp4 \
-filter_complex \
" \
[0:v]scale_npp=640:-2:format=yuv420p,hwdownload,pad=w=2*iw:h=ih:x=0:y=0,hwupload_cuda,scale_npp=format=nv12[base];
[1:v]scale_npp=640:-2:format=nv12[overlay_video];
[base][overlay_video]overlay_cuda=x=640:y=0" \
-an -c:v h264_nvenc overlay_test.mp4
