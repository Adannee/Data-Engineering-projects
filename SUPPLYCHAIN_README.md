# Supply Chain Analytics

An end to end analytics engineering project built on the modern data stack. Raw DataCo supply chain data ingested via Python into Snowflake, transformed through three dbt modeling layers with shipping performance, profitability, and delivery risk logic, and visualized in a 4 page Power BI dashboard.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Dataset](#dataset)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Derived Metrics](#derived-metrics)
- [Dashboard](#dashboard)
- [Key Insights](#key-insights)
- [How to Reproduce](#how-to-reproduce)
- [Author](#author)

---

## Project Overview

This project demonstrates a complete analytics engineering workflow on the DataCo Smart Supply Chain dataset covering 180,519 order line items across multiple markets, regions, product categories, and customer segments. The project builds shipping performance logic, profitability tiers, and delivery risk classifications entirely in dbt.

The project answers five core business questions:

1. What is total revenue and profit across markets and how is it trending?
2. How is delivery performance tracking and where are the biggest delays?
3. Which product categories and departments drive the most revenue?
4. What does the customer base look like in terms of value tier and segment?
5. Which shipping modes and regions have the worst late delivery rates?

---

## Architecture

```
Kaggle CSV File (180,519 rows, 53 columns)
        |
        v
Python Ingestion Script
(snowflake-connector-python, pandas, chunked write_pandas)
        |
        v
Snowflake SUPPLYCHAIN_DB.RAW
        |
        v
dbt Staging Layer
(clean, rename, fix timestamp formats with TRY_TO_TIMESTAMP)
        |
        v
dbt Intermediate Layer
(shipping delay, late flags, performance tiers,
profitability tiers, discount tiers, date dimensions)
        |
        v
dbt Marts Layer
(fct_sc_orders, dim_sc_products, dim_sc_customers)
        |
        v
Power BI Service Dashboard
(4 pages, 18+ visuals)
```

---

## Dataset

**Source:** [DataCo Smart Supply Chain for Big Data Analysis](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) via Kaggle

**1 source table loaded into Snowflake SUPPLYCHAIN_DB.RAW:**

| Column | Description |
|---|---|
| ORDER_ID | Unique order identifier |
| ORDER_ITEM_ID | Unique order line item identifier |
| ORDER_DATE | Date order was placed |
| SHIPPING_DATE | Date order was shipped |
| DAYS_FOR_SHIPPING_REAL | Actual shipping days |
| DAYS_FOR_SHIPMENT_SCHEDULED | Scheduled shipping days |
| LATE_DELIVERY_RISK | Binary late delivery risk flag |
| DELIVERY_STATUS | Delivery status label |
| SHIPPING_MODE | First Class, Second Class, Standard Class, Same Day |
| CATEGORY_NAME | Product category |
| DEPARTMENT_NAME | Department name |
| PRODUCT_NAME | Product name |
| PRODUCT_PRICE | Product price |
| CUSTOMER_SEGMENT | Consumer, Corporate, Home Office |
| MARKET | Europe, LATAM, Pacific Asia, USCA, Africa |
| ORDER_REGION | Geographic region |
| SALES | Order line item sales value |
| ORDER_PROFIT_PER_ORDER | Profit per order |
| ORDER_ITEM_PROFIT_RATIO | Profit margin ratio |
| ORDER_ITEM_DISCOUNT_RATE | Discount rate applied |
| ORDER_ITEM_QUANTITY | Quantity ordered |

**Total rows:** 180,519
**Columns after PII removal:** 44

---

## Tech Stack

| Layer | Tool |
|---|---|
| Ingestion | Python, pandas, snowflake-connector-python (chunked loading) |
| Storage | Snowflake |
| Transformation | dbt Cloud |
| Version Control | GitHub |
| Visualization | Power BI Service |

---

## Project Structure

```
supplychain_analytics/
├── models/
│   └── supplychain/
│       ├── staging/
│       │   ├── sources.yml
│       │   └── stg_supply_chain.sql
│       ├── intermediate/
│       │   └── int_supply_chain_enriched.sql
│       └── marts/
│           ├── fct_sc_orders.sql
│           ├── dim_sc_products.sql
│           ├── dim_sc_customers.sql
│           └── schema.yml
├── dbt_project.yml
├── load_supplychain_to_snowflake.py
└── README.md
```

---

## Data Models

### Staging Layer
Cleans and renames the raw source table. Drops PII columns, fixes CamelCase column names, and uses `TRY_TO_TIMESTAMP` to safely parse the non-standard date format `MM/DD/YYYY HH24:MI`.

| Model | Source Table | Purpose |
|---|---|---|
| stg_supply_chain | SUPPLY_CHAIN | Clean column names, parse dates, cast types, drop PII |

### Intermediate Layer
Derives all shipping performance logic, profitability tiers, and date dimensions.

| Model | Description |
|---|---|
| int_supply_chain_enriched | Calculates shipping delay days, late delivery flag, shipping performance tier, order size tier, profitability tier, discount tier, and full date dimensions |

### Marts Layer
Business ready models consumed directly by Power BI.

| Model | Type | Description |
|---|---|---|
| fct_sc_orders | Fact | One row per order line item with all enriched metrics and performance flags |
| dim_sc_products | Dimension | One row per product with aggregated revenue, profit, units sold, and late delivery rate |
| dim_sc_customers | Dimension | One row per customer with total spend, order count, avg order value, and customer value tier |

### dbt Tests
Applied to mart models via schema.yml:

- fct_sc_orders: order_item_id unique and not null, order_id not null, order_date not null
- dim_sc_products: product_id unique and not null
- dim_sc_customers: customer_id unique and not null

---

## Derived Metrics

All metrics are derived in the intermediate layer using dbt:

| Metric | Logic | Purpose |
|---|---|---|
| Shipping Delay Days | days_shipping_actual minus days_shipping_scheduled | Measures how late a shipment is |
| Is Late | actual > scheduled | Binary flag for late delivery |
| Shipping Performance | On Time, Slightly Late (<=2 days), Significantly Late | Shipping tier classification |
| Order Size Tier | Large (>=500), Medium (>=200), Small | Order value classification |
| Profitability Tier | High Margin (>=0.2), Mid Margin (>=0.1), Low Margin (>=0), Loss Making | Margin classification |
| Discount Tier | High (>=0.2), Mid (>=0.1), Low | Discount level classification |
| Customer Value Tier | High (>=10K), Mid (>=5K), Low | Customer lifetime value classification |

---

## Dashboard

Built in Power BI Service with 4 report pages connected to Snowflake SUPPLYCHAIN_DB.MARTS.

**Page 1: Order Overview**
- Total orders (65.752K), total revenue (36.78M), total profit (3.97M)
- Revenue trend over time showing steady performance around 3M per month
- Revenue by market (Europe leads, followed by LATAM and Pacific Asia)

**Page 2: Delivery Performance**
- Shipping performance breakdown (49.55% On Time, 42.67% Significantly Late, 7.78% Slightly Late)
- Avg shipping delay by region (Central Asia has longest delays)
- Late deliveries by shipping mode (Standard Class worst, Same Day best)
- Late delivery trend over time (improving through the year)

**Page 3: Product Performance**
- Total products (118), orders by profitability tier (47.8% High Margin, 14.88% Loss Making)
- Top 10 categories by revenue (Fishing leads)
- Top 10 products by revenue
- Avg profit margin by department (Technology leads)

**Page 4: Customer Analysis**
- Total customers (20.652K), avg order value (238.35)
- Customer value tier (95.24% Low Value, 4.75% Mid Value, 0.98% High Value)
- Revenue by customer segment (Consumer dominates)
- Top countries by revenue (EE.UU leads)
- Revenue by order size tier (Medium and Small orders dominate)

---

## Key Insights

1. **Over 50% of deliveries are late** with 42.67% classified as Significantly Late. This is a critical operational issue requiring immediate attention to carrier selection, routing, and fulfillment processes.

2. **Europe is the largest market** by revenue, followed by LATAM and Pacific Asia. Africa is the smallest market with significant growth potential.

3. **Standard Class shipping has the highest late delivery rate** while Same Day performs best. Shifting volume toward faster shipping modes could significantly improve customer satisfaction.

4. **14.88% of orders are loss making** despite 47.8% being High Margin. The loss making segment needs immediate investigation into discount policies and product pricing.

5. **95.24% of customers are Low Value** with total spend below 5K. There is significant upside in developing loyalty and retention programs to move customers into higher value tiers.

6. **Consumer segment dominates revenue** far ahead of Corporate and Home Office segments. B2C focus appears to be the core revenue driver.

7. **Central Asia has the longest average shipping delays** suggesting logistics infrastructure gaps in that region that could be addressed through regional warehouse placement or carrier diversification.

---

## How to Reproduce

### Prerequisites
- Snowflake account (free trial at snowflake.com)
- dbt Cloud account (free developer account at cloud.getdbt.com)
- Python 3.8 or higher
- Kaggle account to download the dataset

### Snowflake Setup

```sql
CREATE DATABASE IF NOT EXISTS SUPPLYCHAIN_DB;
CREATE SCHEMA IF NOT EXISTS SUPPLYCHAIN_DB.RAW;
CREATE SCHEMA IF NOT EXISTS SUPPLYCHAIN_DB.STAGING;
CREATE SCHEMA IF NOT EXISTS SUPPLYCHAIN_DB.INTERMEDIATE;
CREATE SCHEMA IF NOT EXISTS SUPPLYCHAIN_DB.MARTS;

GRANT ALL ON DATABASE SUPPLYCHAIN_DB TO ROLE DBT_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE SUPPLYCHAIN_DB TO ROLE DBT_ROLE;
```

### Python Ingestion

```bash
pip install pandas "snowflake-connector-python[pandas]"
python3 load_supplychain_to_snowflake.py
```

Note: The dataset is 180K+ rows. The ingestion script uses chunked loading in batches of 50,000 rows to avoid network timeout errors.

### dbt Setup

1. Add supplychain models to your existing dbt project
2. Update `dbt_project.yml` to include the supplychain folder pointing to SUPPLYCHAIN_DB
3. Add the `generate_database_name` macro to ensure models build into the correct database
4. Run:

```bash
dbt build --select supplychain
```

### Power BI

1. Open Power BI Service at app.powerbi.com
2. Create a new report and connect to Snowflake using the full server URL including region
3. Select SUPPLYCHAIN_DB and the MARTS schema
4. Load fct_sc_orders, dim_sc_products, and dim_sc_customers
5. Build the 4 page dashboard following the structure above

---

## Author

**Ivy Chisom Adiele Khalid**
Data Analyst and Analytics Engineer, Lagos Nigeria
Founder of DatumStack

- Portfolio: [adannee.github.io/IvyAdiele.github.io](https://adannee.github.io/IvyAdiele.github.io)
- LinkedIn: [linkedin.com/in/ivy-khalid](https://linkedin.com/in/ivy-khalid)
- GitHub: [github.com/Adannee](https://github.com/Adannee)
- DatumStack: [@datumstack\_](https://www.linkedin.com/company/datumstack_)
