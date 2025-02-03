select location, population, sum(new_cases) as highest_infection_count,
(SUM(new_cases::numeric) / population::numeric) * 100 as percent_pop_infected
from coviddeaths
group by location, population
order by percent_pop_infected desc;


select location, population, date, max(total_cases) as highest_infection_count,
replace(to_char((max(total_cases::numeric)/population::numeric)*100, '999999999.99'), '.', ',')  as percent_pop_infected
from coviddeaths
group by location, population, date
order by percent_pop_infected desc;

