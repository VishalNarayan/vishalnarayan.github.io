#!/bin/bash

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it first:"
    echo "On macOS: brew install imagemagick"
    echo "On Ubuntu/Debian: sudo apt-get install imagemagick"
    exit 1
fi

# Convert SVG to PNG files
convert -background none -size 192x192 icon.svg icon-192.png
convert -background none -size 512x512 icon.svg icon-512.png

echo "Icons have been created successfully!" 
