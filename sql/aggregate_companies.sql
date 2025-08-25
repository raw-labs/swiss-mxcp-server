-- Enhanced aggregate query supporting up to 2 grouping levels
WITH filtered AS (
    SELECT *
    FROM swiss_companies
    WHERE 1=1
        AND ($legal_form IS NULL OR LegalForm = $legal_form)
        AND ($canton IS NULL OR Canton = $canton)
        AND ($industry_code IS NULL OR IndustryCode = $industry_code)
        AND ($min_capital IS NULL OR ShareCapitalCHF >= $min_capital)
        AND ($max_capital IS NULL OR ShareCapitalCHF <= $max_capital)
        AND ($registration_date_from IS NULL OR RegistrationDate >= $registration_date_from)
        AND ($registration_date_to IS NULL OR RegistrationDate <= $registration_date_to)
),
parsed_groups AS (
    SELECT 
        CASE 
            WHEN $group_by LIKE '%,%' THEN TRIM(SPLIT_PART($group_by, ',', 1))
            ELSE $group_by
        END as group1,
        CASE 
            WHEN $group_by LIKE '%,%' THEN TRIM(SPLIT_PART($group_by, ',', 2))
            ELSE NULL
        END as group2
)
SELECT 
    CASE 
        WHEN pg.group1 = 'Canton' THEN Canton
        WHEN pg.group1 = 'LegalForm' THEN LegalForm
        WHEN pg.group1 = 'IndustryCode' THEN CAST(IndustryCode AS VARCHAR)
        WHEN pg.group1 = 'IndustryDescription' THEN IndustryDescription
        ELSE 'All'
    END as group_field_1,
    CASE 
        WHEN pg.group2 = 'Canton' THEN Canton
        WHEN pg.group2 = 'LegalForm' THEN LegalForm
        WHEN pg.group2 = 'IndustryCode' THEN CAST(IndustryCode AS VARCHAR)
        WHEN pg.group2 = 'IndustryDescription' THEN IndustryDescription
        WHEN pg.group2 IS NOT NULL THEN 'Unknown'
        ELSE NULL
    END as group_field_2,
    COUNT(*) as count,
    SUM(ShareCapitalCHF) as total_capital,
    AVG(ShareCapitalCHF) as avg_capital,
    MIN(ShareCapitalCHF) as min_capital,
    MAX(ShareCapitalCHF) as max_capital,
    SUM(Employees) as total_employees,
    AVG(Employees) as avg_employees
FROM filtered, parsed_groups pg
WHERE ($group_by IS NULL OR 
       pg.group1 IS NULL OR 
       pg.group1 IN ('Canton', 'LegalForm', 'IndustryCode', 'IndustryDescription'))
GROUP BY 
    CASE 
        WHEN pg.group1 = 'Canton' THEN Canton
        WHEN pg.group1 = 'LegalForm' THEN LegalForm
        WHEN pg.group1 = 'IndustryCode' THEN CAST(IndustryCode AS VARCHAR)
        WHEN pg.group1 = 'IndustryDescription' THEN IndustryDescription
        ELSE 'All'
    END,
    CASE 
        WHEN pg.group2 = 'Canton' THEN Canton
        WHEN pg.group2 = 'LegalForm' THEN LegalForm
        WHEN pg.group2 = 'IndustryCode' THEN CAST(IndustryCode AS VARCHAR)
        WHEN pg.group2 = 'IndustryDescription' THEN IndustryDescription
        WHEN pg.group2 IS NOT NULL THEN 'Unknown'
        ELSE NULL
    END
ORDER BY 
    group_field_1 NULLS LAST,
    group_field_2 NULLS LAST,
    count DESC
LIMIT COALESCE($page_size, 50)