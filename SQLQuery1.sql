
--Overview
SELECT *
FROM portfolio_project..Sheet
ORDER by location, date

--Total deaths per country with mmost death first
SELECT location, SUM(cast(new_deaths as int )) as deaths
FROM portfolio_project..Sheet 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY deaths DESC


--Mortality rate in each country in each day
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as mortality_rate
FROM portfolio_project..Sheet 
WHERE continent IS NOT NULL
ORDER BY location, date


--Countries as per Low(<1%), Medium(>1% and <2%) and High(>2%) mortality rate of last recorded day
SELECT location, (total_deaths/total_cases)*100 as mortality_rate,
CASE
	WHEN (total_deaths/total_cases)*100 < 1 THEN 'Low'
	WHEN (total_deaths/total_cases)*100 > 1 AND (total_deaths/total_cases)*100 < 2 THEN 'Medium'
	ELSE 'High'
END AS Country_index
FROM portfolio_project..Sheet 
WHERE continent IS NOT NULL
AND date = '2021-08-04'
ORDER BY location


--Total tests in each country with most tests first
SELECT location, population, SUM(CAST(new_tests as float)) as tests 
FROM portfolio_project..Sheet WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY tests DESC


--Total tests rate of each country
SELECT location, date, population, total_tests, (total_tests /population)*100 as test_rate
FROM portfolio_project..Sheet WHERE continent IS NOT NULL
ORDER BY 1,2


--Vaccination status of each country
SELECT location, date, population, people_vaccinated, total_vaccinations, new_vaccinations, people_fully_vaccinated
FROM portfolio_project..Sheet  
WHERE continent IS NOT NULL
ORDER BY 1,2

--How rate of vaccination changed in countries
SELECT location, date, population, new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY location ORDER BY  date) as total_new_vaccinations
FROM portfolio_project..Sheet  
WHERE continent IS NOT NULL
ORDER BY 1,2


--Percentage of people Single and Double dosed
SELECT location, date, population, people_vaccinated, people_fully_vaccinated, 
(people_vaccinated/population)*100 as people_SingleDosed, (people_fully_vaccinated/population)*100 as people_DoubleDosed
FROM portfolio_project..Sheet  
WHERE continent IS NOT NULL
ORDER BY 1,2


--How mortality rate is related to smokers in that country
SELECT location, date, (total_deaths/total_cases)*100 as death_rate, (CAST(male_smokers as FLOAT) + CAST(female_smokers as FLOAT)) as total_smokers
FROM portfolio_project..Sheet  
WHERE continent IS NOT NULL
AND date = '2021-08-04'
ORDER BY 1,2


--How mortality rate is related to old people in that country
SELECT location, date, (total_deaths/total_cases)*100 as death_rate, aged_65_older, aged_70_older
FROM portfolio_project..Sheet  
WHERE continent IS NOT NULL
AND date = '2021-08-04'
ORDER BY 1,2


--Latest possitivity and mortality rate of each country
--CTE
WITH temp(location, date, population, new_tests, new_deaths, new_cases, c1, c2, c3)
as
(SELECT location, date, population, new_tests, new_deaths, new_cases,
SUM(CONVERT(float,new_tests)) OVER (PARTITION BY location ORDER BY location) AS c1,
SUM(CONVERT(float,new_cases)) OVER (PARTITION BY location ORDER BY location) AS c2,
SUM(CONVERT(float,new_deaths)) OVER (PARTITION BY location ORDER BY location) AS c3
FROM portfolio_project..Sheet  
WHERE continent IS NOT NULL
)
SELECT location, date, 
(c2/c1)*100 AS LastRecorded_positivity_rate,
(c3/c2)*100 as LastRecorded_mortality_rate 
FROM temp t
WHERE date='2021-08-04'
ORDER BY location,date

