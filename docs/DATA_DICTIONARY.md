data_dictionary
raw_encounters.csv

patient_id – unique patient identifier
encounter_id – unique encounter identifier
encounter_date – date of encounter
department – clinical department
provider_id – provider identifier
encounter_status – encounter status (Completed, Cancelled, No Show, etc.)
visit_type – type of visit
workload_units – relative workload measure for encounter
productive_hours – hours attributed to encounter

raw_billing.csv

billing_txn_id – unique billing transaction identifier
encounter_id – associated encounter
charge_code – billing code
charge_amount – total charge amount
allowed_amount – allowed amount after adjustments
paid_amount – amount paid
posting_date – date payment was posted