#!/bin/bash
# Script to compress the interface demo video to a smaller size
# Usage: ./scripts/compress_video.sh <input_file> <output_file>
# Example: ./scripts/compress_video.sh ~/Downloads/demo.mp4 docs/demo.mp4

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

ffmpeg -i "$1" -vf scale=540:-2 -vcodec libx264 -crf 32 -preset fast -c:a aac -b:a 64k "$2"
