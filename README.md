# Swiss Business Registry MXCP Server

An AI-powered data exploration tool for Swiss business registry data, built with [MXCP (Model Context Protocol)](https://github.com/RAW-Labs/mxcp) and dbt. This server enables AI assistants to query and analyze Swiss company information through natural language interfaces.

## Overview

This MXCP server provides intelligent access to Swiss business registry data containing 1,000+ companies across all Swiss cantons. It demonstrates how to build production-ready AI data tools with comprehensive testing, audit logging, and cloud deployment capabilities.

## Quick Start

## Available Tools

All tools support comprehensive filtering with the following parameters:
- **company_name** / **company_name_like**: Exact or partial company name match
- **uid**: Unique Identification Number
- **legal_form**: Legal form (AG, GmbH, etc.)
- **canton**: Swiss canton
- **industry_code**: Industry classification code
- **min_capital** / **max_capital**: Share capital range in CHF
- **min_employees** / **max_employees**: Employee count range
- **registration_date_from** / **registration_date_to**: Registration date range

### 1. search_companies
Search for Swiss companies with pagination support.

Example queries:
- "Find all AG companies in Zürich with capital over 1M CHF"
- "Show companies with 50-200 employees registered in 2024"
- "List companies with 'Tech' in their name"

### 2. aggregate_companies
Aggregate company data by one or two dimensions:
- **Group by** (comma-separated, max 2): Canton, LegalForm, IndustryCode, IndustryDescription, RegistrationYear
- **Metrics** (comma-separated): count, total_capital, avg_share_capital, min_capital, max_capital, total_employees, avg_employees

Example queries:
- "What's the average share capital by legal form?"
- "Show company count by canton and legal form" (two-level grouping)
- "Compare total capital by industry for Zürich companies"
- "Group by canton,legalform and show count and average capital"

### 3. timeseries_companies
Analyze trends over time:
- **date_field**: Currently supports RegistrationDate
- **interval**: day, week, month, quarter, year
- Supports all standard filters

Example queries:
- "Show monthly company registrations for AG companies"
- "Track quarterly registrations with capital > 500K"
- "Analyze yearly growth patterns by canton"

### 4. categorical_company_values
Get distinct values for categorical fields:
- **field**: canton, legal_form, industry_code, industry_description

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

## Release

```bash
git tag v1.0.0 && git push origin v1.0.0
# → Builds Docker image automatically via GitHub Actions
```
