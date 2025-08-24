#!/bin/bash

# 📊 Monitor AWS App Runner Deployment
# Real-time monitoring of Salesforce MXCP service deployment

set -e  # Exit on any error

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
    exit 1
fi

source "$PROJECT_CONFIG"

echo "📊 AWS App Runner Deployment Monitor"
echo "===================================="
show_config

# Validate prerequisites
if ! validate_aws_credentials; then
    exit 1
fi

echo "⏳ Monitoring deployment progress..."
echo "   Press Ctrl+C to stop monitoring"
echo ""

ELAPSED=0
LAST_STATUS=""

while true; do
    # Get current status
    STATUS=$(get_service_status)
    TIMESTAMP_NOW=$(date '+%H:%M:%S')
    
    # Only show status if it changed
    if [ "$STATUS" != "$LAST_STATUS" ]; then
        case "$STATUS" in
            "RUNNING")
                echo "✅ [$TIMESTAMP_NOW] Service is RUNNING"
                echo "   Deployment completed successfully!"
                
                # Get final service URL
                FINAL_URL=$(get_service_url)
                echo "   🌐 Service URL: https://$FINAL_URL"
                echo "   🤖 MCP Endpoint: https://$FINAL_URL$MCP_ENDPOINT_PATH"
                
                # Test endpoints
                echo ""
                echo "🧪 Quick service test..."
                if curl -s --max-time $HEALTH_CHECK_TIMEOUT "https://$FINAL_URL$HEALTH_ENDPOINT_PATH" > /dev/null; then
                    echo "   ✅ Health check: PASSED"
                else
                    echo "   ⚠️  Health check: FAILED (may still be starting)"
                fi
                
                echo ""
                echo "🎉 Monitoring complete - service is operational!"
                break
                ;;
            "OPERATION_IN_PROGRESS")
                echo "🔄 [$TIMESTAMP_NOW] Deployment in progress... (${ELAPSED}s elapsed)"
                ;;
            "CREATE_FAILED"|"UPDATE_FAILED"|"DELETE_FAILED")
                echo "❌ [$TIMESTAMP_NOW] Deployment failed!"
                echo "   Status: $STATUS"
                echo "   Check AWS console for detailed error logs"
                exit 1
                ;;
            "PAUSED")
                echo "⏸️  [$TIMESTAMP_NOW] Service is PAUSED"
                ;;
            "UNKNOWN")
                echo "❓ [$TIMESTAMP_NOW] Cannot determine service status"
                echo "   Check AWS credentials and service ARN"
                ;;
            *)
                echo "📋 [$TIMESTAMP_NOW] Status: $STATUS (${ELAPSED}s elapsed)"
                ;;
        esac
        LAST_STATUS="$STATUS"
    fi
    
    # Check for timeout
    if [ $ELAPSED -ge $DEPLOYMENT_TIMEOUT ]; then
        echo ""
        echo "⏰ Monitoring timeout reached ($DEPLOYMENT_TIMEOUT seconds)"
        echo "   Current status: $STATUS"
        echo "   You can continue monitoring manually in AWS console"
        break
    fi
    
    sleep $MONITORING_INTERVAL
    ELAPSED=$((ELAPSED + MONITORING_INTERVAL))
done

echo ""
echo "📋 Final Status: $(get_service_status)"
echo "🌐 Service URL: $(get_service_url)$MCP_ENDPOINT_PATH" 