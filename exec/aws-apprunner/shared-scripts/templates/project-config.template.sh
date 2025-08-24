#!/bin/bash
# Project-specific configuration for MXCP deployment
# Copy this template to your project's exec/aws-apprunner/project-config.sh
# and update with your project-specific values

# ========================================
# PROJECT SPECIFIC - MUST UPDATE THESE
# ========================================

# AWS Configuration
export AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID_HERE"               # Replace with your AWS account ID
export AWS_REGION="eu-west-1"                                  # Your deployment region

# App Runner Service Configuration
export SERVICE_NAME="your-mxcp-server-name"                    # Your App Runner service name
export ECR_REPOSITORY="your-ecr-repo-name"                     # Your ECR repository name

# Container Configuration
export CONTAINER_PORT="8000"                                   # Port your app listens on

# MCP Project Configuration
export MXCP_PROJECT="your-project-name"                        # Your MXCP project name
export MXCP_PROFILE="prod"                                     # MXCP profile (prod/dev)

# Instance Configuration (for initial creation)
export CPU_SIZE="1 vCPU"                                       # App Runner CPU size
export MEMORY_SIZE="4 GB"                                      # App Runner memory size

# ========================================
# STANDARD CONFIGURATION - RARELY CHANGE
# ========================================

# IAM Configuration
export IAM_ROLE_NAME="AppRunnerECRAccessRole"
export IAM_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${IAM_ROLE_NAME}"

# Derived Values
export SERVICE_ARN="arn:aws:apprunner:${AWS_REGION}:${AWS_ACCOUNT_ID}:service/${SERVICE_NAME}"
export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export ECR_IMAGE_URI="${ECR_REGISTRY}/${ECR_REPOSITORY}:latest"

# MCP Configuration
export MCP_ENDPOINT_PATH="/mcp"
export HEALTH_ENDPOINT_PATH="/health"
export MCP_TRANSPORT="streamable-http"

# File Paths (relative to this script's directory)
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CONFIG_DIR="$SCRIPT_DIR/config"
export DOCKERFILE_PATH="$SCRIPT_DIR/Dockerfile"
export REQUIREMENTS_FILE="$SCRIPT_DIR/requirements.txt"

# Timeouts and Intervals (seconds)
export DEPLOYMENT_TIMEOUT=600          # 10 minutes
export MONITORING_INTERVAL=15          # 15 seconds
export HEALTH_CHECK_TIMEOUT=10         # 10 seconds

# AWS CLI Path (auto-detect)
if command -v /usr/local/bin/aws &> /dev/null; then
    export AWS_CLI_PATH="/usr/local/bin/aws"
elif command -v /usr/bin/aws &> /dev/null; then
    export AWS_CLI_PATH="/usr/bin/aws"
elif command -v aws &> /dev/null; then
    export AWS_CLI_PATH="aws"
else
    echo "❌ AWS CLI not found. Please install AWS CLI."
    exit 1
fi

# ========================================
# SHARED FUNCTIONS - DO NOT MODIFY
# ========================================

# Get service status
get_service_status() {
    $AWS_CLI_PATH apprunner describe-service \
        --service-arn "$SERVICE_ARN" \
        --region "$AWS_REGION" \
        --query 'Service.Status' \
        --output text 2>/dev/null || echo "NOT_FOUND"
}

# Get service URL
get_service_url() {
    $AWS_CLI_PATH apprunner describe-service \
        --service-arn "$SERVICE_ARN" \
        --region "$AWS_REGION" \
        --query 'Service.ServiceUrl' \
        --output text 2>/dev/null
}

# Show configuration
show_config() {
    echo "📋 Project Configuration"
    echo "======================="
    echo "AWS Account: $AWS_ACCOUNT_ID"
    echo "AWS Region: $AWS_REGION"
    echo "Service Name: $SERVICE_NAME"
    echo "ECR Repository: $ECR_REPOSITORY"
    echo "Container Port: $CONTAINER_PORT"
    echo "MXCP Project: $MXCP_PROJECT"
    echo "AWS CLI: $AWS_CLI_PATH"
} 