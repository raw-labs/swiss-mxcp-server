SELECT
  -- Dynamically select group_1
  CASE
    WHEN split_part($group_by, ',', 1) = 'Canton' THEN Canton
    WHEN split_part($group_by, ',', 1) = 'LegalForm' THEN LegalForm
    WHEN split_part($group_by, ',', 1) = 'IndustryCode' THEN CAST(IndustryCode AS VARCHAR)
    WHEN split_part($group_by, ',', 1) = 'IndustryDescription' THEN IndustryDescription
    WHEN split_part($group_by, ',', 1) = 'RegistrationYear' THEN CAST(YEAR(RegistrationDate) AS VARCHAR)
    ELSE NULL
  END AS group_1,
  -- Dynamically select group_2 if present
  CASE
    WHEN strpos($group_by, ',') > 0 AND split_part($group_by, ',', 2) = 'Canton' THEN Canton
    WHEN strpos($group_by, ',') > 0 AND split_part($group_by, ',', 2) = 'LegalForm' THEN LegalForm
    WHEN strpos($group_by, ',') > 0 AND split_part($group_by, ',', 2) = 'IndustryCode' THEN CAST(IndustryCode AS VARCHAR)
    WHEN strpos($group_by, ',') > 0 AND split_part($group_by, ',', 2) = 'IndustryDescription' THEN IndustryDescription
    WHEN strpos($group_by, ',') > 0 AND split_part($group_by, ',', 2) = 'RegistrationYear' THEN CAST(YEAR(RegistrationDate) AS VARCHAR)
    ELSE NULL
  END AS group_2,
  CASE WHEN strpos($metrics, 'count') > 0 THEN COUNT(*) END AS count,
  CASE WHEN strpos($metrics, 'total_capital') > 0 THEN SUM(ShareCapitalCHF) END AS total_capital,
  CASE WHEN strpos($metrics, 'avg_share_capital') > 0 THEN AVG(ShareCapitalCHF) END AS avg_capital,
  CASE WHEN strpos($metrics, 'min_capital') > 0 THEN MIN(ShareCapitalCHF) END AS min_capital,
  CASE WHEN strpos($metrics, 'max_capital') > 0 THEN MAX(ShareCapitalCHF) END AS max_capital,
  CASE WHEN strpos($metrics, 'total_employees') > 0 THEN SUM(Employees) END AS total_employees,
  CASE WHEN strpos($metrics, 'avg_employees') > 0 THEN AVG(Employees) END AS avg_employees
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
GROUP BY group_1, group_2
ORDER BY count DESC
LIMIT COALESCE($page_size, 50)