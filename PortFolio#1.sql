
Select *
From PortFolioProject..CovidDeaths
WHERE location = 'United States'
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data

Select location, date, total_cases, new_cases, total_deaths, population
From PortFolioProject..CovidDeaths
order by 1,2


-- total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
From PortFolioProject..CovidDeaths
Where location like '%states%' AND continent is not null

order by 1,2

-- total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 as caseByPopulation
From PortFolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with highest infection rate per population
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)*100) as PercentPopulationInfected
From PortFolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY location, population
order by 4 DESC

--Break down by continent


-- countries with highest death count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortFolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY location
order by TotalDeathCount DESC


--Break down by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortFolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
GROUP BY location
order by TotalDeathCount DESC

--the right one
Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortFolioProject..CovidDeaths
GROUP BY continent
order by TotalDeathCount DESC

--the wrong one
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortFolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--GROUP BY date
order by 1,2

-- looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int) ) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int) ) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population*100)
From PopvsVac
order by 2,3


-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccnated
CREATE Table #PercentPopulationVaccnated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccnated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int) ) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccnated



-- Creating view to store data for later

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int) ) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *, (RollingPeopleVaccinated/population)*100 as test
from PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated2 as
select *, (RollingPeopleVaccinated/population)*100 as test
from PercentPopulationVaccinated

select *
from PercentPopulationVaccinated2
