/* Covid 19 Data Exploration, focusing on Covid Deaths and Covid Vacciantion data

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent is not null
ORDER BY 3,4

SELECT*
FROM [PortfolioProject].dbo.CovidVaccinations$
ORDER BY 3,4

-- Select Data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS [Death Percentage]
FROM [PortfolioProject].dbo.CovidDeaths$
WHERE location like 'Lithuania' AND continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population is infected with Covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS [Percentage Population Infected]
FROM [PortfolioProject].dbo.CovidDeaths$
-- ORDER BY [Percentage Population Infected] DESC
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS [Highest Infection Count], MAX((total_cases/population))*100 AS [Percent Population Infected]
FROM [PortfolioProject].dbo.CovidDeaths$
GROUP BY location, population
ORDER BY [Percent Population Infected] DESC 

-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS [Total Death Count]
FROM [PortfolioProject].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY [Total Death Count] DESC

-- Break things down by Continent

-- Showing Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS [Total Death Count]
FROM [PortfolioProject].dbo.CovidDeaths$
WHERE continent is not null 
GROUP BY continent
ORDER BY [Total Death Count] DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) *100 AS [Death Percentage]
FROM [PortfolioProject].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Total Population vs Vaccinations 

-- Shows Perentage of Population that has recieved at least one Covid-19 Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS [Rolling People Vaccinated]
FROM [PortfolioProject].dbo.CovidDeaths$ dea
Join [PortfolioProject].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, [Rolling People Vaccinated])
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS [Rolling People Vaccinated]
FROM [PortfolioProject].dbo.CovidDeaths$ dea
Join [PortfolioProject].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, ([Rolling People Vaccinated]/Population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProject].dbo.CovidDeaths$ dea
Join [PortfolioProject].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date


SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [PortfolioProject].dbo.CovidDeaths$ dea
Join [PortfolioProject].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
