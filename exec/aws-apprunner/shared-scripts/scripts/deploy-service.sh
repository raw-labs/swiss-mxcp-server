#!/bin/bash
# Create or update App Runner service
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

echo "🚀 App Runner Deploy Service Script"
echo "==================================="
echo "Service: $SERVICE_NAME"
echo "Image: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
echo ""

# Check AWS credentials
echo "🔐 Checking AWS credentials..."
if ! $AWS_CLI_PATH sts get-caller-identity --region "$AWS_REGION" > /dev/null 2>&1; then
    echo "❌ AWS credentials not configured or expired"
    exit 1
fi
echo "✅ AWS credentials valid"

# Check if service exists
echo ""
echo "🔍 Checking if App Runner service exists..."
SERVICE_EXISTS=false
if $AWS_CLI_PATH apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" > /dev/null 2>&1; then
    SERVICE_EXISTS=true
    echo "✅ Service exists"
    
    # Get current status
    CURRENT_STATUS=$(get_service_status)
    echo "   Current status: $CURRENT_STATUS"
    
    if [ "$CURRENT_STATUS" == "OPERATION_IN_PROGRESS" ]; then
        echo "⚠️  Another operation is already in progress"
        echo "   Please wait for it to complete before deploying"
        exit 1
    fi
else
    echo "📝 Service does not exist, will create it"
fi

# Prepare runtime environment variables
ENV_VARS='{}'
if [ -n "$SALESFORCE_INSTANCE_URL" ] && [ -n "$SALESFORCE_USERNAME" ]; then
    ENV_VARS=$(cat <<EOF
{
    "SALESFORCE_INSTANCE_URL": "$SALESFORCE_INSTANCE_URL",
    "SALESFORCE_USERNAME": "$SALESFORCE_USERNAME",
    "SALESFORCE_PASSWORD": "$SALESFORCE_PASSWORD",
    "SALESFORCE_SECURITY_TOKEN": "$SALESFORCE_SECURITY_TOKEN",
    "SALESFORCE_CLIENT_ID": "$SALESFORCE_CLIENT_ID"
}
EOF
)
fi

# Create or update service
if [ "$SERVICE_EXISTS" = "false" ]; then
    echo ""
    echo "🆕 Creating new App Runner service..."
    
    # Create service configuration
    cat > /tmp/service-config.json <<EOF
{
    "ServiceName": "$SERVICE_NAME",
    "SourceConfiguration": {
        "ImageRepository": {
            "ImageIdentifier": "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}",
            "ImageConfiguration": {
                "Port": "$CONTAINER_PORT",
                "RuntimeEnvironmentVariables": $ENV_VARS
            },
            "ImageRepositoryType": "ECR"
        },
        "AutoDeploymentsEnabled": false,
        "AuthenticationConfiguration": {
            "AccessRoleArn": "$IAM_ROLE_ARN"
        }
    },
    "InstanceConfiguration": {
        "Cpu": "$CPU_SIZE",
        "Memory": "$MEMORY_SIZE"
    },
    "HealthCheckConfiguration": {
        "Protocol": "HTTP",
        "Path": "$HEALTH_ENDPOINT_PATH",
        "Interval": 10,
        "Timeout": 5,
        "HealthyThreshold": 1,
        "UnhealthyThreshold": 5
    }
}
EOF
    
    # Create the service
    if $AWS_CLI_PATH apprunner create-service \
        --cli-input-json file:///tmp/service-config.json \
        --region "$AWS_REGION" > /dev/null; then
        echo "✅ Service created successfully!"
    else
        echo "❌ Failed to create service"
        rm -f /tmp/service-config.json
        exit 1
    fi
    
    rm -f /tmp/service-config.json
else
    echo ""
    echo "🔄 Updating existing App Runner service..."
    
    # Create update configuration
    # NOTE: We don't include AuthenticationConfiguration in updates to avoid
    # requiring iam:PassRole permission for the GitHub Actions user
    cat > /tmp/update-config.json <<EOF
{
    "ServiceArn": "$SERVICE_ARN",
    "SourceConfiguration": {
        "ImageRepository": {
            "ImageIdentifier": "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}",
            "ImageConfiguration": {
                "Port": "$CONTAINER_PORT",
                "RuntimeEnvironmentVariables": $ENV_VARS
            },
            "ImageRepositoryType": "ECR"
        },
        "AutoDeploymentsEnabled": false
    }
}
EOF
    
    # Update the service
    if $AWS_CLI_PATH apprunner update-service \
        --cli-input-json file:///tmp/update-config.json \
        --region "$AWS_REGION" > /dev/null; then
        echo "✅ Service updated successfully!"
    else
        echo "❌ Failed to update service"
        rm -f /tmp/update-config.json
        exit 1
    fi
    
    rm -f /tmp/update-config.json
    
    # Wait for update to complete before starting deployment
    echo ""
    echo "⏳ Waiting for update operation to complete..."
    WAIT_TIME=0
    MAX_WAIT=300  # 5 minutes
    while [ $WAIT_TIME -lt $MAX_WAIT ]; do
        CURRENT_STATUS=$(get_service_status)
        if [ "$CURRENT_STATUS" == "RUNNING" ]; then
            echo "✅ Service is ready"
            break
        elif [ "$CURRENT_STATUS" == "OPERATION_IN_PROGRESS" ]; then
            echo -n "."
            sleep 5
            WAIT_TIME=$((WAIT_TIME + 5))
        else
            echo ""
            echo "❌ Unexpected status: $CURRENT_STATUS"
            exit 1
        fi
    done
    
    if [ $WAIT_TIME -ge $MAX_WAIT ]; then
        echo ""
        echo "❌ Timeout waiting for update to complete"
        exit 1
    fi
    
    # Start deployment after update
    echo ""
    echo "🚀 Starting deployment..."
    if $AWS_CLI_PATH apprunner start-deployment \
        --service-arn "$SERVICE_ARN" \
        --region "$AWS_REGION" > /dev/null; then
        echo "✅ Deployment started successfully!"
    else
        echo "❌ Failed to start deployment"
        exit 1
    fi
fi

echo ""
echo "✅ Deployment initiated!"
echo ""
echo "You can monitor the deployment with:"
echo "   ./monitor-deployment.sh" 