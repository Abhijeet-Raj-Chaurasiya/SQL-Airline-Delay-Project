-- Data quality checks

-- 1. Row count
SELECT COUNT(*) AS total_rows
FROM delay;

-- 2. Missing aircraft identifiers
SELECT COUNT(*) AS missing_tail_numbers
FROM delay
WHERE tail_number IS NULL;

-- 3. Operationally abnormal records
SELECT COUNT(*) AS abnormal_rows
FROM delay
WHERE actual_flt_time = 0
   OR tail_number IS NULL
   OR taxi_out_time = 0;

-- 4. Negative departure delays are valid (early departures), so do not remove them.
SELECT
    MIN(departure_delay) AS earliest_departure_delta,
    MAX(departure_delay) AS largest_departure_delay
FROM delay;

-- 5. Check delay categories for impossible negative values
SELECT COUNT(*) AS negative_delay_category_rows
FROM delay
WHERE carrier_delay < 0
   OR weather_delay < 0
   OR national_aviation_sys_delay < 0
   OR security_delay < 0
   OR late_ac_arrival_delay < 0;

-- 6. Duplicate business records
SELECT date, flight_number, origin, destination, sched_departure, COUNT(*) AS records
FROM delay
GROUP BY date, flight_number, origin, destination, sched_departure
HAVING COUNT(*) > 1
ORDER BY records DESC;

-- 7. Inspect records selected for exclusion from completed-flight analysis
SELECT *
FROM delay
WHERE actual_flt_time = 0
   OR tail_number IS NULL
   OR taxi_out_time = 0;
