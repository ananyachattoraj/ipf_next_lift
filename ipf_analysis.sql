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