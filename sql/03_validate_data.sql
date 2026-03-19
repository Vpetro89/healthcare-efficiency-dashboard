-- 03_validate_data.sql

SELECT 'raw_encounters' AS check_name, COUNT(*) AS row_count FROM raw_encounters
UNION ALL
SELECT 'stg_encounters' AS check_name, COUNT(*) AS row_count FROM stg_encounters;

SELECT encounter_id, COUNT(*) AS duplicate_count
FROM raw_encounters
WHERE encounter_id IS NOT NULL
GROUP BY encounter_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS null_encounter_ids
FROM raw_encounters
WHERE encounter_id IS NULL OR TRIM(encounter_id) = '';

SELECT b.encounter_id, COUNT(*) AS billing_rows
FROM stg_billing b
LEFT JOIN stg_encounters e
    ON b.encounter_id = e.encounter_id
WHERE e.encounter_id IS NULL
GROUP BY b.encounter_id;

SELECT *
FROM stg_billing
WHERE charge_amount = 0
   OR allowed_amount = 0
   OR paid_amount = 0;
