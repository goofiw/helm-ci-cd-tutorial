#!/bin/bash
IMAGE_TAG=$1
REPOSITORY_NAME=$2
LOCK_BUCKET=$3
AWS_REGION=$4



# Check if the image with the specified tag exists in the ECR repository
aws ecr describe-images --repository-name $REPOSITORY_NAME --image-ids imageTag=$IMAGE_TAG --region $AWS_REGION &> /dev/null

# Check the exit status
if [[ $? -eq 0 ]]; then
    echo "Image with tag $IMAGE_TAG exists in repository $REPOSITORY_NAME."
    ./.github/scripts/mark-image-as-built $IMAGE_TAG $LOCK_BUCKET
else
    echo "Image with tag $IMAGE_TAG does not exist in repository $REPOSITORY_NAME."
    echo "Removing lockfile $IMAGE_TAG due to failure as image does not exist in repository"
    aws s3api delete-object --bucket $LOCK_BUCKET --key $IMAGE_TAG.txt
fi
