SELECT *
FROM {{ ref('swiss_companies') }}
WHERE 1=1
{% if company_name %}
    AND CompanyName = '{{ company_name }}'
{% endif %}
{% if company_name_like %}
    AND LOWER(CompanyName) LIKE LOWER('%{{ company_name_like }}%')
{% endif %}
{% if uid %}
    AND UID = '{{ uid }}'
{% endif %}
{% if legal_form %}
    AND LegalForm = '{{ legal_form }}'
{% endif %}
{% if canton %}
    AND Canton = '{{ canton }}'
{% endif %}
{% if industry_code %}
    AND IndustryCode = '{{ industry_code }}'
{% endif %}
{% if min_capital %}
    AND ShareCapitalCHF >= {{ min_capital }}
{% endif %}
{% if max_capital %}
    AND ShareCapitalCHF <= {{ max_capital }}
{% endif %}
{% if min_employees %}
    AND Employees >= {{ min_employees }}
{% endif %}
{% if max_employees %}
    AND Employees <= {{ max_employees }}
{% endif %}
{% if registration_date_from %}
    AND RegistrationDate >= '{{ registration_date_from }}'
{% endif %}
{% if registration_date_to %}
    AND RegistrationDate <= '{{ registration_date_to }}'
{% endif %}
ORDER BY RegistrationDate DESC
LIMIT {{ page_size | default(20) }}
OFFSET ({{ page | default(1) }} - 1) * {{ page_size | default(20) }}