# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the Swiss MXCP Server project.

## Available Workflows

### 1. Tests (`test.yml`)
- **Trigger**: Pull requests to `main` or `develop` branches, or manual dispatch
- **Purpose**: Run the complete test suite including:
  - MXCP validation tests
  - dbt schema tests
  - Tool functionality tests
  - Data quality tests
- **Requirements**: 
  - `OPENAI_API_KEY` secret for evaluation tests
  - `GH_PAT` secret for submodule access

### 2. Deploy to AWS (`deploy.yml`)
- **Trigger**: Push to `main` branch, or manual dispatch
- **Purpose**: Deploy the MXCP server to AWS App Runner
- **Process**:
  1. Runs all tests first
  2. Builds Docker image and pushes to ECR
  3. Updates App Runner service
  4. Monitors deployment until complete
  5. Tests the deployed service
- **Requirements**:
  - `AWS_ACCESS_KEY_ID` secret
  - `AWS_SECRET_ACCESS_KEY` secret
  - `GH_PAT` secret for submodule access
  - `OPENAI_API_KEY` secret for tests

### 3. Release (`release.yml`)
- **Trigger**: Manual dispatch only
- **Purpose**: Create a new version release
- **Process**:
  1. Validates version format (must be vX.Y.Z)
  2. Generates changelog from commits
  3. Creates git tag
  4. Creates GitHub release
  5. Optionally triggers deployment
- **Inputs**:
  - `version`: Version to release (e.g., v1.0.0)
  - `release_notes`: Additional release notes

## Required Repository Secrets

Configure these in your repository settings under Secrets and Variables > Actions:

1. **AWS_ACCESS_KEY_ID**: AWS access key for deployment
2. **AWS_SECRET_ACCESS_KEY**: AWS secret key for deployment
3. **OPENAI_API_KEY**: OpenAI API key for running evaluation tests
4. **GH_PAT**: GitHub Personal Access Token with repo scope (for accessing submodules)

## Manual Workflow Dispatch

You can manually trigger workflows from the Actions tab:

1. Go to the Actions tab in your repository
2. Select the workflow you want to run
3. Click "Run workflow"
4. Fill in any required inputs
5. Click "Run workflow" to start

## Deployment Configuration

The deployment workflow uses these settings (defined in `deploy.yml`):
- **AWS Region**: eu-west-1
- **AWS Account**: 684130658470
- **ECR Repository**: swiss-mxcp-server
- **App Runner Service**: swiss-mxcp-server

To modify these, edit the `env` section in `deploy.yml`.

## Best Practices

1. **Always test locally first**: Run `./scripts/run_tests.sh` before pushing
2. **Use pull requests**: Tests run automatically on PRs to catch issues early
3. **Tag releases**: Use semantic versioning (v1.0.0, v1.1.0, etc.)
4. **Monitor deployments**: Check the Actions tab for deployment status
5. **Review logs**: Download test artifacts if tests fail

## Troubleshooting

### Tests Failing
- Check if `OPENAI_API_KEY` is set correctly in secrets
- Ensure submodules are properly initialized
- Review test logs in the uploaded artifacts

### Deployment Failing
- Verify AWS credentials are correct and have necessary permissions
- Check if ECR repository exists
- Ensure App Runner service is properly configured
- Review deployment logs in the Actions tab

### Release Failing
- Ensure version format is correct (vX.Y.Z)
- Check if the tag already exists
- Verify you have push permissions to create tags
