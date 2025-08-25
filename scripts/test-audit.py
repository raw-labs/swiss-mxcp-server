#!/usr/bin/env python3
"""Quick test to generate audit logs on the remote service."""

import requests
import json

# Service URL
SERVICE_URL = "https://ru9grd9gq8.eu-west-1.awsapprunner.com/mcp"

# Test requests
test_requests = [
    {
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": "search_companies",
            "arguments": {
                "canton": "Zurich",
                "page_size": 5
            }
        },
        "id": 1
    },
    {
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": "aggregate_companies",
            "arguments": {
                "group_by": "Canton",
                "page_size": 10
            }
        },
        "id": 2
    }
]

print("🧪 Testing Swiss MXCP Server audit logging...")
print(f"📍 Service URL: {SERVICE_URL}")
print()

for req in test_requests:
    print(f"📤 Calling tool: {req['params']['name']}")
    try:
        response = requests.post(SERVICE_URL, json=req, headers={
            "Content-Type": "application/json",
            "Accept": "application/json, text/event-stream"
        })
        if response.status_code == 200:
            print(f"✅ Success! Status: {response.status_code}")
            result = response.json()
            if "result" in result and "content" in result["result"]:
                content = result["result"]["content"][0]["text"]
                # Just show first few lines
                lines = content.split("\n")[:3]
                for line in lines:
                    print(f"   {line}")
                if len(content.split("\n")) > 3:
                    print("   ...")
        else:
            print(f"❌ Error! Status: {response.status_code}")
            print(f"   Response: {response.text}")
    except Exception as e:
        print(f"❌ Exception: {e}")
    print()

print("✅ Test complete! Check audit logs with:")
print("   ./scripts/latest-logs.sh --audit --format")
