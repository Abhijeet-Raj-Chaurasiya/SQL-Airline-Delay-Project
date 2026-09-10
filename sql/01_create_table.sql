-- SQL Airline Delay Analysis
-- PostgreSQL schema

CREATE TABLE IF NOT EXISTS delay (
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
    national_aviation_sys_delay INTEGER NOT NULL,
    security_delay INTEGER NOT NULL,
    late_ac_arrival_delay INTEGER NOT NULL
);

-- Expected source fields: BTS American Airlines departure statistics, 2022-2024.
-- tail_number intentionally permits NULL because the source contains missing values.
