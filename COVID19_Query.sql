-- Date formatı

UPDATE coviddeaths
SET date = TO_DATE(date, 'DD.MM.YYYY')::DATE;

ALTER TABLE coviddeaths 
ALTER COLUMN date TYPE DATE 
USING TO_DATE(date, 'YYYY-MM-DD');

UPDATE covidvaccinations
SET date = TO_DATE(date, 'DD.MM.YYYY')::DATE;

ALTER TABLE covidvaccinations 
ALTER COLUMN date TYPE DATE 
USING TO_DATE(date, 'YYYY-MM-DD');

select * from
coviddeaths;

select * from
covidvaccinations;

-----------------------------------------------------
-- Analiz

select location, date,  total_cases, total_deaths, population
from coviddeaths
order by 1,2;


-- Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country.

select location, date,  total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like 'Turkey'
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, population, total_cases,  
round((total_cases::numeric /population::numeric)*100, 1) as PopulationPercentage
from coviddeaths
--where location like 'Turkey'
order by 1,2;


-- Looking at countries with Highest Infection  Rate  compared  to  Population

select location, population, max(total_cases) as Highest_infection_count,  
round(max(total_cases::numeric) /population::numeric *100, 1) as PopulationPercentage
from coviddeaths
where total_cases is not null
and population is not null
group by location, population
order by PopulationPercentage desc;



-- Showing the countries with the highest Death count per population

select location, population, max(total_deaths) as Highest_death_count,  
round(max(total_deaths::numeric) /population::numeric *100, 1) as PopulationPercentage
from coviddeaths
where total_deaths is not null
and population is not null
and continent is not null
group by location, population
order by PopulationPercentage desc;

-- Showing continents with highest death count per population

select continent, max(total_deaths) as total_death_count
from coviddeaths
where continent is not null
group by continent
order by total_death_count desc;


-- Global numbers

select date, sum(new_cases) as total_cases,
sum(new_deaths) as total_deaths, 
round(sum(new_deaths::numeric)/sum(new_cases::numeric)*100,1) as Deaths_percentage
from coviddeaths
where continent is not null
group by date
order by 4 desc;

-- Total pop vs vaccinations (Partition by and window functions)


select dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as rolling_total
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- CTE

with vacc_rolling_total (continent, location, date, population, new_vaccinations, rolling_total)
as
	(
	select dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as rolling_total
	from coviddeaths dea
	join covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	)
select *,
round(rolling_total::numeric/population::numeric * 100, 1) as percentage
from vacc_rolling_total
where location = 'Turkey';

-- Creating view to store data for later visualizations WITH CTE!!! Nice one!

create view percentpopulationvaccinated as
with vacc_rolling_total (continent, location, date, population, new_vaccinations, rolling_total)
as
	(
	select dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as rolling_total
	from coviddeaths dea
	join covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	)
select *,
round(rolling_total::numeric/population::numeric * 100, 1) as percentage
from vacc_rolling_total;
