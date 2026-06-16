import numpy as np
import pandas as pd
from pathlib import Path

def main():
    rng = np.random.default_rng(42)

    # Base folders
    BASE = Path(__file__).resolve().parent
    DATA = BASE / "data"
    DATA.mkdir(parents=True, exist_ok=True)

    # Sizes
    N_ADM = 800      # inpatient admissions
    N_ED  = 1500     # ED visits

    # Distributions (Howard-flavored: safety-net, Level 1 trauma, STEMI/Stroke, OB)
    dates = pd.date_range("2025-10-01","2025-12-15",freq="D")
    payers = ["Medicaid","Medicare","Commercial","Self-pay"]
    payer_p = [0.55,0.25,0.15,0.05]
    wards = [f"Ward {i}" for i in [1,4,5,6,7,8]]
    ward_p = [0.10,0.10,0.15,0.15,0.25,0.25]
    race = ["Black","White","Hispanic/Latino","Other"]
    race_p = [0.75,0.10,0.10,0.05]
    admit_src = ["ED","Clinic","Transfer"]
    admit_src_p = [0.70,0.20,0.10]
    dispo = ["Home","SNF","Transfer","Expired"]
    dispo_p = [0.80,0.08,0.10,0.02]
    icd10s = ["I10","I21.9","I50.9","I63.9","J18.9","J44.1","N39.0","K52.9","R07.9","J06.9"]

    # Admissions
    admission_id = np.arange(1001,1001+N_ADM)
    patient_id = rng.integers(10000, 10000+int(N_ADM*0.7), size=N_ADM)  # repeats enable readmits
    admit_dt = rng.choice(dates, size=N_ADM)
    los = rng.integers(1,7,size=N_ADM)
    discharge_dt = pd.to_datetime(admit_dt) + pd.to_timedelta(los, unit="D")
    active_mask = rng.random(N_ADM) < 0.10  # 10% active (no discharge yet)

    df_adm = pd.DataFrame({
        "admission_id": admission_id,
        "patient_id": patient_id,
        "admit_dt": pd.to_datetime(admit_dt).date,
        "discharge_dt": pd.Series(discharge_dt).dt.date.mask(active_mask, other=pd.NaT),
        "admit_src": rng.choice(admit_src, p=admit_src_p, size=N_ADM),
        "discharge_disp": rng.choice(dispo, p=dispo_p, size=N_ADM),
        "payer": rng.choice(payers, p=payer_p, size=N_ADM),
        "ed_flag": (rng.random(N_ADM) < 0.70).astype(int),
        "ward": rng.choice(wards, p=ward_p, size=N_ADM),
        "race_ethnicity": rng.choice(race, p=race_p, size=N_ADM),
        "trauma_flag": (rng.random(N_ADM) < 0.05).astype(int)
    })

    # Diagnoses: 1–2 rows per admission, guarantee one primary
    rows = []
    enc_id = 9001
    for aid in admission_id:
        k = rng.integers(1,3)
        primary_set = False
        for _ in range(k):
            rows.append([enc_id, aid, rng.choice(icd10s), 1 if not primary_set else 0])
            primary_set = True
            enc_id += 1
    df_diag = pd.DataFrame(rows, columns=["encounter_id","admission_id","icd10","primary_flag"])

    # ED visits
    visit_id = np.arange(30001,30001+N_ED)
    arrival_ts = rng.choice(pd.date_range("2025-10-15","2025-12-15",freq="min"), size=N_ED)
    triage = rng.integers(1,6,size=N_ED)
    door_to_doc = np.clip(rng.normal(30,12,N_ED).astype(int), 2, 120)
    ed_dispo = rng.choice(["Admit","Discharge","Transfer","LWBS"], p=[0.18,0.72,0.06,0.04], size=N_ED)
    stemi = (rng.random(N_ED) < 0.01).astype(int)
    stroke = (rng.random(N_ED) < 0.012).astype(int)
    lang = rng.choice(["English","Spanish","Other"], p=[0.80,0.15,0.05], size=N_ED)

    df_ed = pd.DataFrame({
        "visit_id": visit_id,
        "patient_id": rng.integers(20000, 22000, size=N_ED),
        "arrival_ts": arrival_ts,
        "triage_level": triage,
        "door_to_doc_min": door_to_doc,
        "dispo": ed_dispo,
        "stroke_alert": stroke,
        "stemi_alert": stemi,
        "language": lang
    })

    # Providers (small reference)
    df_prov = pd.DataFrame({
        "provider_id":[2001,2002,2003,2004,2005],
        "dept":["Medicine","Cardiology","Pulm","ED","OBGYN"],
        "specialty":["Hospitalist","Cardiologist","Pulmonology","ED","General"],
        "npi":["1111111111","2222222222","3333333333","4444444444","5555555555"]
    })

    # Save CSVs
    df_adm.to_csv(DATA/"admissions.csv", index=False)
    df_diag.to_csv(DATA/"diag.csv", index=False)
    df_prov.to_csv(DATA/"providers.csv", index=False)
    df_ed.to_csv(DATA/"ed_visits.csv", index=False)
    print("Saved CSVs to", DATA.resolve())

if __name__ == "__main__":
    main()
