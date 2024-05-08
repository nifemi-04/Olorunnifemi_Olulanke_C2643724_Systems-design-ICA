-- Teesside University - SQL Server Submission
-- Author: Nifemi Olulanke
-- date: 2024-05-08

-- Database: Universities.BAK -- University Ranking Data from 2011 to 2016
-- to restore: https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms


USE universties;
GO
ALTER AUTHORIZATION ON DATABASE:: superhero TO sa;


-- Select and execute the following query to retrieve all columns, 
-- all rows from UNIVERSITY_RANKING_YEAR table
SELECT *
FROM university_ranking_year;


-- Simple SELECT query with calculated column 
-- Note the lack of name for the new calculated column.

SELECT university_id, year, num_students, (num_students / student_staff_ratio)
FROM university_year;


-- Step 1: Count with Duplicates
-- Execute the following query to retrieve number of countries
-- universities are located, from UNIVERSITY table

SELECT COUNT(country_id)
FROM university;


-- Step 2: Count without duplicates
-- Execute the following query to retrieve number of DISTINCT countries
-- universities are located, from UNIVERSITY table

SELECT COUNT(DISTINCT country_id) AS number_of_countries
FROM university;


-- Step 1: Rename new column with alias - `number_of_countries`
-- Step 2: Rename new column with alias - `u`
-- Execute the following query to retrieve number of DISTINCT countries
-- universities are located, from UNIVERSITY table

SELECT COUNT(DISTINCT u.country_id) AS number_of_countries
FROM dbo.university AS u;



-- This query assigns letter grades (A-F) to university rankings 
-- based on score in the DBO.UNIVERSITY_RANKING_YEAR table.

SELECT university_id, year, score,
CASE 
    WHEN score >= 70 THEN 'A'
    WHEN score >= 60 THEN 'B'
    WHEN score >= 50 THEN 'C'
    WHEN score >= 45 THEN 'D'
    WHEN score >= 40 THEN 'E'
    ELSE 'F'
    END AS grade
FROM university_ranking_year;


-- This query retrieves university names and corresponding ranking information (if available) 
-- for each university, using a JOIN between 'University' and 'UniversityRankingYear' tables.
SELECT 
  u.university_name AS University,
  ury.year,
  ury.score
FROM university AS u
JOIN university_ranking_year AS ury ON u.university_id = ury.university_id


-- This query retrieves university names and corresponding student data
-- for each year from the 'University' and 'UniversityYear' tables.

SELECT 
  u.university_name AS University,
  uy.year,
  uy.num_students,
  uy.student_staff_ratio,
  uy.pct_international_students,
  uy.pct_female_students
FROM university AS u
INNER JOIN university_year AS uy ON u.university_id = uy.university_id;


-- This query retrieves all universities and their corresponding ranking information (if available) 
-- using a FULL OUTER JOIN between 'University', 'UniversityRankingYear', and 'RankingCriteria' tables.

SELECT 
  u.university_name AS University,
  ury.year,
  rc.criteria_name AS RankingCriteria,
  ury.score
FROM university AS u
FULL OUTER JOIN university_ranking_year AS ury ON u.university_id = ury.university_id
FULL OUTER JOIN ranking_criteria AS rc ON ury.ranking_criteria_id = rc.ranking_criteria_id;


-- This query demonstrates a CROSS JOIN between 'University' and 'RankingCriteria' tables, 
-- returning all possible combinations of universities and ranking criteria.
SELECT 
  u.university_name AS University,
  rc.criteria_name AS RankingCriteria
FROM university AS u
CROSS JOIN dbo.ranking_criteria AS rc;


USE universities;
GO

-- This query retrieves universities sorted by their 'university_name' in ascending order.
SELECT university_name AS University
FROM university
ORDER BY university_name ASC;


USE universities;
GO

-- This query retrieves universities located in 'Canada'.
SELECT university_name AS University, country_name AS country
FROM university AS u
INNER JOIN country AS c ON u.country_id = c.country_id
WHERE c.country_name = 'Canada';


USE universities;
GO

-- This query retrieves the TOP 10 universities with the most number of students in the year 2011.
-- We can use this data to rank universities by student count

SELECT TOP 10 u.university_name AS University, uy.year AS Year, uy.num_students AS Students
FROM university AS u
INNER JOIN university_year AS uy ON u.university_id = uy.university_id
WHERE uy.year = 2011
ORDER BY uy.num_students DESC;


USE universities;
GO

-- Sample 2: With offset
-- This query retrieves universities starting from the 6th position (offset 5) and fetches 3 universities, using LIMIT (might not be supported by all SQL Server versions).
SELECT university_name AS University, university_id
FROM university
ORDER BY university_name ASC
OFFSET 5 ROWS FETCH NEXT 3 ROWS ONLY;


USE universities;
GO
-- This query retrieves universities with potentially missing data (NULL values) 
-- in 'pct_female_students' column.
SELECT university_name AS University, year, pct_female_students
FROM university AS u
JOIN university_year AS uy
ON u.university_id = uy.university_id
WHERE pct_female_students IS NULL;


USE universities;
GO
-- Create new table "StudentDemographics"
CREATE TABLE StudentDemographics (
  student_id INT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  date_of_birth DATE,
  gpa DECIMAL(3, 2)
);

-- Insert into created table "StudentDemographics"
INSERT INTO StudentDemographics (student_id, first_name, last_name, date_of_birth, gpa)
VALUES (1, 'Alice', 'Smith', '1998-01-01', 3.85),
       (2, 'Bob', 'Johnson', '2000-12-31', 3.50),
       (3, 'Charlie', 'Brown', '1999-05-15', 3.20);

-- This query retrieves average GPA of students.
SELECT AVG(gpa) AS AverageGPA
FROM StudentDemographics;


USE universities;
GO

-- Retrieve universities with names starting with 'H' (case-insensitive) and their lengths.
SELECT university_name AS University, LEN(university_name) AS NameLength
FROM dbo.university
WHERE UPPER(university_name) LIKE 'H%';


USE universities;
GO
-- Retrieve universities with the highest rank in the year 2011

SELECT u.university_name AS University, uy.year AS RankingYear, uy.score AS RankingScore
FROM university AS u
INNER JOIN university_ranking_year AS uy ON u.university_id = uy.university_id
WHERE uy.year = 2011
AND uy.score = (SELECT MAX(score) FROM university_ranking_year WHERE year = 2011);


USE universities;
GO

USE universities;
GO

-- Add three United Kingdom universities 
INSERT INTO university (university_id, university_name, country_id)
VALUES (1248, 'University of Manchester', (SELECT country_id FROM country WHERE country_name = 'United Kingdom')),
       (1249, 'University of Leeds', (SELECT country_id FROM country WHERE country_name = 'United Kingdom')),
       (1250, 'University of Derby ', (SELECT country_id FROM country WHERE country_name = 'United Kingdom'));

USE universities;
GO

-- Check for newly created universities
SELECT * FROM university
WHERE country_id = (SELECT country_id FROM country WHERE country_name = 'United Kingdom');

USE universities;
GO

-- Modifying Data
-- Update the name of the university with ID 1248 to 'University of Nigeria, Nsukka'.
UPDATE university
SET university_name = 'University of Manchester, United Kingdom'
WHERE university_id = 1248;

-- Check for updated universities
SELECT * FROM university
WHERE country_id = (SELECT country_id FROM country WHERE country_name = 'United Kingdom');


USE universities;
GO

-- Modifying Data
-- Update the name of the university with ID 1248 to 'University of Nigeria, Nsukka'.
UPDATE university
SET university_name = 'University of Nigeria, Nsukka'
WHERE university_id = 1248;

-- Check for updated universities
SELECT * FROM university
WHERE country_id = (SELECT country_id FROM country WHERE country_name = 'Nigeria');

-- Removing Data
-- Delete the university with ID 1248.
DELETE FROM university
WHERE university_id = 1248;

-- Confirm that the university no longer exists
SELECT * FROM university
WHERE university_id = 1248;


USE universities;
GO

-- Create a new table to store research areas with auto-generated IDs.
CREATE TABLE ResearchAreas (
  id INT PRIMARY KEY IDENTITY(1,1),
  area_name VARCHAR(255) NOT NULL UNIQUE
);

-- Insert some sample research areas.
INSERT INTO ResearchAreas (area_name)
VALUES ('Computer Science'),
       ('Engineering'),
       ('Social Sciences'),
       ('Life Sciences');

SELECT * FROM ResearchAreas;


USE universities;
GO

-- Calculate the average student-staff ratio across all universities.
SELECT AVG(student_staff_ratio) AS AvgStudentStaffRatio
FROM university_year;


USE universities;
GO

-- This query retrieves the top 5 universities along with their corresponding year
-- and the student-to-staff ratio as a decimal value.
SELECT TOP 5 u.university_name AS University, uy.year AS Year,
uy.student_staff_ratio AS StudentStaffRatioDecimal
FROM university_year AS uy
INNER JOIN university AS u ON uy.university_id = u.university_id;

-- This query retrieves the top 5 universities along with their corresponding year
-- and the student-to-staff ratio converted to an integer using the CONVERT function.

SELECT TOP 5 u.university_name AS University, uy.year AS Year,
       CONVERT(INT, uy.student_staff_ratio) AS StudentStaffRatioInt
FROM university_year AS uy
INNER JOIN university AS u ON uy.university_id = u.university_id;


USE universities;
GO
-- This query retrieves the universities suffering from overpopulation and are most in need of staff each year.

SELECT u.university_name AS University, uy.year AS Year, uy.num_students AS Students, uy.student_staff_ratio AS StaffRatio,
FLOOR(uy.num_students/uy.student_staff_ratio) AS staff
FROM university_year AS uy
INNER JOIN university AS u ON uy.university_id = u.university_id
WHERE uy.num_students > )
  SELECT AVG(num_students) FROM university_year
) 
  AND uy.student_staff_ratio <)
  SELECT AVG(student_staff_ratio) FROM university_year
)
ORDER BY StaffRatio DESC


USE universities;
GO

-- Select universities with missing 'num_students' field
SELECT u.university_name AS University, 
		uy.num_students AS TotalStudents
FROM university AS u
LEFT JOIN university_year AS uy ON uy.university_id = u.university_id
WHERE uy.num_students IS NULL
;

-- Replace null fields with 0 using COALESCE function
SELECT u.university_name AS University, 
       COALESCE(uy.num_students, 0) AS TotalStudents
FROM university AS u
LEFT JOIN university_year AS uy ON uy.university_id = u.university_id
WHERE uy.num_students IS NULL
;
