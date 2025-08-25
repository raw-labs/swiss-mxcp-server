# Swiss Business Registry MXCP Server

An AI-powered data exploration tool for Swiss business registry data, built with [MXCP (Model Context Protocol)](https://github.com/RAW-Labs/mxcp) and dbt. This server enables AI assistants to query and analyze Swiss company information through natural language interfaces.

## Overview

This MXCP server provides intelligent access to Swiss business registry data containing 1,000+ companies across all Swiss cantons. It demonstrates how to build production-ready AI data tools with comprehensive testing, audit logging, and cloud deployment capabilities.

### Key Features

- **Natural Language Queries**: Search and analyze companies using conversational language
- **Advanced Analytics**: Aggregate data by various dimensions, create time series analyses
- **Comprehensive Data Model**: Includes company details, legal forms, industries, and financial information
- **Production-Ready**: Complete with testing, audit logging, and AWS deployment
- **AI-Powered**: Integrates seamlessly with AI assistants like Claude, GPT-4, and others

## Quick Start

### Prerequisites

- Python 3.8+
- Virtual environment tool (venv)
- OpenAI API key (for AI-powered features)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/raw-labs/swiss-mxcp-server.git
cd swiss-mxcp-server
git submodule update --init --recursive  # Initialize deployment scripts
```

2. Create and activate a virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Install dbt dependencies:
```bash
dbt deps
```

5. Build the data model:
```bash
dbt run
```

### Running the Server

1. Start the MXCP server:
```bash
mxcp serve
```

2. Test the installation:
```bash
mxcp list
```

You should see 4 available tools:
- `search_companies` - Search for companies with filters
- `aggregate_companies` - Aggregate data by dimensions
- `timeseries_companies` - Time-based analysis
- `categorical_company_values` - Get distinct categorical values

### Testing

Run the comprehensive test suite:
```bash
./scripts/run_tests.sh
```

This runs:
- MXCP configuration validation
- dbt data quality tests
- Tool functionality tests
- Data integrity checks

## Available Tools

### 1. search_companies
Search for Swiss companies with various filters:
- Company name (exact or partial match)
- Canton, legal form, industry
- Capital range, employee count
- Registration date range

Example queries:
- "Find all AG companies in Zürich"
- "Show companies with more than 100 employees"
- "List recently registered startups"

### 2. aggregate_companies
Aggregate company data by one or two dimensions:
- Group by: canton, legal form, industry, founding year
- Metrics: count, average capital, total capital, average employees

Example queries:
- "What's the average share capital by legal form?"
- "Show company count by canton and industry"
- "Compare total capital across cantons"

### 3. timeseries_companies
Analyze trends over time:
- Date fields: registration date, founding date
- Intervals: day, week, month, quarter, year
- Metrics: count, averages, totals

Example queries:
- "Show monthly company registrations"
- "Track founding trends by year"
- "Analyze quarterly growth patterns"

### 4. categorical_company_values
Get distinct values for categorical fields:
- Available fields: canton, legal_form, industry_code, industry_description

Example queries:
- "List all Swiss cantons in the data"
- "What legal forms are available?"
- "Show all industry categories"

## Data Schema

The `swiss_companies` table contains:
- **CompanyName**: Company name
- **LegalForm**: Legal structure (AG, GmbH, etc.)
- **UID**: Unique Identification Number
- **RegistrationDate**: Official registration date
- **Canton**: Swiss canton
- **ShareCapitalCHF**: Share capital in Swiss Francs
- **IndustryCode**: Industry classification code
- **IndustryDescription**: Industry description
- **Employees**: Number of employees

## Production Features

### Audit Logging
All tool calls are automatically logged with:
- Timestamp and tool name
- Input parameters
- Execution time
- Success/error status

View audit logs:
```bash
./scripts/latest-logs.sh --audit
```

### Data Quality
Comprehensive dbt tests ensure:
- Valid Swiss cantons
- Proper legal forms
- Capital requirements (e.g., AG minimum 100,000 CHF)
- No duplicate companies
- Required fields are populated

### Cloud Deployment
Deploy to AWS App Runner:
```bash
cd exec/aws-apprunner
./shared-scripts/scripts/deploy-service.sh
```

Monitor deployment:
```bash
./shared-scripts/scripts/monitor-deployment.sh
```

## Development

### Project Structure
```
swiss-mxcp-server/
├── data/                  # Sample data and DuckDB database
├── models/                # dbt models and schema
├── sql/                   # SQL queries for tools
├── tools/                 # MXCP tool definitions
├── tests/                 # dbt and Python tests
├── scripts/               # Utility scripts
├── exec/aws-apprunner/    # Deployment configuration
└── evals/                 # MXCP evaluation scenarios
```

### Adding New Tools

1. Create SQL query in `sql/`
2. Define tool in `tools/` with YAML configuration
3. Add tests in `tests/python/`
4. Update documentation

### Testing Guidelines

Always run tests before deployment:
```bash
# Validate MXCP configuration
mxcp validate

# Run dbt tests
dbt test

# Run tool tests
python tests/python/test_swiss_companies_fixed.py

# Run all tests
./scripts/run_tests.sh
```

## Deployment

### AWS App Runner

The project includes complete AWS App Runner deployment:

1. Configure AWS credentials
2. Update `exec/aws-apprunner/project-config.sh`
3. Build and push Docker image:
   ```bash
   ./shared-scripts/scripts/build-and-push.sh
   ```
4. Deploy service:
   ```bash
   ./shared-scripts/scripts/deploy-service.sh
   ```

### Environment Variables

Required for deployment:
- `OPENAI_API_KEY` - For AI features (optional for basic testing)
- AWS credentials for deployment

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Built with [MXCP](https://github.com/RAW-Labs/mxcp) by RAW Labs
- Data transformation powered by [dbt](https://www.getdbt.com/)
- Sample data is fictional and for demonstration purposes only

## Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Check the [MXCP documentation](https://docs.mxcp.ai)
- Join the MXCP community discussions