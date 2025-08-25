#!/bin/bash
# Script to find and tail the latest App Runner logs

SERVICE_NAME="swiss-mxcp-server"
REGION="eu-west-1"
# This script expects 3 optional input parameters:
# 1. --time-window=<time-window> - the time window to tail the logs for. If not provided, default to 5m.
# 2. --audit - if provided, only show audit logs.
# 3. --format - if provided with --audit, use Python parser for better formatting
# Note that the user may provide parameters in any order - use shift to parse them.

TIME_WINDOW="5m"
AUDIT=false
FORMAT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --time-window=*)
            TIME_WINDOW="${1#--time-window=}"
            shift
            ;;
        --audit)
            AUDIT=true
            shift
            ;;
        --format)
            FORMAT=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--time-window=5m] [--audit] [--format]"
            exit 1
            ;;
    esac
done

# Find the latest application log group
LATEST_LOG_GROUP=$(/usr/local/bin/aws logs describe-log-groups \
    --region $REGION \
    --log-group-name-prefix "/aws/apprunner/$SERVICE_NAME" \
    --query 'sort_by(logGroups[?contains(logGroupName, `/application`)], &creationTime)[-1].logGroupName' \
    --output text)

echo "📋 Latest log group: $LATEST_LOG_GROUP"
echo ""

# If audit logs requested, filter for them
if $AUDIT; then
    if $FORMAT; then
        echo "🔍 Showing audit logs with formatted output..."
        echo "Time window: $TIME_WINDOW"
        echo ""
        
        # Get script directory for Python parser
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        
        # Use Python parser for better formatting
        /usr/local/bin/aws logs tail "$LATEST_LOG_GROUP" --region $REGION --since "$TIME_WINDOW" | \
            grep "AUDIT" | \
            python3 "$SCRIPT_DIR/parse-audit-logs.py"
    else
        echo "🔍 Showing raw audit logs..."
        echo "Time window: $TIME_WINDOW"
        echo "Tip: Use --format for prettier output"
        echo ""
        
        # Show raw audit logs
        /usr/local/bin/aws logs tail "$LATEST_LOG_GROUP" --region $REGION --since "$TIME_WINDOW" | grep "AUDIT"
    fi
else
    echo "📜 Tailing latest logs (use './latest-logs.sh --audit [--format]' for audit logs only)..."
    /usr/local/bin/aws logs tail "$LATEST_LOG_GROUP" --region $REGION --follow
fi
