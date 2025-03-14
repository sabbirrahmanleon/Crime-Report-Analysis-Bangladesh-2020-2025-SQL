--KPIs


--- Total Cases
SELECT SUM(total_cases) AS total_cases
FROM crime_statistics;


---Total Recovery Cases
SELECT 
    sum(arms_act) + 
    sum(explosive) + 
    sum(narcotics) + 
    sum(smuggling) AS total_recovery_cases
FROM crime_statistics;


-- Avg Cases Per Month
SELECT
    SUM(total_cases) / COUNT(DISTINCT CONCAT(month, ' ', year))
        AS avg_cases_per_month
FROM crime_statistics;


-- Combine These 3
SELECT
    SUM(total_cases) AS total_cases,
    SUM(arms_act) + SUM(explosive) + SUM(narcotics) + SUM(smuggling) AS total_recovery_cases,
    SUM(total_cases) / COUNT(DISTINCT CONCAT(month, ' ', year)) AS avg_cases_per_month
FROM crime_statistics;


----------------------------------------------------------------

--Monthly Trend of Crimes

SELECT
        CONCAT(month, ' ', year) AS month_year,
    SUM(total_cases) AS total_cases_per_month
    FROM crime_statistics
GROUP BY month, year
ORDER BY year, EXTRACT(MONTH FROM TO_DATE(month, 'Month'));


----------------------------------------------------------------

--Total Cases by Crime Type

WITH Total_Cases AS (
    SELECT SUM(dacoity) + SUM(robbery) + SUM(murder) + SUM(speedy_trial) +
           SUM(riot) + SUM(woman_child_repression) + SUM(kidnapping) +
           SUM(police_assault) + SUM(burglary) + SUM(theft) +
           SUM(other_cases) + SUM(arms_act) + SUM(explosive) +
           SUM(narcotics) + SUM(smuggling) AS grand_total
    FROM crime_statistics
)
SELECT 
    'Dacoity' AS crime_type, 
    SUM(dacoity) AS total_cases, 
    (SUM(dacoity) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2) AS percentage
FROM crime_statistics
UNION ALL
SELECT 
    'Robbery', 
    SUM(robbery), 
    (SUM(robbery) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Murder', 
    SUM(murder), 
    (SUM(murder) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Speedy Trial', 
    SUM(speedy_trial), 
    (SUM(speedy_trial) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Riot', 
    SUM(riot), 
    (SUM(riot) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Woman & Child Repression', 
    SUM(woman_child_repression), 
    (SUM(woman_child_repression) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Kidnapping', 
    SUM(kidnapping), 
    (SUM(kidnapping) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Police Assault', 
    SUM(police_assault), 
    (SUM(police_assault) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Burglary', 
    SUM(burglary), 
    (SUM(burglary) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Theft', 
    SUM(theft), 
    (SUM(theft) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Other Cases', 
    SUM(other_cases), 
    (SUM(other_cases) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Arms Act', 
    SUM(arms_act), 
    (SUM(arms_act) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Explosive', 
    SUM(explosive), 
    (SUM(explosive) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Narcotics', 
    SUM(narcotics), 
    (SUM(narcotics) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
UNION ALL
SELECT 
    'Smuggling', 
    SUM(smuggling), 
    (SUM(smuggling) * 100.0 / (SELECT grand_total FROM Total_Cases))::NUMERIC(5,2)
FROM crime_statistics
ORDER BY total_cases DESC;



----------------------------------------------------------------

--Crime Rates by Unit

SELECT 
    Unit_Name, 
    SUM(total_cases) AS total_cases,
    SUM(total_cases) / COUNT(DISTINCT CONCAT(month, ' ', year)) AS cases_per_month
FROM Crime_Statistics
GROUP BY Unit_Name
ORDER BY total_cases DESC


----------------------------------------------------------------

--Yearly Crime Rates and Percentage Change

WITH Yearly_Crime AS (
    SELECT 
        Year,
        SUM(total_cases) AS total_crimes,
        SUM(total_cases) / COUNT(DISTINCT CONCAT(month, ' ', year)) AS crime_rate
    FROM Crime_Statistics
    GROUP BY Year
)
SELECT 
    Year,
    crime_rate,
    LAG(crime_rate) OVER (ORDER BY Year) AS PY_Crime_rate,
    CAST(
        (crime_rate - LAG(crime_rate) OVER (ORDER BY Year)) * 100.0 / 
        NULLIF(LAG(crime_rate) OVER (ORDER BY Year), 0) 
        AS NUMERIC(5,2)
    ) AS Percentage_Change
FROM Yearly_Crime
ORDER BY Year;


----------------------------------------------------------------

--Yearly Rates of the Most Discussed Crimes
SELECT 
    crime_type,
    COALESCE(ROUND(AVG(CASE WHEN year = 2020 THEN total_cases END), 0), 0) AS "2020",
    COALESCE(ROUND(AVG(CASE WHEN year = 2021 THEN total_cases END), 0), 0) AS "2021",
    COALESCE(ROUND(AVG(CASE WHEN year = 2022 THEN total_cases END), 0), 0) AS "2022",
    COALESCE(ROUND(AVG(CASE WHEN year = 2023 THEN total_cases END), 0), 0) AS "2023",
    COALESCE(ROUND(AVG(CASE WHEN year = 2024 THEN total_cases END), 0), 0) AS "2024",
    COALESCE(ROUND(AVG(CASE WHEN year = 2025 THEN total_cases END), 0), 0) AS "2025"
FROM (
    SELECT 
        year, 'Kidnapping' AS crime_type, SUM(kidnapping) / COUNT(DISTINCT month) AS total_cases FROM crime_statistics GROUP BY year
    UNION ALL
    SELECT 
        year, 'Burglary', SUM(burglary) / COUNT(DISTINCT month) FROM crime_statistics GROUP BY year
    UNION ALL
    SELECT 
        year, 'Theft', SUM(theft) / COUNT(DISTINCT month) FROM crime_statistics GROUP BY year
    UNION ALL
    SELECT 
        year, 'Dacoity', SUM(dacoity) / COUNT(DISTINCT month) FROM crime_statistics GROUP BY year
    UNION ALL
    SELECT 
        year, 'Robbery', SUM(robbery) / COUNT(DISTINCT month) FROM crime_statistics GROUP BY year
    UNION ALL
    SELECT 
        year, 'Woman & Child Repression', SUM(woman_child_repression) / COUNT(DISTINCT month) FROM crime_statistics GROUP BY year
) AS CrimeData
GROUP BY crime_type
ORDER BY crime_type;


----------------------------------------------------------------

--Crime Rates of Recovery Cases
WITH Crime_Totals AS (
    SELECT 
        'Arms Act' AS crime_type, SUM(arms_act) AS total_cases FROM crime_statistics
    UNION ALL
    SELECT 
        'Explosive', SUM(explosive) FROM crime_statistics
    UNION ALL
    SELECT 
        'Narcotics', SUM(narcotics) FROM crime_statistics
    UNION ALL
    SELECT 
        'Smuggling', SUM(smuggling) FROM crime_statistics
), 
Total_Crimes AS (
    SELECT SUM(total_cases) AS overall_total FROM Crime_Totals
)
SELECT 
    ct.crime_type,
    ct.total_cases,
    ROUND((ct.total_cases * 100.0) / NULLIF(tc.overall_total, 0), 2) AS crime_percentage
FROM Crime_Totals ct
JOIN Total_Crimes tc ON 1=1
ORDER BY ct.total_cases DESC;
