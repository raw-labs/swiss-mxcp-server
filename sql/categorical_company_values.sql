SELECT DISTINCT 
    {% if field == 'legal_form' %}
        LegalForm as value
    {% elif field == 'canton' %}
        Canton as value
    {% elif field == 'industry_code' %}
        IndustryCode as value
    {% elif field == 'industry_description' %}
        IndustryDescription as value
    {% else %}
        'Unknown field' as value
    {% endif %}
FROM {{ ref('swiss_companies') }}
WHERE value IS NOT NULL
ORDER BY value