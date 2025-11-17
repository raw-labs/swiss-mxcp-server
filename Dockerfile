FROM ghcr.io/raw-labs/mxcp:0.10.0-rc12

COPY --chown=mxcp:mxcp . /mxcp-site/

RUN dbt deps

RUN dbt run