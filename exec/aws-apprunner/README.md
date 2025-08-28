# AWS App Runner Deployment

This directory contains everything needed to deploy the Swiss Business Registry MXCP Server to AWS App Runner.

## Directory Structure

- `Dockerfile` - Container image definition
- `project-config.sh` - Project-specific configuration
- `shared-scripts/` - Common deployment scripts (git submodule from [mxcp-deployment-scripts](https://github.com/raw-labs/mxcp-deployment-scripts))
- `config/` - Deployment configuration files
- `test-docker-locally.sh` - Local Docker testing script
- `start.sh` - Container startup script with audit logging
- `mxcp-site-docker.yml` - MXCP configuration for Docker environment
- `profiles-docker.yml` - dbt profiles for Docker environment
- `mxcp-user-config.yml` - MXCP user configuration with permissions

## Quick Start

1. Copy and configure environment:
   ```bash
   cp environment.example .env
   # Edit .env and set AWS_ACCOUNT_ID
   ```

2. Test locally:
   ```bash
   ./test-docker-locally.sh
   ```

3. Deploy to AWS:
   ```bash
   ./shared-scripts/scripts/build-and-push.sh
   ./shared-scripts/scripts/deploy-service.sh
   ```

4. Monitor deployment:
   ```bash
   ./shared-scripts/scripts/monitor-deployment.sh
   ```

## Configuration

Edit `project-config.sh` to adjust:
- Service name
- Instance size (CPU/Memory)
- AWS region
- ECR repository settings

## Features

### Audit Logging
The deployment includes automatic audit logging:
- All MXCP tool calls are logged to `/app/logs/audit.jsonl`
- Logs are streamed to CloudWatch with `[AUDIT]` prefix
- Use helper scripts to view and parse audit logs

### Health Checks
- HTTP proxy on port 8080 provides health endpoints
- `/health` - Basic health check
- `/ready` - Readiness check (verifies MXCP is running)

## Testing

Test the deployed service:
```bash
./shared-scripts/scripts/test-remote-service.sh
```

View audit logs:
```bash
# From project root
./shared-scripts/scripts/latest-logs.sh --audit
```

## Troubleshooting

1. **Container fails to start**: Check CloudWatch logs for errors
2. **MXCP validation fails**: Ensure all YAML files are valid
3. **Database not found**: Verify dbt models are built during container startup
4. **Audit logs missing**: Check permissions on `/app/logs/` directory

## Updating Deployment Scripts

The `shared-scripts` directory is a git submodule. To update:
```bash
cd shared-scripts
git pull origin main
cd ..
git add shared-scripts
git commit -m "Update deployment scripts"
```