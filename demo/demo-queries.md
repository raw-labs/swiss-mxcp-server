# MXCP Demo Queries for Squirro Presentation

## Core Demo Queries (in order)

### 1. Simple Search
```
Find companies in Zurich with more than 1 million CHF capital
```

### 2. Distribution Analysis  
```
What's the distribution of companies across Swiss cantons? 
Show me the top 5 cantons by number of companies.
```

### 3. Multi-step Analysis
```
Which industries are most common in Geneva? 
Then find the largest company in the top industry.
```

### 4. Report Generation
```
Create a summary report of all technology companies founded in the last 5 years, 
grouped by canton, including average funding and employee count
```

## Alternative Queries (if needed)

### For Performance Discussion
```
How many companies are registered in the Swiss business registry?
What's the total capital of all companies?
```

### For Security Discussion  
```
Show me companies but exclude any sensitive information
List only public company names in Bern
```

### For Squirro Use Cases
```
Find all companies that might be potential Squirro customers 
(technology sector, >50 employees)
```

```
Which cantons have the most growing tech ecosystem 
(most new companies in last 2 years)?
```

## Error Handling Examples

### Show graceful errors
```
Find companies in InvalidCanton
```

```
Search for companies with negative capital
```

## Quick Facts for Q&A

- Database: DuckDB (in-memory analytics)
- Dataset: 1000 Swiss companies (sample data)
- Response time: <100ms for most queries
- Audit logs: Every query logged with timestamp, parameters, duration
- Security: Data never leaves the server, only query results returned
