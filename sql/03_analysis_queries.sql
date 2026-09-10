-- Core business analysis queries
-- PostgreSQL

-- Q1. How many aircraft operated each year?
SELECT
    EXTRACT(YEAR FROM date)::INT AS year,
    COUNT(DISTINCT tail_number) AS total_aircraft,
    COUNT(DISTINCT tail_number)
      - LAG(COUNT(DISTINCT tail_number)) OVER (ORDER BY EXTRACT(YEAR FROM date)) AS year_over_year_change
FROM delay
WHERE tail_number IS NOT NULL
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY year;

-- Q2. How many departures did each hub operate in 2023?
SELECT
    origin,
    COUNT(*) AS total_departures,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS departure_rank
FROM delay
WHERE EXTRACT(YEAR FROM date) = 2023
GROUP BY origin
ORDER BY total_departures DESC;

-- Q3. Maximum delay by category
SELECT
    MAX(taxi_out_time) AS max_taxi_out_time,
    MAX(carrier_delay) AS max_carrier_delay,
    MAX(weather_delay) AS max_weather_delay,
    MAX(national_aviation_sys_delay) AS max_atc_delay,
    MAX(security_delay) AS max_security_delay,
    MAX(late_ac_arrival_delay) AS max_late_aircraft_delay
FROM delay;

-- Q4. Top five delayed flights by reconstructed total delay.
WITH delay_components AS (
    SELECT
        id, date, origin, destination, flight_number,
        sched_departure, actual_departure, departure_delay,
        COALESCE(carrier_delay, 0)
        + COALESCE(weather_delay, 0)
        + COALESCE(national_aviation_sys_delay, 0)
        + COALESCE(security_delay, 0)
        + COALESCE(late_ac_arrival_delay, 0) AS component_delay
    FROM delay
),
reconstructed AS (
    SELECT *,
        GREATEST(departure_delay, component_delay) AS total_delay
    FROM delay_components
)
SELECT *
FROM reconstructed
WHERE total_delay > 0
ORDER BY total_delay DESC, late_ac_arrival_delay DESC NULLS LAST
LIMIT 5;

-- Q5. Median delay by airport and category.
SELECT
    origin,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY departure_delay)
        FILTER (WHERE departure_delay > 0) AS median_departure_delay,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY carrier_delay)
        FILTER (WHERE carrier_delay > 0) AS median_carrier_delay,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY weather_delay)
        FILTER (WHERE weather_delay > 0) AS median_weather_delay,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY national_aviation_sys_delay)
        FILTER (WHERE national_aviation_sys_delay > 0) AS median_atc_delay,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY security_delay)
        FILTER (WHERE security_delay > 0) AS median_security_delay,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY late_ac_arrival_delay)
        FILTER (WHERE late_ac_arrival_delay > 0) AS median_late_aircraft_delay
FROM delay
GROUP BY origin
ORDER BY origin;

-- Q6. Which weekday has the largest aggregate departure delay?
SELECT
    TO_CHAR(date, 'FMDay') AS day_of_week,
    EXTRACT(ISODOW FROM date)::INT AS day_number,
    SUM(GREATEST(departure_delay, 0)) AS total_positive_departure_delay
FROM delay
GROUP BY TO_CHAR(date, 'FMDay'), EXTRACT(ISODOW FROM date)
ORDER BY total_positive_departure_delay DESC;

-- Q7. Morning vs afternoon on-time performance.
WITH categorized AS (
    SELECT *,
        CASE
            WHEN sched_departure < TIME '12:00:00' THEN 'Morning'
            ELSE 'Afternoon'
        END AS time_of_day
    FROM delay
)
SELECT
    time_of_day,
    COUNT(*) AS total_flights,
    COUNT(*) FILTER (WHERE departure_delay <= 0) AS on_time_flights,
    COUNT(*) FILTER (WHERE departure_delay > 0) AS delayed_flights,
    ROUND(100.0 * COUNT(*) FILTER (WHERE departure_delay <= 0) / COUNT(*), 2) AS on_time_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE departure_delay > 0) / COUNT(*), 2) AS delayed_pct
FROM categorized
GROUP BY time_of_day
ORDER BY time_of_day;

-- Q8. Primary controllable delay driver by time of day.
WITH categorized AS (
    SELECT *,
        CASE
            WHEN sched_departure < TIME '12:00:00' THEN 'Morning'
            ELSE 'Afternoon'
        END AS time_of_day
    FROM delay
    WHERE departure_delay > 0
)
SELECT
    time_of_day,
    COUNT(*) AS delayed_departures,
    COUNT(*) FILTER (WHERE carrier_delay > late_ac_arrival_delay) AS carrier_primary,
    COUNT(*) FILTER (WHERE late_ac_arrival_delay > carrier_delay) AS late_aircraft_primary,
    COUNT(*) FILTER (WHERE carrier_delay = 0 AND late_ac_arrival_delay = 0) AS other_primary,
    ROUND(100.0 * COUNT(*) FILTER (WHERE carrier_delay > late_ac_arrival_delay) / COUNT(*), 2) AS carrier_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE late_ac_arrival_delay > carrier_delay) / COUNT(*), 2) AS late_aircraft_pct
FROM categorized
GROUP BY time_of_day
ORDER BY time_of_day;
