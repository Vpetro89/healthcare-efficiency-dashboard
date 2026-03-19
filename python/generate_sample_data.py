import csv
import random
from pathlib import Path

random.seed(7)
root = Path(__file__).resolve().parents[1]
raw_dir = root / "data" / "raw"
raw_dir.mkdir(parents=True, exist_ok=True)

departments = ["ED", "CARDIOLOGY", "PRIMARY CARE", "ORTHOPEDICS", "ONCOLOGY"]
providers = ["P100", "P101", "P102", "P103", "P104"]
visit_types = ["Emergency", "Follow Up", "New Patient", "Procedure"]
statuses = ["Completed", "Cancelled", "No Show", "COMPLETE"]

# reuse patient IDs to simulate repeat visits
patient_ids = [f"PT{1000+i}" for i in range(1, 21)]

encounters = []
for i in range(1, 41):
    workload = random.choice([1.0, 1.5, 2.0, 2.5])
    
    # loosely tie productive hours to workload with small variation
    productive = round(workload * random.uniform(0.8, 1.2), 2)

    encounters.append([
        random.choice(patient_ids),
        f"ENC{2000+i}",
        f"2026-03-{(i % 28) + 1:02d}",
        random.choice(departments),
        random.choice(providers),
        random.choice(statuses),
        random.choice(visit_types),
        workload,
        productive,
    ])

with open(raw_dir / "raw_encounters.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow([
        "patient_id",
        "encounter_id",
        "encounter_date",
        "department",
        "provider_id",
        "encounter_status",
        "visit_type",
        "workload_units",
        "productive_hours"
    ])
    writer.writerows(encounters)

print("Sample encounter data regenerated.")