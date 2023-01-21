

SELECT *
FROM PORTFOLIOPROJECT..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PORTFOLIOPROJECT..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you can contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PORTFOLIOPROJECT..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPoulationInfected
FROM PORTFOLIOPROJECT..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compares to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPoulationInfected
FROM PORTFOLIOPROJECT..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPoulationInfected desc

--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's Break Things Down by Continent (USE THIS SCRIPT-CORRECT)
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--Changing the previous query (location vs continent)
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PORTFOLIOPROJECT..CovidDeaths
--Where location like '%states%'
where continent is not null
Group By date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PORTFOLIOPROJECT..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--Temp Table

DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentpopulationVaccinated




--Creating View to store data for later visualizations




Create View PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
--	, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



