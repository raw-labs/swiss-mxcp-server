# MXCP Deployment Scripts

Shared deployment scripts for all MXCP (Model Context Protocol) projects using AWS App Runner.

## 📁 Repository Structure

```
mxcp-deployment-scripts/
├── scripts/                        # Deployment scripts
│   ├── build-and-push.sh          # Build Docker image and push to ECR
│   ├── deploy-service.sh          # Create/update App Runner service
│   ├── monitor-deployment.sh      # Monitor deployment progress
│   └── test-remote-service.sh     # Test deployed service
├── templates/                      # Templates for new projects
│   └── project-config.template.sh # Configuration template
└── README.md                      # This file
```

## 🚀 Quick Start

### For New Projects

1. Add this repository as a git submodule:
   ```bash
   git submodule add ../mxcp-deployment-scripts.git exec/aws-apprunner/shared-scripts
   ```

2. Copy and customize the configuration template:
   ```bash
   cd exec/aws-apprunner
   cp shared-scripts/templates/project-config.template.sh project-config.sh
   # Edit project-config.sh with your project-specific values
   ```

3. Use the scripts:
   ```bash
   ./shared-scripts/scripts/build-and-push.sh
   ./shared-scripts/scripts/deploy-service.sh
   ./shared-scripts/scripts/monitor-deployment.sh
   ```

### For Existing Projects

See the migration section below.

## 📋 Configuration

Each project must have a `project-config.sh` file with these required variables:

- `SERVICE_NAME` - Your App Runner service name
- `ECR_REPOSITORY` - Your ECR repository name  
- `MXCP_PROJECT` - Your MXCP project name

See `templates/project-config.template.sh` for a complete example.

## 🔧 Available Scripts

### build-and-push.sh
Builds Docker image and pushes to Amazon ECR.
```bash
./build-and-push.sh [tag] [skip-build]
# Examples:
./build-and-push.sh                # Build and push with 'latest' tag
./build-and-push.sh v1.2.3         # Build and push with specific tag
./build-and-push.sh v1.2.3 true    # Push existing image with new tag
```

### deploy-service.sh
Creates or updates App Runner service.
```bash
./deploy-service.sh [tag]
# Examples:
./deploy-service.sh                 # Deploy latest image
./deploy-service.sh v1.2.3         # Deploy specific tag
```

### monitor-deployment.sh
Monitors deployment progress in real-time.
```bash
./monitor-deployment.sh
```

### test-remote-service.sh
Tests the deployed service endpoints.
```bash
./test-remote-service.sh
```

## 🔄 Migration Guide

To migrate an existing project:

1. Remove old scripts:
   ```bash
   cd exec/aws-apprunner
   rm -f build-and-push.sh deploy-service.sh monitor-deployment.sh test-remote-service.sh
   ```

2. Add shared scripts as submodule:
   ```bash
   git submodule add ../mxcp-deployment-scripts.git shared-scripts
   ```

3. Update your `project-config.sh` to ensure all required variables are set.

4. Update `deploy.yml` to use shared scripts:
   ```yaml
   - run: |
       cd exec/aws-apprunner
       ./shared-scripts/scripts/build-and-push.sh "${{ github.sha }}"
   ```

## 📝 Script Behavior

The scripts automatically search for `project-config.sh` in these locations:
1. Current directory (`./project-config.sh`)
2. Parent directory (`../project-config.sh`)
3. Two levels up (`../../project-config.sh`)
4. Standard project structure (`../../exec/aws-apprunner/project-config.sh`)

This allows flexibility in where you run the scripts from.

## 🔒 Security

- Never commit credentials to `project-config.sh`
- Use environment variables for sensitive data:
  ```bash
  export SALESFORCE_INSTANCE_URL="..."
  export SALESFORCE_USERNAME="..."
  export SALESFORCE_PASSWORD="..."
  export SALESFORCE_SECURITY_TOKEN="..."
  export SALESFORCE_CLIENT_ID="..."
  ```

## 🚨 Troubleshooting

### project-config.sh not found
Ensure you're running scripts from `exec/aws-apprunner/` or that `project-config.sh` exists in one of the search paths.

### Permission denied
```bash
chmod +x shared-scripts/scripts/*.sh
```

### Submodule issues
```bash
git submodule update --init --recursive
```

## 🔄 Updating Scripts

To get the latest version of shared scripts:
```bash
cd exec/aws-apprunner
git submodule update --remote shared-scripts
git add shared-scripts
git commit -m "Update shared deployment scripts"
```

## 📚 Project Requirements

Projects using these scripts must have:
- `exec/aws-apprunner/project-config.sh` - Configuration file
- `exec/aws-apprunner/Dockerfile` - Docker build instructions
- AWS credentials configured
- ECR repository access
- App Runner service permissions

## 🤝 Contributing

1. Make changes in this repository
2. Test with at least one project
3. Update all projects to pull latest changes
4. Document any breaking changes

## 📄 License

Internal use only - Raw Labs proprietary.
