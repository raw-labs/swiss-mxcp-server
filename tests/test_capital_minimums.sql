-- Test that AG companies have minimum 100k capital
select CompanyName, LegalForm, ShareCapitalCHF
from {{ ref('swiss_companies') }}
where LegalForm = 'AG' and ShareCapitalCHF < 100000

union all

-- Test that GmbH companies have minimum 20k capital  
select CompanyName, LegalForm, ShareCapitalCHF
from {{ ref('swiss_companies') }}
where LegalForm = 'GmbH' and ShareCapitalCHF < 20000
