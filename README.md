# ✈️ American Airlines Delay Analysis — SQL Portfolio Project

An end-to-end SQL analytics project exploring American Airlines departure performance, delay patterns, airport operations, and controllable causes of late departures.

> **Learning project:** This repository is an independent implementation inspired by a public airline-delay SQL project. It is intended to demonstrate practical SQL, data-quality, analytical, and business-reasoning skills.

## 🎯 Business Objective

The objective is to identify where and when departure delays occur, understand their major drivers, and translate the analysis into operational questions and recommendations.

### Questions answered

1. How many aircraft operated each year?
2. Which hubs handled the most departures in 2023?
3. What is the maximum observed delay for each delay category?
4. Which flights experienced the largest reconstructed delays?
5. What is the median delay by airport and delay category?
6. Which weekday accumulated the most positive departure delay?
7. How does on-time performance differ between morning and afternoon flights?
8. Which controllable delay driver is more prominent by time of day?

## 🧰 Tech Stack

- **PostgreSQL** — data storage and SQL analysis
- **SQL** — cleaning, aggregation, CTEs, window functions, ranking and statistical analysis
- **Excel / spreadsheet workflow** — optional source-data inspection
- **GitHub** — version control and portfolio documentation

## 📁 Repository Structure

```text
SQL-Airline-Delay-Project/
├── README.md
├── sql/
│   ├── 01_create_table.sql
│   ├── 02_quality_checks.sql
│   └── 03_analysis_queries.sql
├── documentation/
│   ├── data_dictionary.md
│   └── methodology.md
├── data/
│   ├── raw/
│   └── processed/
└── visuals/
```

## 🗃️ Dataset

The analytical scope follows American Airlines departure statistics from the U.S. Bureau of Transportation Statistics (BTS), covering 2022–2024. The reference analysis focuses on major American Airlines hubs including DFW, CLT, MIA, PHX, ORD, PHL, LAX, DCA, and JFK.

The repository intentionally does not claim quantitative findings until the underlying dataset is loaded and the queries are executed against it.

## 🔍 Data Quality Approach

Before analysis, the project checks:

- Missing `tail_number` values
- Zero `actual_flt_time`
- Zero `taxi_out_time`
- Negative values in delay-category fields
- Duplicate business records
- Overall row counts and basic delay ranges

Negative `departure_delay` values are retained because they represent flights that departed early rather than data errors.

## 📊 SQL Techniques Demonstrated

- `COUNT()` and `COUNT(DISTINCT ...)`
- `SUM()`, `MAX()`, `GREATEST()`
- `CASE WHEN`
- `FILTER`
- `COALESCE()`
- `PERCENTILE_CONT()` for median analysis
- `RANK()` and `LAG()` window functions
- `GROUP BY` / `HAVING`
- Common Table Expressions (CTEs)
- Date/time extraction and formatting

## 💡 Portfolio Value

This project demonstrates a complete analytics workflow rather than isolated SQL exercises:

**Raw data → quality checks → relational schema → analytical SQL → operational insights → business recommendations**

## 🚀 Future Enhancements

- Add an interactive Power BI/Tableau dashboard
- Add automated data-quality tests
- Build airport-level delay KPIs
- Analyze monthly and seasonal trends
- Add route-level performance analysis
- Create an executive operations dashboard

## 📚 Reference

The project structure and problem framing were inspired by the public repository used for learning and comparison:

`MichaelZaniewski/SQL-Airline-Delay-Project`

The implementation in this repository is independently organized and should be validated against the actual source data before quantitative conclusions are published.
