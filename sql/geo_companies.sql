-- Note: This is a simplified geo query since we don't have lat/lon coordinates
-- In a real implementation, you would have coordinates for each company location

WITH canton_centers AS (
    SELECT 
        'Zürich' as canton, 47.3769 as latitude, 8.5417 as longitude
    UNION ALL SELECT 'Genève', 46.2044, 6.1432
    UNION ALL SELECT 'Bern', 46.9480, 7.4474
    UNION ALL SELECT 'Vaud', 46.5197, 6.6323
    UNION ALL SELECT 'Basel-Stadt', 47.5596, 7.5886
    UNION ALL SELECT 'Aargau', 47.3887, 8.0517
    UNION ALL SELECT 'St. Gallen', 47.4245, 9.3767
    UNION ALL SELECT 'Luzern', 47.0502, 8.3093
    UNION ALL SELECT 'Ticino', 46.3317, 8.8005
    UNION ALL SELECT 'Zug', 47.1662, 8.5156
    UNION ALL SELECT 'Solothurn', 47.2088, 7.5323
    UNION ALL SELECT 'Thurgau', 47.5535, 9.0559
    UNION ALL SELECT 'Schwyz', 47.0207, 8.6530
    UNION ALL SELECT 'Fribourg', 46.8065, 7.1620
    UNION ALL SELECT 'Neuchâtel', 46.9900, 6.9293
    UNION ALL SELECT 'Valais', 46.2278, 7.5206
),
companies_with_coords AS (
    SELECT 
        c.*,
        cc.latitude,
        cc.longitude
    FROM {{ ref('dim_companies') }} c
    LEFT JOIN canton_centers cc ON c.canton = cc.canton
    WHERE 1=1
    {% if company_name_like %}
        AND LOWER(c.company_name) LIKE LOWER('%{{ company_name_like }}%')
    {% endif %}
    {% if legal_form %}
        AND c.legal_form = '{{ legal_form }}'
    {% endif %}
    {% if canton %}
        AND c.canton = '{{ canton }}'
    {% endif %}
    {% if industry_code %}
        AND c.industry_code = '{{ industry_code }}'
    {% endif %}
    {% if min_capital %}
        AND c.share_capital_chf >= {{ min_capital }}
    {% endif %}
    {% if max_capital %}
        AND c.share_capital_chf <= {{ max_capital }}
    {% endif %}
    {% if min_employees %}
        AND c.employees >= {{ min_employees }}
    {% endif %}
    {% if max_employees %}
        AND c.employees <= {{ max_employees }}
    {% endif %}
),
filtered_by_bbox AS (
    SELECT *
    FROM companies_with_coords
    WHERE 1=1
    {% if bbox %}
        {% set coords = bbox.split(',') %}
        {% if coords | length == 4 %}
            AND longitude >= {{ coords[0] }}
            AND latitude >= {{ coords[1] }}
            AND longitude <= {{ coords[2] }}
            AND latitude <= {{ coords[3] }}
        {% endif %}
    {% endif %}
),
paginated AS (
    SELECT 
        *,
        COUNT(*) OVER() AS total_count
    FROM filtered_by_bbox
    ORDER BY registration_date DESC, company_name
    LIMIT {{ page_size | default(100) }}
    OFFSET ({{ page | default(1) }} - 1) * {{ page_size | default(100) }}
)
SELECT 
    company_uid,
    company_name,
    legal_form,
    registration_date,
    canton,
    latitude,
    longitude,
    share_capital_chf,
    industry_code,
    industry_description,
    employees,
    company_size_category,
    total_count
FROM paginated
