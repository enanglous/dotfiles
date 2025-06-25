#!/bin/sh
for file in *;
do
  if [[ "$file" == *.m4a || "$file" == *.aac || "$file" == *.opus ]]; then
    ffmpeg -i "$file" -acodec libmp3lame -ab 256k "${file%.m4a}.mp3"
  fi
done
