# Analysis Workflow

This project follows a simple progression from raw flight records to business-facing findings.

## 1. Prepare the data

The source CSV files are combined and inspected in Excel. An ID is added for record-level identification, dates are formatted consistently, and filters are used to identify missing or unusual values.

## 2. Validate the SQL table

The cleaned structure is represented by the PostgreSQL `delay` table. The quality-check script verifies the imported population and identifies irregular records before analysis.

## 3. Establish the analytical population

Records with zero actual flight time, missing aircraft identifiers, or zero taxi-out time are treated as irregular for the analytical workflow. They remain available in the source material for traceability.

## 4. Answer the business questions

The analysis is organized into eight questions covering fleet size, airport activity, maximum delays, extreme-delay flights, median delays, weekday patterns, time-of-day performance, and major controllable delay causes.

## 5. Translate results into operations

The final step is to interpret the SQL outputs in an operational context. The strongest observed pattern is the deterioration in on-time performance from morning to afternoon, alongside a shift from carrier-related delays toward late-aircraft-arrival delays.

## Reproducibility checklist

Before rerunning the analysis:

- [ ] Create the `delay` table using `sql/quality_checks.sql`.
- [ ] Load the prepared flight data into PostgreSQL.
- [ ] Run the irregular-record count and review the flagged rows.
- [ ] Run `sql/analysis_queries.sql` in order.
- [ ] Compare the resulting figures with the visuals in `assets/images/`.
- [ ] Record any differences caused by a changed or incomplete dataset.

> The repository does not include the full flight dataset. The SQL scripts assume the `delay` table has already been populated.
