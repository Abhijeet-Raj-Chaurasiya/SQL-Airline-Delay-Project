-- Airline Delay Data Quality Checks

-- 1. Create the PostgreSQL table
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

-- 2. Identify irregular records
SELECT COUNT(*)
FROM delay
WHERE actual_flt_time = 0
   OR tail_number IS NULL
   OR taxi_out_time = 0;

-- 3. Review records selected for exclusion from analysis
SELECT *
FROM delay
WHERE actual_flt_time = 0
   OR tail_number IS NULL
   OR taxi_out_time = 0;

-- Expected imported row count from the project documentation: 1,546,452.
