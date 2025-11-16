data work.dm;
   input SUBJECT $ USUBJID $ AGE SEX $ BRTHDTC yymmdd10. RFSTDC yymmdd10.;
   format BRTHDTC RFSTDC yymmdd10.;
   datalines;
	S01 1001 45 M 1979-05-12 2025-01-01
	S02 1002 .  F 1985-03-21 2025-01-02
	S03 1003 60 M 1965-11-03 2025-01-03
	S04 1004 30 C 1995-07-09 2025-01-04
	S02 1002 29 F 1996-06-01 2025-01-02 /* duplicate SUBJECT intentionally */
	;
proc print noobs;
run;
/*---------------------------------------*/
data work.vs;
   input USUBJID $ AGE SEX $ VSDTC yymmdd10. SBP DBP;
   format VSDTC yymmdd10.;
   datalines;
	1001 Baseline 2025-01-01 120 80
	1001 Day15    2025-01-15 125 82
	1002 Baseline 2025-01-02 450 90    /* obvious outlier */
	1003 Baseline 2025-01-03 110 70
	1004 Baseline 2025-01-04 115 75
	;
proc print noobs;
run;
/*////////////////////// */
data work.advs;
   input USUBJID $ VISIT $ VISITN GLUCOSE;
   datalines;
	1001 Baseline 0  140
	1001 Day15    1  150
	1001 Day30    2  160
	1002 Baseline 0  200
	1002 Day15    1  210
	1003 Baseline 0  120
	1003 Day15    1   35  /* hypoglycemic / outlier example */
	1004 Baseline 0  140
	;
	proc print;
	run;
/*****************************/
/*Q: Mising AGE In Work.dm*/
proc sql;
	title "Missing Age Dataset";
	select USUBJID $ AGE SEX $
	from work.dm;
	where Missing(AGE);
	quit;
	
	data missing_age;
	set work.dm;
	if missing(AGE);
	proc print;
	run;
	/**************************/
/* Q. Merging Dataset *****/
	data merging dataset_DM_VS;
	merge work.dm (in=inDM) work.vs;
	by USUBJID;
	if inDM;
	proc print;
	run;
/*---------------------------by SQL****************/
	proc sql;
	create table Merge of work.dm_work.vs as
	select a.*, b.*
	from work.dm a
	left join work.vs b
	on a.usubjid=b.usubjid;
	proc print;
	run;
	quit;

	proc sql;
	create table Merge of work.dm_work.vs as
	select a.*, b.visit, b.vsdtc, b.sbp, b.dbp, b.age
	from work.dm a
	left join work.vs b
	on a.subjid=b.subjid;
	quit;
	
	/**************GLUCOSE IF THEN ELSE************/
data work.check_glucose;
  set work.advs;
  /* flag extreme / clinically improbable glucose */
  if glucose < 40 or glucose > 600 then glucose_flag = 1;
  else glucose_flag = 0;
run;

proc print data=work.check_glucose;
  where glucose_flag = 1 or glucose < 70; /* show extreme and low values */
  title "Abnormal glucose (flagged)";
run;
	/************
/* ========================= Q11: Identify duplicates in DM ========================= */
/* Using PROC SORT with NODUPKEY and DUPOUT */
proc sort data=work.dm nodupkey dupout=work.dm_duplicates out=work.dm_nodup;
  by usubjid;
run;

proc print data=work.dm_nodup;
  title "Duplicate DM records (dupout)";
run;
/**********************/
/* ========================= Q12: Calculate Change From Baseline (CFB) for glucose ========================= */
/* Approach: ensure sorted by subject and visit number; capture baseline then compute cfb */
proc sort data=work.advs; by usubjid visitn; run;

data work.advs_cfb;
  set work.advs;
  by usubjid;
  retain base_glucose;
  if first.usubjid then base_glucose = .; /* reset for each subject */
  if visitn = 0 then base_glucose = glucose; /* baseline defined by visitn=0 */
  cfb = glucose - base_glucose;
run;

proc print data=work.advs_cfb; title "ADVS with Change From Baseline (CFB)"; run;
/**************CHANGE IN GLUCOSE BY IF****/
data Glucose_change;
	set work.advs;
	by usubjid;
	retain base_glucose;
	if first.usubjid then base_glucose= .;
	if visitn=0 then base_glucose= glucose;
	cfb= glucose-base_glucose;
run;
proc print data=Glucose_change; title "Change in Blood Glucose Level (mg/dl)"; run;

/* ========================= Q13: IF–THEN–ELSE blood pressure classification ========================= */
/* Simple cutoff example */
data work.vs_bp_class;
  set work.vs;
  length bp_status $20;
  if sbp > 200 then bp_status = "Severe Hypertension";
  else if sbp >= 140 then bp_status = "Stage 2 Hypertension";
  else if sbp >= 130 then bp_status = "Stage 1 Hypertension";
  else bp_status = "Normal";
run;

proc print data=work.vs_bp_class; title "BP Classification"; run;
/*****************/