select * from PortfolioProject..CovidDeaths
order by 3,4

select*from dbo.CovidDeaths
order by 3,4

select * from PortfolioProject..CovidVaccinations
order by 3,4

--select Data to use for the analysis

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Insights on the Total number of cases and Deaths.
--Also the percentage of deaths to total cases.
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--filter to view data for the united states
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where Location = 'United states'
order by 1,2

--filter to view data for Canada
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where Location = 'Canada'
order by 1,2

--comparing total cases to population for the 'United States'
--percentage of population infected with covid
select Location, date,population, total_cases,(total_deaths/population)*100 as Percentage_of_Population_infected
from PortfolioProject..CovidDeaths
where Location = 'United states'
order by 1,2

--comparing total cases to population for the 'Canada'
--percentage of population infected with covid
select Location, date,population, total_cases,(total_deaths*100/population) as Percentage_of_Population_infected
from PortfolioProject..CovidDeaths
--where Location = 'Canada'
order by 1,2

--Query statement to find the country with the highest infection rate compared to the population
select Location,population, MAX(total_cases) as Highest_infection_count, MAX(total_deaths*100/population) as Percentage_of_Population_infected
from PortfolioProject..CovidDeaths
where continent is not null
group by Location, population
order by Percentage_of_Population_infected desc


--filtering by continents
select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject..CovidDeaths
where continent is null
group by continent
order by Total_Death_count desc

select Location, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject..CovidDeaths
where continent is null
group by Location
order by Total_Death_count desc


--Query statement to show countries with the highest Death count per population
select Location, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by Total_Death_count desc

--Query to show the Continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Death_count desc

--Exploring global statistics
select date, SUM(new_cases) as Total_new_cases, SUM(cast(new_deaths as int)) as new_total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Aggregates
select SUM(new_cases) as Total_new_cases, SUM(cast(new_deaths as int)) as new_total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2



--Join the covid Deaths and vaccination tables together.
select*
from PortfolioProject..CovidDeaths dea

join PortfolioProject..CovidVaccinations vax

on dea.location = vax.location
and dea.date = vax.date

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
from PortfolioProject..CovidDeaths dea

join PortfolioProject..CovidVaccinations vax

on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null

order by 2,3

-------------------------------------------
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
 SUM(cast(vax.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
 as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (continent, Location, Date, population, New_vaccinations, RollingpeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
 SUM(cast(vax.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
 as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
 from PopvsVac


--TEMP TABLE

DROP Table if exists #percentPopulationVaccinated
Create Table  #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
 SUM(cast(vax.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
 as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
 from #percentPopulationVaccinated

