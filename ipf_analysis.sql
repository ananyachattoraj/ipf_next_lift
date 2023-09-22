USE ipf;
SELECT
avg(Best3SquatKg) as avgsq
, avg(Best3BenchKg) as avgb
, avg(Best3DeadliftKg) as avgd
, avg(TotalKg) as avgtot
, Sex
, WClass2023
FROM sbd
GROUP BY Sex, WClass2023;

SELECT
DISTINCT Tested
FROM sbd;

#for modeling, I want to go back to python using the relevant columns
#so, let's export back to csv and then put it back in the python folder.
SELECT
'Sex', 'BirthClass', 'BW', 'S1', 'S2', 'S3', 'Best3S', 'B1', 'B2', 'B3', 'Best3B', 'D1', 'D2', 'D3', 'Best3D', 'Total'
UNION ALL
SELECT
Sex
, BirthClassImputed
, BodyweightKG
, Squat1KG
, Squat2KG
, Squat3KG
, Best3SquatKG
, Bench1KG
, Bench2KG
, Bench3KG
, Best3BenchKG
, Deadlift1KG
, Deadlift2KG
, Deadlift3KG
, Best3DeadliftKG
, TotalKG
FROM sbd
WHERE Equipment = 'Raw'
AND Tested = 'Yes'
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/output.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';