<p align="center">
  <img src="https://github.com/nnajiyamz/rfm-customer-segmentation/blob/a6f58458b3429882a4e91e7d583cff976bae8803/images/stratex-logo.png" width="300">
</p>

<h1 align="center">Stratex Commerce<br>Customer Behaviour & RFM Segmentation Analysis</h1>

### Client Background

**Stratex Commerce** is a global e-commerce retailer offering consumer products across essential and lifestyle categories, including Food & Grocery, Health, Pet Supplies, Clothing, Jewellery, Sports, and Electronics.

As the company continues to expand its customer base and product offerings, understanding how customers interact with the platform has become a key strategic priority. This project moves beyond surface-level reporting toward deeper insights into customer behaviour and growth opportunities.

---

### Project Objective

This project analyses customer purchasing behaviour and revenue performance to uncover insights that support data-driven business decision-making. The analysis focuses on:

- **Identifying high-value customer segments using RFM segmentation**
- **Detecting early indicators of customer churn**
- **Uncovering opportunities to strengthen customer retention and engagement strategies to support long-term revenue growth**

---

### Business Questions

This analysis aims to answer several key questions related to revenue performance and customer behaviour:
1. How does revenue change across months and seasons?
2. Which markets generate the highest total revenue and revenue per customer?
3. Which customer segments contribute the largest share of revenue?
4. Which customer segments show early signs of declining engagement or churn risk?
5. How do customers transition between RFM segments over time?

---

### Dataset Overview

This project uses the <a href="https://www.kaggle.com/datasets/lorenzoscaturchio/ecommerce-behavior" target="_blank"><strong>Synthetic E-Commerce Customer Behaviour Dataset</strong></a>, a multi-table dataset designed to simulate real-world online retail operations.
The full dataset consists of five relational tables connected through shared `customer_id` and `product_id` identifiers:
  
| Table | Description | Volume
|---|---|---|
| `customers` | Demographics and account info | 10,000 |
| `products` | Product details and categories | 1,000 across 15 categories |
| `transactions` | Purchase history and order values | 120,000 |
| `sessions` | Session activity and behaviour | 80,000 |
| `reviews` | Customer ratings and feedback | 25,000 |


#### Tables used in this project:

| Table | Usage Scope |
|---|---|
| `customers` | SQL exploration, RFM analysis, Power BI |
| `transactions` | SQL exploration, RFM analysis, Power BI |
| `products` | SQL exploration |

`sessions` and `reviews` tables were loaded into SQLiteStudio for data exploration but were not included in the final dashboard.

The RFM analysis produces a derived output (`rfm_segments.csv`) exported from SQL and loaded into Power BI as an additional dataset for segmentation visuals.
> Analysis is based on completed transactions from 2023–2024, covering 9,730 customers with at least one purchase.

---

### Tools Used

- **SQLite / SQLiteStudio**: Data cleaning, data exploration, analysis, RFM scoring
- **Power BI**: Interactive dashboard & visualizations
- **Power Query**: Advanced data cleaning & preparation

---

## SQL Analysis

SQL was used for data validation, metric calculations, and customer segmentation.

### Data Cleaning & Exploration

- Checked row counts across all tables
- Validated for duplicate records and missing values
- Explored customer demographics, transaction coverage, and product distribution
- Identified 270 customers with no completed transaction history
- Verified all table joins are clean with no orphan records

[`data-cleaning-exploration.sql`](https://github.com/nnajiyamz/rfm-customer-segmentation/blob/a6f58458b3429882a4e91e7d583cff976bae8803/sql/data-cleaning-exploration.sql)

### Business Metric Calculations

Key metrics were calculated in SQL and used to verify Power BI outputs:

- Total Revenue, Total Orders, Average Order Value (AOV), Revenue per Customer
- Revenue and AOV breakdown by country
- Customer count by country and customer tier
- Revenue breakdown by age group, customer tier, and gender

[`business-metric-calculation.sql`](https://github.com/nnajiyamz/rfm-customer-segmentation/blob/a6f58458b3429882a4e91e7d583cff976bae8803/sql/business-metric-calculation.sql)

### Customer Segmentation (RFM Analysis)

Customer segmentation was performed using Recency, Frequency, and Monetary (RFM) analysis. Key steps included:

- Explored RFM distributions to determine appropriate scoring thresholds
- Calculated RFM scores based on purchase recency, order frequency, and total spending
- Applied year-end boundary logic to enable consistent 2023 vs 2024 comparison
- Assigned behavioural segments: Champion, Loyal, Potential Loyalist, Promising, At Risk, and Inactive
- Exported customer-level RFM dataset (`rfm_segments.csv`) to Power BI for visualization

[`rfm-analysis.sql`](https://github.com/nnajiyamz/rfm-customer-segmentation/blob/a6f58458b3429882a4e91e7d583cff976bae8803/sql/rfm-analysis.sql)
