-- Get distinct values for categorical fields
WITH field_values AS (
  SELECT DISTINCT LegalForm as value, 'legal_form' as field_type FROM swiss_companies WHERE LegalForm IS NOT NULL
  UNION ALL
  SELECT DISTINCT Canton as value, 'canton' as field_type FROM swiss_companies WHERE Canton IS NOT NULL  
  UNION ALL
  SELECT DISTINCT CAST(IndustryCode as VARCHAR) as value, 'industry_code' as field_type FROM swiss_companies WHERE IndustryCode IS NOT NULL
  UNION ALL
  SELECT DISTINCT IndustryDescription as value, 'industry_description' as field_type FROM swiss_companies WHERE IndustryDescription IS NOT NULL
)
SELECT DISTINCT value 
FROM field_values 
WHERE field_type = $field
ORDER BY value