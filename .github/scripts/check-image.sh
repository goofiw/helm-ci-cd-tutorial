#!/bin/bash

# Variables
BUCKET_NAME="ci-image-lock-demo"
IMAGE_TAG=$1
SLEEP_INTERVAL=10  # Interval in seconds to check the S3 file status
TIMEOUT=180
REPOSITORY_NAME=cicd-tutorial

# Check if image tag is provided
if [[ -z "$IMAGE_TAG" ]]; then
    echo "Error: Please provide an image tag."
    exit 1
fi

# Function to check if the file exists in S3
does_lock_file_exist() {
    aws s3 ls s3://$BUCKET_NAME/$IMAGE_TAG.txt > /dev/null 2>&1
    return $?
}

does_image_exist() {
  echo "Does image exist args"
  echo $REPOSITORY_NAME
  echo $IMAGE_TAG
  echo $AWS_REGION
  # aws ecr describe-images --repository-name $REPOSITORY_NAME --image-ids imageTag=$IMAGE_TAG --region $AWS_REGION &> /dev/null
  aws ecr describe-images --repository-name $REPOSITORY_NAME --image-ids imageTag=$IMAGE_TAG --region $AWS_REGION 
  if [[ $? -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}
  

# Check if the file for the image tag exists
if does_image_exist; then
  echo "Image already exists in repository"
  echo "STATUS:IMAGE_EXISTS"
  exit 0;
elif does_lock_file_exist; then
    # File exists, let's check its content
    echo "Image is already being built! Waiting for completion..."

        # Loop until file is updated to 'built' or disappears
    while true; do
        sleep $SLEEP_INTERVAL
        echo "Waiting for image build to complete"
        elapsed_time=$((elapsed_time + SLEEP_INTERVAL))

        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Error: Build timeout reached."
            echo "STATUS:ERROR"
            exit 0
        fi

        if does_image_exist; then
            echo "Image has been built!"
            echo "STATUS:IMAGE_EXISTS"
            exit 0
        fi
    done
else
    # File doesn't exist, let's create one with 'building' status
    echo "building" | aws s3 cp - s3://$BUCKET_NAME/$IMAGE_TAG.txt
    echo "Created Image Lock"
    echo "STATUS:IMAGE_LOCK_NOT_FOUND"
fi

