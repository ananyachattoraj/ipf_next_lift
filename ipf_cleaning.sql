USE ipf;

SELECT
avg(Best3SquatKg) as avgsq
, avg(Best3BenchKg) as avgb
, avg(Best3DeadliftKg) as avgd
, avg(TotalKg) as avgtot
, Sex
, WeightClassKg
FROM pl_data
GROUP BY Sex, WeightClassKg;