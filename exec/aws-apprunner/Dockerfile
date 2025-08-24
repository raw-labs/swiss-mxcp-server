# Build stage
FROM python:3.11-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt exec/aws-apprunner/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Copy Docker-specific configurations
COPY exec/aws-apprunner/mxcp-site-docker.yml mxcp-site.yml
COPY exec/aws-apprunner/profiles-docker.yml profiles.yml

# Install dbt packages
RUN dbt deps --profiles-dir . --project-dir .

# Build dbt models during image creation
RUN dbt run --profiles-dir . --project-dir . --target prod

# Run dbt tests to validate models
RUN dbt test --profiles-dir . --project-dir . --target prod

# Final stage
FROM python:3.11-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1001 appuser

# Set working directory
WORKDIR /app

# Copy from builder
COPY --from=builder --chown=appuser:appuser /app /app
COPY --from=builder --chown=appuser:appuser /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder --chown=appuser:appuser /usr/local/bin /usr/local/bin

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DBT_PROFILES_DIR=/app
ENV MXCP_DEBUG=true
ENV MXCP_PROFILE=prod

# Run MXCP server
CMD ["mxcp", "serve", "--host", "0.0.0.0", "--port", "8000"]
