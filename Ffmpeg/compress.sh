#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 input_video [output_video]"
  exit 1
fi

input="$1"

if [ -z "$2" ]; then
  # Extract filename without extension
  filename="${input%.*}"
  extension="${input##*.}"
  output="${filename}_output.${extension}"
else
  output="$2"
fi

ffmpeg -i "$input" -c:v libx265 -crf 28 -preset medium "$output"
