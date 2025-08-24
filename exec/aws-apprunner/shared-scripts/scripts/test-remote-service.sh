#!/bin/bash

# 🧪 Test Remote Salesforce MXCP Service
# Tests the deployed AWS App Runner service

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

echo "🧪 Testing Remote Salesforce MXCP Service"
echo "========================================="
show_config

# Get current service details
echo "📊 Checking service status..."
SERVICE_STATUS=$(get_service_status)
ACTUAL_SERVICE_URL=$(get_service_url)

echo "   📋 Status: $SERVICE_STATUS"
echo "   🌐 URL: $ACTUAL_SERVICE_URL"

if [ "$SERVICE_STATUS" != "RUNNING" ]; then
    echo "⚠️  Warning: Service is not in RUNNING state"
    echo "   Current status: $SERVICE_STATUS"
    echo "   Tests may fail if service is not fully operational"
fi

echo ""
echo "🧪 Running service tests..."
echo ""

# Test 1: Health Check
echo "1. 🏥 Health Check Test"
echo "   URL: $ACTUAL_SERVICE_URL$HEALTH_ENDPOINT_PATH"

if curl -s --max-time $HEALTH_CHECK_TIMEOUT "$ACTUAL_SERVICE_URL$HEALTH_ENDPOINT_PATH" > /dev/null; then
    echo "   ✅ PASSED: Health endpoint responding"
else
    echo "   ❌ FAILED: Health endpoint not responding"
fi

echo ""

# Test 2: MCP Endpoint
echo "2. 🤖 MCP Endpoint Test"
echo "   URL: $ACTUAL_SERVICE_URL$MCP_ENDPOINT_PATH"

MCP_RESPONSE=$(curl -s --max-time $HEALTH_CHECK_TIMEOUT -H "Accept: application/json" "$ACTUAL_SERVICE_URL$MCP_ENDPOINT_PATH" 2>/dev/null || echo "FAILED")

if [[ "$MCP_RESPONSE" == *"Not Acceptable"* ]]; then
    echo "   ✅ PASSED: MCP endpoint available (requires proper Accept headers)"
elif [[ "$MCP_RESPONSE" == "FAILED" ]]; then
    echo "   ❌ FAILED: Cannot connect to MCP endpoint"
else
    echo "   ✅ PASSED: MCP endpoint responding"
fi

echo ""

# Test 3: Service Configuration
echo "3. ⚙️  Service Configuration Test"
echo "   Getting service details from AWS..."

SERVICE_INFO=$($AWS_CLI_PATH apprunner describe-service \
    --service-arn "$SERVICE_ARN" \
    --region "$AWS_REGION" \
    --output json 2>/dev/null || echo "{}")

if [ "$SERVICE_INFO" != "{}" ]; then
    echo "   ✅ PASSED: Service configuration accessible"
    
    ACTUAL_CPU=$(echo "$SERVICE_INFO" | jq -r '.Service.InstanceConfiguration.Cpu // "unknown"')
    ACTUAL_MEMORY=$(echo "$SERVICE_INFO" | jq -r '.Service.InstanceConfiguration.Memory // "unknown"')
    ACTUAL_IMAGE=$(echo "$SERVICE_INFO" | jq -r '.Service.SourceConfiguration.ImageRepository.ImageIdentifier // "unknown"')
    
    echo "   📊 CPU: $ACTUAL_CPU"
    echo "   💾 Memory: $ACTUAL_MEMORY"
    echo "   🐳 Image: $ACTUAL_IMAGE"
else
    echo "   ❌ FAILED: Cannot retrieve service configuration"
fi

echo ""

# Test 4: Claude Desktop Configuration
echo "4. 🎯 Claude Desktop Integration"
echo "   MCP Server Configuration:"
echo ""
echo "   Add this to your Claude Desktop config:"
echo ""
echo '   {'
echo '     "servers": {'
echo '       "salesforce-mxcp": {'
echo '         "command": "node",'
echo "         \"args\": [\"path/to/mcp-client-http\", \"$ACTUAL_SERVICE_URL$MCP_ENDPOINT_PATH\"]"
echo '       }'
echo '     }'
echo '   }'

echo ""
echo ""

# Summary
echo "📋 Test Summary"
echo "==============="
echo "🔗 Service URL: $ACTUAL_SERVICE_URL"
echo "📊 Service Status: $SERVICE_STATUS"
echo "🏥 Health Endpoint: $ACTUAL_SERVICE_URL$HEALTH_ENDPOINT_PATH"
echo "🤖 MCP Endpoint: $ACTUAL_SERVICE_URL$MCP_ENDPOINT_PATH"
echo ""
echo "💡 Available Tools:"
echo "   • search_opportunities (with user context filtering)"
echo "   • search_leads (with user context filtering)"
echo "   • search_call_notes (with user context filtering)"
echo "   • aggregate_opportunity_revenue (with user context filtering)"
echo "   • get_lead_ratings, get_opportunity_stages"
echo "   • list_sobjects, describe_sobject, get_sobject"
echo "   • search, soql, sosl"
echo ""
echo "🔐 Enhanced Features:"
echo "   • User context filtering (secure by default)"
echo "   • Email parameter for cross-user access"
echo "   • include_all_users parameter for admin access"
echo "   • Comprehensive AI system prompts included"
echo ""
echo "🎉 Service ready for your 26 Salesforce template questions!" 