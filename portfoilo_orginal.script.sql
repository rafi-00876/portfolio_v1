select location, date, total_cases,new_cases,total_deaths,population
from coviddeaths
order by 1,2;


-- looking at total cases vs total deaths
-- shows liklihood of dying if you contact covid in your country your counntry

SELECT location, date, total_cases, total_deaths, population, (total_deaths / total_cases) * 100 AS death_percentage
FROM coviddeaths
WHERE location LIKE '%bangladesh%'
ORDER BY location, date  ;



-- looking at total cases vs population 
-- shows what percentage of  population  got covid 
SELECT location, date, population,total_cases, (total_cases /population ) * 100 AS infection_percentage 
FROM coviddeaths
WHERE location LIKE '%bangladesh%'
ORDER BY location, date  ;


-- looking at countries with highest infection rate 
SELECT location, date, population,max(total_cases), max((total_cases /population )) * 100 AS infection_percentage 
FROM coviddeaths
group by location,population
ORDER BY infection_percentage desc

 ;



SELECT location, MAX(total_cases) as Highest_Infection_Count , (MAX(total_cases) / population) * 100 AS infection_percentage
FROM coviddeaths
GROUP BY location, population
ORDER BY infection_percentage DESC;


-- showing countries with highest deathrate


SELECT location, MAX(CAST(total_deaths AS SIGNED INTEGER))
FROM coviddeaths
where continent is not null
GROUP BY location
ORDER BY MAX(total_deaths) DESC;


--




-- lets go break down continennt



SELECT continent, MAX(CAST(total_deaths AS SIGNED INTEGER)) AS TotalDeathCount
FROM coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- showing the continent with highest deathcount per population

SELECT continent, MAX(CAST(total_deaths AS SIGNED INTEGER)) AS TotalDeathCount
FROM coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS 

SELECT  date, sum(new_cases), sum(new_deaths)  -- , (total_deaths / total_cases) * 100 AS death_percentage
FROM coviddeaths
-- WHERE location LIKE '%bangladesh%'
where continent is not null 

group by date
ORDER BY location, date  ;





SELECT 
       sum(new_cases) AS total_cases,
       sum(new_deaths) AS total_deaths,
       (sum(new_deaths) / sum(new_cases)) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
-- GROUP BY date, location
ORDER BY location, date;



-- TOTAL POPULATION VS TOTAL VACCINATION
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       sum( vac.new_vaccinations) as totalvaccination over (partion by dea.location)
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3;



SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location) AS totalvaccination
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3;








 


  -- USING CTE
  WITH popvsvacc AS (
    SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location) AS Rolling_People_Vaccinated
    FROM portfolioproject.coviddeaths dea
    JOIN portfolioproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 1, 2, 3
)
SELECT *,
       (Rolling_People_Vaccinated / population) * 100 AS percentage_vaccinated
FROM popvsvacc;






--    CTE         WITH SERIAL NO  

WITH popvsvacc AS (
    SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location) AS Rolling_People_Vaccinated,
           ROW_NUMBER() OVER () AS serial_no
    FROM portfolioproject.coviddeaths dea
    JOIN portfolioproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 1, 2, 3
)
SELECT *,
       (Rolling_People_Vaccinated / population) * 100 AS percentage_vaccinated
FROM popvsvacc;

-- TEMP TABLE

CREATE TEMPORARY TABLE PercentPopulationVaccinated AS
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location) AS Rolling_People_Vaccinated,
       ROW_NUMBER() OVER () AS serial_no
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3;

select * from PercentPopulationVaccinated



-- CREATING VIEW TO SORE DATA FOR LATER VISUALIAZTION

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rolling_People_Vaccinated,
    ROW_NUMBER() OVER () AS serial_no
FROM
    portfolioproject.coviddeaths dea
JOIN
    portfolioproject.covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.continent, dea.location, dea.date;
