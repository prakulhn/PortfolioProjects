SELECT * FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM PortfolioProject..covid_vaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT location, date, total_cases, total_deaths,
CASE
  WHEN total_cases=0 THEN NULL
  ELSE (total_deaths/total_cases)*100 
END AS deathPercentage
FROM PortfolioProject..covid_deaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2


SELECT location, date, population, total_cases, (total_cases/population)*100 casesPercentage
FROM PortfolioProject..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT location, population, MAX(total_cases) MaxCases, MAX((total_cases/population))*100 casesPercentage
FROM PortfolioProject..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY casesPercentage DESC


SELECT location, MAX(CAST(total_deaths AS INT)) MaxDeaths
FROM PortfolioProject..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeaths DESC


SELECT continent, MAX(CAST(total_deaths AS INT)) MaxDeaths
FROM PortfolioProject..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MaxDeaths DESC


SELECT continent, population, MAX(total_deaths) MaxDeaths, MAX((total_deaths/population))*100 deathPercentage
FROM PortfolioProject..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY deathPercentage DESC


SELECT date, SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeaths,
CASE
  WHEN SUM(new_cases)=0 THEN NULL
  ELSE (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 
END AS DeathPercentage
FROM PortfolioProject..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeaths,
CASE
  WHEN SUM(new_cases)=0 THEN NULL
  ELSE (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 
END AS DeathPercentage
FROM PortfolioProject..covid_deaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
RollingPeopleVaccinated  --, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


--USING CTE

WITH PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
RollingPeopleVaccinated  
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


--USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
RollingPeopleVaccinated  
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 RollingPeopleVaccinatedPercent
FROM #PercentPopulationVaccinated


--CREATING VIEWS

CREATE VIEW RollingPeopleVaccinatedPercent AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
RollingPeopleVaccinated  
--, (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM RollingPeopleVaccinatedPercent