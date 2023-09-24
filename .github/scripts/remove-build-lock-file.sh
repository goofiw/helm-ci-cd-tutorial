#!/bin/bash
IMAGE_TAG=$1
LOCK_BUCKET=$2

echo "Removing building lock file for $IMAGE_TAG in $LOCK_BUCKET"
aws s3api delete-object --bucket $LOCK_BUCKET --key $IMAGE_TAG.txt
