# Methodology

## 1. Data acquisition

The project uses American Airlines departure statistics from the U.S. Bureau of Transportation Statistics (BTS), covering 2022–2024.

## 2. Data preparation

The workflow is designed for PostgreSQL:

1. Inspect source CSV files.
2. Confirm column names and expected data types.
3. Assign a unique record identifier.
4. Check missing values and operational abnormalities.
5. Preserve source records while excluding clearly irregular flights from completed-flight analysis where appropriate.

## 3. Quality checks

Important checks include missing aircraft identifiers, zero flight duration, zero taxi-out time, negative delay-category values, duplicate business records, and overall row counts.

A negative `departure_delay` is not automatically an error: it means the aircraft departed before its scheduled departure time.

## 4. Analysis framework

The analysis answers eight business questions covering fleet size, airport activity, maximum delay exposure, extreme delays, median delay behavior, weekday performance, time-of-day reliability, and controllable delay drivers.

The SQL uses aggregation, filtering, window functions, conditional logic, CTEs, ranking, and percentile calculations.

## 5. Portfolio principle

This repository is a learning implementation inspired by a public reference project. Queries and documentation are independently organized and should be validated against the actual dataset before making quantitative claims.
