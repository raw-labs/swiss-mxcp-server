# Swiss MXCP Server - Single stage build following HKMA pattern
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Create non-root user
RUN groupadd -r mxcp && useradd -r -g mxcp -m -d /home/mxcp mxcp

# Copy requirements first for better caching
COPY exec/aws-apprunner/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY --chown=mxcp:mxcp exec/aws-apprunner/mxcp-site-docker.yml ./mxcp-site.yml

# Copy SQL files
COPY --chown=mxcp:mxcp sql/ ./sql/

# Copy tools
COPY --chown=mxcp:mxcp tools/ ./tools/

# Copy models for dbt
COPY --chown=mxcp:mxcp models/ ./models/

# Copy dbt files
COPY --chown=mxcp:mxcp dbt_project.yml ./dbt_project.yml
COPY --chown=mxcp:mxcp exec/aws-apprunner/profiles-docker.yml ./profiles.yml
COPY --chown=mxcp:mxcp packages.yml ./packages.yml

# Copy MXCP user config to bind to all interfaces
RUN mkdir -p /home/mxcp/.mxcp
COPY --chown=mxcp:mxcp exec/aws-apprunner/mxcp-user-config.yml /home/mxcp/.mxcp/config.yml

# Copy data directory (CSV files only)
COPY --chown=mxcp:mxcp data/swiss-business-registry-sample.csv ./data/swiss-business-registry-sample.csv

# Ensure data directory has write permissions for DuckDB and create logs directory
RUN chmod -R 755 ./data && chown -R mxcp:mxcp ./data && \
    rm -f ./data/*.duckdb ./data/*.wal && \
    mkdir -p ./logs && chown -R mxcp:mxcp ./logs && chmod -R 755 ./logs

# Build dbt models during image build (not at runtime)
RUN cd /app && \
    echo "Building dbt models..." && \
    dbt deps --profiles-dir . --project-dir . && \
    dbt run --profiles-dir . --project-dir . && \
    echo "✅ dbt models built successfully" && \
    chown -R mxcp:mxcp /app/data/

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV PORT=8000
ENV MXCP_PROFILE=prod
ENV MXCP_TRANSPORT=streamable-http
ENV HOME=/home/mxcp
ENV DBT_PROFILES_DIR=/app
ENV PYTHONLOGLEVEL=INFO

# Switch to non-root user
USER mxcp

# Expose port
EXPOSE $PORT

# Create a simple startup script with health endpoint
COPY --chown=mxcp:mxcp exec/aws-apprunner/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Start the wrapper script
CMD ["/app/start.sh"]
