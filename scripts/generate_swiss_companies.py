#!/usr/bin/env python3
"""
Generate realistic Swiss business registry data.

This script generates synthetic but realistic Swiss company data that matches
the exact schema of the swiss-business-registry-sample.csv file.
"""

import csv
import random
from datetime import datetime, timedelta
from typing import List, Dict

# Set seed for reproducibility (optional - comment out for truly random data)
# random.seed(42)


def generate_uid() -> str:
    """Generate a realistic Swiss UID in format CHE-XXX.XXX.XXX"""
    part1 = random.randint(100, 999)
    part2 = random.randint(100, 999)
    part3 = random.randint(100, 999)
    return f"CHE-{part1}.{part2}.{part3}"


def generate_company_name(legal_form: str) -> str:
    """Generate a realistic Swiss company name"""
    # Swiss/German family names
    surnames = [
        "Müller", "Meier", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer",
        "Wagner", "Becker", "Schulz", "Hoffmann", "Schäfer", "Koch", "Bauer",
        "Richter", "Klein", "Wolf", "Schröder", "Neumann", "Schwarz"
    ]
    
    # Common business prefixes and terms
    prefixes = [
        "Swiss", "Helvetia", "Alpine", "Geneva", "Zurich", "Basel", "Bern",
        "Lausanne", "Lucerne", "St. Gallen", "Lugano", "Winterthur"
    ]
    
    business_types = [
        "Trading", "Consulting", "Solutions", "Services", "Group", "Holdings",
        "Partners", "Associates", "Ventures", "Capital", "Systems", "Technologies",
        "Engineering", "Manufacturing", "Finance", "Banking", "Investment",
        "Insurance", "Real Estate", "Watch", "Pharma", "Chocolate", "Energy",
        "Digital", "Innovation", "Management", "Retail", "Logistics", "Tourism",
        "Medical", "Global", "International"
    ]
    
    descriptors = [
        "AG", "Holding", "Group", "International", "Suisse", "Switzerland",
        "Sàrl", "GmbH", "& Co.", "Innovations"
    ]
    
    # Generate different name patterns
    pattern = random.choice([1, 2, 3, 4, 5, 6])
    
    if pattern == 1:
        # "Prefix + Business Type"
        name = f"{random.choice(prefixes)} {random.choice(business_types)}"
    elif pattern == 2:
        # "Business Type + Descriptor"
        name = f"{random.choice(business_types)} {random.choice(descriptors)}"
    elif pattern == 3:
        # "Surname + Business Type"
        name = f"{random.choice(surnames)} {random.choice(business_types)}"
    elif pattern == 4:
        # "Prefix + Business Type + Descriptor"
        name = f"{random.choice(prefixes)} {random.choice(business_types)} {random.choice(descriptors)}"
    elif pattern == 5:
        # "Surname + Descriptor"
        name = f"{random.choice(surnames)} {random.choice(descriptors)}"
    else:
        # "Business Type + Business Type + Descriptor"
        name = f"{random.choice(business_types)} {random.choice(business_types)} {random.choice(descriptors)}"
    
    return name


def get_legal_form_distribution() -> List[str]:
    """
    Return legal forms with realistic distribution.
    AG and GmbH are most common, followed by Einzelfirma.
    
    Distribution based on Swiss statistics:
    - AG: ~35%
    - GmbH: ~40%
    - Einzelfirma: ~18%
    - Others: ~7%
    """
    distribution = (
        ["AG"] * 35 +
        ["GmbH"] * 40 +
        ["Einzelfirma"] * 18 +
        ["Kollektivgesellschaft"] * 3 +
        ["Verein"] * 2 +
        ["Stiftung"] * 2
    )
    return distribution


def generate_share_capital(legal_form: str) -> int:
    """
    Generate realistic share capital based on legal form.
    
    Swiss requirements:
    - AG: minimum 100,000 CHF
    - GmbH: minimum 20,000 CHF
    - Einzelfirma, Verein, Stiftung, Kollektivgesellschaft: typically 0 or small amounts
    """
    if legal_form == "AG":
        # AG companies: 100,000 CHF minimum, most common values
        choices = [
            100000, 100000, 100000, 100000,  # Most common
            200000, 200000, 300000,
            500000, 500000,
            1000000, 1000000,
            2000000, 5000000, 10000000
        ]
        return random.choice(choices)
    elif legal_form == "GmbH":
        # GmbH companies: 20,000 CHF minimum
        choices = [
            20000, 20000, 20000,  # Most common minimum
            40000, 50000, 50000,
            100000, 100000, 200000,
            500000, 1000000
        ]
        return random.choice(choices)
    elif legal_form == "Einzelfirma":
        # Sole proprietorships: usually 0, sometimes small amounts
        return random.choice([0, 0, 0, 0, 0, 10000, 20000, 50000])
    elif legal_form in ["Verein", "Stiftung"]:
        # Associations and foundations: typically 0
        return 0
    else:  # Kollektivgesellschaft, etc.
        # Partnerships: typically small amounts or 0
        return random.choice([0, 0, 0, 10000, 20000])


def get_canton_distribution() -> List[str]:
    """
    Return cantons with realistic distribution based on Swiss business statistics.
    
    Major business hubs (Zürich, Geneva, Vaud) have more companies.
    Uses English canton names to match the expected schema.
    """
    distribution = (
        ["Zürich"] * 25 +
        ["Geneva"] * 12 +
        ["Vaud"] * 10 +
        ["Bern"] * 9 +
        ["Aargau"] * 7 +
        ["St. Gallen"] * 6 +
        ["Basel-Stadt"] * 6 +
        ["Ticino"] * 5 +
        ["Lucerne"] * 5 +
        ["Zug"] * 4 +
        ["Solothurn"] * 3 +
        ["Thurgau"] * 2 +
        ["Fribourg"] * 2 +
        ["Neuchâtel"] * 2 +
        ["Valais"] * 1 +
        ["Schwyz"] * 1
    )
    return distribution


def get_industry_data() -> List[Dict[str, str]]:
    """
    Return NACE industry codes with descriptions.
    These are realistic Swiss/European industry classifications.
    """
    industries = [
        {"code": "21", "description": "Manufacture of pharmaceuticals"},
        {"code": "26", "description": "Manufacture of computer and electronic products"},
        {"code": "27", "description": "Manufacture of electrical equipment"},
        {"code": "28", "description": "Manufacture of machinery"},
        {"code": "41", "description": "Construction of buildings"},
        {"code": "43", "description": "Specialised construction activities"},
        {"code": "46", "description": "Wholesale trade"},
        {"code": "47", "description": "Retail trade"},
        {"code": "49", "description": "Land transport"},
        {"code": "52", "description": "Warehousing and transport support"},
        {"code": "55", "description": "Accommodation"},
        {"code": "56", "description": "Food and beverage service activities"},
        {"code": "58", "description": "Publishing activities"},
        {"code": "61", "description": "Telecommunications"},
        {"code": "62", "description": "Computer programming and consultancy"},
        {"code": "64", "description": "Financial service activities"},
        {"code": "65", "description": "Insurance and pension funding"},
        {"code": "66", "description": "Activities auxiliary to financial services"},
        {"code": "68", "description": "Real estate activities"},
        {"code": "69", "description": "Legal and accounting activities"},
        {"code": "70", "description": "Management consultancy"},
        {"code": "71", "description": "Architectural and engineering activities"},
        {"code": "72", "description": "Scientific research and development"},
        {"code": "73", "description": "Advertising and market research"},
        {"code": "74", "description": "Other professional activities"},
        {"code": "82", "description": "Office administrative services"},
        {"code": "85", "description": "Education"},
        {"code": "86", "description": "Human health activities"},
    ]
    return industries


def generate_employees() -> int:
    """
    Generate realistic employee count with proper distribution.
    Most Swiss companies are small (1-10 employees), fewer large companies.
    """
    # Weighted distribution - more small companies
    rand = random.random()
    
    if rand < 0.40:  # 40% very small (1-5)
        return random.randint(1, 5)
    elif rand < 0.70:  # 30% small (6-20)
        return random.randint(6, 20)
    elif rand < 0.85:  # 15% medium-small (21-50)
        return random.randint(21, 50)
    elif rand < 0.93:  # 8% medium (51-150)
        return random.randint(51, 150)
    elif rand < 0.97:  # 4% medium-large (151-500)
        return random.randint(151, 500)
    else:  # 3% large (501-5000)
        return random.randint(501, 5000)


def generate_registration_date(end_date: datetime, years_back: int = 30) -> str:
    """
    Generate a random registration date.
    More recent dates are slightly more common (business growth over time).
    """
    # Calculate start date
    start_date = end_date - timedelta(days=years_back * 365)
    
    # Generate random date with slight bias towards more recent dates
    # Use exponential distribution for more realistic date clustering
    days_range = (end_date - start_date).days
    
    # Exponential bias: more recent dates are more likely
    random_factor = 1 - (random.random() ** 1.5)  # Bias towards 1 (recent)
    days_offset = int(random_factor * days_range)
    
    reg_date = start_date + timedelta(days=days_offset)
    return reg_date.strftime("%Y-%m-%d")


def generate_companies(num_companies: int = 1000, end_date: datetime = None) -> List[Dict]:
    """Generate the specified number of company records"""
    if end_date is None:
        end_date = datetime.now()
    
    companies = []
    used_uids = set()
    used_names = set()
    
    legal_forms = get_legal_form_distribution()
    cantons = get_canton_distribution()
    industries = get_industry_data()
    
    for i in range(num_companies):
        # Generate unique UID
        while True:
            uid = generate_uid()
            if uid not in used_uids:
                used_uids.add(uid)
                break
        
        # Select legal form
        legal_form = random.choice(legal_forms)
        
        # Generate unique company name
        attempts = 0
        while True:
            company_name = generate_company_name(legal_form)
            if company_name not in used_names or attempts > 50:
                used_names.add(company_name)
                break
            attempts += 1
        
        # Generate other fields
        registration_date = generate_registration_date(end_date)
        canton = random.choice(cantons)
        share_capital = generate_share_capital(legal_form)
        industry = random.choice(industries)
        employees = generate_employees()
        
        company = {
            "CompanyName": company_name,
            "LegalForm": legal_form,
            "UID": uid,
            "RegistrationDate": registration_date,
            "Canton": canton,
            "ShareCapitalCHF": share_capital,
            "IndustryCode": industry["code"],
            "IndustryDescription": industry["description"],
            "Employees": employees
        }
        
        companies.append(company)
        
        # Progress indicator
        if (i + 1) % 100 == 0:
            print(f"Generated {i + 1} / {num_companies} companies...")
    
    # Sort by registration date (newest first)
    companies.sort(key=lambda x: x["RegistrationDate"], reverse=True)
    
    return companies


def save_to_csv(companies: List[Dict], filename: str):
    """Save companies to CSV file with exact schema match"""
    headers = [
        "CompanyName",
        "LegalForm",
        "UID",
        "RegistrationDate",
        "Canton",
        "ShareCapitalCHF",
        "IndustryCode",
        "IndustryDescription",
        "Employees"
    ]
    
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()
        writer.writerows(companies)
    
    print(f"\n✅ Successfully saved {len(companies)} companies to {filename}")


def main():
    """Main execution function"""
    print("🇨🇭 Swiss Business Registry Data Generator")
    print("=" * 50)
    
    # Configuration
    num_companies = 1000
    # Use current date (October 30, 2025)
    end_date = datetime(2025, 10, 30)
    output_file = "data/swiss-business-registry-sample.csv"
    
    print(f"\nConfiguration:")
    print(f"  Number of companies: {num_companies}")
    print(f"  Latest registration date: {end_date.strftime('%Y-%m-%d')}")
    print(f"  Output file: {output_file}")
    print(f"\nGenerating data...\n")
    
    # Generate companies
    companies = generate_companies(num_companies, end_date)
    
    # Save to CSV
    save_to_csv(companies, output_file)
    
    # Print statistics
    print("\n📊 Data Statistics:")
    legal_form_counts = {}
    canton_counts = {}
    
    for company in companies:
        legal_form = company["LegalForm"]
        canton = company["Canton"]
        legal_form_counts[legal_form] = legal_form_counts.get(legal_form, 0) + 1
        canton_counts[canton] = canton_counts.get(canton, 0) + 1
    
    print("\nLegal Forms:")
    for form, count in sorted(legal_form_counts.items(), key=lambda x: x[1], reverse=True):
        percentage = (count / num_companies) * 100
        print(f"  {form:25} {count:4} ({percentage:5.1f}%)")
    
    print("\nTop 10 Cantons:")
    for canton, count in sorted(canton_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
        percentage = (count / num_companies) * 100
        print(f"  {canton:25} {count:4} ({percentage:5.1f}%)")
    
    print("\n✨ Data generation complete!")


if __name__ == "__main__":
    main()

