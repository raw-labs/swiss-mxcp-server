#!/bin/bash

# 🔧 Swiss Business Registry MXCP Project Configuration
# =====================================================
# Central configuration file for all project-specific settings
# Source this file in other scripts: source "$(dirname "$0")/project-config.sh"

# AWS Configuration
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-YOUR_AWS_ACCOUNT_ID}"  # Set in .env file
export AWS_REGION="${AWS_REGION:-eu-west-1}"
export IAM_ROLE_NAME="AppRunnerECRAccessRole"
export IAM_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${IAM_ROLE_NAME}"

# App Runner Service Configuration
export SERVICE_NAME="swiss-mxcp-server"
export SERVICE_ARN="arn:aws:apprunner:${AWS_REGION}:${AWS_ACCOUNT_ID}:service/${SERVICE_NAME}"

# ECR Configuration
export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export ECR_REPOSITORY="swiss-mxcp-server"
export ECR_IMAGE_URI="${ECR_REGISTRY}/${ECR_REPOSITORY}:latest"

# Container Configuration
export CONTAINER_PORT="8000"
export CONTAINER_NAME_LOCAL="swiss-test"
export CONTAINER_NAME_FINAL="swiss-final"

# MCP Configuration
export MCP_ENDPOINT_PATH="/mcp"
export HEALTH_ENDPOINT_PATH="/health"
export MCP_TRANSPORT="streamable-http"
export MXCP_PROFILE="prod"
export MXCP_PROJECT="swiss-mxcp-server"

# Instance Configuration  
export CPU_SIZE="${CPU_SIZE:-0.5 vCPU}"
export MEMORY_SIZE="${MEMORY_SIZE:-2 GB}"

# File Paths (relative to script directory)
export CONFIG_DIR="config"
export DEPLOY_CONFIG_FILE="$CONFIG_DIR/deploy-config.json"
export DOCKERFILE_PATH="Dockerfile"

# Timeouts and Intervals (seconds)
export DEPLOYMENT_TIMEOUT=600          # 10 minutes
export MONITORING_INTERVAL=15          # 15 seconds
export HEALTH_CHECK_TIMEOUT=10         # 10 seconds
export STARTUP_WAIT_TIME=15            # Container startup wait

# Docker Configuration
export DOCKER_BUILD_CONTEXT="../.." # Relative to aws-apprunner directory (repository root)
export DOCKER_BUILD_TAG="swiss-mxcp-server:latest"
export DOCKER_LOCAL_TAG="swiss-mxcp-local"

# Validation Functions
validate_aws_cli() {
    if ! command -v aws &> /dev/null && ! command -v /usr/local/bin/aws &> /dev/null; then
        echo "❌ AWS CLI not found. Please install AWS CLI first."
        echo "   Installation: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        return 1
    fi
    
    # Use the correct AWS CLI path
    export AWS_CLI_PATH=$(command -v aws 2>/dev/null || echo "/usr/local/bin/aws")
    return 0
}

validate_aws_credentials() {
    if ! $AWS_CLI_PATH sts get-caller-identity &> /dev/null; then
        echo "❌ AWS credentials not configured or invalid."
        echo "   Please run: aws configure"
        return 1
    fi
    
    # Verify correct account
    local account_id=$($AWS_CLI_PATH sts get-caller-identity --query Account --output text 2>/dev/null)
    if [ "$account_id" != "$AWS_ACCOUNT_ID" ]; then
        echo "❌ AWS account mismatch"
        echo "   Expected: $AWS_ACCOUNT_ID"
        echo "   Got: $account_id"
        return 1
    fi
    return 0
}

validate_docker() {
    if ! docker ps &> /dev/null; then
        echo "❌ Docker not accessible. Options:"
        echo "   1. Add user to docker group: sudo usermod -aG docker $USER"
        echo "   2. Use sudo for docker commands"
        return 1
    fi
    return 0
}

validate_required_files() {
    local missing_files=()
    
    if [ ! -f "$DOCKERFILE_PATH" ]; then
        missing_files+=("$DOCKERFILE_PATH")
    fi
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "❌ Required files missing:"
        printf "   • %s\n" "${missing_files[@]}"
        return 1
    fi
    return 0
}

# Utility Functions
generate_timestamp() {
    date +%Y%m%d_%H%M%S
}

get_service_status() {
    $AWS_CLI_PATH apprunner describe-service \
        --service-arn "$SERVICE_ARN" \
        --region "$AWS_REGION" \
        --query 'Service.Status' \
        --output text 2>/dev/null || echo "UNKNOWN"
}

get_service_url() {
    # Try to get current URL from AWS App Runner
    local current_url=$($AWS_CLI_PATH apprunner describe-service \
        --service-arn "$SERVICE_ARN" \
        --region "$AWS_REGION" \
        --query 'Service.ServiceUrl' \
        --output text 2>/dev/null)
    
    if [ "$current_url" != "None" ] && [ ! -z "$current_url" ] && [ "$current_url" != "null" ]; then
        echo "$current_url"
    else
        echo "Service not deployed yet"
    fi
}

service_exists() {
    local service_arn=$($AWS_CLI_PATH apprunner list-services \
        --region "$AWS_REGION" \
        --query "ServiceSummaryList[?ServiceName=='$SERVICE_NAME'].ServiceArn" \
        --output text 2>/dev/null)
    
    if [ ! -z "$service_arn" ] && [ "$service_arn" != "None" ]; then
        return 0  # Service exists
    else
        return 1  # Service does not exist
    fi
}

# Docker wrapper function
docker_cmd() {
    # Try regular docker first
    if docker ps &> /dev/null; then
        docker "$@"
    else
        # Fall back to sudo
        sudo docker "$@"
    fi
}

# Display Configuration
show_config() {
    echo "🔧 Swiss Business Registry MXCP Project Configuration"
    echo "===================================================="
    echo "📋 Service: $SERVICE_NAME"
    echo "🌍 Region: $AWS_REGION" 
    echo "🏗️ Account: $AWS_ACCOUNT_ID"
    echo "🌐 URL: $(get_service_url)"
    echo "🐳 Image: $ECR_IMAGE_URI"
    echo "💾 CPU/Memory: $CPU_SIZE / $MEMORY_SIZE"
    echo "🔧 AWS CLI: $AWS_CLI_PATH"
    echo ""
}

# Initialize (run when sourced)
if validate_aws_cli; then
    # Configuration loaded successfully
    :
else
    echo "⚠️  Configuration loaded with warnings"
fi

# Export all functions for use in other scripts
export -f validate_aws_cli validate_aws_credentials validate_docker validate_required_files
export -f generate_timestamp get_service_status get_service_url show_config service_exists docker_cmd

