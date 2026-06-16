--PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS diag; 
DROP TABLE IF EXISTS ed_visits; 
DROP TABLE IF EXISTS providers; 
DROP TABLE IF EXISTS admissions;

CREATE TABLE admissions ( admission_id INTEGER PRIMARY KEY, patient_id INTEGER NOT NULL, admit_dt TEXT NOT NULL, discharge_dt TEXT, admit_src TEXT, discharge_disp TEXT, payer TEXT, ed_flag INTEGER, ward TEXT, race_ethnicity TEXT, trauma_flag INTEGER );

CREATE TABLE diag ( encounter_id INTEGER PRIMARY KEY, admission_id INTEGER NOT NULL, icd10 TEXT NOT NULL, primary_flag INTEGER NOT NULL CHECK (primary_flag IN (0,1)), FOREIGN KEY (admission_id) REFERENCES admissions(admission_id) );

CREATE TABLE ed_visits ( visit_id INTEGER PRIMARY KEY, patient_id INTEGER NOT NULL, arrival_ts TEXT NOT NULL, triage_level INTEGER, door_to_doc_min INTEGER, dispo TEXT, stroke_alert INTEGER, stemi_alert INTEGER, language TEXT );

CREATE TABLE providers ( provider_id INTEGER PRIMARY KEY, dept TEXT NOT NULL, specialty TEXT NOT NULL, npi TEXT NOT NULL );

