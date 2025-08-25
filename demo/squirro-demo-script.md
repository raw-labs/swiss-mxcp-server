# Squirro MXCP Demo Script (8-10 minutes)

## Setup Before Demo
1. Have the Swiss MXCP Server running on App Runner
2. Open Claude or Cursor with MXCP integration
3. Have terminal ready for audit log demonstration
4. Pre-test all queries to ensure they work

## 1. Quick Introduction (1 minute)

**What to say:**
"After Miguel's overview, let me show you MXCP in action. MXCP - Model Context Protocol - is a standard that gives AI assistants controlled, auditable access to your data and systems."

**Show diagram (on slide or whiteboard):**
```
User Question → AI Assistant → MXCP Server → Your Data
                                    ↓
                               Audit Trail
```

"Think of it as a secure bridge between AI and your enterprise data."

## 2. Live Demo (6-7 minutes)

### A. Service Health Check (30 seconds)

**In terminal:**
```bash
# Show the service is live
curl https://ru9grd9gq8.eu-west-1.awsapprunner.com/health
```

**What to say:**
"This MXCP server is running on AWS App Runner - fully managed, auto-scaling, production-ready."

### B. Natural Language Data Queries (3 minutes)

**In Claude/Cursor, type these queries:**

**Query 1 - Simple Search:**
```
Find companies in Zurich with more than 1 million CHF capital
```

**What to say:**
"Notice how the AI understands natural language and translates it to structured queries."

**Query 2 - Complex Aggregation:**
```
What's the distribution of companies across Swiss cantons? 
Show me the top 5 cantons by number of companies.
```

**What to say:**
"MXCP handles complex aggregations that would typically require SQL knowledge."

**Query 3 - Multi-step Analysis:**
```
Which industries are most common in Geneva? 
Then find the largest company in the top industry.
```

**What to say:**
"The AI can perform multi-step analysis, maintaining context between queries."

### C. Show the Audit Trail (2 minutes)

**In terminal:**
```bash
# Show real-time audit logs
./scripts/latest-logs.sh --audit --format --time-window=5m
```

**What to say:**
"Every interaction is logged. You see who queried what, when, and how long it took. This is crucial for compliance and security."

**Point out in the audit log:**
- Timestamp of each query
- Tool name (which data operation)
- Input parameters (what was requested)
- Execution time
- Success/failure status

### D. Architecture Benefits (1.5 minutes)

**Show the GitHub repo briefly:**
```bash
# Show the simple configuration
cat tools/search_companies.yml | head -20
```

**What to say:**
"Adding new data sources is just YAML configuration. No coding required. Your data team can expose new datasets to AI in minutes, not weeks."

**Key points to emphasize:**
- SQL stays on your servers (data never leaves)
- Row-level security can be enforced
- Works with any database (we use DuckDB here, but supports PostgreSQL, Snowflake, etc.)
- Integrates with any AI (Claude, GPT, Gemini, etc.)

## 3. Squirro-Specific Value Props (2 minutes)

**Relate to Squirro's needs:**

"For Squirro specifically, imagine:
- Your knowledge base accessible via natural language
- Customer insights queryable without SQL
- Automated report generation with full audit trail
- Secure multi-tenant data access

The same pattern we showed with Swiss companies works with:
- Customer data
- Knowledge articles  
- Analytics dashboards
- Any structured data"

**Show one more query relevant to Squirro:**
```
Create a summary report of all technology companies founded in the last 5 years, 
grouped by canton, including average funding and employee count
```

## 4. Closing (30 seconds)

**What to say:**
"MXCP bridges the gap between AI's language capabilities and your enterprise data's security requirements. It's:
- Secure: Data never leaves your control
- Auditable: Every query is logged
- Scalable: From POC to production
- Simple: YAML config, no complex coding"

**End with:**
"Questions? Happy to dive deeper into any aspect - security, integration, or specific use cases for Squirro."

---

## Backup Queries (if time permits or for Q&A)

1. **Performance query:**
   ```
   How fast can you search through all companies in Switzerland?
   ```

2. **Error handling:**
   ```
   Find companies in InvalidCanton (show graceful error handling)
   ```

3. **Complex filtering:**
   ```
   Find all GmbH companies in German-speaking cantons with 
   capital between 50k and 500k CHF, founded after 2020
   ```

## Technical Questions - Quick Answers

**Q: How secure is it?**
A: Data never leaves your servers. MXCP only sends query results, not raw data. All access is authenticated and audited.

**Q: What databases does it support?**
A: Any SQL database - PostgreSQL, MySQL, Snowflake, BigQuery, DuckDB, etc. Also supports custom REST APIs.

**Q: How hard is it to implement?**
A: Basic setup in hours, not weeks. It's YAML configuration plus your existing SQL queries.

**Q: What about performance?**
A: Queries run at native database speed. MXCP adds minimal overhead (<50ms).

## Demo Troubleshooting

If something doesn't work:
1. Check service health: `curl https://ru9grd9gq8.eu-west-1.awsapprunner.com/health`
2. Use the test script: `python3 scripts/test-audit.py`
3. Have backup screenshots ready
4. Focus on the concept rather than the specific query

## Post-Demo Resources

Share these:
- GitHub repo: https://github.com/raw-labs/swiss-mxcp-server
- MXCP documentation: https://modelcontextprotocol.com
- Live endpoint for testing: https://ru9grd9gq8.eu-west-1.awsapprunner.com/mcp
