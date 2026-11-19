"""Run every SQL file in sql/ against the Olist CSVs and save each result to results/<name>.csv.

Usage:
    uv run python analysis/download_data.py   # once
    uv run python analysis/run.py
"""

from __future__ import annotations

import argparse
from pathlib import Path

import duckdb


def main() -> None:
    ap = argparse.ArgumentParser(description="Run the Olist SQL analysis.")
    ap.add_argument("--data-dir", type=Path, default=Path("data"))
    ap.add_argument("--sql-dir", type=Path, default=Path("sql"))
    ap.add_argument("--out-dir", type=Path, default=Path("results"))
    args = ap.parse_args()

    con = duckdb.connect()
    setup = (
        (args.sql_dir / "00_setup.sql").read_text().replace("{DATA}", str(args.data_dir.resolve()))
    )
    # Drop comment lines first so a ";" inside a comment doesn't split a statement.
    setup = "\n".join(ln for ln in setup.splitlines() if not ln.strip().startswith("--"))
    for statement in setup.split(";"):
        if statement.strip():
            con.execute(statement)

    args.out_dir.mkdir(exist_ok=True)
    for path in sorted(args.sql_dir.glob("[0-9][0-9]_*.sql")):
        if path.name.startswith("00_"):
            continue
        df = con.execute(path.read_text()).fetchdf()
        df.to_csv(args.out_dir / f"{path.stem}.csv", index=False)
        print(f"\n== {path.stem}")
        print(df.to_string(index=False))


if __name__ == "__main__":
    main()
