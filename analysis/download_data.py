"""Download the Olist public dataset (CSV files) into ./data.

Dataset: "Brazilian E-Commerce Public Dataset by Olist" (about 100k orders, 2016-2018),
released by Olist under CC BY-NC-SA 4.0. The raw files are not redistributed in this repo;
this script fetches them from a public mirror on the Hugging Face Hub.
"""

from __future__ import annotations

import urllib.request
from pathlib import Path

BASE = "https://huggingface.co/datasets/bulutttt/olist-raw-data/resolve/main"
FILES = [
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_customers_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv",
]


def main(data_dir: Path = Path("data")) -> None:
    data_dir.mkdir(exist_ok=True)
    for name in FILES:
        dest = data_dir / name
        if dest.exists():
            continue
        print(f"Downloading {name} ...")
        urllib.request.urlretrieve(f"{BASE}/{name}", dest)  # noqa: S310 (fixed https URL)
    print("Data ready in", data_dir.resolve())


if __name__ == "__main__":
    main()
