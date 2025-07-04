#!/bin/sh

for i in *$1*.mp3
do
  mv "$i" "`echo $i | sed \"s/$1//\"`"
done
