{{ config(
    materialized='view'
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

