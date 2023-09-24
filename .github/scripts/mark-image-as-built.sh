#!/bin/bash
IMAGE_TAG=$1
LOCK_BUCKET=$2

echo "built" | aws s3 cp - s3://$LOCK_BUCKET/$IMAGE_TAG.txt
