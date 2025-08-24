-- Test that we have the expected 1000 companies
select count(*) as company_count
from {{ ref('swiss_companies') }}
having count(*) != 1000
