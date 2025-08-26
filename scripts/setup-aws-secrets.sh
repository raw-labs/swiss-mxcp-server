#!/bin/bash

# Script to set up AWS secrets for GitHub Actions
# Usage: ./setup-aws-secrets.sh

echo "🔐 GitHub AWS Secrets Setup"
echo "=========================="
echo ""

# Check if gh CLI is authenticated
if ! gh auth status &>/dev/null; then
    echo "❌ Error: GitHub CLI not authenticated"
    echo "Run: gh auth login"
    exit 1
fi

# Get AWS credentials
echo "Please enter your AWS credentials:"
echo "(These will be stored as GitHub secrets, not locally)"
echo ""

read -p "AWS Access Key ID: " AWS_KEY
read -s -p "AWS Secret Access Key: " AWS_SECRET
echo ""

# Validate inputs
if [ -z "$AWS_KEY" ] || [ -z "$AWS_SECRET" ]; then
    echo "❌ Error: Both AWS Access Key ID and Secret Access Key are required"
    exit 1
fi

# Set the secrets
echo ""
echo "Setting GitHub secrets..."

if gh secret set AWS_ACCESS_KEY_ID --repo raw-labs/swiss-mxcp-server --body "$AWS_KEY"; then
    echo "✅ AWS_ACCESS_KEY_ID set successfully"
else
    echo "❌ Failed to set AWS_ACCESS_KEY_ID"
    exit 1
fi

if gh secret set AWS_SECRET_ACCESS_KEY --repo raw-labs/swiss-mxcp-server --body "$AWS_SECRET"; then
    echo "✅ AWS_SECRET_ACCESS_KEY set successfully"
else
    echo "❌ Failed to set AWS_SECRET_ACCESS_KEY"
    exit 1
fi

echo ""
echo "🎉 AWS credentials configured successfully!"
echo ""
echo "All required secrets are now set:"
echo "✅ AWS_ACCESS_KEY_ID"
echo "✅ AWS_SECRET_ACCESS_KEY"
echo "✅ OPENAI_API_KEY (previously set)"
echo "✅ GH_PAT (previously set)"
echo ""
echo "Your GitHub Actions workflows are ready to use!"
