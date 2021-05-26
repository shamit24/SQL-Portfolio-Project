Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * from PortfolioProject..['covid-vaccinations$'] 
--order by 3,4

-- Select the Data that we will use

Select Location, date, total_cases, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (Canada)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%canada%'
order by 1,2

-- Looking at the total cases vs population and total deaths vs population
-- Shows what percentage of population got Covid

Select Location, date,  Population, total_cases, (total_deaths/population)*100 as Death_by_population
From PortfolioProject..CovidDeaths
where location like '%canada%'
order by 1,2

Select Location, date,  Population, total_cases, round((total_cases/population),3)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%canada%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location,  Population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Looking at Countries with Highest Infection Rate compared to Population where minimum population is 5 million

Select  Location,  Population, Max(total_cases) as HighestInfectionCount, round(max((total_cases/population)),4)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where Population > 5000000
Group by location, Population
order by PercentPopulationInfected desc

-- Showing Countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by Total_Death_Count desc



-- Showing continents wiht highest death counts

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by Total_Death_Count desc


-- Global Numbers

Select   SUM(new_cases) AS Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as Death_Percentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- USE CTE
With PopulationvsVaccination (Continent, Location, Date, Population, new_vaccinations, rolling_People_Vaccinated)
as 
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--group by dea.continent, dea.location
--order by 2,3
)


Select *, (rolling_People_Vaccinated/Population) * 100
From PopulationvsVaccination


-- Temp Table
DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_People_Vaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--group by dea.continent, dea.location
--order by 2,3

Select *, (rolling_People_Vaccinated/Population) * 100
From PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PerecentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

