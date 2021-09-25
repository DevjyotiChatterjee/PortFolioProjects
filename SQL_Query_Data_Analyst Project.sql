-- SELECTING TOP FROM DEATHS TABLE
SELECT TOP(5) * 
FROM PortfolioProject.dbo.CovidDeaths

-- SELECTING ALL FROM COVID VACCINATIONS TABLE
SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations

-- GET DATA	
SELECT location, date , total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Get Data for Total Deaths vs Total Cases (Filtered on Country 'India') 
SELECT location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage  
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

-- Get Data for Total Deaths vs Total Population (Filtered on Country 'India') 
SELECT location, date , total_cases, total_deaths, (total_deaths/population)*100 AS 'Covid Contraction % '  
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

--Countries with Highest Infection Rate 
SELECT location, MAX(total_cases), population , MAX((total_cases/population))*100 AS InfectionRate 
from PortfolioProject.DBO.CovidDeaths
GROUP BY Location, population
HAVING population > 20000000
ORDER BY InfectionRate DESC 

--Countries with Highest Death Count per Population Rate / Filtered on Continent  
SELECT location, MAX(CAST( Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL AND location = 'ASIA'
GROUP BY location
ORDER BY TotalDeathCount DESC
GO

--GLOBAL NUMBERS -- DEATH PERCENTAGE 	
SELECT SUM(new_cases) AS TotalCases, SUM(TRy_CAST(new_deaths AS INT)) AS Total_Death,
(SUM(TRy_CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths
WHERE new_cases>0 AND new_deaths>0
--GROUP BY Date
ORDER BY DeathPercentage DESC
GO

--LOOKING AT TOTAL POPULATION vs VACCINATION FILTERED ON INDIA
SELECT dea.continent , dea.location , dea.date, 
SUM(CAST(vac.new_vaccinations AS int)) 
	OVER(PARTITION BY dea.Location 
		 ORDER BY dea.location, dea.date) AS RollingVaccineCount

FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
		AND dea.location LIKE 'India'
ORDER BY 2,3

-- USING CTE for ABOVE to GET PERCENTAGE AND USE ALIAS COLUMN FOR COMPUTATION 
WITH PopVac(Continent, Location, Population, Date, RollingVaccineCount)
AS
(
SELECT dea.continent , dea.location ,dea.population, dea.date, 
SUM(CAST(vac.new_vaccinations AS int)) 
	OVER(PARTITION BY dea.Location 
		 ORDER BY dea.location, dea.date) AS RollingVaccineCount
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
		AND dea.location LIKE 'India'
--ORDER BY 2,3
)
SELECT * , (RollingVaccineCount/CAST(Population AS decimal))*100.00 FROM PopVac
GO

-- Creating view to store data later
DROP VIEW IF EXISTS PercentPopulationVaccinated
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent , dea.location ,dea.population, dea.date, 
SUM(CAST(vac.new_vaccinations AS int)) 
	OVER(PARTITION BY dea.Location 
		 ORDER BY dea.location, dea.date) AS RollingVaccineCount
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
		AND dea.location LIKE 'India'
--ORDER BY 2,3
GO

SELECT * FROM PercentPopulationVaccinated

