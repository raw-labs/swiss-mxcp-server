WITH filtered AS (
    SELECT *
    FROM swiss_companies
    WHERE 1=1
        AND ($legal_form IS NULL OR LegalForm = $legal_form)
        AND ($canton IS NULL OR Canton = $canton)
        AND ($industry_code IS NULL OR IndustryCode = $industry_code)
        AND ($registration_date_from IS NULL OR RegistrationDate >= $registration_date_from)
        AND ($registration_date_to IS NULL OR RegistrationDate <= $registration_date_to)
)
SELECT 
    CASE 
        WHEN COALESCE($interval, 'month') = 'year' THEN CAST(EXTRACT(YEAR FROM RegistrationDate) AS TEXT)
        ELSE CAST(DATE_TRUNC('month', RegistrationDate) AS TEXT)
    END as period,
    COUNT(*) as count,
    SUM(ShareCapitalCHF) as total_capital,
    SUM(Employees) as total_employees
FROM filtered
GROUP BY 
    CASE 
        WHEN COALESCE($interval, 'month') = 'year' THEN CAST(EXTRACT(YEAR FROM RegistrationDate) AS TEXT)
        ELSE CAST(DATE_TRUNC('month', RegistrationDate) AS TEXT)
    END
ORDER BY period DESC
LIMIT COALESCE($page_size, 100)