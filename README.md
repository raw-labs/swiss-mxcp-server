# Swiss Business Registry MXCP Server

A simple MXCP demo server providing access to synthetic Swiss business registry data.

## 🎯 Purpose

Demo project for Squirro sales representatives to showcase MXCP capabilities using Swiss business data (1,000 synthetic companies).

## 🚀 Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Install dbt packages
dbt deps

# Build data models
dbt run

# Start MXCP server
mxcp serve
```

Server available at: http://localhost:8000

## 📊 Available Tools

1. **search_companies** - Search companies with filters
2. **aggregate_companies** - Aggregate by canton, legal form, etc.
3. **timeseries_companies** - Analyze registrations over time
4. **categorical_company_values** - Get distinct field values
5. **execute_sql_query** - Run custom SQL queries

## 🚀 Deployment

See `exec/aws-apprunner/README.md` for AWS deployment instructions.

## 📝 Example Queries

- "Show me all AG companies in Zürich"
- "What's the average capital by legal form?"
- "Show company registrations by month"
- "List all available cantons"

## 📁 Project Structure

```
├── data/                  # Swiss company CSV data
├── models/               # Single dbt model
├── sql/                 # SQL queries for tools
├── tools/               # MXCP tool definitions
├── tests/               # Simple dbt tests
└── exec/                # AWS deployment scripts
```