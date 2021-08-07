
select*
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at total cases vs total deaths 
--shows the likelihood of dying if you get covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%finland%'
order by 1,2


--looking at total cases vs population
--shows what percentage of population have had covid

select location, date, population, total_cases, (total_cases/population)*100 as HadCovidPercentage
from PortfolioProject..CovidDeaths
where location like '%finland%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%finland%'
group by location, population
order by PercentPopulationInfected desc 

--showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%finland%'
where continent is not null 
group by location
order by TotalDeathCount desc 

---By contintent


--- Showíng continents with the highest death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%finland%'
where continent is not null 
group by continent 
order by TotalDeathCount desc 


--Global numbers 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%finland%'
where continent is not null 
--group by date
order by 1,2


--looking at totalt population vs vaccinations

select dea.continent, dea.location, dea.date, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as RollingPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as RollingPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as RollingPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualisation

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as RollingPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from PercentPopulationVaccinated