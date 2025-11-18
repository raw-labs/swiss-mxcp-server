FROM ghcr.io/raw-labs/mxcp:0.10.0-rc14

COPY --chown=mxcp:mxcp . /mxcp-site/

RUN dbt deps

RUN dbt run