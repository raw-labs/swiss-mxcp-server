# Data Generation Scripts

## generate_swiss_companies.py

This script generates realistic synthetic Swiss business registry data that matches the exact schema of the `swiss-business-registry-sample.csv` file.

### Features

- **Realistic UIDs**: Generates proper Swiss UID format `CHE-XXX.XXX.XXX`
- **Accurate Legal Forms**: Proper distribution of AG, GmbH, Einzelfirma, etc.
- **Capital Requirements**: Enforces Swiss legal requirements:
  - AG: minimum 100,000 CHF
  - GmbH: minimum 20,000 CHF
  - Einzelfirma, Verein, Stiftung: typically 0 CHF
- **Weighted Canton Distribution**: More companies in business hubs (Zürich, Geneva, Vaud)
- **NACE Industry Codes**: Uses proper European industry classification codes
- **Realistic Company Names**: Swiss-style company names with German family names and business terms
- **Employee Distribution**: Most companies are small (1-20 employees), fewer large companies
- **Date Distribution**: Exponentially weighted towards more recent registrations
- **Unique Values**: All UIDs and company names are unique

### Usage

```bash
# Generate 1000 companies with current date as the latest registration
cd /Users/alexzerntev/workspace/swiss-mxcp-server
python3 scripts/generate_swiss_companies.py
```

### Configuration

You can modify the script to adjust:

- `num_companies`: Number of companies to generate (default: 1000)
- `end_date`: Latest registration date (default: October 30, 2025)
- `output_file`: Output CSV file path
- `years_back`: How many years back to generate registrations (default: 30)

Edit the `main()` function in the script:

```python
def main():
    num_companies = 1000  # Change this
    end_date = datetime(2025, 10, 30)  # Change this
    output_file = "data/swiss-business-registry-sample.csv"  # Change this
```

### Data Quality

The generated data passes all critical dbt tests:

✅ Valid Swiss cantons
✅ Proper legal forms
✅ Capital minimums (AG ≥ 100,000 CHF, GmbH ≥ 20,000 CHF)
✅ Unique UIDs and company names
✅ No duplicate companies
✅ All required fields populated
✅ Proper NACE industry codes

### Output Schema

The generated CSV contains the following columns:

| Column | Type | Description |
|--------|------|-------------|
| CompanyName | string | Company name (Swiss-style) |
| LegalForm | string | AG, GmbH, Einzelfirma, Kollektivgesellschaft, Verein, or Stiftung |
| UID | string | Swiss UID format: CHE-XXX.XXX.XXX |
| RegistrationDate | date | YYYY-MM-DD format |
| Canton | string | English canton name (e.g., Zürich, Geneva, Bern) |
| ShareCapitalCHF | integer | Share capital in Swiss Francs |
| IndustryCode | string | 2-digit NACE industry code |
| IndustryDescription | string | Industry description |
| Employees | integer | Number of employees (1-5000) |

### Statistics

Example distribution from a 1000-company generation:

**Legal Forms:**
- GmbH: ~38%
- AG: ~37%
- Einzelfirma: ~17%
- Stiftung: ~3%
- Kollektivgesellschaft: ~3%
- Verein: ~2%

**Top Cantons:**
- Zürich: ~24%
- Geneva: ~11%
- Vaud: ~10%
- Bern: ~9%
- Aargau: ~8%

**Employee Distribution:**
- 1-5 employees: ~40%
- 6-20 employees: ~30%
- 21-50 employees: ~15%
- 51-150 employees: ~8%
- 151-500 employees: ~4%
- 501-5000 employees: ~3%

### Improvements Over Previous Data

The new script generates more realistic data compared to the old synthetic data:

1. **No company name/legal form conflicts**: Previously had companies like "International Sàrl" with legal form "AG"
2. **Proper capital amounts**: Respects Swiss minimum capital requirements
3. **Realistic distributions**: Canton and legal form distributions match Swiss business statistics
4. **Unique names and UIDs**: All entries are guaranteed unique
5. **Current dates**: Registration dates go up to the current date (October 30, 2025)
6. **Better name variety**: More diverse and realistic Swiss company names
7. **Proper English canton names**: Uses standardized English names (Geneva, not Genève)

### Dependencies

- Python 3.8+
- No external packages required (uses only standard library)

### Notes

- The script uses a slight exponential bias towards more recent registration dates to simulate business growth over time
- All data is purely synthetic and does not represent real companies
- The script can be easily modified to generate different distributions or larger datasets

