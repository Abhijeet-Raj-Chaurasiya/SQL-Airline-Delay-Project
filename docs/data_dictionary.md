# Data Dictionary

The `delay` table contains the flight-level fields used throughout the analysis.

| Column | Type | Purpose |
|---|---|---|
| `id` | integer | Unique record identifier / primary key |
| `date` | date | Flight date |
| `flight_number` | varchar | Flight identifier |
| `tail_number` | varchar | Aircraft identifier; may be NULL in source data |
| `origin` | varchar | Four-character origin airport code |
| `destination` | varchar | Four-character destination airport code |
| `sched_departure` | time | Scheduled departure time |
| `actual_departure` | time | Actual departure time |
| `sched_flt_time` | integer | Scheduled flight duration in minutes |
| `actual_flt_time` | integer | Actual flight duration in minutes |
| `departure_delay` | integer | Recorded departure delay in minutes |
| `wheels_up_time` | time | Wheels-up time |
| `taxi_out_time` | integer | Taxi-out duration in minutes |
| `carrier_delay` | integer | Carrier-attributed delay in minutes |
| `weather_delay` | integer | Weather-attributed delay in minutes |
| `national_aviation_sys_delay` | integer | National aviation system / ATC delay in minutes |
| `security_delay` | integer | Security-attributed delay in minutes |
| `late_ac_arrival_delay` | integer | Delay attributed to a late-arriving aircraft in minutes |

## Analytical fields

The analysis primarily uses `departure_delay` to classify flights as on-time or delayed and uses the five categorized delay fields to understand delay composition:

- `carrier_delay`
- `weather_delay`
- `national_aviation_sys_delay`
- `security_delay`
- `late_ac_arrival_delay`

For the time-of-day analysis, scheduled departure before `12:00:00` is classified as **MORNING** and scheduled departure at or after `12:00:00` as **AFTERNOON**.

## Data-quality notes

The preparation workflow specifically checks for `actual_flt_time = 0`, missing `tail_number`, and `taxi_out_time = 0`. These records are documented as irregular records and are excluded from the analytical population while remaining in the source files for traceability.
