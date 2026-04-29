# Fintech Transaction Monitoring

An end to end analytics engineering project built on the modern data stack. Raw bank transaction data ingested via Python into Snowflake, transformed through three dbt modeling layers with custom fraud flagging logic and risk tiering, and visualized in a 4 page Power BI dashboard.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Dataset](#dataset)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Fraud Detection Logic](#fraud-detection-logic)
- [Dashboard](#dashboard)
- [Key Insights](#key-insights)
- [How to Reproduce](#how-to-reproduce)
- [Author](#author)

---

## Project Overview

This project demonstrates a complete analytics engineering workflow on a bank transaction dataset covering 2,512 transactions across 495 accounts and 100 merchants. The project builds custom fraud detection logic entirely in dbt without any pre-labeled fraud column, deriving fraud flags from behavioral patterns in the data.

The project answers five core business questions:

1. What is the total transaction volume and how is it trending over time?
2. Which transactions exhibit fraud risk patterns and why?
3. How are accounts distributed across risk tiers?
4. Which customer segments and age groups transact the most?
5. Which merchants have the highest revenue and fraud exposure?

---

## Architecture

```
Kaggle CSV File (2,512 rows)
        |
        v
Python Ingestion Script
(snowflake-connector-python, pandas, write_pandas)
        |
        v
Snowflake FINTECH_DB.RAW
        |
        v
dbt Staging Layer
(clean, rename, cast, fix CamelCase column names)
        |
        v
dbt Intermediate Layer
(fraud flagging, risk tiering, age grouping,
transaction size classification, time gap analysis)
        |
        v
dbt Marts Layer
(fct_transactions, dim_accounts, dim_merchants)
        |
        v
Power BI Service Dashboard
(4 pages, 15+ visuals)
```

---

## Dataset

**Source:** [Bank Transaction Dataset for Fraud Detection](https://www.kaggle.com/datasets/valakhorasani/bank-transaction-dataset-for-fraud-detection) via Kaggle

**1 source table loaded into Snowflake FINTECH_DB.RAW:**

| Column | Type | Description |
|---|---|---|
| TRANSACTION_ID | VARCHAR | Unique transaction identifier |
| ACCOUNT_ID | VARCHAR | Customer account identifier |
| TRANSACTION_AMOUNT | FLOAT | Transaction value |
| TRANSACTION_DATE | VARCHAR | Timestamp of transaction |
| TRANSACTION_TYPE | VARCHAR | Type of transaction |
| LOCATION | VARCHAR | Geographic location |
| DEVICE_ID | VARCHAR | Device used for transaction |
| IP_ADDRESS | VARCHAR | IP address of transaction |
| MERCHANT_ID | VARCHAR | Merchant identifier |
| CHANNEL | VARCHAR | Branch, ATM, or Online |
| CUSTOMER_AGE | INTEGER | Customer age |
| CUSTOMER_OCCUPATION | VARCHAR | Student, Doctor, Engineer, Retired |
| TRANSACTION_DURATION | INTEGER | Duration of transaction in seconds |
| LOGIN_ATTEMPTS | INTEGER | Number of login attempts |
| ACCOUNT_BALANCE | FLOAT | Account balance at time of transaction |
| PREVIOUS_TRANSACTION_DATE | VARCHAR | Date of previous transaction |

**Total rows:** 2,512

---

## Tech Stack

| Layer | Tool |
|---|---|
| Ingestion | Python, pandas, snowflake-connector-python |
| Storage | Snowflake |
| Transformation | dbt Cloud |
| Version Control | GitHub |
| Visualization | Power BI Service |

---

## Project Structure

```
fintech_analytics/
├── models/
│   └── fintech/
│       ├── staging/
│       │   ├── sources.yml
│       │   └── stg_transactions.sql
│       ├── intermediate/
│       │   └── int_transactions_enriched.sql
│       └── marts/
│           ├── fct_transactions.sql
│           ├── dim_accounts.sql
│           ├── dim_merchants.sql
│           └── schema.yml
├── dbt_project.yml
├── load_fintech_to_snowflake.py
└── README.md
```

---

## Data Models

### Staging Layer
Cleans and renames the raw source table. Converts CamelCase column names to SNAKE_CASE and casts all columns to the correct data types.

| Model | Source Table | Purpose |
|---|---|---|
| stg_transactions | TRANSACTIONS | Clean column names, cast timestamps and numeric fields |

### Intermediate Layer
Derives all fraud detection logic, risk tiers, behavioral metrics, and date dimensions.

| Model | Description |
|---|---|
| int_transactions_enriched | Calculates fraud flags, fraud reasons, risk tiers, transaction to balance ratio, time gap analysis, age groups, transaction size tiers, and date dimensions |

### Marts Layer
Business ready models consumed directly by Power BI.

| Model | Type | Description |
|---|---|---|
| fct_transactions | Fact | One row per transaction with all enriched fields including fraud flags and risk tiers |
| dim_accounts | Dimension | One row per account with aggregated spend, fraud count, fraud rate, and account risk tier |
| dim_merchants | Dimension | One row per merchant with total revenue, unique customers, fraud flag rate, and most used channel |

### dbt Tests
Applied to mart models via schema.yml:

- fct_transactions: transaction_id unique and not null, account_id not null, transaction_date not null
- dim_accounts: account_id unique and not null
- dim_merchants: merchant_id unique and not null

---

## Fraud Detection Logic

Since the dataset has no pre-labeled fraud column, all fraud detection logic is built from scratch in dbt using behavioral patterns:

### Fraud Flag Rules

| Rule | Threshold | Fraud Reason Label |
|---|---|---|
| High login attempts | login_attempts >= 3 | High Login Attempts |
| Large transaction | transaction_amount > 9,000 | Large Transaction Amount |
| High transaction duration | transaction_duration > 1,000 seconds | High Transaction Duration |
| Rapid successive transaction | < 2 minutes since last transaction | Rapid Successive Transaction |

A transaction is flagged if ANY of the above conditions are met.

### Risk Tier Classification

| Tier | Conditions |
|---|---|
| High Risk | login_attempts >= 3 OR transaction_amount > 9,000 |
| Medium Risk | transaction_duration > 500 OR transaction to balance ratio > 50% |
| Low Risk | All other transactions |

### Account Risk Tier

Accounts are classified based on their total fraud flagged count:

| Tier | Condition |
|---|---|
| High Risk | fraud_flagged_count >= 3 |
| Medium Risk | fraud_flagged_count >= 1 |
| Low Risk | No flagged transactions |

---

## Dashboard

Built in Power BI Service with 4 report pages connected to Snowflake FINTECH_DB.MARTS.

**Page 1: Transaction Overview**
- Total transactions (2.512K), total volume (747.56K), avg transaction amount (297.59)
- Transaction volume trend over time with a clear dip in April
- Transactions by channel (Branch leads, followed by ATM and Online)

**Page 2: Fraud Analysis**
- Fraud flagged count and risk tier distribution (87.42% Low Risk, 8.8% Medium Risk, 3.78% High Risk)
- Fraud flag reason breakdown (Rapid Successive Transactions dominate)
- Fraud by channel and fraud by location (Fort Worth leads)

**Page 3: Account Analysis**
- Total accounts (495), account risk tier distribution (86.46% Medium Risk, 13.54% High Risk)
- Total transactions by customer occupation (Students lead)
- Top 10 accounts by total spend
- Total transactions by age group (Boomers lead)

**Page 4: Merchant Analysis**
- Total merchants (100)
- Unique customers by merchant (M026 leads)
- Total transactions by most used channel (Branch 37.78%, Online 32.8%, ATM 29.42%)
- Total revenue by merchant

---

## Key Insights

1. **Rapid Successive Transactions are the dominant fraud pattern,** accounting for the majority of fraud flags. This suggests automated or scripted transaction behavior that warrants real time velocity checks.

2. **87.42% of transactions are Low Risk** with only 3.78% classified as High Risk. The fraud detection thresholds are appropriately calibrated to avoid over-flagging legitimate transactions.

3. **Branch channel has the highest transaction volume** at 37.78%, suggesting in-person banking still dominates despite digital channel availability.

4. **Students generate the most transactions** among all occupations, followed by Retired and Engineer customers. This is counterintuitive and may reflect higher transaction frequency rather than higher value.

5. **Boomers transact more than any other age group,** more than Millennials, Gen X, and Gen Z combined. This challenges the assumption that younger customers are more digitally active.

6. **Fort Worth has the highest fraud concentration** by location. Geographic concentration of fraud flags can indicate regional targeting or organized fraud rings operating in specific areas.

7. **Transaction volume dips sharply in April** before recovering. This seasonal pattern should be factored into capacity planning and anomaly detection thresholds.

---

## How to Reproduce

### Prerequisites
- Snowflake account (free trial at snowflake.com)
- dbt Cloud account (free developer account at cloud.getdbt.com)
- Python 3.8 or higher
- Kaggle account to download the dataset

### Snowflake Setup

```sql
CREATE DATABASE IF NOT EXISTS FINTECH_DB;
CREATE SCHEMA IF NOT EXISTS FINTECH_DB.RAW;
CREATE SCHEMA IF NOT EXISTS FINTECH_DB.STAGING;
CREATE SCHEMA IF NOT EXISTS FINTECH_DB.INTERMEDIATE;
CREATE SCHEMA IF NOT EXISTS FINTECH_DB.MARTS;

GRANT ALL ON DATABASE FINTECH_DB TO ROLE DBT_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE FINTECH_DB TO ROLE DBT_ROLE;
```

### Python Ingestion

```bash
pip install pandas "snowflake-connector-python[pandas]"
python3 load_fintech_to_snowflake.py
```

### dbt Setup

1. Add fintech models to your existing dbt project
2. Update `dbt_project.yml` to include the fintech folder configuration pointing to FINTECH_DB
3. Run:

```bash
dbt build --select fintech
```

### Power BI

1. Open Power BI Service at app.powerbi.com
2. Create a new report and connect to Snowflake
3. Select FINTECH_DB and the MARTS schema
4. Load fct_transactions, dim_accounts, and dim_merchants
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
