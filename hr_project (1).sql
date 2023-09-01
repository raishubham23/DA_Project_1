USE hr_proj_sample;

SELECT * FROM hr_proj_sample.hr1;

SELECT * FROM hr_proj_sample.hr2;

/*Q1. Average Attrition rate for all Departments*/

SELECT 
  Department, 
  COUNT(CASE WHEN Attrition_Count = 1 THEN 1 END) / COUNT(EmployeeNumber) * 100 AS Attrition_Rate
  FROM hr1
  GROUP BY Department;
  
/*Q2. 2.Average Hourly Rate Of Male Research Scientist*/

SELECT 
  AVG(HourlyRate) AS Average_Hourly_Rate
  FROM hr1
  WHERE JobRole = 'Research Scientist' AND Gender = 'Male'; 
  
/*Q3. Attrition Rate Vs Monthly Income*/
  
SELECT
	h2.Income_Bracket,
    COUNT(CASE WHEN h1.Attrition_Count = 1 THEN 1 END) / COUNT(h1.EmployeeNumber) * 100 AS Attrition_Rate
    FROM hr2 as h2
    JOIN hr1 as h1 on h2.EmployeeID=h1.EmployeeNumber
    GROUP BY Income_Bracket;
    
/*Q4. Average working years for each Department*/

SELECT 
	h1.Department,
    AVG(h2.TotalWorkingYears) AS Average_Working_Years
    FROM hr1 as h1
    JOIN hr2 as h2 on h1.EmployeeNumber=h2.EmployeeID
    GROUP BY Department;
    
/*Q5. Job Role Vs Work Life Balance*/
   
CREATE Temporary TABLE TempTable1
  (
  JobRole VARCHAR(50),
  WLB VARCHAR(50),
  Work_Life_Balance INT
  );
  
CREATE Temporary TABLE TempTable2
  (
  JobRole VARCHAR(50),
  WLB VARCHAR(50),
  Work_Life_Balance INT
  );
  
INSERT INTO TempTable1
  SELECT 
	h1.JobRole AS JobRole,
	WLB as WLB,
	COUNT(WLB) as Work_Life_Balance
	FROM hr2 AS h2
	JOIN hr1 as h1 on h1.EmployeeNumber=h2.EmployeeID 
	GROUP BY WLB,JobRole
    ORDER BY JobRole ASC,Work_Life_Balance DESC;
  
INSERT INTO TempTable2
  SELECT 
	h1.JobRole AS JobRole,
	WLB as WLB,
	COUNT(WLB) as Work_Life_Balance
	FROM hr2 AS h2
	JOIN hr1 as h1 on h1.EmployeeNumber=h2.EmployeeID 
	GROUP BY WLB,JobRole
    ORDER BY JobRole ASC,Work_Life_Balance DESC;
  
SELECT t1.JobRole, t1.WLB, t1.Work_Life_Balance as Count_Of_Employees
	FROM TempTable1 t1
	JOIN (
    SELECT JobRole, MAX(Work_Life_Balance) AS max_work_life_balance 
    FROM TempTable2
    GROUP BY JobRole
	) t2 ON t1.JobRole = t2.JobRole AND t1.Work_Life_Balance = t2.max_work_life_balance;

 DROP TEMPORARY TABLE TempTable1;
 DROP TEMPORARY TABLE TempTable2;
 
/*Q6. Attrition Rate Vs Year Since Last Promotion*/

ALTER TABLE hr2
	ADD COLUMN Years_Since_Last_Promotion_Bracket VARCHAR(10);
    
UPDATE hr2
	SET Years_Since_Last_Promotion_Bracket=
    CASE 
    WHEN YearsSinceLastPromotion BETWEEN 0 AND 8 THEN '0-8'
    WHEN YearsSinceLastPromotion BETWEEN 9 AND 16 THEN '9-16'
    WHEN YearsSinceLastPromotion BETWEEN 17 AND 24 THEN '17-24'
    WHEN YearsSinceLastPromotion BETWEEN 25 AND 32 THEN '25-32'
    ELSE '33-40'
  END;
  
  SELECT
	h2.Years_Since_Last_Promotion_Bracket,
    COUNT(CASE WHEN h1.Attrition_Count = 1 THEN 1 END) / COUNT(h1.EmployeeNumber) * 100 AS Attrition_Rate
    FROM hr2 as h2
    JOIN hr1 as h1 on h2.EmployeeID=h1.EmployeeNumber
    GROUP BY Years_Since_Last_Promotion_Bracket
    ORDER BY CAST( SUBSTRING_INDEX(Years_Since_Last_Promotion_Bracket, '-', 1) AS UNSIGNED);
    

