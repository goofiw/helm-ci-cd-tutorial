#!/bin/bash
IMAGE_TAG=$1

echo "built" | aws s3 cp - s3://ci-image-lock-demo/$IMAGE_TAG.txt
