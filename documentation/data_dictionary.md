# Data Dictionary

The project analyzes American Airlines departure records sourced from the U.S. Bureau of Transportation Statistics (BTS).

| Column | Type | Description |
|---|---|---|
| `id` | integer | Unique record identifier / primary key |
| `date` | date | Flight operating date |
| `flight_number` | varchar | Flight identifier |
| `tail_number` | varchar | Aircraft registration identifier |
| `origin` | varchar | Origin airport code |
| `destination` | varchar | Destination airport code |
| `sched_departure` | time | Scheduled departure time |
| `actual_departure` | time | Actual departure time |
| `sched_flt_time` | integer | Scheduled flight duration |
| `actual_flt_time` | integer | Actual flight duration |
| `departure_delay` | integer | Departure delay in minutes; negative values represent early departure |
| `wheels_up_time` | time | Wheels-up time |
| `taxi_out_time` | integer | Taxi-out duration in minutes |
| `carrier_delay` | integer | Carrier/airline-controlled delay |
| `weather_delay` | integer | Weather-related delay |
| `national_aviation_sys_delay` | integer | National aviation system / ATC-related delay |
| `security_delay` | integer | Security-related delay |
| `late_ac_arrival_delay` | integer | Delay caused by late arrival of the aircraft from its previous flight |

## Analytical scope

The reference analysis focuses on American Airlines operations at major hubs including DFW, CLT, MIA, PHX, ORD, PHL, LAX, DCA, and JFK. The dataset covers 2022–2024.
