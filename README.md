# COVID-19 Data Exploration

A SQL-based exploratory data analysis project examining global COVID-19 deaths and vaccination data.

---

## Dataset

Two tables sourced from [Our World in Data](https://ourworldindata.org/covid-deaths):

| Table | Description |
|---|---|
| `CovidDeaths$` | Daily records of cases, deaths, and population by location |
| `CovidVaccinations$` | Daily vaccination counts by location |

---

## SQL Skills Demonstrated

- **Joins** — Combining deaths and vaccinations tables on location and date
- **CTEs (Common Table Expressions)** — Performing calculations on top of window function results
- **Temporary Tables** — Storing intermediate results for reuse in further queries
- **Window Functions** — Running totals using `OVER (PARTITION BY ... ORDER BY ...)`
- **Aggregate Functions** — `SUM()`, `MAX()` across grouped data
- **Views** — Persisting query logic for use in downstream visualisation tools
- **Type Conversion** — `CAST()` and `CONVERT()` to handle numeric operations on string-stored columns

---

## Analysis Sections

### 1. Death Rate by Country
Calculates the percentage of confirmed cases that resulted in death, filtered by country. Highlights the likelihood of dying after contracting COVID-19 in a given location.

### 2. Infection Rate vs Population
Shows what share of each country's population was infected at any point in time, using total cases against population figures.

### 3. Highest Infection Rates
Ranks countries by their peak infection rate relative to population size, using `MAX()` to find each country's highest recorded case count.

### 4. Death Count by Country
Identifies the countries with the highest absolute death tolls, filtering out continent-level aggregate rows using `WHERE continent IS NOT NULL`.

### 5. Death Count by Continent
Aggregates total deaths at the continent level to provide a regional overview.

### 6. Global Totals
A single-row summary of worldwide total cases, total deaths, and the overall death percentage across the entire dataset.

### 7. Rolling Vaccination Count
Joins deaths and vaccinations data to compute a running total of people vaccinated per country over time, using a window function partitioned by location.

### 8. Vaccination Rate via CTE
Wraps the rolling vaccination query in a CTE to then calculate each country's vaccinated population as a percentage — something not possible in a single query step.

### 9. Vaccination Rate via Temp Table
Replicates the CTE approach using a temporary table (`#PercentPopulationVaccinated`), demonstrating an alternative method for multi-step calculations.

### 10. Saved View
Creates a reusable view (`PercentPopulationVaccinated`) storing the rolling vaccination logic, ready to connect directly to a visualisation tool such as Tableau or Power BI.

---

## How to Run

1. Import the `CovidDeaths` and `CovidVaccinations` CSV files into a database named `PortfolioProject`
2. Open the `.sql` file in SQL Server Management Studio (SSMS)
3. Execute queries individually or all at once
4. The final `CREATE VIEW` statement can be queried at any time after creation

---

## Notes

- Rows where `continent IS NULL` represent continent-level or world-level aggregate rows in the dataset and are excluded from country-level queries to avoid double counting
- Some numeric columns (e.g. `total_deaths`, `new_vaccinations`) are stored as strings in the raw data and require `CAST` or `CONVERT` before arithmetic operations
