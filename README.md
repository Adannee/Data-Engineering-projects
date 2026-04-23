# Olist E-commerce Analytics

An end to end analytics engineering project built on the modern data stack. Raw Brazilian e-commerce data ingested via two methods (Python and SQL) into Snowflake, transformed through three dbt modeling layers, and visualized in a 4 page Power BI dashboard.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Dataset](#dataset)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Ingestion Methods](#ingestion-methods)
- [Data Models](#data-models)
- [Dashboard](#dashboard)
- [Key Insights](#key-insights)
- [How to Reproduce](#how-to-reproduce)
- [Author](#author)

---

## Project Overview

This project demonstrates a complete analytics engineering workflow on the [Olist Brazilian E-commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), a real-world dataset of 100,000+ orders placed on Brazil's largest department store marketplace between 2016 and 2018.

The project is built in two rounds to demonstrate two different production ingestion patterns:

**Round 1: Python Ingestion**
Python reads CSVs, cleans them with pandas, and bulk loads into Snowflake using `snowflake-connector-python` and `write_pandas`.

**Round 2: SQL Ingestion**
Pure Snowflake native ingestion using internal stages, file formats, and `COPY INTO`. No Python involved.

The project answers four core business questions:

1. How is revenue trending over time and which states drive the most sales?
2. Which product categories perform best and what does demand look like across the catalog?
3. What does the customer base look like in terms of lifetime value and segmentation?
4. How is delivery performance tracking and where are the biggest delays?

---

## Architecture

### Round 1: Python Ingestion
```
Kaggle CSV Files (9 tables)
        |
        v
Python Ingestion Script
(snowflake-connector-python, pandas, write_pandas)
        |
        v
Snowflake RAW Schema
        |
        v
dbt Staging Layer (models/staging)
        |
        v
dbt Intermediate Layer (models/intermediate)
        |
        v
dbt Marts Layer (models/marts)
        |
        v
Power BI Service Dashboard
```

### Round 2: SQL Ingestion
```
Kaggle CSV Files (9 tables)
        |
        v
SnowSQL CLI PUT command
(upload to Snowflake Internal Stage)
        |
        v
COPY INTO command
(bulk load from stage into RAW_V2 tables)
        |
        v
dbt Staging Layer (models/staging_v2)
        |
        v
dbt Intermediate Layer (models/intermediate_v2)
        |
        v
dbt Marts Layer (models/marts_v2)
        |
        v
Power BI Service Dashboard
```

---

## Dataset

**Source:** [Olist Brazilian E-commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) via Kaggle

**9 source tables loaded into Snowflake:**

| Table | Description | Rows |
|---|---|---|
| ORDERS | Order header with status and timestamps | 99,441 |
| ORDER_ITEMS | Line items with product, seller, price | 112,650 |
| ORDER_PAYMENTS | Payment method and value per order | 103,886 |
| ORDER_REVIEWS | Customer review scores and comments | 99,224 |
| CUSTOMERS | Customer location data | 99,441 |
| PRODUCTS | Product attributes and dimensions | 32,951 |
| SELLERS | Seller location data | 3,095 |
| GEOLOCATION | Brazilian zip code coordinates | 1,000,163 |
| PRODUCT_CATEGORY_TRANSLATION | Portuguese to English category names | 71 |

---

## Tech Stack

| Layer | Tool |
|---|---|
| Ingestion Round 1 | Python, pandas, snowflake-connector-python |
| Ingestion Round 2 | SnowSQL CLI, Snowflake Internal Stage, COPY INTO |
| Storage | Snowflake |
| Transformation | dbt Cloud |
| Version Control | GitHub |
| Visualization | Power BI Service |

---

## Project Structure

```
ecommerce_analytics/
├── models/
│   ├── staging/                          # Round 1 staging models
│   │   ├── sources.yml
│   │   ├── stg_orders.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_order_payments.sql
│   │   ├── stg_order_reviews.sql
│   │   ├── stg_products.sql
│   │   ├── stg_sellers.sql
│   │   └── stg_product_category_translation.sql
│   ├── staging_v2/                       # Round 2 staging models
│   │   ├── sources.yml
│   │   ├── stg_v2_orders.sql
│   │   ├── stg_v2_customers.sql
│   │   ├── stg_v2_order_items.sql
│   │   ├── stg_v2_order_payments.sql
│   │   ├── stg_v2_order_reviews.sql
│   │   ├── stg_v2_products.sql
│   │   ├── stg_v2_sellers.sql
│   │   └── stg_v2_product_category_translation.sql
│   ├── intermediate/                     # Round 1 intermediate models
│   │   ├── int_orders_enriched.sql
│   │   └── int_products_enriched.sql
│   ├── intermediate_v2/                  # Round 2 intermediate models
│   │   ├── int_v2_orders_enriched.sql
│   │   └── int_v2_products_enriched.sql
│   ├── marts/                            # Round 1 mart models
│   │   ├── fct_orders.sql
│   │   ├── fct_product_performance.sql
│   │   ├── dim_customers.sql
│   │   └── schema.yml
│   └── marts_v2/                         # Round 2 mart models
│       ├── fct_v2_orders.sql
│       ├── fct_v2_product_performance.sql
│       ├── dim_v2_customers.sql
│       └── schema.yml
├── dbt_project.yml
├── load_to_snowflake.py
└── README.md
```

---

## Ingestion Methods

### Round 1: Python Ingestion

Uses `snowflake-connector-python` with `write_pandas` for bulk loading. Ideal when you need Python-based transformations before loading or integration with external APIs.

```python
from snowflake.connector.pandas_tools import write_pandas

success, nchunks, nrows, _ = write_pandas(
    conn=conn,
    df=df,
    table_name=table_name,
    database='ECOMMERCE_DB',
    schema='RAW'
)
```

**When to use Python ingestion:**
- Data requires pre-processing before loading
- Integrating with external APIs or non-file sources
- Embedding ingestion inside a larger Python orchestration workflow

### Round 2: SQL Ingestion via Snowflake Stages

Uses Snowflake native capabilities including internal stages, file formats, and `COPY INTO`. Common in enterprise Snowflake environments.

**Key concepts:**

| Concept | Purpose |
|---|---|
| `CREATE FILE FORMAT` | Defines how Snowflake parses the CSV files |
| `CREATE STAGE` | Creates a named internal storage location in Snowflake |
| `PUT` (SnowSQL) | Uploads local files to the stage with auto compression |
| `COPY INTO` | Bulk loads data from stage into tables at high speed |

```sql
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
  TYPE='CSV' FIELD_DELIMITER=',' SKIP_HEADER=1
  FIELD_OPTIONALLY_ENCLOSED_BY='"'
  NULL_IF=('NULL','null','')
  EMPTY_FIELD_AS_NULL=TRUE TRIM_SPACE=TRUE;

CREATE OR REPLACE STAGE OLIST_STAGE FILE_FORMAT=CSV_FORMAT;

PUT file:///path/to/file.csv @OLIST_STAGE AUTO_COMPRESS=TRUE;

COPY INTO ORDERS
  FROM @OLIST_STAGE/olist_orders_dataset.csv.gz
  FILE_FORMAT=CSV_FORMAT ON_ERROR='CONTINUE';
```

**When to use SQL ingestion:**
- Loading large volumes of files directly into Snowflake
- No Python environment available or preferred
- Enterprise teams using Snowflake as the primary data platform

---

## Data Models

### Staging Layer
Clean and rename raw source tables. One model per source table. No business logic at this layer.

| Model | Source Table | Purpose |
|---|---|---|
| stg_orders | ORDERS | Clean order headers, cast timestamps |
| stg_customers | CUSTOMERS | Clean customer location fields |
| stg_order_items | ORDER_ITEMS | Cast price and freight to float |
| stg_order_payments | ORDER_PAYMENTS | Cast payment values and types |
| stg_order_reviews | ORDER_REVIEWS | Clean review scores and timestamps |
| stg_products | PRODUCTS | Clean product dimensions and category |
| stg_sellers | SELLERS | Clean seller location fields |
| stg_product_category_translation | PRODUCT_CATEGORY_TRANSLATION | Map Portuguese to English category names |

### Intermediate Layer
Join and enrich staging models. Aggregations and business logic introduced here.

| Model | Description |
|---|---|
| int_orders_enriched | Joins orders, customers, items, payments, and reviews. Calculates actual and estimated delivery days. |
| int_products_enriched | Joins products with English category translations and aggregated order item metrics. |

### Marts Layer
Business ready models consumed directly by Power BI.

| Model | Type | Description |
|---|---|---|
| fct_orders | Fact | One row per order with delivery status flag (On Time, Late, Not Delivered) |
| fct_product_performance | Fact | One row per product with revenue, order count, and demand tier |
| dim_customers | Dimension | One row per unique customer with lifetime value and segment |

### dbt Tests
Applied to all mart models via schema.yml:

- fct_orders: order_id unique and not null, customer_id not null, order_status not null
- fct_product_performance: product_id unique and not null
- dim_customers: customer_unique_id unique and not null

---

## Dashboard

Built in Power BI Service with 4 report pages connected to Snowflake.

**Page 1: Revenue Overview**
- Total revenue (16.01M BRL), total orders (99.4K), average order value (160.99 BRL)
- Revenue trend line chart by month
- Revenue by customer state bar chart

**Page 2: Product Performance**
- Total product revenue (13.59M BRL)
- Top 10 product categories by revenue
- Demand tier breakdown (83.6% Low, 9.45% High, 6.95% Medium)
- Average price by product category

**Page 3: Customer Analysis**
- Total unique customers (96K), average lifetime value (172.64 BRL)
- Customer segments (94.92% Low Value, 3.72% High Value)
- Top 10 states by customer count

**Page 4: Delivery Performance**
- Average actual delivery (12.50 days) vs estimated (24.40 days)
- Delivery status (90.45% On Time, 6.57% Late, 2.98% Not Delivered)
- Average delivery days by state

---

## Key Insights

1. **Olist significantly over-promises on delivery.** Estimated delivery averages 24.4 days but actual delivery averages 12.5 days, nearly half. This drives positive customer satisfaction.

2. **São Paulo dominates the customer base** by a wide margin, followed by RJ and MG. Marketing and logistics investments should be weighted accordingly.

3. **Health and beauty leads all product categories** by revenue, followed by watches and gifts, and bed, bath and table.

4. **83.6% of products are in the Low Demand tier,** confirming a classic long tail catalog where a small percentage of SKUs drive the majority of volume.

5. **94.92% of customers are Low Value** with lifetime value below 500 BRL. Significant upside exists in developing retention and upsell strategies for mid and high value segments.

6. **Northern states (RR, AP, AM) have the longest delivery times,** averaging close to 30 days versus southern states under 10 days. A clear logistics gap exists across regions.

---

## How to Reproduce

### Prerequisites
- Snowflake account (free trial at snowflake.com)
- dbt Cloud account (free developer account at cloud.getdbt.com)
- SnowSQL CLI installed (download at developers.snowflake.com/snowsql)
- Python 3.8 or higher (Round 1 only)
- Kaggle account to download the dataset

### Snowflake Setup

```sql
CREATE WAREHOUSE IF NOT EXISTS DEV_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

CREATE DATABASE IF NOT EXISTS ECOMMERCE_DB;
CREATE SCHEMA IF NOT EXISTS ECOMMERCE_DB.RAW;
CREATE SCHEMA IF NOT EXISTS ECOMMERCE_DB.RAW_V2;

CREATE ROLE IF NOT EXISTS DBT_ROLE;
CREATE USER IF NOT EXISTS DBT_USER
  PASSWORD = 'YourPassword'
  DEFAULT_ROLE = DBT_ROLE
  DEFAULT_WAREHOUSE = DEV_WH;

GRANT ROLE DBT_ROLE TO USER DBT_USER;
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE DBT_ROLE;
GRANT ALL ON DATABASE ECOMMERCE_DB TO ROLE DBT_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE ECOMMERCE_DB TO ROLE DBT_ROLE;
```

### Round 1: Python Ingestion

```bash
pip install pandas "snowflake-connector-python[pandas]"
python load_to_snowflake.py
```

### Round 2: SQL Ingestion

```sql
CREATE OR REPLACE FILE FORMAT ECOMMERCE_DB.RAW_V2.CSV_FORMAT
  TYPE='CSV' FIELD_DELIMITER=',' SKIP_HEADER=1
  FIELD_OPTIONALLY_ENCLOSED_BY='"' NULL_IF=('NULL','null','')
  EMPTY_FIELD_AS_NULL=TRUE TRIM_SPACE=TRUE;

CREATE OR REPLACE STAGE ECOMMERCE_DB.RAW_V2.OLIST_STAGE
  FILE_FORMAT=ECOMMERCE_DB.RAW_V2.CSV_FORMAT;
```

```bash
snowsql -a your_account -u DBT_USER
USE WAREHOUSE DEV_WH;
USE DATABASE ECOMMERCE_DB;
USE SCHEMA RAW_V2;

PUT file:///path/to/olist_orders_dataset.csv @OLIST_STAGE AUTO_COMPRESS=TRUE;
```

```sql
COPY INTO ORDERS
  FROM @OLIST_STAGE/olist_orders_dataset.csv.gz
  FILE_FORMAT=CSV_FORMAT ON_ERROR='CONTINUE';
```

### dbt Setup

1. Create a free account at [cloud.getdbt.com](https://cloud.getdbt.com)
2. Connect to Snowflake using DBT_USER credentials
3. Connect your GitHub repository
4. Set development credentials: schema = STAGING, target = dev, threads = 4
5. Run:

```bash
dbt build
```

---

## Author

**Ivy Chisom Adiele Khalid**
Data Analyst and Analytics Engineer, Lagos Nigeria
Founder of DatumStack

- Portfolio: [adannee.github.io/IvyAdiele.github.io](https://adannee.github.io/IvyAdiele.github.io)
- LinkedIn: [linkedin.com/in/ivy-khalid](https://linkedin.com/in/ivy-khalid)
- GitHub: [github.com/Adannee](https://github.com/Adannee)
- DatumStack: [@datumstack\_](https://www.linkedin.com/company/datumstack_)
