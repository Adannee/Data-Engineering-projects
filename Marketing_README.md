# Marketing Campaign Analytics

An end to end analytics engineering project built on the modern data stack. Raw marketing campaign data ingested via Python into Snowflake, transformed through three dbt modeling layers with derived marketing metrics, and visualized in a 4 page Power BI dashboard.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Dataset](#dataset)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Metrics Calculated](#metrics-calculated)
- [Dashboard](#dashboard)
- [Key Insights](#key-insights)
- [How to Reproduce](#how-to-reproduce)
- [Author](#author)

---

## Project Overview

This project demonstrates a complete analytics engineering workflow on a marketing campaign performance dataset covering 200,000 campaigns across 6 channels, 5 customer segments, and multiple campaign types. The project is designed to answer the core questions any marketing team needs answered about their spend efficiency and campaign effectiveness.

The project answers five core business questions:

1. What is the overall revenue and ROAS across all campaigns?
2. Which channel drives the best return on ad spend?
3. Which customer segment converts best and at what acquisition cost?
4. Which campaign types deliver the highest ROI?
5. How is conversion rate trending over time?

---

## Architecture

```
Kaggle CSV File (200,000 rows)
        |
        v
Python Ingestion Script
(snowflake-connector-python, pandas, write_pandas)
        |
        v
Snowflake MARKETING_DB.RAW
        |
        v
dbt Staging Layer
(clean, rename, cast, fix source typos)
        |
        v
dbt Intermediate Layer
(derive CTR, CPC, ROAS, performance tiers, channel grouping)
        |
        v
dbt Marts Layer
(fct_campaign_performance, dim_channels, dim_segments)
        |
        v
Power BI Service Dashboard
(4 pages, 16 visuals)
```

---

## Dataset

**Source:** [Marketing Campaign Performance Dataset](https://www.kaggle.com/datasets/manishabhatt22/marketing-campaign-performance-dataset) via Kaggle

**1 source table loaded into Snowflake MARKETING_DB.RAW:**

| Column | Type | Description |
|---|---|---|
| CAMPAIGN_ID | Integer | Unique campaign identifier |
| COMPANY | String | Advertiser company name |
| CAMPAIGN_TYPE | String | Influencer, Search, Display, Email, Social Media |
| TARGET_AUDIENCE | String | Who the campaign targeted |
| DURATION | String | Campaign length in days |
| CHANNEL_USED | String | Google Ads, Facebook, Instagram, Email, YouTube, Website |
| CONVERSION_RATE | Float | Conversions divided by clicks |
| ACQISITION_COST | String | Customer acquisition cost (note: source typo retained) |
| ROI | Float | Return on investment |
| LOCATION | String | Geographic targeting |
| LANGUAGE | String | Campaign language |
| CLICKS | Integer | Total clicks |
| IMPRESSIONS | Integer | Total impressions |
| ENGAGEMENT_SCORE | Integer | Engagement metric |
| CUSTOMER_SEGMENT | String | Foodies, Tech Enthusiasts, Outdoor Adventurers, Health and Wellness, Fashionistas |
| DATE | String | Campaign date |

**Total rows:** 200,000

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
marketing_analytics/
├── models/
│   └── marketing/
│       ├── staging/
│       │   ├── sources.yml
│       │   └── stg_marketing_campaigns.sql
│       ├── intermediate/
│       │   └── int_marketing_campaigns_enriched.sql
│       └── marts/
│           ├── fct_campaign_performance.sql
│           ├── dim_channels.sql
│           ├── dim_segments.sql
│           └── schema.yml
├── macros/
│   └── generate_schema_name.sql
├── dbt_project.yml
├── load_marketing_to_snowflake.py
└── README.md
```

---

## Data Models

### Staging Layer
Cleans and renames the raw source table. Fixes the source typo in ACQISITION_COST and casts all columns to the correct data types.

| Model | Source Table | Purpose |
|---|---|---|
| stg_marketing_campaigns | MARKETING_CAMPAIGNS | Clean column names, cast types, fix source typo |

### Intermediate Layer
Derives all marketing metrics from the cleaned staging model.

| Model | Description |
|---|---|
| int_marketing_campaigns_enriched | Calculates CTR, CPC, cost per conversion, ROAS, performance tier, channel group, and date dimensions for every campaign |

### Marts Layer
Business ready models consumed directly by Power BI.

| Model | Type | Description |
|---|---|---|
| fct_campaign_performance | Fact | One row per campaign with all metrics and estimated revenue |
| dim_channels | Dimension | One row per channel with aggregated performance metrics |
| dim_segments | Dimension | One row per customer segment with aggregated performance metrics |

### dbt Tests
Applied to mart models via schema.yml:

- fct_campaign_performance: campaign_id unique and not null, channel not null, campaign_date not null
- dim_channels: channel unique and not null
- dim_segments: customer_segment not null

---

## Metrics Calculated

All metrics are derived in the intermediate layer using dbt:

| Metric | Formula | Purpose |
|---|---|---|
| CTR | clicks / impressions * 100 | Measures ad engagement rate |
| CPC | acquisition_cost / clicks | Cost efficiency per click |
| Cost Per Conversion | acquisition_cost / (conversion_rate * clicks) | True cost per acquired customer |
| ROAS | roi * acquisition_cost / acquisition_cost * 100 | Return on every dollar spent |
| Estimated Conversions | clicks * conversion_rate | Total estimated conversions |
| Estimated Revenue | acquisition_cost * (1 + roi) | Total estimated revenue generated |
| Performance Tier | ROI >= 5 = High, >= 2 = Mid, else Low | Campaign performance classification |
| Channel Group | Google Ads and YouTube = Paid Search, Facebook and Instagram = Social Media | Channel category grouping |

---

## Dashboard

Built in Power BI Service with 4 report pages connected to Snowflake MARKETING_DB.MARTS.

**Page 1: Campaign Overview**
- Total acquisition cost (2.50bn), total estimated revenue (15.02bn), average ROAS (500.24), average CTR (14.04)
- Spend and revenue trend over time by month
- Revenue by channel bar chart

**Page 2: Channel Performance**
- Channel summary table with spend, revenue, ROAS, CTR, and conversion rate
- ROAS by channel bar chart (Facebook leads at 6.0)
- Spend by channel group donut chart (even ~16.6% split across all channels)
- Average CTR by channel bar chart

**Page 3: Segment Analysis**
- Revenue by customer segment (Foodies lead)
- Total campaigns by segment donut chart (even ~20% split)
- Average acquisition cost by segment
- Full segment summary table with conversion rate and ROAS

**Page 4: Campaign Performance**
- Average ROI by campaign type (Influencer leads)
- Performance tier donut (49.8% High Performers, 50.2% Mid Performers)
- Top 10 companies by estimated revenue
- Conversion rate trend over time

---

## Key Insights

1. **Email is the top revenue channel** despite even spend distribution across all 6 channels. Reallocating budget toward Email could significantly improve overall ROAS.

2. **Budget is evenly distributed across all channels at ~16.6% each.** This suggests a spray and pray approach rather than data driven allocation. Concentrating spend on top performers could improve efficiency.

3. **All 5 customer segments perform almost identically** with ~40K campaigns, ~0.40 conversion rate, and ROAS around 30 each. This suggests either excellent targeting balance or an opportunity to identify and invest more in the highest potential segment.

4. **Influencer campaigns deliver the highest ROI** among all campaign types, followed by Search. Social Media campaigns deliver the lowest ROI.

5. **Zero Low Performer campaigns** with a 49.8% High Performer and 50.2% Mid Performer split. This is an unusually strong overall portfolio suggesting either good campaign management or conservative ROI thresholds.

6. **Conversion rate is volatile month to month** with peaks in May and October. These months should be prioritized for budget allocation in future planning cycles.

---

## How to Reproduce

### Prerequisites
- Snowflake account (free trial at snowflake.com)
- dbt Cloud account (free developer account at cloud.getdbt.com)
- Python 3.8 or higher
- Kaggle account to download the dataset

### Snowflake Setup

```sql
CREATE DATABASE IF NOT EXISTS MARKETING_DB;
CREATE SCHEMA IF NOT EXISTS MARKETING_DB.RAW;
CREATE SCHEMA IF NOT EXISTS MARKETING_DB.STAGING;
CREATE SCHEMA IF NOT EXISTS MARKETING_DB.INTERMEDIATE;
CREATE SCHEMA IF NOT EXISTS MARKETING_DB.MARTS;

GRANT ALL ON DATABASE MARKETING_DB TO ROLE DBT_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE MARKETING_DB TO ROLE DBT_ROLE;
```

### Python Ingestion

```bash
pip install pandas "snowflake-connector-python[pandas]"
python3 load_marketing_to_snowflake.py
```

### dbt Setup

1. Add marketing models to your existing dbt project or create a new one
2. Update `dbt_project.yml` to include the marketing folder configuration
3. Add the `generate_schema_name` macro to avoid schema prefix issues
4. Run:

```bash
dbt build --select marketing
```

### Power BI

1. Open Power BI Service at app.powerbi.com
2. Create a new report and connect to Snowflake
3. Select MARKETING_DB and the MARTS schema
4. Load fct_campaign_performance, dim_channels, and dim_segments
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
