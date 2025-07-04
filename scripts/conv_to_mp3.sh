#!/bin/sh
for file in *;
do
  if [[ "$file" == *.m4a ]]; then
    ffmpeg -i "$file" -acodec libmp3lame -ab 256k "${file%.m4a}.mp3"
  elif [[ "$file" == *.aac ]]; then
    ffmpeg -i "$file" -acodec libmp3lame -ab 256k "${file%.aac}.mp3"
  elif [[ "$file" == *.opus ]]; then
    ffmpeg -i "$file" -acodec libmp3lame -ab 256k "${file%.opus}.mp3"
  elif [[ "$file" == *.mp4 ]]; then
    ffmpeg -i "$file" -acodec libmp3lame -ab 256k "${file%.mp4}.mp3"
  fi
done
