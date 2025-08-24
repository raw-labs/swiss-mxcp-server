# Swiss Business Registry MXCP Server

[![Tests](https://img.shields.io/badge/tests-passing-green)](#testing)
[![Tools](https://img.shields.io/badge/tools-4-blue)](#available-tools)
[![Data](https://img.shields.io/badge/companies-1000-brightgreen)](#data-model)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Deployment](https://img.shields.io/badge/AWS-deployed-orange)](#live-demo)

A comprehensive MXCP server providing AI-powered access to Swiss business registry data. This project transforms synthetic Swiss company data into a queryable, analytics-ready API designed for the **RAW Labs MXCP** platform and seamlessly integrates with LLMs like Claude for natural language querying.

---

## 🎯 Purpose

Professional demonstration project showcasing **MXCP (Model Context Protocol)** capabilities using Swiss business data. Perfect for demonstrating:

- **Natural Language Business Intelligence**: Query Swiss companies using plain English
- **LLM Integration**: Built for GPT-4, Claude, and other LLMs
- **Real-world Data Analysis**: 1,000 synthetic Swiss companies with realistic business data
- **Multi-modal Querying**: Search, aggregate, analyze trends, and explore categorical data

---

## Key Features

| Feature                    | Description                                                                                      |
| -------------------------- | ------------------------------------------------------------------------------------------------ |
| **🏢 Swiss Business Data** | 1,000 synthetic companies with realistic Swiss business registry information                    |
| **🤖 4 Specialized Tools** | Search, aggregate, timeseries analysis, and categorical data exploration                        |
| **🧠 LLM-Ready**           | Natural language querying capabilities with comprehensive tool descriptions                      |
| **📊 dbt Data Pipeline**   | Automated data transformation pipeline with quality validation                                   |
| **🔍 Advanced Filtering**  | Filter by canton, legal form, capital, employees, registration date, and industry               |
| **📈 Analytics Ready**     | Built-in aggregation and time-series analysis capabilities                                      |
| **☁️ Cloud Deployable**    | Production-ready AWS App Runner deployment with health checks                                    |
| **🧪 Comprehensively Tested** | 3-level testing: dbt data quality, MXCP tool tests, and evaluation suites               |

---

## 🚀 Quick Start

> **Prerequisites:** Python 3.8+, git, and OpenAI API key (for LLM features)

### 1. Setup Environment
```bash
git clone https://github.com/raw-labs/swiss-mxcp-server.git
cd swiss-mxcp-server

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set API key for LLM features
export OPENAI_API_KEY="your-api-key"
```

### 2. Build Data Pipeline & Run Tests
```bash
# Run comprehensive test suite (builds data, validates tools)
./scripts/run_tests.sh

# Or manual setup:
dbt deps              # Install dbt dependencies
dbt run               # Build data models
mxcp validate         # Validate tool configurations
```

### 3. Start MXCP Server
```bash
# Start the server
mxcp serve --port 8000

# Server available at: http://localhost:8000
# MCP Endpoint: http://localhost:8000/mcp
```

### 4. Verify Installation
```bash
# Quick functionality test
curl -X POST http://localhost:8000/tools/search_companies \
  -H "Content-Type: application/json" \
  -d '{"canton": "Zürich", "page_size": 5}'
```

---

## 📊 Data Model

### Swiss Company Data
The project contains **1,000 synthetic Swiss companies** with realistic business registry information:

#### Company Attributes
- **Company Name**: Swiss company names (German, French, Italian)
- **Legal Form**: AG, GmbH, Einzelfirma, Kollektivgesellschaft, Verein, Stiftung
- **Swiss Cantons**: All 26 cantons represented (Zürich, Bern, Geneva, etc.)
- **Share Capital**: Realistic capital amounts in CHF
- **Employee Count**: Company size from 1 to 100,000+ employees  
- **Industry Codes & Descriptions**: Swiss industry classification
- **Registration Dates**: Historical registration data from 1990-2025
- **Unique IDs**: Swiss business registry UIDs

#### Data Distribution
- **By Canton**: Zürich (253), Geneva (151), Bern (111), others distributed realistically
- **By Legal Form**: GmbH (399), AG (347), Einzelfirma (176), others (78)
- **By Industry**: Technology, Finance, Manufacturing, Services, and more
- **Capital Range**: From CHF 20,000 to CHF 100M+

### Database Schema
The final `swiss_companies` table contains:
- `UID`: Unique business registry identifier
- `CompanyName`: Company name  
- `LegalForm`: Legal structure
- `Canton`: Swiss canton location
- `ShareCapitalCHF`: Share capital amount
- `Employees`: Number of employees
- `IndustryCode` & `IndustryDescription`: Industry classification
- `RegistrationDate`: Date of business registration

---

## 🔧 Available Tools

### 1. search_companies
Search and filter Swiss companies with comprehensive filtering options.

**Parameters:**
- `company_name`: Exact company name match
- `company_name_like`: Partial name search  
- `uid`: Unique identification number
- `legal_form`: Legal form (AG, GmbH, etc.)
- `canton`: Swiss canton name
- `industry_code`: Industry classification code
- `min_capital` / `max_capital`: Share capital range in CHF
- `min_employees` / `max_employees`: Employee count range
- `registration_date_from` / `registration_date_to`: Date range (YYYY-MM-DD)
- `page`, `page_size`: Pagination controls

**Example:** Find large AG companies in Zürich
```json
{
  "legal_form": "AG",
  "canton": "Zürich", 
  "min_capital": 1000000,
  "min_employees": 100
}
```

### 2. aggregate_companies  
Aggregate and analyze company data by various dimensions.

**Parameters:**
- `group_by`: Group by field (Canton, LegalForm, IndustryCode, IndustryDescription)
- All search_companies filter parameters for subset analysis
- `page_size`: Results per page (default: 50)

**Example:** Company distribution by canton
```json
{
  "group_by": "Canton"
}
```

**Returns:** Count, total capital, average capital, total employees, average employees per group.

### 3. timeseries_companies
Analyze company registration trends over time.

**Parameters:**  
- `interval`: Time granularity (month or year, default: month)
- All search_companies filter parameters for subset analysis
- `page_size`: Results per page (default: 100)

**Example:** Monthly registration trend for tech companies
```json
{
  "interval": "month",
  "industry_description_like": "Technology"
}
```

### 4. categorical_company_values
Get distinct values for categorical fields to support dynamic filtering.

**Parameters:**
- `field`: Field name (legal_form, canton, industry_code, industry_description)

**Example:** Get all available legal forms
```json
{
  "field": "legal_form"
}
```

**Returns:** List of distinct values for the specified field.

---

## 💡 Example Use Cases & Queries

### Business Intelligence Queries
1. **Market Analysis**: "Show me the distribution of companies by Swiss canton"
2. **Legal Structure Analysis**: "What's the average share capital for AG vs GmbH companies?"
3. **Geographic Insights**: "Which cantons have the most technology companies?"
4. **Growth Trends**: "Show company registrations by year over the last decade"
5. **Industry Analysis**: "List the top industries by employee count"

### Sales & Prospecting  
6. **Target Identification**: "Find large AG companies in Zürich with over 1M CHF capital"
7. **Market Sizing**: "How many financial services companies are there in Geneva?"
8. **Competitive Analysis**: "Show me companies similar to UBS in size and industry"

### Compliance & Research
9. **Regulatory Compliance**: "List all companies that meet minimum AG capital requirements"
10. **Due Diligence**: "Show me the complete profile for company UID CHE-123.456.789"

### Trend Analysis
11. **Registration Patterns**: "Which months see the highest company registrations?"
12. **Economic Indicators**: "Has company formation increased or decreased recently?"
13. **Regional Growth**: "Which cantons are seeing the most new business formation?"

---

## 🧪 Testing

This project includes comprehensive testing at **three levels** to ensure data quality and tool functionality.

### Automated Test Suite
```bash
# Run all tests with one command
./scripts/run_tests.sh
```

The test suite includes:

#### 1. **dbt Data Quality Tests** (26 tests)
- **Schema validation**: Not null, unique, accepted values
- **Business rules**: AG capital requirements, Swiss canton validation  
- **Data integrity**: No duplicates, reasonable ranges
- **Custom SQL tests**: Swiss-specific validation logic

#### 2. **MXCP Tool Tests** (6 comprehensive test suites) 
- **Individual tool functionality**: All 4 tools tested end-to-end
- **Parameter validation**: Required vs optional parameters
- **Data quality verification**: 1,000 companies loaded correctly
- **Edge case handling**: Empty results, invalid inputs, pagination
- **Error scenarios**: Graceful failure handling

#### 3. **MXCP Evaluations** (3 evaluation suites)
- **Basic functionality**: Core tool operations
- **Business analysis scenarios**: Real-world query patterns
- **Edge cases**: Complex filtering, error conditions

### Manual Testing Commands

#### Individual Test Components
```bash
# Validate MXCP configuration
mxcp validate

# Run dbt data quality tests  
dbt test --store-failures

# Test specific tool functionality
python tests/python/test_swiss_companies.py

# Quick data verification
duckdb data/mxcp.duckdb "SELECT count(*) FROM swiss_companies"
```

#### Expected Test Results
- **✅ All 4 MXCP tools** should pass validation
- **✅ 16+ dbt tests** should pass (core data quality)
- **✅ 6/6 Python test suites** should pass
- **✅ 1,000 companies** loaded in database
- **✅ All Swiss cantons** represented in data

---

## 🚀 Deployment

### AWS App Runner Deployment

This project is **production-ready** and includes complete AWS App Runner deployment automation.

#### Quick Deployment
```bash
cd exec/aws-apprunner

# Set environment variables
export AWS_ACCOUNT_ID="your-account-id"
export OPENAI_API_KEY="your-api-key"

# Deploy to AWS App Runner
./shared-scripts/scripts/build-and-push.sh
./shared-scripts/scripts/deploy-service.sh

# Monitor deployment
./shared-scripts/scripts/monitor-deployment.sh
```

#### Deployment Features
- **Containerized**: Docker-based deployment with all dependencies
- **Health Checks**: Custom health check endpoint at `/health`
- **Auto-scaling**: AWS App Runner handles traffic scaling automatically
- **Secure**: Environment variable injection for API keys
- **Monitored**: Deployment monitoring and status checking

#### Production Configuration
- **Resources**: 1 vCPU, 4GB RAM (configurable)
- **Port**: 8000 (HTTP)
- **Health Check**: HTTP GET /health
- **Database**: Embedded DuckDB (no external dependencies)
- **Logging**: Debug logging enabled

#### Testing Deployed Service
```bash
# Test the deployed service
curl https://your-service-url.awsapprunner.com/health

# Test tool functionality
curl -X POST https://your-service-url.awsapprunner.com/tools/search_companies \
  -H "Content-Type: application/json" \
  -d '{"canton": "Zürich", "page_size": 5}'
```

For detailed deployment instructions, see [`exec/aws-apprunner/README.md`](exec/aws-apprunner/README.md).

---

## 🏗️ Development

### Project Structure
```
swiss-mxcp-server/
├── data/
│   ├── swiss-business-registry-sample.csv  # Source data
│   └── mxcp.duckdb                         # Built database
├── models/
│   ├── swiss_companies.sql                 # dbt data model  
│   └── schema.yml                          # dbt tests & documentation
├── sql/                                    # SQL query templates
│   ├── search_companies.sql
│   ├── aggregate_companies.sql
│   ├── timeseries_companies.sql
│   └── categorical_company_values.sql
├── tools/                                  # MXCP tool definitions
│   ├── search_companies.yml
│   ├── aggregate_companies.yml
│   ├── timeseries_companies.yml
│   └── categorical_company_values.yml
├── tests/
│   ├── python/                             # Python test suite
│   │   └── test_swiss_companies.py
│   ├── assert_valid_swiss_cantons.sql      # Custom dbt tests
│   ├── assert_no_duplicate_companies.sql
│   └── assert_ag_minimum_capital.sql
├── evals/                                  # MXCP evaluation suites
│   ├── basic_swiss_registry.yml
│   ├── business_analysis.yml
│   └── edge_cases.yml
├── scripts/
│   └── run_tests.sh                        # Comprehensive test runner
├── exec/                                   # Deployment configurations
│   └── aws-apprunner/                      # AWS App Runner deployment
│       ├── Dockerfile
│       ├── requirements.txt
│       ├── config/
│       └── shared-scripts/
├── dbt_project.yml                         # dbt configuration
├── profiles.yml                            # dbt profiles
├── mxcp-site.yml                          # MXCP configuration  
└── README.md                              # This file
```

### Running dbt Models
```bash
# Install dependencies
dbt deps

# Build all models
dbt run

# Test data quality
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

### Adding New Tools
1. Create SQL query in `sql/`
2. Create YAML tool definition in `tools/`
3. Add tests in `tests/python/`
4. Validate with `mxcp validate`

### Querying the Database Directly
```bash
# Direct DuckDB queries
duckdb data/mxcp.duckdb

# Example analysis query
SELECT Canton, COUNT(*) as company_count, 
       AVG(ShareCapitalCHF) as avg_capital
FROM swiss_companies 
GROUP BY Canton 
ORDER BY company_count DESC;
```

---

## 📚 Sample Questions

Here are example questions you can ask the Swiss Business Registry MXCP system:

### General Business Intelligence
1. "Show me a summary of all Swiss companies in the registry"
2. "How many companies are there in each Swiss canton?"  
3. "What's the average share capital by legal form?"
4. "Which legal forms are most common in Switzerland?"

### Geographic Analysis  
5. "Find all companies in Zürich with over 1 million CHF capital"
6. "Which canton has the most AG companies?"
7. "Show me the distribution of companies across all Swiss cantons"
8. "Compare company formation in Zürich vs Geneva"

### Industry & Sector Analysis
9. "What industries are most represented in the Swiss business registry?"
10. "Find technology companies with over 100 employees"  
11. "Show me all financial services companies in Basel"
12. "Which industries have the highest average share capital?"

### Temporal & Trend Analysis
13. "Show company registrations by year over the last decade"
14. "Which months see the most company formations?"
15. "Has business registration increased or decreased recently?"
16. "Show the trend of AG vs GmbH formations over time"

### Specific Company Research  
17. "Find companies with 'Technology' in their industry description"
18. "Show me all companies with exactly 1 million CHF capital"
19. "List companies registered in the year 2020"
20. "Find the largest employers in Switzerland"

### Legal Form Analysis
21. "How do AG and GmbH companies compare in terms of capital?"
22. "Which legal forms meet the minimum capital requirements?"
23. "Show me all Stiftung (foundation) organizations"
24. "What percentage of companies are AG vs GmbH?"

### Advanced Analytics
25. "Find companies that are outliers in terms of employee count"
26. "Show me the capital distribution across different cantons"  
27. "Which combination of canton and legal form is most common?"
28. "Analyze company size by legal form and geographic distribution"

These questions demonstrate the versatility of the Swiss Business Registry MXCP system for business intelligence, market research, and regulatory analysis.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🌐 Live Demo

**Production Service**: https://ru9grd9gq8.eu-west-1.awsapprunner.com/mcp  
**Status**: ✅ Running  
**Resources**: 1 vCPU, 4GB RAM  

*Note: This is a live MXCP server endpoint for integration with LLM applications and Claude Desktop.*

---

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests locally (`./scripts/run_tests.sh`)
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

---

## 🤝 Acknowledgments

- **Powered by**: [RAW Labs MXCP Platform](https://github.com/raw-labs)
- **Data Pipeline**: dbt for data transformation
- **Database**: DuckDB for efficient analytics  
- **Deployment**: AWS App Runner for production hosting
- **Testing**: Comprehensive 3-level validation approach
- **Data**: Synthetic Swiss business registry data for demonstration

---

## 🆘 Support

For questions or issues:

1. **Check Documentation**: Review this README and run `./scripts/run_tests.sh`
2. **Validate Configuration**: Run `mxcp validate` to check tool setup
3. **Test Locally**: Execute `python tests/python/test_swiss_companies.py`
4. **Open Issues**: Use GitHub Issues for bugs and feature requests

**Current Status**: ✅ All systems operational, comprehensive test coverage, production-ready deployment