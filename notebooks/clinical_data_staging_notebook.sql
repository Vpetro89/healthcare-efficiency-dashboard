-- Databricks notebook source

-- COMMAND ----------
CREATE OR REPLACE TEMP VIEW raw_encounters AS
SELECT * FROM csv.`dbfs:/FileStore/data/raw/raw_encounters.csv`
OPTIONS (header = "true");

CREATE OR REPLACE TEMP VIEW raw_billing AS
SELECT * FROM csv.`dbfs:/FileStore/data/raw/raw_billing.csv`
OPTIONS (header = "true");

-- COMMAND ----------
CREATE OR REPLACE TEMP VIEW stg_encounters AS
WITH normalized AS (
    SELECT
        TRIM(patient_id) AS patient_id,
        NULLIF(TRIM(encounter_id), '') AS encounter_id,
        CAST(encounter_date AS DATE) AS encounter_date,
        UPPER(TRIM(department)) AS department,
        TRIM(provider_id) AS provider_id,
        CASE
            WHEN encounter_status IS NULL OR TRIM(encounter_status) = '' THEN 'UNKNOWN'
            WHEN UPPER(TRIM(encounter_status)) LIKE 'COMPLETE%' THEN 'COMPLETED'
            ELSE UPPER(TRIM(encounter_status))
        END AS encounter_status,
        TRIM(visit_type) AS visit_type,
        CAST(workload_units AS DOUBLE) AS workload_units,
        CAST(productive_hours AS DOUBLE) AS productive_hours
    FROM raw_encounters
),
deduped AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY encounter_id ORDER BY encounter_date DESC) AS rn
        FROM normalized
        WHERE encounter_id IS NOT NULL
    )
    WHERE rn = 1
)
SELECT * FROM deduped;

-- COMMAND ----------
CREATE OR REPLACE TEMP VIEW stg_billing AS
SELECT *
FROM (
    SELECT
        TRIM(billing_txn_id) AS billing_txn_id,
        TRIM(encounter_id) AS encounter_id,
        TRIM(charge_code) AS charge_code,
        CAST(charge_amount AS DOUBLE) AS charge_amount,
        CAST(allowed_amount AS DOUBLE) AS allowed_amount,
        CAST(paid_amount AS DOUBLE) AS paid_amount,
        CAST(posting_date AS DATE) AS posting_date,
        ROW_NUMBER() OVER (PARTITION BY billing_txn_id ORDER BY posting_date DESC) AS rn
    FROM raw_billing
)
WHERE rn = 1 AND encounter_id IS NOT NULL;

-- COMMAND ----------
SELECT 'raw_encounters' AS table_name, COUNT(*) AS row_count FROM raw_encounters
UNION ALL
SELECT 'stg_encounters', COUNT(*) FROM stg_encounters
UNION ALL
SELECT 'raw_billing', COUNT(*) FROM raw_billing
UNION ALL
SELECT 'stg_billing', COUNT(*) FROM stg_billing;

-- COMMAND ----------
SELECT
    e.department,
    COUNT(DISTINCT e.encounter_id) AS encounters,
    ROUND(SUM(e.workload_units), 2) AS workload_units,
    ROUND(SUM(e.productive_hours), 2) AS productive_hours,
    ROUND(SUM(e.workload_units) / NULLIF(SUM(e.productive_hours), 0), 2) AS productivity,
    ROUND(SUM(COALESCE(b.paid_amount, 0)), 2) AS total_paid
FROM stg_encounters e
LEFT JOIN stg_billing b
    ON e.encounter_id = b.encounter_id
WHERE e.encounter_status = 'COMPLETED'
GROUP BY e.department
ORDER BY e.department;