CREATE schema ipf;
USE ipf;

DROP TABLE if exists pl_data;
CREATE TABLE pl_data (
    LifterName VARCHAR(255),
    Sex CHAR(2),
    EventType VARCHAR(255),
    Equipment VARCHAR(255),
    Age FLOAT,
    AgeClass VARCHAR(255),
    BirthYearClass VARCHAR(255),
    BodyweightKg FLOAT,
    WeightClassKg VARCHAR(255),
    Squat1Kg FLOAT,
    Squat2Kg FLOAT,
    Squat3Kg FLOAT,
    Squat4Kg FLOAT,
    Best3SquatKg FLOAT,
    Bench1Kg FLOAT,
    Bench2Kg FLOAT,
    Bench3Kg FLOAT,
    Bench4Kg FLOAT,
    Best3BenchKg FLOAT,
    Deadlift1Kg FLOAT,
    Deadlift2Kg FLOAT,
    Deadlift3Kg FLOAT,
    Deadlift4Kg FLOAT,
    Best3DeadliftKg FLOAT,
    TotalKg FLOAT,
    Place VARCHAR(255),
    Dots FLOAT,
    Wilks FLOAT,
    Glossbrenner FLOAT,
    Goodlift FLOAT,
    Tested VARCHAR(3),
    Country VARCHAR(255),
    State VARCHAR(255),
    Federation VARCHAR(255),
    Date_ DATE,
    MeetCountry VARCHAR(255),
    MeetState VARCHAR(255),
    MeetTown VARCHAR(255),
    MeetName VARCHAR(255)
);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ipfdropped.csv'
INTO TABLE pl_data
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select * from pl_data
limit 10;