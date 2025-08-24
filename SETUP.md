# Swiss MXCP Server Setup

## Project Created! ✅

I've created a simplified Swiss MXCP demo server at:
`/opt/projects/raw/projects/swiss-mxcp-server`

## What I Did:

1. **Created project structure** - Minimal and demo-friendly
2. **Copied Swiss demo data** - 1,000 synthetic companies  
3. **Built simple models** - Just one table: `swiss_companies`
4. **Created basic tools** - Search, aggregate, timeseries, and categorical values
5. **Set up AWS deployment** - Using improved scripts from hkma-mxcp-server
6. **Initialized git** - Ready to push to remote

## Next Steps:

1. **Create remote repository** on GitHub/GitLab
2. **Add remote and push**:
   ```bash
   cd /opt/projects/raw/projects/swiss-mxcp-server
   git remote add origin <your-repo-url>
   git push -u origin master
   ```

3. **To run locally** (requires dbt and mxcp installed):
   ```bash
   pip install -r requirements.txt
   dbt deps
   dbt run
   mxcp serve
   ```

4. **To deploy to AWS**:
   ```bash
   cd exec/aws-apprunner
   cp environment.example .env
   # Edit .env with your AWS account ID
   ./test-docker-locally.sh
   ./shared-scripts/scripts/build-and-push.sh
   ./shared-scripts/scripts/deploy-service.sh
   ```

## Key Simplifications:

- Single dbt model (no staging/marts complexity)
- Basic tools only (removed geo capabilities)
- Minimal test suite
- No complex configurations
- Demo-optimized structure

Perfect for sales demos! 🚀
