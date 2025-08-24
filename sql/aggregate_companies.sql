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
)
SELECT 
    CASE 
        WHEN $group_by = 'Canton' THEN Canton
        WHEN $group_by = 'LegalForm' THEN LegalForm
        WHEN $group_by = 'IndustryCode' THEN CAST(IndustryCode AS VARCHAR)
        WHEN $group_by = 'IndustryDescription' THEN IndustryDescription
        ELSE 'All'
    END as group_field,
    COUNT(*) as count,
    SUM(ShareCapitalCHF) as total_capital,
    AVG(ShareCapitalCHF) as avg_capital,
    SUM(Employees) as total_employees,
    AVG(Employees) as avg_employees
FROM filtered
WHERE ($group_by IS NULL OR $group_by IN ('Canton', 'LegalForm', 'IndustryCode', 'IndustryDescription'))
GROUP BY 
    CASE 
        WHEN $group_by = 'Canton' THEN Canton
        WHEN $group_by = 'LegalForm' THEN LegalForm
        WHEN $group_by = 'IndustryCode' THEN CAST(IndustryCode AS VARCHAR)
        WHEN $group_by = 'IndustryDescription' THEN IndustryDescription
        ELSE 'All'
    END
ORDER BY count DESC
LIMIT COALESCE($page_size, 50)