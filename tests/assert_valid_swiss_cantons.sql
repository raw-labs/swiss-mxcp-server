-- Test that all cantons in the data are valid Swiss cantons

WITH valid_cantons AS (
    SELECT unnest([
        'Zürich', 'Bern', 'Geneva', 'Basel-Stadt', 'Basel-Landschaft', 
        'Aargau', 'St. Gallen', 'Grisons', 'Lucerne', 'Ticino',
        'Valais', 'Vaud', 'Thurgau', 'Solothurn', 'Neuchâtel',
        'Fribourg', 'Schaffhausen', 'Appenzell Ausserrhoden',
        'Appenzell Innerrhoden', 'Glarus', 'Jura', 'Obwalden',
        'Nidwalden', 'Schwyz', 'Uri', 'Zug'
    ]) as valid_canton
),
actual_cantons AS (
    SELECT DISTINCT Canton
    FROM {{ ref('swiss_companies') }}
    WHERE Canton IS NOT NULL
)
SELECT 
    ac.Canton as invalid_canton
FROM actual_cantons ac
LEFT JOIN valid_cantons vc ON ac.Canton = vc.valid_canton
WHERE vc.valid_canton IS NULL
