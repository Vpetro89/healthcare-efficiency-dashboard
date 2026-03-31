## Clinical Data Staging

### Description
This project focuses on staging and validating clinical encounter and billing data before it is used for reporting. The workflow is built to catch common data issues early, confirm that encounter and billing records align, and produce reporting tables that can be used for operational review.

### Structure
- `sql/01_stage_encounters.sql`
- `sql/02_stage_billing.sql`
- `sql/03_validate_data.sql`
- `sql/04_reporting_tables.sql`

### Workflow
`load → stage → validate → report`

### Validation Checks
- Row counts
- Duplicate `encounter_id` checks
- Null checks for `patient_id` and `encounter_id`
- Encounter-to-billing join coverage

### Output
- Volume by department
- Productivity reporting
- Revenue reporting
