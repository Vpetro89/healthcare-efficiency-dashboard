-- 02_stage_billing.sql

CREATE OR REPLACE TEMP VIEW raw_billing AS
SELECT * FROM csv.`data/raw/raw_billing.csv`;

CREATE OR REPLACE TEMP VIEW stg_billing AS
WITH normalized AS (
    SELECT
        TRIM(billing_txn_id) AS billing_txn_id,
        TRIM(encounter_id) AS encounter_id,
        TRIM(charge_code) AS charge_code,
        CAST(charge_amount AS DOUBLE) AS charge_amount,
        CAST(allowed_amount AS DOUBLE) AS allowed_amount,
        CAST(paid_amount AS DOUBLE) AS paid_amount,
        CAST(posting_date AS DATE) AS posting_date
    FROM raw_billing
),
deduped AS (
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY billing_txn_id
                ORDER BY posting_date DESC
            ) AS rn
        FROM normalized
    )
    WHERE rn = 1
)
SELECT
    billing_txn_id,
    encounter_id,
    charge_code,
    charge_amount,
    allowed_amount,
    paid_amount,
    posting_date
FROM deduped;
