Trainee Clinical Data Engineer — SAS Practice Project

This repository contains a complete SAS practice project designed to demonstrate the core skills required for a Trainee Clinical Data Engineer (CDE) role in Clinical Research Organizations (CROs) like Parexel, IQVIA, ICON, Syneos, and Covance.

The project uses Demographics (DM), Vital Signs (VS), and Glucose (ADVS) datasets to simulate real-world CDM tasks such as:

Missing data checks

Duplicate detection

Data merging (DM + VS)

Outlier identification

Baseline and Change-From-Baseline derivations

Clinical logic using IF–THEN–ELSE

Query management simulation

SAS DATA step + SQL programming
////////////////////////////////////////////////
Demo Datasets
1️⃣ Demographics (DM)

Variables:

SUBJECT

USUBJID

AGE

SEX

BRTHDTC

RFSTDTC

Includes:

✔ Missing AGE

✔ Duplicate USUBJID (to demonstrate duplicate handling)

2️⃣ Vital Signs (VS)

Variables:

USUBJID

VISIT

VSDTC

SBP

DBP

Includes:

✔ Outlier systolic BP (SBP = 450)

3️⃣ ADVS (Glucose Measurements)

Variables:

USUBJID

VISIT

VISITN

GLUCOSE

Includes:

✔ Hypoglycemic value (GLUCOSE = 35)

✔ Baseline + follow-up values

🎯 Key SAS Tasks Covered
✔ 1. Missing Data Detection
proc sql;
  select * from dm where missing(age);
quit;

✔ 2. Merging Datasets (DM + VS)

DATA step merge:

merge dm(in=inDM) vs;
by usubjid;
if inDM;


SQL join:

select a.*, b.visit, b.vsdtc, b.sbp, b.dbp
from dm a
left join vs b
on a.usubjid = b.usubjid;

✔ 3. Outlier Identification (Glucose)
if glucose < 40 or glucose > 600 then glucose_flag = 1;

✔ 4. Detect Duplicate Subjects
proc sort data=dm nodupkey dupout=dm_duplicates;
by usubjid;
run;

✔ 5. Baseline & Change-From-Baseline (CFB)
retain base_glucose;
if visitn = 0 then base_glucose = glucose;
cfb = glucose - base_glucose;

✔ 6. IF–THEN–ELSE Clinical Logic (Blood Pressure Classification)
if sbp > 200 then bp_status = "Severe Hypertension";
else if sbp >= 140 then bp_status = "Stage 2 Hypertension";
else if sbp >= 130 then bp_status = "Stage 1 Hypertension";
else bp_status = "Normal";

✔ 7. Query Management Simulation

Includes:

Detecting incorrect BP value (450)

Creating a query dataset

Simulating site response dataset

Updating original dataset

Maintaining a change_log audit trail

🔍 Skills Demonstrated (Recruiter Friendly)
Clinical Data Management (CDM)

Data cleaning

Discrepancy identification

Query generation & resolution

Visit-based data checks

Clinical validation logic

Baseline derivations (ADaM-style)

SAS Programming

DATA step programming

PROC SQL (joins, missing checks)

PROC SORT (nodupkey, dupout)

RETAIN + FIRST. logic

Flag creation

Merging / joining datasets

Date handling (YYMMDD informat/format)

🚀 How to Run the Project

Open SAS Studio / SAS OnDemand

Upload the .sas file from the sas/ directory

Run the demo data creation blocks (DM, VS, ADVS)

Run each analysis block in order:

Missing data

Merging

Outliers

Duplicates

Baseline + CFB

BP classification

Query workflow

View results in SAS output window or export into /outputs folder

👨‍💻 Author

Shekhar Nalawade
M.Pharm (Pharmacology)
Aspiring Clinical Data Engineer
Skills: SAS | SQL | R | CDM | SDTM Basics | REDCap
Location: India
