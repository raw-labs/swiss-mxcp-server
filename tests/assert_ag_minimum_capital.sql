-- Test that AG companies meet minimum capital requirements
-- In Switzerland, AG companies require minimum 100,000 CHF capital

SELECT 
    CompanyName,
    LegalForm,
    ShareCapitalCHF
FROM {{ ref('swiss_companies') }}
WHERE LegalForm = 'AG' 
  AND ShareCapitalCHF < 100000
