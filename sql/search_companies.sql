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
ORDER BY RegistrationDate DESC
LIMIT COALESCE($page_size, 20)
OFFSET (COALESCE($page, 1) - 1) * COALESCE($page_size, 20)