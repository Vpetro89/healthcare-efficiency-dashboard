clinical-data-staging

Staging and validation of clinical encounter and billing data.

structure

sql/01_stage_encounters.sql

sql/02_stage_billing.sql

sql/03_validate_data.sql

sql/04_reporting_tables.sql

workflow

load → stage → validate → report

checks

row counts

duplicates (encounter_id)

nulls (patient_id, encounter_id)

encounter ↔ billing join coverage

output

volume by department

productivity

revenue