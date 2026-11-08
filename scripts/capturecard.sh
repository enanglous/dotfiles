#!/bin/bash
mpv av://v4l2:/dev/video2 --demuxer-lavf-o=video_size=1920x1080,input_format=mjpeg,framerate=60 --profile=low-latency --untimed
