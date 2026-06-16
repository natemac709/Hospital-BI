/**
--Admissions by day (first 15) 
SELECT substr(admit_dt,1,10) AS admit_date, COUNT(*) AS admits FROM admissions GROUP BY substr(admit_dt,1,10) ORDER BY substr(admit_dt,1,10) LIMIT 15;

--Average LOS 
SELECT ROUND(AVG(julianday(discharge_dt) - julianday(admit_dt)), 2) AS avg_los_days FROM admissions WHERE discharge_dt IS NOT NULL;

--30-day readmissions (count) 
SELECT COUNT(*) AS readmit_pairs FROM ( SELECT a.patient_id FROM admissions a JOIN admissions b ON a.patient_id = b.patient_id AND b.admit_dt > a.discharge_dt WHERE a.discharge_dt IS NOT NULL AND (julianday(b.admit_dt) - julianday(a.discharge_dt)) <= 30 );

--Top 10 diagnoses 
SELECT icd10, COUNT(*) AS dx_count FROM diag WHERE primary_flag = 1 GROUP BY icd10 ORDER BY dx_count DESC LIMIT 10;

--Discharge disposition mix 
WITH total AS ( SELECT COUNT() AS n FROM admissions WHERE discharge_dt IS NOT NULL ) SELECT COALESCE(discharge_disp,'Unknown') AS discharge_disp, COUNT() AS discharges, ROUND(100.0 * COUNT(*) / (SELECT n FROM total), 1) AS pct FROM admissions WHERE discharge_dt IS NOT NULL GROUP BY COALESCE(discharge_disp,'Unknown') ORDER BY discharges DESC;

--ED LWBS rate by day (first 15) 
SELECT substr(arrival_ts,1,10) AS d, ROUND(AVG(CASE WHEN dispo='LWBS' THEN 1.0 ELSE 0 END), 3) AS lwbs_rate FROM ed_visits GROUP BY substr(arrival_ts,1,10) ORDER BY substr(arrival_ts,1,10) LIMIT 15;

--Door-to-Doc average by day (first 15) 
SELECT substr(arrival_ts,1,10) AS d, ROUND(AVG(door_to_doc_min), 1) AS avg_dtd FROM ed_visits GROUP BY substr(arrival_ts,1,10) ORDER BY substr(arrival_ts,1,10) LIMIT 15;

--Payer mix 
WITH total AS (SELECT COUNT() AS n FROM admissions) SELECT payer, COUNT() AS visits, ROUND(100.0 * COUNT(*) / (SELECT n FROM total), 1) AS pct FROM admissions GROUP BY payer ORDER BY visits DESC;

--Equity: Door-to-Doc by ward (proxy via ed_flag) 
SELECT ward, ROUND(AVG(door_to_doc_min), 1) AS avg_dtd, COUNT(*) AS n FROM admissions a JOIN ed_visits e ON a.ed_flag = 1 GROUP BY ward ORDER BY AVG(door_to_doc_min) DESC;

--KPI summary (single result grid) 
SELECT 'admits' AS metric, (SELECT COUNT() FROM admissions) AS value UNION ALL SELECT 'avg_los_days', (SELECT ROUND(AVG(julianday(discharge_dt) - julianday(admit_dt)),2) FROM admissions WHERE discharge_dt IS NOT NULL) UNION ALL SELECT 'readmit_pairs', (SELECT COUNT() FROM ( SELECT a.patient_id FROM admissions a JOIN admissions b ON a.patient_id=b.patient_id AND b.admit_dt>a.discharge_dt WHERE a.discharge_dt IS NOT NULL AND (julianday(b.admit_dt)-julianday(a.discharge_dt))<=30 )) UNION ALL SELECT 'lwbs_rate', (SELECT ROUND(AVG(CASE WHEN dispo='LWBS' THEN 1.0 ELSE 0 END),3) FROM ed_visits) UNION ALL SELECT 'avg_door_to_doc', (SELECT ROUND(AVG(door_to_doc_min),1) FROM ed_visits);

**/


SELECT 'Admissions by day' AS Section, substr(admit_dt,1,10) AS Metric, CAST(COUNT(*) AS TEXT) AS Value FROM admissions GROUP BY substr(admit_dt,1,10)

UNION ALL SELECT 'Average LOS','avg_los_days', CAST(ROUND(AVG(julianday(discharge_dt) - julianday(admit_dt)), 2) AS TEXT) FROM admissions WHERE discharge_dt IS NOT NULL

UNION ALL SELECT '30-day readmissions','readmit_pairs', CAST(COUNT(*) AS TEXT) FROM ( SELECT a.patient_id FROM admissions a JOIN admissions b ON a.patient_id = b.patient_id AND b.admit_dt > a.discharge_dt WHERE a.discharge_dt IS NOT NULL AND (julianday(b.admit_dt) - julianday(a.discharge_dt)) <= 30 )

UNION ALL SELECT 'Top diagnoses', icd10, CAST(COUNT(*) AS TEXT) FROM diag WHERE primary_flag = 1 GROUP BY icd10

UNION ALL SELECT 'Discharge mix', COALESCE(discharge_disp,'Unknown'), CAST(COUNT() AS TEXT) || ' (' || CAST(ROUND(100.0 * COUNT() / (SELECT COUNT(*) FROM admissions WHERE discharge_dt IS NOT NULL),1) AS TEXT) || '%)' FROM admissions WHERE discharge_dt IS NOT NULL GROUP BY COALESCE(discharge_disp,'Unknown')

UNION ALL SELECT 'ED LWBS rate by day', substr(arrival_ts,1,10), CAST(ROUND(AVG(CASE WHEN dispo='LWBS' THEN 1.0 ELSE 0 END), 3) AS TEXT) FROM ed_visits GROUP BY substr(arrival_ts,1,10)

UNION ALL SELECT 'Door-to-Doc avg by day', substr(arrival_ts,1,10), CAST(ROUND(AVG(door_to_doc_min), 1) AS TEXT) FROM ed_visits GROUP BY substr(arrival_ts,1,10)

UNION ALL SELECT 'Payer mix', payer, CAST(COUNT() AS TEXT) || ' (' || CAST(ROUND(100.0 * COUNT() / (SELECT COUNT(*) FROM admissions),1) AS TEXT) || '%)' FROM admissions GROUP BY payer

UNION ALL SELECT 'Equity: DTD by ward', ward, CAST(ROUND(AVG(door_to_doc_min), 1) AS TEXT) || ' | n=' || CAST(COUNT(*) AS TEXT) FROM admissions a JOIN ed_visits e ON a.ed_flag = 1 GROUP BY ward

UNION ALL SELECT 'KPI summary','admits', CAST((SELECT COUNT() FROM admissions) AS TEXT) UNION ALL SELECT 'KPI summary','avg_los_days', CAST((SELECT ROUND(AVG(julianday(discharge_dt) - julianday(admit_dt)),2) FROM admissions WHERE discharge_dt IS NOT NULL) AS TEXT) UNION ALL SELECT 'KPI summary','readmit_pairs', CAST((SELECT COUNT() FROM ( SELECT a.patient_id FROM admissions a JOIN admissions b ON a.patient_id=b.patient_id AND b.admit_dt>a.discharge_dt WHERE a.discharge_dt IS NOT NULL AND (julianday(b.admit_dt)-julianday(a.discharge_dt))<=30 )) AS TEXT) UNION ALL SELECT 'KPI summary','lwbs_rate', CAST((SELECT ROUND(AVG(CASE WHEN dispo='LWBS' THEN 1.0 ELSE 0 END),3) FROM ed_visits) AS TEXT) UNION ALL SELECT 'KPI summary','avg_door_to_doc', CAST((SELECT ROUND(AVG(door_to_doc_min),1) FROM ed_visits) AS TEXT);
