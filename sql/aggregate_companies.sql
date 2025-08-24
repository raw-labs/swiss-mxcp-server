WITH filtered AS (
    SELECT *
    FROM {{ ref('swiss_companies') }}
    WHERE 1=1
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
    {% if registration_date_from %}
        AND RegistrationDate >= '{{ registration_date_from }}'
    {% endif %}
    {% if registration_date_to %}
        AND RegistrationDate <= '{{ registration_date_to }}'
    {% endif %}
)
SELECT 
    {% if group_by %}
        {{ group_by }} as group_field,
    {% else %}
        'All' as group_field,
    {% endif %}
    COUNT(*) as count,
    SUM(ShareCapitalCHF) as total_capital,
    AVG(ShareCapitalCHF) as avg_capital,
    SUM(Employees) as total_employees,
    AVG(Employees) as avg_employees
FROM filtered
{% if group_by %}
    GROUP BY {{ group_by }}
    ORDER BY count DESC
{% endif %}
LIMIT {{ page_size | default(50) }}