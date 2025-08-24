-- Test that there are no duplicate company names
-- This ensures data quality for business registry

SELECT 
    CompanyName,
    count(*) as duplicate_count
FROM {{ ref('swiss_companies') }}
GROUP BY CompanyName
HAVING count(*) > 1
