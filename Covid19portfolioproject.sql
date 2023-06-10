/*
COVID 19 Data exploration
Skills used: Joins,temp tables,creating views,aggregrate functions,converting data types,CTE's,windows functions

*/

select * from CovidDeaths
where continent is not null
order by 3,4;

--select data to work with

select location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths
where continent is not null
order by 1,2

--total cases vs total deaths
-- shows likelihood of dying if contacted 

select location, date, total_cases, total_deaths, ( total_deaths/ total_cases)*100 as deathpercentage
from CovidDeaths
where location like 'nigeria' 
order by 1,2

--total_cases vs population
--shows percentage of population with covid

select location, date, total_cases, population, ( total_cases/ population)*100 as percentofinfectedpopulation
from CovidDeaths
where location like 'nigeria'
order by 1,2

--countries with highest infection rate compared to population

 select location,population,max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as percentpopulationinfected
 from CovidDeaths 
 group by location, population
 order by percentpopulationinfected desc

 --showing countries with highest death count per population
 -- breaking things up using continent

 select location,max(cast(total_deaths as int))as totaldeathcount
from CovidDeaths
where continent is null
group by location
order by totaldeathcount desc

--global numbers for total case,total deaths, and death percentage

select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, (sum(cast (new_deaths as int))/ sum(new_cases) )*100
as deathpercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

--working with the vaccination table

 select * from covidvaccination
 
 -- total population vs vaccinations
 -- shows percentage of population that has recieved at least one vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as rollingpeoplevaccinated
from CovidDeaths dea
     join Covidvaccination vac
on dea.location=vac.location
  and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--use CTE to perform calculations on partition by in previous query

with popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) 
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as rollingpeoplevaccinated
from CovidDeaths dea
     join Covidvaccination vac
on dea.location=vac.location
  and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100 from popvsvac


--temp table

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentagepopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as rollingpeoplevaccinated
from CovidDeaths dea
     join Covidvaccination vac
on dea.location=vac.location
  and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100 from #percentagepopulationvaccinated

--creating view for data visualizations

create view percentagepopulationvaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as rollingpeoplevaccinated
from CovidDeaths dea
     join Covidvaccination vac
on dea.location=vac.location
  and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select * from percentagepopulationvaccinated