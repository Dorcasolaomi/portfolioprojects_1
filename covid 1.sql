select*
from [Portfolio Project]..['covid death]
where location is not null
order by 3,4

--select*
--from [Portfolio Project]..['covid vaccination]
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..['covid death]
order by 1,2


 --Looking at total_cases vs total_deaths
 --shows likelihood if you contact covid in your country
  
select location, date, total_cases, total_deaths
from [Portfolio Project]..['covid death]
where location like '%Nigeria%'
order by 1,2

--Looking at total_cases vs population
--shows what percentage of population got covid

select location, date, total_cases, population
from [Portfolio Project]..['covid death]
where location like '%Nigeria%'
order by 1,2

--looking at country with highest infection rate compared to population

select location, date, total_cases, total_deaths
from [Portfolio Project]..['covid death]
where location like '%Nigeria%'
order by 1,2

--showing countries with highest death count per population 

select location, MAX(cast(total_deaths as int)) as Totaldeathcount
from [Portfolio Project]..['covid death]
where continent is not null
group by location
order by Totaldeathcount desc



 --LET'S BREAK THINGS DOWN DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from [Portfolio Project]..['covid death]
where continent is not null
group by continent
order by Totaldeathcount desc

--showing continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from [Portfolio Project]..['covid death]
where continent is not null
group by continent
order by Totaldeathcount desc

--global numbers

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths 
from [Portfolio Project]..['covid death]
--where location like '%nigeria%' 
where continent is not null
--group by date
order by 1,2

--looking at total population vs total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccination
from [Portfolio Project]..['covid death] dea
join [Portfolio Project]..['covid vaccination] vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


 --	USE CTE

 with PopvsVac (continent,location, date, population, new_vaccination, rollingpeoplevaccinated) as
 (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid death] dea
join [Portfolio Project]..['covid vaccination] vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac


 --TEMP TABLE

 DROP table if exists #percentagepeoplevaccinated
 CREATE TABLE #percentagepeoplevaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )

 insert into #percentagepeoplevaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid death] dea
join [Portfolio Project]..['covid vaccination] vac
    on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3
select *, (rollingpeoplevaccinated/population)*100
from  #percentagepeoplevaccinated


--Creating view to store data for later visualizations

create view percentagepeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['covid death] dea
join [Portfolio Project]..['covid vaccination] vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select*
from percentagepeoplevaccinated
