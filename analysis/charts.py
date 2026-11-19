"""Draw the charts used in the report from the CSVs in results/."""

from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

BLUE, RED, GREY = "#2f5bea", "#d64545", "#8a8a85"


def style(ax) -> None:
    ax.spines[["top", "right"]].set_visible(False)
    ax.tick_params(labelsize=8)


def growth(res: Path, out: Path) -> None:
    df = pd.read_csv(res / "01_growth.csv")
    fig, (a, b) = plt.subplots(1, 2, figsize=(10, 3.6))
    a.bar(df["month"], df["orders"], color=BLUE)
    a.set_title("Orders per month", fontsize=10, loc="left")
    b.plot(df["month"], df["gmv_brl"] / 1e6, color=BLUE, marker="o", ms=3)
    b.set_title("GMV per month (million BRL, item value)", fontsize=10, loc="left")
    b.set_ylim(0)
    for ax in (a, b):
        style(ax)
        ax.set_xticks(range(0, len(df), 3), df["month"][::3], rotation=0)
    fig.tight_layout()
    fig.savefig(out / "01_growth.png", dpi=160)
    plt.close(fig)


def delay_vs_reviews(res: Path, out: Path) -> None:
    df = pd.read_csv(res / "05_review_by_delay.csv")
    labels = [s.split(") ", 1)[1] for s in df["delivery_vs_promise"]]
    colors = [BLUE, BLUE, "#e8a33d", RED, RED, RED]
    fig, ax = plt.subplots(figsize=(8.5, 4))
    bars = ax.bar(labels, df["pct_1_2_stars"], color=colors)
    for bar, v, avg in zip(bars, df["pct_1_2_stars"], df["avg_review"], strict=True):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            v + 1.5,
            f"{v:.0f}%\navg {avg:.2f}",
            ha="center",
            fontsize=8,
        )
    ax.set_ylim(0, 100)
    ax.set_ylabel("Orders rated 1-2 stars (%)", fontsize=9)
    ax.set_title(
        "Satisfaction falls off a cliff once an order is 4+ days late", fontsize=11, loc="left"
    )
    style(ax)
    plt.setp(ax.get_xticklabels(), fontsize=8)
    fig.tight_layout()
    fig.savefig(out / "02_delay_vs_reviews.png", dpi=160)
    plt.close(fig)


def late_by_state(res: Path, out: Path) -> None:
    df = pd.read_csv(res / "06_late_by_state.csv").sort_values("late_pct")
    stages = pd.read_csv(res / "03_stage_times.csv")
    avg = round(
        100 * stages.loc[stages["delivery"] == "late", "orders"].sum() / stages["orders"].sum(), 1
    )
    fig, ax = plt.subplots(figsize=(7, 5))
    ax.barh(df["state"], df["late_pct"], color=[RED if v > avg else BLUE for v in df["late_pct"]])
    ax.axvline(avg, ls="--", color=GREY, label=f"all delivered orders: {avg}%")
    ax.legend(frameon=False, fontsize=8, loc="lower right")
    for y, (v, n) in enumerate(zip(df["late_pct"], df["delivered_orders"], strict=True)):
        ax.text(v + 0.2, y, f"{v:.1f}%  ({n:,} orders)", va="center", fontsize=7)
    ax.set_xlim(0, 26)
    ax.set_xlabel("Late deliveries (%)", fontsize=9)
    ax.set_title("Late-delivery rate by customer state", fontsize=11, loc="left")
    style(ax)
    fig.tight_layout()
    fig.savefig(out / "03_late_by_state.png", dpi=160)
    plt.close(fig)


def north_star(res: Path, out: Path) -> None:
    df = pd.read_csv(res / "13_north_star.csv")
    fig, ax = plt.subplots(figsize=(9, 3.8))
    ax.plot(
        df["month"], df["happy_order_pct"], color=BLUE, marker="o", ms=4, label="Happy order rate"
    )
    ax.plot(df["month"], df["late_pct"], color=RED, marker="o", ms=4, label="Late deliveries")
    ax.set_ylim(0, 100)
    ax.set_ylabel("% of reviewed delivered orders", fontsize=9)
    ax.set_title(
        "Happy order rate (on time and 4-5 stars), by month of purchase", fontsize=11, loc="left"
    )
    ax.set_xticks(range(0, len(df), 2), df["month"][::2])
    ax.legend(frameon=False, fontsize=8, loc="center right")
    style(ax)
    fig.tight_layout()
    fig.savefig(out / "04_north_star.png", dpi=160)
    plt.close(fig)


def seller_concentration(res: Path, out: Path) -> None:
    df = pd.read_csv(res / "10_seller_concentration.csv")
    fig, ax = plt.subplots(figsize=(7, 3.8))
    ax.bar(df["decile"], df["pct_of_gmv"], color=BLUE)
    for x, v in zip(df["decile"], df["pct_of_gmv"], strict=True):
        ax.text(x, v + 1, f"{v:.0f}%", ha="center", fontsize=8)
    ax.set_xticks(df["decile"])
    ax.set_xlabel("Seller decile (1 = top 10% of sellers by GMV)", fontsize=9)
    ax.set_ylabel("Share of GMV (%)", fontsize=9)
    ax.set_title("The top 10% of sellers bring in two thirds of GMV", fontsize=11, loc="left")
    style(ax)
    fig.tight_layout()
    fig.savefig(out / "05_seller_concentration.png", dpi=160)
    plt.close(fig)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--results", type=Path, default=Path("results"))
    ap.add_argument("--out", type=Path, default=Path("charts"))
    args = ap.parse_args()
    args.out.mkdir(exist_ok=True)
    for fn in (growth, delay_vs_reviews, late_by_state, north_star, seller_concentration):
        fn(args.results, args.out)
    print("Charts written to", args.out)


if __name__ == "__main__":
    main()
