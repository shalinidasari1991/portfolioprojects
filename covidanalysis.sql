--select * from portfolioproject..CovidDeaths
--order by 3 ,4 

--select * from portfolioproject..CovidVaccinations
-- order by 3 ,4 

-- take the date we want

select location, date, total_cases, new_cases,total_deaths,population
from portfolioproject..CovidDeaths
order by 1 ,2 


-- total cases vs total deaths 
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as death_precent
from portfolioproject..CovidDeaths
where location = 'india'
order by 1 ,2 

-- total cases vs population 
-- shows wat population got covid 
select location, date, total_cases,population,(total_cases/population)*100 as population_precent
from portfolioproject..CovidDeaths
-- where location = 'india'
order by 1 ,2 

-- countries with highest infection rate compared to population 
select location,population, max(total_cases)as highest_infectioncount ,max((total_cases/population))*100 as precentinfection
from portfolioproject..CovidDeaths
--where location = 'india'
group by location,population
order by precentinfection desc

-- countries with highest death count per population 
select location,max(cast(total_deaths as int))as totaldeathcount
from portfolioproject..CovidDeaths
where continent is  not null 
--and location = 'india'
group by location, population
order by totaldeathcount desc


-- lets break things  down by continents 

select continent,max(cast(total_deaths as int))as totaldeathcount
from portfolioproject..CovidDeaths
where continent is not null 
--and location = 'india'
group by continent
order by totaldeathcount desc;

--breakdown of continent, global numbers
select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths ,
sum(cast(new_deaths as int))/ sum(new_cases)*100 as death_precent
from portfolioproject..CovidDeaths
where continent is not null 
order by 1 ,2 

--looking at total population vs total vaccination in indai 

select D.continent,D.location,D.date,D.population,V.new_vaccinations ,V.total_vaccinations 
 from portfolioproject..CovidDeaths as D
join portfolioproject..CovidVaccinations as V 
on D.location = V.location and D.date = V.date
where D.continent is not null and D.location ='India'
order by 2,3




-- looking total population vs total vaccination 
-- joining two tables 
select D.continent,D.location,D.date,D.population,V.new_vaccinations ,V.total_vaccinations 
 from portfolioproject..CovidDeaths as D
join portfolioproject..CovidVaccinations as V 
on D.location = V.location and D.date = V.date
where D.continent is not null 
order by 2,3


--using	CTE , common table expression 

 with popVsvac (continent, location,population,new_vaccination, rollingpeoplevaccinated)
 as
 (
 select D.continent,D.location,D.population,V.new_vaccinations , 
 sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,
D.date) as rollingpeoplevaccinated
 from portfolioproject..CovidDeaths as D
join portfolioproject..CovidVaccinations as V 
on D.location = V.location and D.date = V.date
where D.continent is not null and D.location = 'india' 
--order by 2,3
)
select *, ( rollingpeoplevaccinated/population)*100 as precentRPV from popVsvac


-- creating a temperory table 
create table #percentpopulationvaccinated 
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select D.continent,D.location,D.date,D.population,V.new_vaccinations , 
 sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,
D.date) as rollingpeoplevaccinated
 from portfolioproject..CovidDeaths as D
join portfolioproject..CovidVaccinations as V 
on D.location = V.location and D.date = V.date
--where D.continent is not null 
--order by 2,3

select *, ( rollingpeoplevaccinated/population)*100 as precentRPV from #percentpopulationvaccinated


-- creating viewa to store date for visualisation

create view percentpolulationvaccinated as 
select D.continent,D.location,D.date,D.population,V.new_vaccinations , 
 sum(convert(int,V.new_vaccinations)) over (partition by D.location order by D.location,
D.date) as rollingpeoplevaccinated
 from portfolioproject..CovidDeaths as D
join portfolioproject..CovidVaccinations as V 
on D.location = V.location and D.date = V.date
--where D.continent is not null 
--order by 2,3

select * from percentpolulationvaccinated




