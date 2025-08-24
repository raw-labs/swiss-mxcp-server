{{ config(
    materialized='table',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_canton ON {{ this }} (Canton)",
        "CREATE INDEX IF NOT EXISTS idx_legal_form ON {{ this }} (LegalForm)",
        "CREATE INDEX IF NOT EXISTS idx_registration_date ON {{ this }} (RegistrationDate)"
    ]
) }}

select
    "CompanyName" as CompanyName,
    "LegalForm" as LegalForm,
    "UID" as UID,
    cast("RegistrationDate" as date) as RegistrationDate,
    "Canton" as Canton,
    cast("ShareCapitalCHF" as bigint) as ShareCapitalCHF,
    "IndustryCode" as IndustryCode,
    "IndustryDescription" as IndustryDescription,
    cast("Employees" as integer) as Employees
from read_csv('data/swiss-business-registry-sample.csv', header=true, auto_detect=true)
