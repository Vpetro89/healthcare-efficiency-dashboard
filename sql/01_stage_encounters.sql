-- 01_stage_encounters.sql

CREATE OR REPLACE TEMP VIEW raw_encounters AS
SELECT * FROM csv.`data/raw/raw_encounters.csv`;

CREATE OR REPLACE TEMP VIEW stg_encounters AS
WITH normalized AS (
    SELECT
        TRIM(patient_id) AS patient_id,
        NULLIF(TRIM(encounter_id), '') AS encounter_id,
        CAST(encounter_date AS DATE) AS encounter_date,
        UPPER(TRIM(department)) AS department,
        TRIM(provider_id) AS provider_id,
        CASE
            WHEN UPPER(TRIM(encounter_status)) LIKE 'COMPLETE%' THEN 'COMPLETED'
            WHEN UPPER(TRIM(encounter_status)) = 'CANCELLED' THEN 'CANCELLED'
            WHEN UPPER(TRIM(encounter_status)) = 'NO SHOW' THEN 'NO SHOW'
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
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY encounter_id
                ORDER BY encounter_date DESC, patient_id
            ) AS rn
        FROM normalized
        WHERE encounter_id IS NOT NULL
    )
    WHERE rn = 1
)
SELECT
    patient_id,
    encounter_id,
    encounter_date,
    department,
    provider_id,
    encounter_status,
    visit_type,
    workload_units,
    productive_hours
FROM deduped;
