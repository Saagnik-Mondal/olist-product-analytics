# Impact sizing and experiment plan

All inputs come from the SQL results in this folder. These are associations in observational data,
not proof of cause, so treat the estimates as upper bounds.

## 1. How much of the dissatisfaction is lateness?

- Late orders are **8.0%** of delivered orders but **33.8%** of all 1-2 star reviews.
- Average review: **4.29** on time vs **2.57** late.
- Share rated 1-2 stars: **9.2%** on time vs **54.0%** late.

## 2. What if late deliveries were cut in half?

If half of today's late orders were delivered on time and then behaved like other on-time orders:

| | Today | After |
|---|---:|---:|
| Late deliveries | 8.0% | 4.0% |
| Average review | 4.16 | 4.23 |
| Orders rated 1-2 stars | 12.8% | 11.0% |

That is a 14% relative drop in 1-2 star reviews. It is an upper bound: late orders may also differ in other ways (bulky items, remote regions).

## 3. Does a late first delivery reduce repeat purchase?

New customers who ordered by 2018-02-28, repeat within 180 days:

- First order on time: **3.18%** (1,622 of 51,012)
- First order late: **2.70%** (113 of 4,184)
- Difference: **+0.48 percentage points** (95% CI -0.04 to +0.99), two-sided p = **0.09**.

The difference is not statistically significant at the 5% level, so this data cannot confirm that lateness drives churn. Only about 3% of customers return either way, so low repeat purchase looks like a separate problem.

## 4. Experiment sizing (80% power, 5% significance, two-sided)

| Experiment | Baseline | Detectable change | Orders per arm | Total | Time at 2018 volume |
|---|---:|---:|---:|---:|---:|
| Proactive delay message, judged on late orders only (1-2 star rate) | 54.0% | -5 points | 1,568 | 3,136 | about 6 months |
| Delivery change on all orders, judged on happy order rate | 75.1% | +2 points | 7,135 | 14,270 | about 2.1 months |

Average 2018 volume (Jan-Aug): about 6,691 orders per month, with about 8% of them late. Testing a change on late orders alone is too slow; randomize all orders in the affected states and judge it on the happy order rate instead.
