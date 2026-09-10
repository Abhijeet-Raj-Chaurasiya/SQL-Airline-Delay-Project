-- Airline Delay Analysis
-- Extracted from the project analysis documentation.

-- 1. Fleet size by year
SELECT 
    EXTRACT(YEAR FROM date) AS year, 
    COUNT(DISTINCT tail_number) AS Total_Planes,
    COUNT(DISTINCT tail_number) - LAG(COUNT(DISTINCT tail_number),1) OVER () AS difference
FROM delay
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY YEAR;

-- 2. Departures by base in 2023
SELECT origin, COUNT(*) AS total_departures,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS RANK
FROM (SELECT origin, id,
    EXTRACT(YEAR FROM date) AS year
    FROM delay)
WHERE year = '2023'
GROUP BY year, origin
ORDER BY total_departures DESC;

-- 3. Maximum delay by category
SELECT 
    MAX(taxi_out_time) AS max_taxi,
    MAX(carrier_delay) AS max_carrier_dly,
    MAX(weather_delay) AS max_weather_dly,
    MAX(national_aviation_sys_delay) AS max_atc_dly,
    MAX(security_delay) AS max_security_dly,
    MAX(late_ac_arrival_delay) AS max_late_ac_dly
FROM delay;

-- 4. Top 5 most delayed flights
SELECT date, origin, sched_departure, actual_departure, departure_delay, carrier_delay, weather_delay, national_aviation_sys_delay, security_delay, late_ac_arrival_delay,
    CASE
        WHEN departure_delay > 0 OR departure_delay > almost_total_delay
        THEN SUM(almost_total_delay + pos_difference)
        WHEN departure_delay < 0 OR departure_delay < almost_total_delay
        THEN SUM(almost_total_delay + neg_difference)
        ELSE 0
    END AS total_delay
FROM (SELECT *, COALESCE(SUM(almost_total_delay - departure_delay) FILTER(WHERE departure_delay > 0), departure_delay) AS neg_difference,
        COALESCE(ABS(SUM(almost_total_delay - departure_delay) FILTER(WHERE departure_delay > 0)), ABS(departure_delay)) AS pos_difference
    FROM (SELECT id, date, origin, sched_departure, actual_departure, departure_delay, carrier_delay, weather_delay, national_aviation_sys_delay, security_delay, late_ac_arrival_delay,
            SUM(carrier_delay + weather_delay + national_aviation_sys_delay + security_delay + late_ac_arrival_delay) AS almost_total_delay
        FROM delay
        GROUP BY id) AS z
    GROUP BY id, date, origin, sched_departure, actual_departure, departure_delay, carrier_delay, weather_delay, national_aviation_sys_delay, security_delay, late_ac_arrival_delay, z.almost_total_delay) AS y
GROUP BY date, origin, sched_departure, actual_departure, departure_delay, carrier_delay, weather_delay, national_aviation_sys_delay, security_delay, late_ac_arrival_delay, y.late_ac_arrival_delay, y.almost_total_delay, y.neg_difference, y.pos_difference
ORDER BY total_delay DESC, late_ac_arrival_delay DESC
LIMIT 5;

-- 5. Median delay by category and base
SELECT RANK() OVER (ORDER BY total_mdn_dly DESC) AS top_mdn_dlyd_base_rank, *
FROM (SELECT origin,
        SUM(mdn_dept_dly + mdn_carrier_dly + mdn_weather_dly + mdn_atc_dly + mdn_security_dly + mdn_late_ac_dly) AS total_mdn_dly,
        mdn_dept_dly, mdn_carrier_dly, mdn_weather_dly, mdn_atc_dly, mdn_security_dly, mdn_late_ac_dly
    FROM (SELECT origin,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY departure_delay) FILTER(WHERE departure_delay > 0) AS mdn_dept_dly,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY carrier_delay) FILTER(WHERE carrier_delay <> 0) AS mdn_carrier_dly,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY weather_delay) FILTER(WHERE weather_delay <> 0) AS mdn_weather_dly,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY national_aviation_sys_delay) FILTER(WHERE national_aviation_sys_delay <> 0) AS mdn_atc_dly,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY security_delay) FILTER(WHERE security_delay <> 0) AS mdn_security_dly,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY late_ac_arrival_delay) FILTER(WHERE late_ac_arrival_delay <> 0) AS mdn_late_ac_dly
        FROM delay
        GROUP BY origin)
GROUP BY origin, mdn_dept_dly, mdn_carrier_dly, mdn_weather_dly, mdn_atc_dly, mdn_security_dly, mdn_late_ac_dly
ORDER BY total_mdn_dly DESC);

-- 6. Total delay by day of week
SELECT day_of_week, SUM(total_delay) AS total_delay_time
FROM (SELECT TO_CHAR(date, 'DAY') AS day_of_week,
        CASE
            WHEN departure_delay > 0 OR departure_delay > almost_total_delay THEN SUM(almost_total_delay + pos_difference)
            WHEN departure_delay < 0 OR departure_delay < almost_total_delay THEN SUM(almost_total_delay + neg_difference)
            ELSE 0
        END AS total_delay
    FROM (SELECT *, COALESCE(SUM(almost_total_delay - departure_delay) FILTER(WHERE departure_delay > 0), departure_delay) AS neg_difference,
            COALESCE(ABS(SUM(almost_total_delay - departure_delay) FILTER(WHERE departure_delay > 0)), ABS(departure_delay)) AS pos_difference
        FROM (SELECT date, id, origin, departure_delay, carrier_delay, weather_delay, national_aviation_sys_delay, security_delay, late_ac_arrival_delay,
                SUM(carrier_delay + weather_delay + national_aviation_sys_delay + security_delay + late_ac_arrival_delay) AS almost_total_delay
            FROM delay
            GROUP BY id) AS z
        GROUP BY date, id, origin, departure_delay, carrier_delay, weather_delay, national_aviation_sys_delay, security_delay, late_ac_arrival_delay, z.almost_total_delay) AS y
    GROUP BY day_of_week, id, origin, departure_delay, carrier_delay, weather_delay, national_aviation_sys_delay, security_delay, late_ac_arrival_delay, y.almost_total_delay, y.neg_difference, y.pos_difference)
GROUP BY day_of_week
ORDER BY total_delay_time DESC;

-- 7. Morning vs afternoon on-time performance
SELECT time_of_day,
    COUNT(*) AS total_flights,
    TO_CHAR(ROUND(100 * (COUNT(*) FILTER(WHERE departure_delay <= 0) / CAST(COUNT(*) AS numeric)), 2), '999D99%') AS on_time,
    TO_CHAR(ROUND(100 * (COUNT(*) FILTER(WHERE departure_delay > 0) / CAST(COUNT(*) AS numeric)), 2), '999D99%') AS delayed
FROM (SELECT *,
    CASE
        WHEN sched_departure < '12:00:00' THEN 'MORNING'
        WHEN sched_departure >= '12:00:00' THEN 'AFTERNOON'
        ELSE NULL
    END AS time_of_day
FROM delay)
GROUP BY time_of_day
ORDER BY total_flights ASC;

-- 8. Main controllable causes by time of day
SELECT time_of_day,
    COUNT(*) FILTER(WHERE departure_delay > 0) AS count_delayed_departures,
    TO_CHAR(100 * (COUNT(*) FILTER(WHERE carrier_delay > late_ac_arrival_delay)) / CAST(COUNT(*) FILTER(WHERE departure_delay > 0) AS NUMERIC), '999D99%') AS carrier_delayed,
    TO_CHAR(100 * (COUNT(*) FILTER(WHERE late_ac_arrival_delay > carrier_delay)) / CAST(COUNT(*) FILTER(WHERE departure_delay > 0) AS NUMERIC), '999D99%') AS late_ac_delayed,
    TO_CHAR(100 * (COUNT(*) FILTER(WHERE carrier_delay = 0 AND late_ac_arrival_delay = 0 AND departure_delay > 0)) / CAST(COUNT(*) FILTER(WHERE departure_delay > 0) AS NUMERIC), '999D99%') AS other_delayed
FROM (SELECT *,
    CASE
        WHEN sched_departure < '12:00:00' THEN 'MORNING'
        WHEN sched_departure >= '12:00:00' THEN 'AFTERNOON'
        ELSE NULL
    END AS time_of_day
FROM delay)
GROUP BY time_of_day
ORDER BY count_delayed_departures ASC;
