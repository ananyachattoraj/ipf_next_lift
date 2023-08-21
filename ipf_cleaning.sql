USE ipf;
SET SQL_SAFE_UPDATES = 0;
/*
Now that data has been loaded into this database, my goal is to clean this data. First, I want to just take a look at the data.
This will include simply viewing all columns with a limit of 10 rows to see if there's any inconsistencies in types of data.
I know from the schema creation that there are some issues with weight classes and the + symbol.
First, I will fix issues like that, then I will create a procedure to check null counts across the table.
I expect there to be many nulls in columns like the 4th attempts because those are only used in special cases.
So, I will create a separate table without those 4th attempts and then impute data the best I can.
Once as much data can be imputed has been done, I will then visualize some analyses using Tableau and then move back into Python for modeling.
*/

SELECT * FROM pl_data
LIMIT 10;
#Since I know weight classes were an issue in importing data, let's work on that first.
#As mentioned in the EDA Jupyter file, I want to convert all weight classes into the 2023 classes.
#First, I want to check for nulls to see how best to deal with the weight classes. It will be helpful to be able to see these across all columns for any table.

#Create procedure to call to check null values
#Drop check
DROP PROCEDURE IF EXISTS count_null_values;
#I want to make this procedure for any input table in the schema, so make variable tablen for input table
DELIMITER //
CREATE PROCEDURE count_null_values(
	IN tablen VARCHAR(100)
)
BEGIN
	#Run through each column in the table
    DECLARE cols VARCHAR(100);
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT c.column_name
        FROM information_schema.columns c
        WHERE c.table_name = tablen;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    SET @null_counts = '';

    OPEN cur;
	#Gather all the column names and null counts
    read_loop: LOOP
        FETCH cur INTO cols;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @null_counts = CONCAT(@null_counts, 'SUM(CASE WHEN `', cols, '` IS NULL THEN 1 ELSE 0 END) AS `', cols, '_nulls`, ');
    END LOOP;

    CLOSE cur;

    #Remove trailing commas and prepare the dynamic SQL with SELECT
    SET @null_counts = LEFT(@null_counts, LENGTH(@null_counts) - 2);
    SET @sql = CONCAT('CREATE OR REPLACE VIEW null_counts_view AS SELECT ', @null_counts, ' FROM `', tablen,'`;');

    #Execute the dynamic SQL
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    #Retrieve the data from null_counts_view
    SELECT * FROM null_counts_view;
END//
DELIMITER ;
#First call is on pl_data to check null counts for Bodyweight and Weight Class
CALL count_null_values('pl_data');

/*I see that weight class has fewer nulls. There might be cases where bodyweight isn't a null but weight class is, but given the
relatively few null values in either, I think it can be safe to simply convert using one. I will use weight class to convert to the
new weight class system with far fewer values.
*/

#Weight classes are dependent on age, sex, and weight. I'll peek into these a bit more first.
SELECT WeightClassKg
, COUNT(*) 
FROM pl_data
GROUP BY WeightClassKg;

SELECT DISTINCT WeightClassKg
FROM pl_data;
#There are numbers with + that will mess up the change. I have to fix this first.
UPDATE pl_data
SET WeightClassKg =
	CASE
		WHEN WeightClassKg LIKE '%+'
			THEN CONCAT(REPLACE(WeightClassKg, '+', ''), '.01')
			ELSE WeightClassKg
	END;
#Because WeightClassKg wasn't a decimal and the concat happened with a string, we now have issues of 85.5.01.
#To fix this, I'll search for those strings specifically and then get rid of the double decimal
SELECT WeightClassKg
FROM pl_data
WHERE WeightClassKg REGEXP '[0-9]+\\.[0-9]+\\.[0-9]+';

#All incorrect values follow the same pattern. Since IPF weight classes do not have a cusp on a decimal, I can simply drop the 
# incorrectly added '.01' and these values will still go into the correct weight class
UPDATE pl_data
SET WeightClassKg = SUBSTRING(WeightClassKg, 1, LENGTH(WeightClassKg) - 3)
WHERE WeightClassKg IS NOT NULL
    AND WeightClassKg REGEXP '[0-9]+\\.[0-9]+\\.[0-9]+';

SELECT DISTINCT BodyweightKg
FROM pl_data;

#Double check format of the Sex marker
SELECT Sex
FROM pl_data;

#The data dictionary says that Birth Year Class is most commonly used in IPF, and that's the data I'm using, so I'll use that.
#It also has fewer nulls than Age or Age Class (not to mention the fact that Age is approximate anyways)
SELECT BirthYearClass
FROM pl_data;

#Finally making the new column
ALTER TABLE pl_data
ADD COLUMN WClass2023 INT;

UPDATE pl_data
SET WClass2023 = CASE
    WHEN BirthYearClass = '14-18' AND Sex = 'F' AND WeightClassKg <= 43 THEN 43
    WHEN BirthYearClass = '14-18' AND Sex = 'M' AND WeightClassKg <= 53 THEN 53
    WHEN BirthYearClass = '19-23' AND Sex = 'F' AND WeightClassKg <= 43 THEN 43
    WHEN BirthYearClass = '19-23' AND Sex = 'M' AND WeightClassKg <= 53 THEN 53
	WHEN Sex = 'F' AND WeightClassKg <= 47 THEN 47
    WHEN Sex = 'F' AND WeightClassKg <= 52 THEN 52
    WHEN Sex = 'F' AND WeightClassKg <= 57 THEN 57
    WHEN Sex = 'F' AND WeightClassKg <= 63 THEN 63
    WHEN Sex = 'F' AND WeightClassKg <= 69 THEN 69
    WHEN Sex = 'F' AND WeightClassKg <= 76 THEN 76
    WHEN Sex = 'F' AND WeightClassKg <= 84 THEN 84
    WHEN Sex = 'F' AND WeightClassKg > 84 THEN 840
    WHEN Sex = 'M' AND WeightClassKg <= 59 THEN 59
    WHEN Sex = 'M' AND WeightClassKg <= 66 THEN 66
	WHEN Sex = 'M' AND WeightClassKg <= 74 THEN 74
    WHEN Sex = 'M' AND WeightClassKg <= 83 THEN 83
    WHEN Sex = 'M' AND WeightClassKg <= 93 THEN 93
    WHEN Sex = 'M' AND WeightClassKg <= 105 THEN 105
    WHEN Sex = 'M' AND WeightClassKg <= 120 THEN 120
    WHEN Sex = 'M' AND WeightClassKg > 120 THEN 1200
    ELSE NULL
END;

#double check
SELECT * FROM pl_data
LIMIT 10;

/* Now to figure out age issues. Birth Year Class is primary in IPF, but there may be null Birth Year Classes where age class or age is filled in.
I will first try to impute missing values into birth year class using age and age class.
For continued null values, one possible solution would be to look up the lifter and infer their age at the time of the meet based
on their current age and the date of the meet recorded. This, however, will be very tedious given how scattered this information is.
Instead, I will keep in the null values for visualization and let Tableau handle nulls, but when I get to modeling, I will drop the nulls
in Python.
*/

SELECT Age, AgeClass, BirthYearClass FROM pl_data
LIMIT 10;
#Learning from the last imputation and how scary it was to deal with WeightClassKg, I'll simply create a whole new column to impute into
ALTER TABLE pl_data
ADD COLUMN BirthClassImputed VARCHAR(50);

#Sex or weight don't matter here, only age, which can be found from age, age class, or birth year class
UPDATE pl_data
SET BirthClassImputed = CASE
	WHEN BirthYearClass = '14-18' THEN '14-18'
    WHEN BirthYearClass = '19-23' THEN '19-23'
    WHEN BirthYearClass = '24-39' THEN '24-39'
    WHEN BirthYearClass = '40-49' THEN '40-49'
    WHEN BirthYearClass = '50-59' THEN '50-59'
    WHEN BirthYearClass = '60-69' THEN '60-69'
    WHEN BirthYearClass = '70-999' THEN '70-999'
    WHEN BirthYearClass = NULL AND (Age >= 14 AND Age < 19) OR (AgeClass = '13-15' OR AgeClass = '16-17') THEN '14-18'
    #note that because age class has an '18-19' range, and the real competition classes are cut off at 18, I won't use that ageclass category
    WHEN BirthYearClass = NULL AND (Age >= 19 AND Age < 24) OR (AgeClass = '20-23') THEN '19-23'
	WHEN BirthYearClass = NULL AND (Age >= 24 AND Age < 40) OR (AgeClass = '24-34' OR AgeClass = '35-39') THEN '24-39'
	WHEN BirthYearClass = NULL AND (Age >= 40 AND Age < 50) OR (AgeClass = '40-44' OR AgeClass = '45-49') THEN '40-49'
    WHEN BirthYearClass = NULL AND (Age >= 50 AND Age < 60) OR (AgeClass = '50-54' OR AgeClass = '55-59') THEN '50-59'
    WHEN BirthYearClass = NULL AND (Age >= 60 AND Age < 70) OR (AgeClass = '60-64' OR AgeClass = '65-69') THEN '60-69'
    WHEN BirthYearClass = NULL AND (Age >= 70 ) OR (AgeClass = '70-74' OR AgeClass = '75-79' OR AgeClass = '80-999') THEN '70-999'
    ELSE NULL
END;
#Running the nulls call again and we see that birthclassimputed has fewer nulls than birthyearclass so the aim of this big case was justified

# Let's go back to check Event Types. I know that full SBD and Bench Only events are most common, so let's see what the
# representation of those values are in this table.
SELECT EventType
, COUNT(*) 
FROM pl_data
GROUP BY EventType;
# As expected, SBD has the highest count with almost 900000. I will separate out a table with only SBD. This should take out most of the
# 4th attempts as well.

DROP TABLE IF EXISTS sbd;
CREATE TABLE sbd AS
SELECT *
FROM pl_data
WHERE EventType = 'SBD';

#I'll also make a Bench only event table for further analysis and comparisons
DROP TABLE IF EXISTS benchonly;
CREATE TABLE benchonly AS
SELECT *
FROM pl_data
WHERE EventType = 'B';

#double check to make sure everything worked
SELECT COUNT(*) FROM sbd
LIMIT 10;

SELECT COUNT(*) FROM benchonly
LIMIT 10;

# Now I need to fill in any best of 3 pulls that might be missing when the actual attempts are present for the SBD table.
# Since I'm not changing of the existing best3 pulls values, I'll impute it right into the existing columns
UPDATE sbd
SET Best3SquatKg = CASE
	WHEN Best3SquatKg IS NOT NULL THEN Best3SquatKg
    ELSE GREATEST(Squat1Kg, Squat2Kg, Squat3Kg)
END;

UPDATE sbd
SET Best3BenchKg = CASE
	WHEN Best3BenchKg IS NOT NULL THEN Best3BenchKg
    ELSE GREATEST(Bench1Kg, Bench2Kg, Bench3Kg)
END;

UPDATE sbd
SET Best3DeadliftKg = CASE
	WHEN Best3DeadliftKg IS NOT NULL THEN Best3DeadliftKg
    ELSE GREATEST(Deadlift1Kg, Deadlift2Kg, Deadlift3Kg)
END;

#Do the same for Bench only but including 4th attempt
UPDATE benchonly
SET Best3BenchKg = CASE
	WHEN Best3BenchKg IS NOT NULL THEN Best3BenchKg
    ELSE GREATEST(Bench1Kg, Bench2Kg, Bench3Kg, Bench4Kg)
END;

#Now, in these tables, I want to drop the pointless columns like 4th lifts in SBD and non-Bench lifts in Bench. I will also drop
#columns that are no longer used like WeightClassKG
ALTER TABLE benchonly
DROP COLUMN EventType
, DROP COLUMN WeightClassKg
, DROP COLUMN Squat1Kg
, DROP COLUMN Squat2Kg
, DROP COLUMN Squat3Kg
, DROP COLUMN Best3SquatKg
, DROP COLUMN Deadlift1Kg
, DROP COLUMN Deadlift2Kg
, DROP COLUMN Deadlift3Kg
, DROP COLUMN Best3DeadliftKg
;

#missed a couple
ALTER TABLE benchonly
DROP COLUMN Squat4Kg
, DROP COLUMN Deadlift4Kg;

#forgot to drop the non imputed birth years
ALTER TABLE benchonly
DROP COLUMN BirthYearClass;

SELECT * FROM benchonly
LIMIT 10;

#now same for SBD\
ALTER TABLE sbd
DROP COLUMN EventType
, DROP COLUMN WeightClassKg
, DROP COLUMN Squat4Kg
, DROP COLUMN Bench4Kg
, DROP COLUMN Deadlift4Kg
, DROP COLUMN BirthYearClass
;

SELECT * FROM sbd
LIMIT 10;