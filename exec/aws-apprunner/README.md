# AWS App Runner Deployment

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

## Testing

Test the deployed service:
```bash
./shared-scripts/scripts/test-remote-service.sh
```
