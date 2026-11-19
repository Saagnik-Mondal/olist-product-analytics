"""Impact sizing and experiment planning, computed from the SQL results.

Nothing here is invented: every input is read from results/*.csv. The outputs are written to
results/sizing.md. These are association-based estimates, not causal claims.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path
from statistics import NormalDist

import pandas as pd

N = NormalDist()


def n_per_arm(p_base: float, mde_abs: float, alpha: float = 0.05, power: float = 0.8) -> int:
    """Sample size per arm for a two-sided two-proportion z-test (normal approximation)."""
    p2 = p_base + mde_abs
    p_bar = (p_base + p2) / 2
    z_a, z_b = N.inv_cdf(1 - alpha / 2), N.inv_cdf(power)
    num = (
        z_a * math.sqrt(2 * p_bar * (1 - p_bar))
        + z_b * math.sqrt(p_base * (1 - p_base) + p2 * (1 - p2))
    ) ** 2
    return math.ceil(num / mde_abs**2)


def two_prop_ztest(x1: int, n1: int, x2: int, n2: int) -> tuple[float, float, tuple[float, float]]:
    """Returns (difference p1-p2, two-sided p-value, 95% CI of the difference)."""
    p1, p2 = x1 / n1, x2 / n2
    pooled = (x1 + x2) / (n1 + n2)
    se0 = math.sqrt(pooled * (1 - pooled) * (1 / n1 + 1 / n2))
    z = (p1 - p2) / se0
    p_value = 2 * (1 - N.cdf(abs(z)))
    se = math.sqrt(p1 * (1 - p1) / n1 + p2 * (1 - p2) / n2)
    return p1 - p2, p_value, (p1 - p2 - 1.96 * se, p1 - p2 + 1.96 * se)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--results", type=Path, default=Path("results"))
    args = ap.parse_args()
    r = args.results

    attr = pd.read_csv(r / "14_low_review_attribution.csv").iloc[0]
    reviewed = float(attr["reviewed_delivered_orders"])
    late_share = float(attr["pct_of_all_orders_late"]) / 100
    late_n = reviewed * late_share
    low_late = float(attr["low_review_and_late"]) / late_n
    low_on_time = (float(attr["low_review_orders"]) - float(attr["low_review_and_late"])) / (
        reviewed - late_n
    )
    low_all = float(attr["low_review_orders"]) / reviewed
    avg_all, avg_on, avg_late = (
        float(attr[k]) for k in ("avg_review_all", "avg_review_on_time", "avg_review_late")
    )

    # --- what if late deliveries were cut in half (association-based upper bound)
    new_late = late_share / 2
    moved = late_share - new_late
    avg_new = avg_all + moved * (avg_on - avg_late)
    low_new = low_all - moved * (low_late - low_on_time)

    # --- repeat purchase: first delivery late vs on time
    rep = pd.read_csv(r / "07_repeat_by_first_delivery.csv").set_index("first_delivery")
    on, lt = rep.loc["first order on time"], rep.loc["first order late"]
    diff, p_val, ci = two_prop_ztest(
        int(on.repeat_customers),
        int(on.new_customers),
        int(lt.repeat_customers),
        int(lt.new_customers),
    )

    # --- experiment planning
    growth = pd.read_csv(r / "01_growth.csv")
    monthly_orders = float(growth[growth["month"] >= "2018-01"]["orders"].mean())
    ns = pd.read_csv(r / "13_north_star.csv")
    ns18 = ns[ns["month"] >= "2018-01"]
    happy_base = (
        float(
            (ns18["happy_order_pct"] * ns18["reviewed_orders"]).sum()
            / ns18["reviewed_orders"].sum()
        )
        / 100
    )
    n_late = n_per_arm(low_late, -0.05)
    n_all = n_per_arm(happy_base, 0.02)
    months_late = 2 * n_late / (monthly_orders * late_share)
    months_all = 2 * n_all / monthly_orders

    md = f"""# Impact sizing and experiment plan

All inputs come from the SQL results in this folder. These are associations in observational data,
not proof of cause, so treat the estimates as upper bounds.

## 1. How much of the dissatisfaction is lateness?

- Late orders are **{late_share:.1%}** of delivered orders but **{attr["pct_of_low_reviews_that_were_late"]:.1f}%** of all 1-2 star reviews.
- Average review: **{avg_on:.2f}** on time vs **{avg_late:.2f}** late.
- Share rated 1-2 stars: **{low_on_time:.1%}** on time vs **{low_late:.1%}** late.

## 2. What if late deliveries were cut in half?

If half of today's late orders were delivered on time and then behaved like other on-time orders:

| | Today | After |
|---|---:|---:|
| Late deliveries | {late_share:.1%} | {new_late:.1%} |
| Average review | {avg_all:.2f} | {avg_new:.2f} |
| Orders rated 1-2 stars | {low_all:.1%} | {low_new:.1%} |

That is a {(low_all - low_new) / low_all:.0%} relative drop in 1-2 star reviews. It is an upper bound: late orders may also differ in other ways (bulky items, remote regions).

## 3. Does a late first delivery reduce repeat purchase?

New customers who ordered by 2018-02-28, repeat within 180 days:

- First order on time: **{on.repeat_within_180d_pct:.2f}%** ({int(on.repeat_customers):,} of {int(on.new_customers):,})
- First order late: **{lt.repeat_within_180d_pct:.2f}%** ({int(lt.repeat_customers):,} of {int(lt.new_customers):,})
- Difference: **{diff * 100:+.2f} percentage points** (95% CI {ci[0] * 100:+.2f} to {ci[1] * 100:+.2f}), two-sided p = **{p_val:.2f}**.

{"The difference is not statistically significant at the 5% level, so this data cannot confirm that lateness drives churn. Only about 3% of customers return either way, so low repeat purchase looks like a separate problem." if p_val >= 0.05 else "The difference is statistically significant at the 5% level."}

## 4. Experiment sizing (80% power, 5% significance, two-sided)

| Experiment | Baseline | Detectable change | Orders per arm | Total | Time at 2018 volume |
|---|---:|---:|---:|---:|---:|
| Proactive delay message, judged on late orders only (1-2 star rate) | {low_late:.1%} | -5 points | {n_late:,} | {2 * n_late:,} | about {months_late:.0f} months |
| Delivery change on all orders, judged on happy order rate | {happy_base:.1%} | +2 points | {n_all:,} | {2 * n_all:,} | about {months_all:.1f} months |

Average 2018 volume (Jan-Aug): about {monthly_orders:,.0f} orders per month, with about {late_share:.0%} of them late. Testing a change on late orders alone is too slow; randomize all orders in the affected states and judge it on the happy order rate instead.
"""
    (r / "sizing.md").write_text(md)
    print(md)


if __name__ == "__main__":
    main()
