WITH filtered AS (
    SELECT *
    FROM swiss_companies
    WHERE 1=1
        AND ($company_name IS NULL OR CompanyName = $company_name)
        AND ($company_name_like IS NULL OR LOWER(CompanyName) LIKE LOWER('%' || $company_name_like || '%'))
        AND ($uid IS NULL OR UID = $uid)
        AND ($legal_form IS NULL OR LegalForm = $legal_form)
        AND ($canton IS NULL OR Canton = $canton)
        AND ($industry_code IS NULL OR IndustryCode = $industry_code)
        AND ($min_capital IS NULL OR ShareCapitalCHF >= $min_capital)
        AND ($max_capital IS NULL OR ShareCapitalCHF <= $max_capital)
        AND ($min_employees IS NULL OR Employees >= $min_employees)
        AND ($max_employees IS NULL OR Employees <= $max_employees)
        AND ($registration_date_from IS NULL OR RegistrationDate >= $registration_date_from)
        AND ($registration_date_to IS NULL OR RegistrationDate <= $registration_date_to)
)
SELECT 
    CASE 
        WHEN $date_field = 'RegistrationDate' AND COALESCE($interval, 'month') = 'year' 
            THEN CAST(EXTRACT(YEAR FROM RegistrationDate) AS TEXT)
        WHEN $date_field = 'RegistrationDate' AND COALESCE($interval, 'month') = 'month' 
            THEN CAST(DATE_TRUNC('month', RegistrationDate) AS TEXT)
        WHEN $date_field = 'RegistrationDate' AND COALESCE($interval, 'month') = 'quarter' 
            THEN CAST(DATE_TRUNC('quarter', RegistrationDate) AS TEXT)
        WHEN $date_field = 'RegistrationDate' AND COALESCE($interval, 'month') = 'week' 
            THEN CAST(DATE_TRUNC('week', RegistrationDate) AS TEXT)
        WHEN $date_field = 'RegistrationDate' AND COALESCE($interval, 'month') = 'day' 
            THEN CAST(DATE_TRUNC('day', RegistrationDate) AS TEXT)
        ELSE CAST(DATE_TRUNC('month', RegistrationDate) AS TEXT)
    END as period,
    COUNT(*) as count,
    SUM(ShareCapitalCHF) as total_capital,
    AVG(ShareCapitalCHF) as avg_capital,
    SUM(Employees) as total_employees,
    AVG(Employees) as avg_employees
FROM filtered
WHERE ($date_field IS NULL OR $date_field = 'RegistrationDate')
GROUP BY period
ORDER BY period DESC
LIMIT COALESCE($page_size, 100)