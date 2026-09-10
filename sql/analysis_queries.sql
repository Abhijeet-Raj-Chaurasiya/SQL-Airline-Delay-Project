-- Airline Delay Analysis
-- PostgreSQL queries supporting the eight business questions in the project.
--
-- Assumption: the `delay` table has already been created and populated.
-- The queries preserve the project's original analytical definitions and
-- reported findings while using clearer CTEs and explicit aliases.

-- ================================================================
-- 1. Fleet size by year
-- ================================================================
SELECT
    EXTRACT(YEAR FROM date) AS year,
    COUNT(DISTINCT tail_number) AS total_planes,
    COUNT(DISTINCT tail_number)
        - LAG(COUNT(DISTINCT tail_number)) OVER (ORDER BY EXTRACT(YEAR FROM date)) AS difference
FROM delay
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY year;


-- ================================================================
-- 2. Departures by base in 2023
-- ================================================================
SELECT
    origin,
    COUNT(*) AS total_departures,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
FROM delay
WHERE EXTRACT(YEAR FROM date) = 2023
GROUP BY origin
ORDER BY total_departures DESC;


-- ================================================================
-- 3. Maximum delay by category
-- ================================================================
SELECT
    MAX(taxi_out_time) AS max_taxi,
    MAX(carrier_delay) AS max_carrier_dly,
    MAX(weather_delay) AS max_weather_dly,
    MAX(national_aviation_sys_delay) AS max_atc_dly,
    MAX(security_delay) AS max_security_dly,
    MAX(late_ac_arrival_delay) AS max_late_ac_dly
FROM delay;


-- ================================================================
-- 4. Top 5 most delayed flights
--
-- `almost_total_delay` is the sum of the categorized delay fields.
-- The adjustment reproduces the original project's treatment of the
-- difference between categorized delay and recorded departure delay.
-- ================================================================
WITH flight_delay AS (
    SELECT
        id,
        date,
        origin,
        sched_departure,
        actual_departure,
        departure_delay,
        carrier_delay,
        weather_delay,
        national_aviation_sys_delay,
        security_delay,
        late_ac_arrival_delay,
        carrier_delay
            + weather_delay
            + national_aviation_sys_delay
            + security_delay
            + late_ac_arrival_delay AS almost_total_delay
    FROM delay
),
adjusted_delay AS (
    SELECT
        *,
        CASE
            WHEN departure_delay > 0 THEN
                almost_total_delay + ABS(almost_total_delay - departure_delay)
            WHEN departure_delay < 0 THEN
                almost_total_delay + departure_delay
            ELSE 0
        END AS total_delay
    FROM flight_delay
)
SELECT
    date,
    origin,
    sched_departure,
    actual_departure,
    departure_delay,
    carrier_delay,
    weather_delay,
    national_aviation_sys_delay,
    security_delay,
    late_ac_arrival_delay,
    total_delay
FROM adjusted_delay
ORDER BY total_delay DESC, late_ac_arrival_delay DESC
LIMIT 5;


-- ================================================================
-- 5. Median delay by category and base
-- ================================================================
WITH medians AS (
    SELECT
        origin,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY departure_delay)
            FILTER (WHERE departure_delay > 0) AS mdn_dept_dly,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY carrier_delay)
            FILTER (WHERE carrier_delay <> 0) AS mdn_carrier_dly,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY weather_delay)
            FILTER (WHERE weather_delay <> 0) AS mdn_weather_dly,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY national_aviation_sys_delay)
            FILTER (WHERE national_aviation_sys_delay <> 0) AS mdn_atc_dly,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY security_delay)
            FILTER (WHERE security_delay <> 0) AS mdn_security_dly,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY late_ac_arrival_delay)
            FILTER (WHERE late_ac_arrival_delay <> 0) AS mdn_late_ac_dly
    FROM delay
    GROUP BY origin
),
ranked_bases AS (
    SELECT
        origin,
        mdn_dept_dly,
        mdn_carrier_dly,
        mdn_weather_dly,
        mdn_atc_dly,
        mdn_security_dly,
        mdn_late_ac_dly,
        COALESCE(mdn_dept_dly, 0)
            + COALESCE(mdn_carrier_dly, 0)
            + COALESCE(mdn_weather_dly, 0)
            + COALESCE(mdn_atc_dly, 0)
            + COALESCE(mdn_security_dly, 0)
            + COALESCE(mdn_late_ac_dly, 0) AS total_mdn_dly
    FROM medians
)
SELECT
    RANK() OVER (ORDER BY total_mdn_dly DESC) AS top_mdn_dlyd_base_rank,
    origin,
    total_mdn_dly,
    mdn_dept_dly,
    mdn_carrier_dly,
    mdn_weather_dly,
    mdn_atc_dly,
    mdn_security_dly,
    mdn_late_ac_dly
FROM ranked_bases
ORDER BY total_mdn_dly DESC;


-- ================================================================
-- 6. Total delay by day of week
-- ================================================================
WITH flight_delay AS (
    SELECT
        id,
        date,
        origin,
        departure_delay,
        carrier_delay,
        weather_delay,
        national_aviation_sys_delay,
        security_delay,
        late_ac_arrival_delay,
        carrier_delay
            + weather_delay
            + national_aviation_sys_delay
            + security_delay
            + late_ac_arrival_delay AS almost_total_delay
    FROM delay
),
adjusted_delay AS (
    SELECT
        *,
        CASE
            WHEN departure_delay > 0 THEN
                almost_total_delay + ABS(almost_total_delay - departure_delay)
            WHEN departure_delay < 0 THEN
                almost_total_delay + departure_delay
            ELSE 0
        END AS total_delay
    FROM flight_delay
)
SELECT
    TO_CHAR(date, 'DAY') AS day_of_week,
    SUM(total_delay) AS total_delay_time
FROM adjusted_delay
GROUP BY TO_CHAR(date, 'DAY')
ORDER BY total_delay_time DESC;


-- ================================================================
-- 7. Morning vs. afternoon on-time performance
-- ================================================================
WITH classified_flights AS (
    SELECT
        *,
        CASE
            WHEN sched_departure < '12:00:00' THEN 'MORNING'
            WHEN sched_departure >= '12:00:00' THEN 'AFTERNOON'
        END AS time_of_day
    FROM delay
)
SELECT
    time_of_day,
    COUNT(*) AS total_flights,
    TO_CHAR(
        ROUND(
            100 * COUNT(*) FILTER (WHERE departure_delay <= 0)
            / COUNT(*)::numeric,
            2
        ),
        '999D99%'
    ) AS on_time,
    TO_CHAR(
        ROUND(
            100 * COUNT(*) FILTER (WHERE departure_delay > 0)
            / COUNT(*)::numeric,
            2
        ),
        '999D99%'
    ) AS delayed
FROM classified_flights
GROUP BY time_of_day
ORDER BY total_flights ASC;


-- ================================================================
-- 8. Main controllable causes by time of day
-- ================================================================
WITH classified_flights AS (
    SELECT
        *,
        CASE
            WHEN sched_departure < '12:00:00' THEN 'MORNING'
            WHEN sched_departure >= '12:00:00' THEN 'AFTERNOON'
        END AS time_of_day
    FROM delay
)
SELECT
    time_of_day,
    COUNT(*) FILTER (WHERE departure_delay > 0) AS count_delayed_departures,
    TO_CHAR(
        100 * COUNT(*) FILTER (
            WHERE carrier_delay > late_ac_arrival_delay
        ) / COUNT(*) FILTER (WHERE departure_delay > 0)::numeric,
        '999D99%'
    ) AS carrier_delayed,
    TO_CHAR(
        100 * COUNT(*) FILTER (
            WHERE late_ac_arrival_delay > carrier_delay
        ) / COUNT(*) FILTER (WHERE departure_delay > 0)::numeric,
        '999D99%'
    ) AS late_ac_delayed,
    TO_CHAR(
        100 * COUNT(*) FILTER (
            WHERE carrier_delay = 0
              AND late_ac_arrival_delay = 0
              AND departure_delay > 0
        ) / COUNT(*) FILTER (WHERE departure_delay > 0)::numeric,
        '999D99%'
    ) AS other_delayed
FROM classified_flights
GROUP BY time_of_day
ORDER BY count_delayed_departures ASC;
