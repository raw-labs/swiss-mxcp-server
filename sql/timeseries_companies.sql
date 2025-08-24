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
    {% if registration_date_from %}
        AND RegistrationDate >= '{{ registration_date_from }}'
    {% endif %}
    {% if registration_date_to %}
        AND RegistrationDate <= '{{ registration_date_to }}'
    {% endif %}
)
SELECT 
    {% if interval == 'year' %}
        EXTRACT(YEAR FROM RegistrationDate) as period,
    {% elif interval == 'month' %}
        DATE_TRUNC('month', RegistrationDate) as period,
    {% else %}
        DATE_TRUNC('month', RegistrationDate) as period,
    {% endif %}
    COUNT(*) as count,
    SUM(ShareCapitalCHF) as total_capital,
    SUM(Employees) as total_employees
FROM filtered
GROUP BY period
ORDER BY period DESC
LIMIT {{ page_size | default(100) }}