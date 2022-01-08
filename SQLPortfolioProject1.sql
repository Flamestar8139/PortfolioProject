select*
from [Portflio project]..coviddeaths$
where continent is not null
order by 3,4

--Select data that we are going to be using


select location, date, total_cases, new_cases, total_deaths, population
from [Portflio project]..coviddeaths$
order by 1,2


--Looking at total cases vs total deaths( Shows likelihood of dying in each country )

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portflio project]..coviddeaths$
where continent is not null
where location like '%india%'
order by 1,2


--Looking at the total cases vs population (Shows what amount of the population got covid)

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from [Portflio project]..coviddeaths$
where continent is not null
where location like '%india%'
order by 1,2


-- Looking at which country has highest infection rate vs population

select location, max(total_cases) as HishestinfectionCount, population, max((total_cases/population))*100 as PercentPopulationInfected
from [Portflio project]..coviddeaths$
--where location like '%india%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries With Highest death count per popuation

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portflio project]..coviddeaths$
where continent is not null
--where location like '%india%'
group by location
order by TotalDeathCount desc


--Showing continents with highest death counts 

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portflio project]..coviddeaths$
where continent is null
--where location like '%india%'
group by location
order by TotalDeathCount desc
 -- bottom code is not accurate cause it neglects few countries which should be grouped into north america and south america asia 
 -- and the other continets

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portflio project]..coviddeaths$
where continent is not null
--where location like '%india%'
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

--This gives the overall total but if  you add date in the select and use the group by function we can get the new cases on each specific date
select  sum(new_cases)as Total_Cases,sum(cast(new_deaths as int))as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [Portflio project]..coviddeaths$
where continent is not null
--where location like '%india%'
--group by date
order by 1,2



--Looking at Total population vs vaccinations

WITH PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from [Portflio project]..coviddeaths$ dea
join [Portflio project]..covidvacinations$ vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--and dea.location like '%india%'
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP Table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime, 
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
insert into #PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from [Portflio project]..coviddeaths$ dea
join [Portflio project]..covidvacinations$ vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--and dea.location like '%india%'
order by 2,3
select*,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated


--Creating View To store data for later visulizations


create view PercentPopulationVaccinated1 as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from [Portflio project]..coviddeaths$ dea
join [Portflio project]..covidvacinations$ vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--and dea.location like '%india%'
--order by 2,3

select *
from PercentPopulationVaccinated