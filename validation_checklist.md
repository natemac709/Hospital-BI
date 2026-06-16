Validation Checklist — Hospital BI SQL Pack (v0.1)
Import Checks
●	☐ admissions row count matches CSV
●	☐ diag row count matches CSV
●	☐ ed_visits row count matches CSV
●	☐ providers row count matches CSV
●	☐ Key fields parsed as expected (dates/text)
Logic Checks
●	Length of Stay (LOS)
●	☐ Exclude rows where discharge_dt IS NULL
●	☐ Hand-check 3 admissions: LOS = discharge_dt - admit_dt (days)
●	Readmissions (30-day)
●	☐ Confirm at least one patient has multiple admissions
●	☐ Query returns only readmits within 30 days after discharge
●	☐ Spot-check 2 patients for correctness
●	ED Metrics
●	☐ LWBS rate between 0%–10% across days; no day >15%
●	☐ Door-to-doc average ~10–60 minutes; P90 > average
●	☐ Remove/flag extreme outliers if present
●	Payer Mix
●	☐ Medicaid + Medicare ≈ 70%–85% (safety‑net profile)
●	☐ Commercial + Self-pay ≈ 15%–30%
●	Discharge Disposition
●	☐ Home ≈ 70%–85%; SNF 5%–10%; Transfer 5%–12%; Expired 1%–3%
●	Equity Slice (aggregate only)
●	☐ Ward and race_ethnicity look plausible
●	☐ Average door_to_doc_min by ward shows small/moderate variation; investigate extremes
Null Handling
●	☐ LOS/readmission exclude NULL discharge_dt
●	☐ COALESCE or WHERE clauses prevent NULL math
Performance/Sanity
●	☐ Queries run under ~1s on SQLite
●	☐ Save 2–3 output screenshots/CSVs and reference in README
Sign-offs (initials/date)
●	Data imported correctly: ____ / ____
●	KPIs validated: ____ / ____
●	README updated with sample outputs: ____ / ____
