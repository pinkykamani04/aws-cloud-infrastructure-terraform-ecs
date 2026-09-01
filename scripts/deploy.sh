#!/bin/bash

set -e

AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="835930218319"
ECR_REPOSITORY="aws-cloud-infrastructure-ecs"
ECS_CLUSTER="aws-cloud-infrastructure-ecs-cluster"
ECS_SERVICE="aws-cloud-infrastructure-ecs-service"
TASK_FAMILY="aws-cloud-infrastructure-ecs-app"

IMAGE_TAG="v$(date +%Y%m%d-%H%M%S)"
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

echo "======================================"
echo "Starting application deployment"
echo "Image tag: ${IMAGE_TAG}"
echo "======================================"

echo "Logging in to Amazon ECR..."

aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$ECR_URI"

echo "Building Docker image..."

docker build \
  -t "${ECR_REPOSITORY}:${IMAGE_TAG}" \
  ./app

echo "Tagging Docker image..."

docker tag \
  "${ECR_REPOSITORY}:${IMAGE_TAG}" \
  "${ECR_URI}:${IMAGE_TAG}"

echo "Pushing image to Amazon ECR..."

docker push "${ECR_URI}:${IMAGE_TAG}"

echo "Retrieving current ECS task definition..."

aws ecs describe-task-definition \
  --task-definition "$TASK_FAMILY" \
  --region "$AWS_REGION" \
  --query 'taskDefinition' \
  --output json > /tmp/task-definition.json

echo "Creating new task definition revision..."

python3 - <<PY
import json

with open("/tmp/task-definition.json") as f:
    task_definition = json.load(f)

image = "${ECR_URI}:${IMAGE_TAG}"

for container in task_definition["containerDefinitions"]:
    if container["name"] == "app":
        container["image"] = image

fields = [
    "family",
    "taskRoleArn",
    "executionRoleArn",
    "networkMode",
    "containerDefinitions",
    "volumes",
    "placementConstraints",
    "requiresCompatibilities",
    "cpu",
    "memory",
    "runtimePlatform",
]

new_definition = {
    key: task_definition[key]
    for key in fields
    if key in task_definition
}

with open("/tmp/new-task-definition.json", "w") as f:
    json.dump(new_definition, f)
PY

NEW_TASK_DEFINITION=$(aws ecs register-task-definition \
  --cli-input-json file:///tmp/new-task-definition.json \
  --region "$AWS_REGION" \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

echo "New task definition:"
echo "$NEW_TASK_DEFINITION"

echo "Updating ECS service..."

aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --task-definition "$NEW_TASK_DEFINITION" \
  --region "$AWS_REGION" \
  --query 'service.serviceName' \
  --output text

echo "======================================"
echo "Deployment started successfully."
echo "Image: ${ECR_URI}:${IMAGE_TAG}"
echo "======================================"
