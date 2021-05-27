--Query to check imported tables
SELECT *
FROM Portfolioproject1..CovidDeaths
WHERE continent IS NOT NULL

SELECT *
FROM Portfolioproject1..Covidvaccinations


-- Selecting data to be used for this project and Ordering By location and Date
SELECT location, date, population, total_cases, new_cases,total_deaths, population
FROM Portfolioproject1..CovidDeaths
ORDER BY location, date

-- Exploring Total Cases vs Total Deaths (Eg.Canada)
-- Shows likelihood of dying if you contract COVID based on location
SELECT location, 
	   date, 
	   total_cases,
	   total_deaths, 
	   (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolioproject1..CovidDeaths
WHERE location LIKE 'Cana%'
ORDER BY 1,2

-- Exploring Total Cases vs Population (Eg.Canada)
-- Shows percentage of population that got infected by COVID
SELECT location, 
	   date, 
	   total_cases, 
	   population,
	   (total_cases/population)*100 AS PercentPopInfected
FROM Portfolioproject1..CovidDeaths
WHERE location LIKE 'Cana%'
ORDER BY 1,2

-- Looking at countries with highest Infection rate compared to Population
SELECT location,
	   population,
	   MAX(total_cases) AS HighestInfectionCount, 
	   MAX((total_cases/population))*100 AS PercentPopInfected
FROM Portfolioproject1..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopInfected DESC

-- Finding countries with highest death count per population
SELECT location,
	   MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolioproject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Now breaking it by continent (actual numbers)
SELECT location,
	   MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolioproject1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Following with tutorial
SELECT continent,
	   MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolioproject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT  SUM(new_cases) AS Total_cases,
		SUM(CAST(new_deaths AS INT)) AS Total_deaths,
	   (SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 AS Death_perct_per_day
FROM Portfolioproject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at total population vs vaccination
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS INT)) 
	   OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM Portfolioproject1..CovidDeaths AS dea
JOIN Portfolioproject1..Covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rollingpeoplevaccinated)
AS
(SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS INT)) 
	   OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM Portfolioproject1..CovidDeaths AS dea
JOIN Portfolioproject1..Covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *,
	(Rollingpeoplevaccinated/Population)*100 AS percentagevaccinated
FROM PopvsVac



--USE TEMP TABLE

-- DROP table to be used when altering any internal queries 
DROP TABLE IF exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rollingpeoplevaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS INT)) 
	   OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM Portfolioproject1..CovidDeaths AS dea
JOIN Portfolioproject1..Covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,
	(Rollingpeoplevaccinated/Population)*100 AS percentagevaccinated
FROM #PercentPopulationVaccinated
ORDER BY location

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS INT)) 
	   OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM Portfolioproject1..CovidDeaths AS dea
JOIN Portfolioproject1..Covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


-- Creating view for total death counts per continent
CREATE VIEW Totaldeathcountpercontinent AS
SELECT location,
	   MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolioproject1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC
