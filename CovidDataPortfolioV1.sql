--SELECT *
--From PortfolioProject..CovidDeaths$
--order by 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at the total cases versus total deaths
-- Shoes likelyhood of death if you contract Covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Total Cases Vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2


-- Countries with Highest Infection rate compared to population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as MaxInfectionPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, population
order by MaxInfectionPercentage desc

-- Countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location, population
order by HighestDeathCount desc

-- Countries with the highest death count per population percentage
Select Location, MAX(cast(total_deaths as int)/population)*100 as DeathPerPopulation
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location, population 
order by DeathPerPopulation desc

--Breakdown by Continent
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by HighestDeathCount desc

--GLOBAL NUMBERS 
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--------------
--VACCINATIONS
--------------

--Join 

Select dea.continent, dea.date, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-------------
---USE CTE---
-------------

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated / Population)*100
From PopVsVac

-----------------
--- TEMP Table---
-----------------

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric

)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated / Population)*100
From #PercentPopulationVaccinated

-----------------------------------------------------------
---Creating View to store data fore later visualizations---
-----------------------------------------------------------

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated / Population)*100
From PercentPopulationVaccinated