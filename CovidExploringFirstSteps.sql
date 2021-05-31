select *
from ProjectPORTFOLIO..COVIDDEATHS
order by 3,4

-- select *
--from ProjectPORTFOLIO..COVIDVACCINES
--order by 3,4 
--Select Data we are working with

Select location, date, total_cases, new_cases, population
from ProjectPORTFOLIO..COVIDDEATHS
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
from ProjectPORTFOLIO..COVIDDEATHS
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population,  MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from ProjectPORTFOLIO..COVIDDEATHS
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
Select continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
from ProjectPORTFOLIO..COVIDDEATHS
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Breaking things by CONTINENT 
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPORTFOLIO..COVIDDEATHS
Where continent is null
Group by location
order by TotalDeathCount desc

-- showing continents with the highest death count per population
Select SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from ProjectPORTFOLIO..COVIDDEATHS
where continent is not null
order by 1,2

--- showing vaccines table

select *
from ProjectPORTFOLIO..COVIDVACCINES

-- Looking at Total Population vs Vaccinations

-- USE CTE


;WITH PopvsVac (continent, location, date, population, new_Vaccinations, all_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS all_vaccinations
From ProjectPORTFOLIO..COVIDDEATHS dea
join ProjectPORTFOLIO..COVIDVACCINES vac
	On dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3
)
select *,
(all_vaccinations/population)*100 AS PercentageVaccinations
from PopvsVac;


-- TEMPORARY TABLE CREATION

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPORTFOLIO..COVIDDEATHS dea
Join ProjectPORTFOLIO..COVIDVACCINES vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent IS NOT NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Checking the table
select *
from #PercentPopulationVaccinated
GO
Create View PercentPopulationVaccinated
AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPORTFOLIO..COVIDDEATHS dea
Join ProjectPORTFOLIO..COVIDVACCINES vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
