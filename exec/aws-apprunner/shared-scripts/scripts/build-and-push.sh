#!/bin/bash
# Build and push Docker image to ECR
set -e

# Find and load project configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find project-config.sh in multiple locations
if [ -f "./project-config.sh" ]; then
    PROJECT_CONFIG="./project-config.sh"
elif [ -f "../project-config.sh" ]; then
    PROJECT_CONFIG="../project-config.sh"
elif [ -f "../../project-config.sh" ]; then
    PROJECT_CONFIG="../../project-config.sh"
elif [ -f "../../exec/aws-apprunner/project-config.sh" ]; then
    PROJECT_CONFIG="../../exec/aws-apprunner/project-config.sh"
else
    echo "❌ Error: project-config.sh not found!"
    echo "   Searched in:"
    echo "   - ./project-config.sh"
    echo "   - ../project-config.sh"
    echo "   - ../../project-config.sh"
    echo "   - ../../exec/aws-apprunner/project-config.sh"
    echo ""
    echo "   Please run this script from your project's exec/aws-apprunner directory"
    echo "   or ensure project-config.sh exists in one of the expected locations."
    exit 1
fi

echo "📋 Loading configuration from: $PROJECT_CONFIG"
source "$PROJECT_CONFIG"

# Parse arguments
IMAGE_TAG="${1:-latest}"
SKIP_BUILD="${2:-false}"

echo "🐳 Docker Build and Push Script"
echo "==============================="
echo "Registry: $ECR_REGISTRY"
echo "Repository: $ECR_REPOSITORY"
echo "Tag: $IMAGE_TAG"
echo ""

# Check AWS credentials
echo "🔐 Checking AWS credentials..."
if ! $AWS_CLI_PATH sts get-caller-identity --region "$AWS_REGION" > /dev/null 2>&1; then
    echo "❌ AWS credentials not configured or expired"
    exit 1
fi
echo "✅ AWS credentials valid"

# Login to ECR
echo ""
echo "🔑 Logging in to ECR..."
if ! $AWS_CLI_PATH ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY" > /dev/null 2>&1; then
    echo "❌ Failed to login to ECR"
    exit 1
fi
echo "✅ ECR login successful"

# Create repository if it doesn't exist
echo ""
echo "📦 Checking ECR repository..."
if ! $AWS_CLI_PATH ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$AWS_REGION" > /dev/null 2>&1; then
    echo "Creating ECR repository..."
    $AWS_CLI_PATH ecr create-repository \
        --repository-name "$ECR_REPOSITORY" \
        --region "$AWS_REGION" \
        --image-scanning-configuration scanOnPush=true \
        --output json > /dev/null
    echo "✅ Repository created"
else
    echo "✅ Repository exists"
fi

# Build Docker image (unless skipped)
if [ "$SKIP_BUILD" != "true" ]; then
    echo ""
    echo "🔨 Building Docker image..."
    
    # Get the directory containing project-config.sh
    PROJECT_CONFIG_DIR=$(cd "$(dirname "$PROJECT_CONFIG")" && pwd)
    
    # Determine build context - should be repository root
    # If project-config.sh is in exec/aws-apprunner, go up two levels
    if [[ "$PROJECT_CONFIG_DIR" == *"exec/aws-apprunner"* ]]; then
        BUILD_CONTEXT=$(cd "$PROJECT_CONFIG_DIR/../.." && pwd)
    else
        # Otherwise assume we're already at project root
        BUILD_CONTEXT="$PROJECT_CONFIG_DIR"
    fi
    
    echo "   Build context: $BUILD_CONTEXT"
    echo "   Dockerfile: $DOCKERFILE_PATH"
    
    # Build from repository root with proper context
    if docker build -f "$DOCKERFILE_PATH" -t "${ECR_REPOSITORY}:${IMAGE_TAG}" "$BUILD_CONTEXT" ; then
        echo "✅ Build successful"
    else
        echo "❌ Build failed"
        exit 1
    fi
else
    echo ""
    echo "⏭️  Skipping build (SKIP_BUILD=true)"
fi

# Tag images
echo ""
echo "🏷️  Tagging images..."
docker tag "${ECR_REPOSITORY}:${IMAGE_TAG}" "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
if [ "$IMAGE_TAG" != "latest" ]; then
    docker tag "${ECR_REPOSITORY}:${IMAGE_TAG}" "${ECR_REGISTRY}/${ECR_REPOSITORY}:latest"
fi

# Push to ECR
echo ""
echo "📤 Pushing to ECR..."
docker push "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
if [ "$IMAGE_TAG" != "latest" ]; then
    docker push "${ECR_REGISTRY}/${ECR_REPOSITORY}:latest"
fi

echo ""
echo "✅ Image pushed successfully!"
echo "   - ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
if [ "$IMAGE_TAG" != "latest" ]; then
    echo "   - ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest"
fi 