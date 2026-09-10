# ✈️ American Airlines Flight Delay Analysis

> **SQL + PostgreSQL analysis of American Airlines departure performance, delay drivers, and operational patterns.**

![Project Banner](Banner%20Skinny.png)

## Overview

This project analyzes American Airlines departure data for **2022–2024** to understand where delays are concentrated, which delay categories have the greatest operational impact, and how delay patterns change throughout the day.

The analysis focuses on American Airlines' nine major hubs:

`DFW` · `CLT` · `MIA` · `PHX` · `ORD` · `PHL` · `LAX` · `DCA` · `JFK`

The project combines **Excel-based data quality checks**, **PostgreSQL**, and targeted SQL analysis to turn raw flight records into operational insights.

---

## 🎯 Business Questions

The analysis answers eight practical questions:

1. How many aircraft did AA operate each year?
2. How many departures did each major base operate in 2023?
3. What is the maximum delay recorded for each delay category?
4. Which five flights experienced the largest total delays?
5. What is the median delay by category and airport base?
6. Which day of the week experienced the greatest total delay time?
7. How does on-time performance differ between morning and afternoon departures?
8. Which controllable delay causes dominate morning versus afternoon departures?

---

## 📊 Key Findings

| Metric | Finding |
|---|---:|
| Morning delayed departures | **31.19%** |
| Afternoon delayed departures | **50.44%** |
| Aircraft in 2022 | **915** |
| Aircraft in 2023 | **954** |
| Aircraft in 2024 | **971** |
| 2023 departure leader | **DFW — 159,270** |
| Highest total-delay weekday | **Friday** |
| Lowest total-delay weekday | **Tuesday** |
| Largest recorded delay | **2,506 min — late aircraft arrival** |

### The main operational pattern

The strongest pattern in the analysis is the increase in delayed departures as the operational day progresses. Morning delays are more strongly associated with **carrier delays**, while afternoon delays are more heavily associated with **late aircraft arrivals**.

This supports the project's central operational hypothesis: **early-day disruption can propagate through subsequent aircraft rotations and contribute to later-day delays.**

---

## 🔎 Analysis Highlights

### Morning vs. afternoon performance

- **Morning:** 676,647 flights; **68.81% on time** and **31.19% delayed**.
- **Afternoon:** 946,731 flights; **49.56% on time** and **50.44% delayed**.

### Controllable delay mix

Among delayed departures:

- Morning carrier-delay share: **25.40%**
- Morning late-aircraft share: **17.06%**
- Afternoon carrier-delay share: **22.79%**
- Afternoon late-aircraft share: **31.83%**

### Airport footprint

DFW is the largest departure base in the 2023 dataset, followed by CLT and PHX. JFK has the smallest departure volume among the nine analyzed hubs.

---

## 🧰 Tools & Techniques

**Database**
- PostgreSQL
- SQL aggregation and filtering
- Window functions (`LAG`, `RANK`)
- Conditional aggregation with `FILTER`
- Percentiles with `PERCENTILE_CONT`
- Date/time extraction and formatting
- Nested subqueries and calculated metrics

**Data preparation**
- Excel formatting and inspection
- Primary-key generation
- NULL detection
- Abnormal-record identification
- CSV-to-PostgreSQL preparation

---

## 🗂️ Project Structure

```text
SQL-Airline-Delay-Project/
│
├── README.md
├── Excel and SQL Quality Checks.md
├── SQL Analysis Queries.md
│
├── sql/
│   ├── quality_checks.sql
│   └── analysis_queries.sql
│
├── Banner Full Size.png
├── Banner Skinny.png
├── Describe Table.png
├── Excel step 1.gif
├── Excel step 3.gif
├── Excel step 4.png
├── Figure 1.png
├── Figure 2.png
├── Figure 3.png
├── Figure 4.png
├── Figure 5.png
├── Figure 6.png
├── Figure 7.png
└── Figure 8.png
```

---

## 🧹 Data Quality & Preparation

Before analysis, the source workflow checks for missing and abnormal records. The PostgreSQL schema contains 18 fields, with `id` used as the primary key and `tail_number` allowed to remain NULL because the source data contains missing aircraft identifiers.

The documented quality checks identify records with:

- `actual_flt_time = 0`
- `tail_number IS NULL`
- `taxi_out_time = 0`

The source documentation reports an expected imported row count of **1,546,452** and approximately **32K irregular records** identified by these conditions.

See [`Excel and SQL Quality Checks.md`](Excel%20and%20SQL%20Quality%20Checks.md) for the full preparation workflow.

---

## 🧪 SQL Analysis

The complete business-question analysis is documented in [`SQL Analysis Queries.md`](SQL%20Analysis%20Queries.md).

For easier reuse, the executable query set is also available in [`sql/analysis_queries.sql`](sql/analysis_queries.sql), while the data-quality SQL is available in [`sql/quality_checks.sql`](sql/quality_checks.sql).

---

## 💡 Business Recommendations

Based on the documented findings, the project proposes:

1. **Protect first-half-of-day on-time performance** to reduce rolling operational delays.
2. **Maintain minimum spare-parts inventories** at key airports to reduce maintenance-related waiting time.
3. **Pilot an A/B test at DCA**, a smaller base where an operational intervention can be tested and measured more easily.

These recommendations are derived from the project's observed delay patterns rather than from a predictive model.

---

## 📚 Data Source

The underlying flight data was collected from the **Bureau of Transportation Statistics (BTS)** for American Airlines departure metrics covering 2022 through 2024. The source workflow and compiled-data location are documented in the original project materials.

> **Data availability note:** the documented dataset ends in **October 2024**, so 2024 is not a complete calendar year.

---

## 📈 Visual Evidence

The repository includes the original analysis visuals supporting the SQL results, including:

- Fleet growth by year
- Departures by airport base
- Maximum delay categories
- Top five delayed flights
- Median delay by base
- Delay time by weekday
- Morning vs. afternoon performance
- Controllable delay mix by time of day

---

## ⚠️ Assumptions & Limitations

The project documentation notes several limitations, including incomplete 2024 coverage, difficulty tracing an individual aircraft across an entire operational day, and differences between departure-delay definitions used by airlines.

The analysis should therefore be interpreted as an **operational diagnostic**, not as a causal model.

---

## 🔗 Project Resources

- [Excel & SQL Quality Checks](Excel%20and%20SQL%20Quality%20Checks.md)
- [SQL Analysis Queries](SQL%20Analysis%20Queries.md)
- [Executable Analysis SQL](sql/analysis_queries.sql)
- [Data Quality SQL](sql/quality_checks.sql)

---

## Reference

This project is based on the public **SQL Airline Delay Project** by Michael Zaniewski. The original project is used as the reference for the dataset workflow, analytical questions, SQL logic, and visual evidence; this repository reorganizes and presents those materials in a cleaner portfolio-oriented structure.
