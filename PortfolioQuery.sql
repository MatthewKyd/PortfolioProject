select*
from coviddeaths
where continent <> ''
order by 3,4

--select*
--from covidvaccinations
--order by 3,4

 

--look at total cases vs total deaths
--Estimate of likelihood of dying from covid in SOuth Africa
Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From coviddeaths
Where location like'%South Africa%'
and continent <> ' '
order by 1,2

--Total cases vs Population
Select location, date,  population, total_cases, (Convert(float, total_cases)/Nullif(Convert(float, population), 0))*100 as InfectedPopulationPercentage
From coviddeaths
Where location = 'South Africa'
and continent is not Null
order by 1,2

--looking at countries with highest infection rate compared population
Select 
location, 
population, 
MAX(total_cases) as HighestInfectionRate, 
MAX((Convert(float, total_cases)/Nullif(Convert(float, population), 0)))*100 as InfectPopulationPercent
From coviddeaths 
Group By population, location
Order By InfectPopulationPercent desc

--countries with the highest deathcount per population
Select location, Max(Convert(float, total_deaths)) as TotalDeaths
From coviddeaths
Where continent <> ''
Group By location
Order By TotalDeaths desc

--Break by continent
--correct way
Select location, Max(Convert(float, total_deaths)) as TotalDeaths
From coviddeaths
Where continent = ''
Group By location
Order By TotalDeaths desc
--incorect way
Select continent, Max(Convert(float, total_deaths)) as TotalDeaths
From coviddeaths
Where continent <> ''
Group By continent
Order By TotalDeaths desc


--Global numbers
--global cases and deaths
Select Sum(Convert(float, new_cases)) as total_cases, SUM(Convert(float, new_deaths)) as total_deaths, Sum(Convert(float, new_deaths))/SUM(Nullif(Convert(float, new_cases), 0))*100 as DeathPercentage
From coviddeaths
--Where location like'%South Africa%'
Where continent <> ' '
--Group by date
order by 1,2

--deaths per day
Select date, Sum(Convert(float, new_cases)) as total_cases, SUM(Convert(float, new_deaths)) as total_deaths, Sum(Convert(float, new_deaths))/SUM(Nullif(Convert(float, new_cases), 0))*100 as DeathPercentage
From coviddeaths
--Where location like'%South Africa%'
Where continent <> ' '
Group by date
order by 1,2

--Vaccinations
--look at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Convert(float, vac.new_vaccinations)) OVER 
	(Partition by dea.location order by dea.location, dea.date) as RollingCount, (RollingCount/dea.population)*100
From vac1 vac
Join coviddeaths dea
	on dea.location = vac.location and
	dea.date = vac.date
Where dea.location = 'South Africa'
order by 2,3

--CTE
with Popvaccination (continent, location, date, population, new_vaccinations, RollingCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Convert(float, vac.new_vaccinations)) OVER 
	(Partition by dea.location order by dea.location, dea.date) as RollingCount
From vac1 vac
Join coviddeaths dea
	on dea.location = vac.location and
	dea.date = vac.date
Where dea.location = 'South Africa'
)

select *, (RollingCount/population)*100 as PercentPopVacc
From Popvaccination

--Temp Table
Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination float,
RollingCount float
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Convert(float, vac.new_vaccinations)) OVER  
	(Partition by dea.location order by dea.location, dea.date) as RollingCount
From vac1 vac
Join coviddeaths dea
	on dea.location = vac.location and
	dea.date = vac.date
Where dea.location = 'South Africa'

select *, (RollingCount/population)*100 as PercentPopVacc
From #PercentPopulationVaccinated