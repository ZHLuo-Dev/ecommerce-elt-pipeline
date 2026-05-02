# E-Commerce ELT Pipeline

An end-to-end ELT data pipeline built with **dbt** and **Snowflake**, transforming raw Brazilian e-commerce data into analytics-ready datasets.

## Architecture

```
Data Source (Kaggle/Olist)
        ↓
  Snowflake [RAW Schema]
  raw_orders, raw_customers, raw_products,
  raw_sellers, raw_reviews, raw_payments, raw_order_items
        ↓
  dbt [Staging Layer - Ephemeral]
  src_orders, src_customers, src_products,
  src_sellers, src_reviews, src_payments, src_order_items
        ↓
  dbt [Dimension Layer - Tables]
  dim_customers, dim_products, dim_sellers
        ↓
  dbt [Fact Layer - Incremental]
  fct_orders
        ↓
  dbt [Mart Layer - Tables]
  mart_seller_performance, mart_delivery_analysis, mart_product_category_performance
```

## Key Features

- **Modular ELT architecture**: Raw → Staging → Dimension → Fact → Mart
- **Incremental loading**: `fct_orders` processes only new records using timestamp-based incremental strategy
- **SCD Type 2 snapshots**: Tracks historical changes in seller data using check strategy
- **Data quality testing**: Generic tests (unique, not_null, relationships, accepted_values), singular tests, custom macros, and dbt-expectations
- **Surrogate keys**: Generated via `dbt_utils.generate_surrogate_key` for reliable record identification
- **Audit logging**: Automated audit trail via on-run-start hooks and post-hooks
- **Documentation**: Auto-generated docs with `dbt docs generate` including lineage graphs

## Key Analyses

- **Seller Performance**: Revenue, review scores, and delivery reliability per seller
- **Delivery Analysis**: Actual vs estimated delivery times and impact on customer satisfaction
- **Product Category Performance**: AOV, sales volume, review scores, and cancel rates across 70+ product categories

## Production Deployment

In a production environment, this pipeline would be orchestrated using **Apache Airflow**, with a daily scheduled DAG executing `dbt run`, `dbt test`, and `dbt snapshot` in sequence, with automated alerting on test failures.

## Tech Stack

- **Transformation**: dbt Core 1.11
- **Data Warehouse**: Snowflake
- **Testing**: dbt-utils, dbt-expectations
- **Version Control**: Git

## Setup

1. Clone this repository
2. Configure `profiles.yml` with your Snowflake credentials
3. Run `dbt deps` to install packages
4. Run `dbt seed` to load seed data
5. Run `dbt run` to build all models
6. Run `dbt test` to validate data quality
7. Run `dbt snapshot` to capture SCD changes
