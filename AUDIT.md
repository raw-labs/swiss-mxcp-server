# Audit Logging Guide

The Swiss MXCP Server has audit logging enabled using MXCP's built-in audit capabilities.

## Configuration

Audit logging is configured in `mxcp-site.yml`:

```yaml
profiles:
  prod:
    audit:
      enabled: true
      path: logs/audit.jsonl
```

## What Gets Logged

MXCP automatically logs every tool execution with:
- Timestamp
- Caller information  
- Tool name and parameters (sensitive data redacted)
- Execution duration
- Status (success/error)
- Error details (if applicable)
- Policy decisions

## Log Format

Logs are stored in JSONL (JSON Lines) format in `logs/audit.jsonl`.

## Querying Audit Logs

Use MXCP's built-in log querying commands:

```bash
# View all logs
mxcp log

# Filter by tool name
mxcp log --tool search_companies

# Filter by status
mxcp log --status error
mxcp log --status success

# Filter by time (last 10 minutes)
mxcp log --since 10m

# Filter by time (last hour)
mxcp log --since 1h

# Combine filters
mxcp log --tool aggregate_companies --since 30m --status success
```

## Production Deployment

In the deployed App Runner service, audit logs are:
1. **Written to**: `/app/logs/audit.jsonl` inside the container
2. **Streamed to CloudWatch**: With `[AUDIT]` prefix for easy filtering
3. **Available in**: CloudWatch Logs under `/aws/apprunner/swiss-mxcp-server/*/application`

## Helper Scripts

This project includes scripts to easily view and parse audit logs:

### `scripts/latest-logs.sh`

Automatically finds the latest App Runner log group and displays logs:

```bash
# Tail all logs in real-time
./scripts/latest-logs.sh

# Show only audit logs (raw format)
./scripts/latest-logs.sh --audit

# Show audit logs with pretty formatting
./scripts/latest-logs.sh --audit --format

# Show audit logs from last 2 hours
./scripts/latest-logs.sh --audit --time-window=2h --format
```

### `scripts/parse-audit-logs.py`

Python script that properly parses MXCP's audit log format (handles malformed JSON):

```bash
# Pipe audit logs through the parser
aws logs tail <log-group> | grep AUDIT | python3 scripts/parse-audit-logs.py
```

### Example Formatted Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🕐 Time: 18:38:48.223000 (2025-08-25)
🔧 Tool: aggregate_companies
✅ Status: success
⏱️  Duration: 58ms
📥 Input Parameters:
   • canton: Bern
   • page_size: 50
```

## Monitoring and Alerting

To monitor the service in production:

1. **Use the helper script** (recommended):
   ```bash
   ./scripts/latest-logs.sh --audit --format
   ```

2. **Direct AWS CLI commands**:
   ```bash
   # Find latest log group
   aws logs describe-log-groups --region eu-west-1 \
     --log-group-name-prefix "/aws/apprunner/swiss-mxcp-server" \
     --query 'sort_by(logGroups, &creationTime)[-1].logGroupName'
   
   # Filter audit logs only
   aws logs tail <log-group> --region eu-west-1 | grep "[AUDIT]"
   ```

3. **CloudWatch Insights query**:
   ```
   fields @timestamp, @message
   | filter @message like /\[AUDIT\]/
   | sort @timestamp desc
   ```

## Security and Compliance

- Sensitive parameters are automatically redacted
- All access is logged with caller context
- Logs include execution duration for performance monitoring
- Failed requests include detailed error information
- JSON format enables integration with SIEM systems

## Log Retention

- Local logs: Managed by application lifecycle
- CloudWatch logs: 30-day retention (configurable)
- Long-term storage: Can be exported to S3
