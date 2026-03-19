-- 04_reporting_tables.sql

CREATE OR REPLACE TEMP VIEW rpt_department_volume AS
SELECT
    department,
    COUNT(*) AS encounters,
    SUM(workload_units) AS total_workload_units,
    SUM(productive_hours) AS total_productive_hours,
    ROUND(SUM(workload_units) / NULLIF(SUM(productive_hours), 0), 2) AS productivity_ratio
FROM stg_encounters
WHERE encounter_status = 'COMPLETED'
GROUP BY department;

CREATE OR REPLACE TEMP VIEW rpt_department_revenue AS
SELECT
    e.department,
    COUNT(DISTINCT e.encounter_id) AS billed_encounters,
    ROUND(SUM(b.charge_amount), 2) AS total_charge_amount,
    ROUND(SUM(b.allowed_amount), 2) AS total_allowed_amount,
    ROUND(SUM(b.paid_amount), 2) AS total_paid_amount
FROM stg_encounters e
INNER JOIN stg_billing b
    ON e.encounter_id = b.encounter_id
WHERE e.encounter_status = 'COMPLETED'
GROUP BY e.department;

CREATE OR REPLACE TEMP VIEW rpt_department_summary AS
SELECT
    v.department,
    v.encounters,
    v.total_workload_units,
    v.total_productive_hours,
    v.productivity_ratio,
    r.billed_encounters,
    r.total_charge_amount,
    r.total_allowed_amount,
    r.total_paid_amount
FROM rpt_department_volume v
LEFT JOIN rpt_department_revenue r
    ON v.department = r.department;

SELECT * FROM rpt_department_summary ORDER BY department;
