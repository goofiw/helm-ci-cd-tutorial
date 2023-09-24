#!/bin/bash
IMAGE_TAG=$1

echo "built" | aws s3api delete-object --bucket ci-image-lock-demo --key $IMAGE_TAG.txt
