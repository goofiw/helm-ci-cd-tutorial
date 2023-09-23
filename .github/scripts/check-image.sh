#!/bin/bash

# Variables
BUCKET_NAME="ci-image-lock-demo"
IMAGE_TAG=$1
SLEEP_INTERVAL=10  # Interval in seconds to check the S3 file status
TIMEOUT=300

# Check if image tag is provided
if [[ -z "$IMAGE_TAG" ]]; then
    echo "Error: Please provide an image tag."
    exit 1
fi

# Function to check if the file exists in S3
does_file_exist() {
    aws s3 ls s3://$BUCKET_NAME/$IMAGE_TAG.txt > /dev/null 2>&1
    return $?
}

# Check if the file for the image tag exists
if does_file_exist; then
    # File exists, let's check its content
    CONTENT=$(aws s3 cp s3://$BUCKET_NAME/$IMAGE_TAG.txt -)

    if [[ "$CONTENT" == "building" ]]; then
        echo "Image is already being built! Waiting for completion..."

        # Loop until file is updated to 'built' or disappears
        while true; do
            sleep $SLEEP_INTERVAL
            echo "Waiting for image build to complete"
            elapsed_time=$((elapsed_time + SLEEP_INTERVAL))

            if [[ $elapsed_time -ge $TIMEOUT ]]; then
                echo "Error: Build timeout reached."
                echo "STATUS:ERROR"
                exit 2
            fi

            if ! does_file_exist; then
                echo "Error: File disappeared during build process."
                echo "STATUS:ERROR"
                exit 2
            fi

            CONTENT=$(aws s3 cp s3://$BUCKET_NAME/$IMAGE_TAG.txt -)
            if [[ "$CONTENT" == "built" ]]; then
                echo "Image has been built!"
                echo "STATUS:IMAGE_EXISTS"
                exit 0
            fi
        done
    elif [[ "$CONTENT" == "built" ]]; then
        echo "Image has been built!"
        echo "STATUS:IMAGE_EXISTS"
        exit 0
    else
        echo "Unknown content in the file. Exiting."
        exit 3
    fi
else
    # File doesn't exist, let's create one with 'building' status
    echo "building" | aws s3 cp - s3://$BUCKET_NAME/$IMAGE_TAG.txt
    echo "Another Echo"
    echo "Started building the image."
    echo "STATUS:IMAGE_LOCK_NOT_FOUND"
fi

# At this point, you can add your docker build logic
# ...

# After building the docker image, update the file to 'built'
# echo "built" | aws s3 cp - s3://$BUCKET_NAME/$IMAGE_TAG.txt
