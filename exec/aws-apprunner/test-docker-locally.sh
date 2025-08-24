#!/bin/bash

# Test Swiss MXCP Docker Container Locally
# ========================================

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/project-config.sh"

echo "🧪 Testing Swiss MXCP Docker Container Locally"
echo "============================================="

# Validate prerequisites
echo "📋 Validating prerequisites..."
validate_docker || exit 1

# Clean up any existing test container
echo "🧹 Cleaning up existing test containers..."
docker_cmd stop swiss-test 2>/dev/null || true
docker_cmd rm swiss-test 2>/dev/null || true

# Build the Docker image
echo "🏗️  Building Docker image..."
docker_cmd build -t $DOCKER_LOCAL_TAG -f $DOCKERFILE_PATH $DOCKER_BUILD_CONTEXT

# Run the container
echo "🚀 Starting container..."
docker_cmd run -d \
    --name swiss-test \
    -p 8000:8000 \
    -e MXCP_DEBUG=true \
    $DOCKER_LOCAL_TAG

# Wait for container to start
echo "⏳ Waiting for container to start..."
sleep $STARTUP_WAIT_TIME

# Check if container is running
if ! docker_cmd ps | grep -q swiss-test; then
    echo "❌ Container failed to start"
    echo "📋 Container logs:"
    docker_cmd logs swiss-test
    exit 1
fi

# Test health endpoint
echo "🏥 Testing health endpoint..."
if curl -f -s http://localhost:8000/health > /dev/null; then
    echo "✅ Health check passed"
else
    echo "❌ Health check failed"
    echo "📋 Container logs:"
    docker_cmd logs swiss-test
    exit 1
fi

# Test MCP endpoint
echo "🔧 Testing MCP endpoint..."
if curl -f -s http://localhost:8000/mcp > /dev/null; then
    echo "✅ MCP endpoint accessible"
else
    echo "❌ MCP endpoint not accessible"
    echo "📋 Container logs:"
    docker_cmd logs swiss-test
    exit 1
fi

# Test data access
echo "📊 Testing data access..."
TOOL_LIST=$(curl -s -X POST http://localhost:8000/mcp \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"list_tools","params":{},"id":1}' | \
    grep -o '"name":"[^"]*"' | wc -l)

if [ "$TOOL_LIST" -gt 0 ]; then
    echo "✅ Found $TOOL_LIST tools available"
else
    echo "❌ No tools found or MCP not responding correctly"
    echo "📋 Container logs:"
    docker_cmd logs swiss-test
    exit 1
fi

# Success
echo ""
echo "✅ All tests passed!"
echo ""
echo "📋 Container Information:"
echo "   • Name: swiss-test"
echo "   • Port: 8000"
echo "   • Health: http://localhost:8000/health"
echo "   • MCP: http://localhost:8000/mcp"
echo ""
echo "🔧 Useful commands:"
echo "   • View logs: docker logs swiss-test"
echo "   • Stop container: docker stop swiss-test"
echo "   • Remove container: docker rm swiss-test"
echo "   • Shell access: docker exec -it swiss-test /bin/bash"
echo ""
