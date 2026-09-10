# Excel and SQL Data Quality Checks

## Excel — Initial View and Formatting

**Step 1:** Combined multiple CSVs into a master file within Excel's 1M-row limit.

**Step 2:** Added an ID column to act as a primary key and uniquely identify each record.

![Excel step 1](../assets/images/Excel%20step%201.gif)

**Step 3:** Formatted the date column using Excel's Format Cells option so the data can be imported into SQL using the expected date structure.

**Step 4:** Applied filters to identify blank values. `tail_number` is the documented field containing NULLs.

![Excel step 3](../assets/images/Excel%20step%203.gif)

**Step 5:** Reviewed the dataset for abnormalities such as `actual_flt_time = 0` and `taxi_out_time = 0`.

![Excel step 4](../assets/images/Excel%20step%204.png)

**Step 6:** Repeated the preparation process for the remaining data, continuing the ID sequence so records remain uniquely labeled.

## PostgreSQL — Importing and Cleaning

The PostgreSQL table mirrors the CSV structure:

```sql
CREATE TABLE delay(
  id SERIAL PRIMARY KEY,
  date DATE NOT NULL,
  flight_number VARCHAR(20) NOT NULL,
  tail_number VARCHAR(45),
  origin VARCHAR(4) NOT NULL,
  destination VARCHAR(4) NOT NULL,
  sched_departure TIME NOT NULL,
  actual_departure TIME NOT NULL,
  sched_flt_time INTEGER NOT NULL,
  actual_flt_time INTEGER NOT NULL,
  departure_delay INTEGER NOT NULL,
  wheels_up_time TIME NOT NULL,
  taxi_out_time INTEGER NOT NULL,
  carrier_delay INTEGER NOT NULL,
  weather_delay INTEGER NOT NULL,
  national_aviation_sys_delay INT NOT NULL,
  security_delay INTEGER NOT NULL,
  late_ac_arrival_delay INTEGER NOT NULL
);
```

Because `tail_number` contains NULL values, it is intentionally not constrained as `NOT NULL`. The documented expected imported row count is **1,546,452**.

### Irregular-record checks

The workflow identifies records where:

- `actual_flt_time = 0`
- `tail_number IS NULL`
- `taxi_out_time = 0`

```sql
SELECT COUNT(*)
FROM delay
WHERE actual_flt_time = 0
   OR tail_number IS NULL
   OR taxi_out_time = 0;
```

The source documentation reports approximately **32K irregular rows out of 1.5M**.

For analysis, these records are excluded from the analytical population. The original CSVs retain the records for traceability.

> **Note:** The executable quality-check queries are also available in [`../sql/quality_checks.sql`](../sql/quality_checks.sql).
