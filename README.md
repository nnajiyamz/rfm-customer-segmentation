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

---

## Power BI Dashboard

<h3 align="center">Customer & Market Overview</h3>
<p align="center">
  <img src="https://github.com/nnajiyamz/rfm-customer-segmentation/blob/6ceb3a2aefd127e2651d1a4affe685979fe69d27/images/customer-and-market-overview-dashboard.png" height="1800" width="1800">
</p>

<h3 align="center">RFM Analysis</h3>
<p align="center">
  <img src="https://github.com/nnajiyamz/rfm-customer-segmentation/blob/6ceb3a2aefd127e2651d1a4affe685979fe69d27/images/rfm-analysis-dashboard.png" height="1800" width="1800">
</p>

---

## Key Business Insights

### Revenue Overview

- **Total Revenue: $5.44M | 68,700 orders | AOV $79.23 | $559/customer**
  - Revenue remained stable at ~$2.7M per year
- **Q1 Weakest quarter**
  - February recorded the lowest monthly revenue
  - $160.6K in 2023, $172.1K in 2024
  - Reflects a typical post-holiday slowdown in consumer spending
- **Q2 & Q3 Gradual recovery**
  - Revenue averaged ~$217.8K per month
  - Order values showed a gradual decline outside peak seasons
- **Q4 Peak season**
  - Contributed ~32% of annual revenue
  - Showed a clear holiday driven seasonal pattern

### Year-on-Year Highlights

- **Q4 revenue growth**
  - Driven by larger order values, not more frequent purchases
  - Reflects seasonal purchasing behaviour rather than higher customer activity
- **Q4 2024 declined slightly compared to Q4 2023**
  - A small decline pattern was observed across revenue, orders, and AOV
  - Minor individually, but collectively signals a mild slowdown in peak season performance
- **Q2 & Q3 average spending per order declined**
  - Order frequency remained stable but average order value decreased
  - Q2 AOV declined by $1.48 and Q3 by $1.59

### Market & Demographics

- **United States being the dominant market**
  -  Generated $2.1M in revenue
  -  Indicates exposure to revenue concentration risk
- **Japan, United Kingdom, and France**
  - Recorded the highest revenue per customer, ranging from $585 to $588
  - Smaller markets but consisted of higher-value customers despite lower total revenue
- **26–45: Working-age customers**
  - Contributed $3.24M in revenue
  - Age group with the greatest revenue impact
- **Younger & Senior age customers**
  - 18–25: Highest AOV among top 3 groups at $80.10, showing strong spending intent among younger demographic
  - 66–75: Highest AOV overall at $82.74, smallest customer base but highest spend per order
- **Gender split in revenue**
  - Female $2.47M | Male $2.44M
  - Revenue distribution between genders was nearly equal
  - Purchasing behaviour is not strongly influenced by gender

### Customer Tier Performance

- **Regular and Premium customers**
  - Largest revenue base, generating $3.35M 
  - Strongest opportunity for tier progression strategies
- **VIP customers**
  - Smaller customer base but contributed $1.25M in revenue
  - Significantly higher customer value
  - Should be prioritised for retention strategies
- **Budget and Occasional customers**
  - Contributed $837.5K in revenue
  - Lower revenue potential unless their purchasing behaviour changes

### RFM Segmentation Overview

Each customer is scored from 1–5 across three dimensions:
- **Recency**: how recently they purchased
- **Frequency**: how often they buy
- **Monetary**: how much they spend

| Segment |  Description | Customers | Revenue | Revenue per Customer | Recommended Strategy |
|---|---|---|---|---|---|
| Champion | Recent, frequent, high spenders | 1,933 | $2.17M | $1,120 | Protect |
| Loyal | Consistent buyers still actively purchasing | 2,682 | $1.41M | $526 | Nurture |
| At-Risk | Previously active, now going quiet | 3,135 | $1.62M | $517 | Win-back |
| Potential Loyalist | Recent buyers, still building purchase habit | 499 | $116.6K | $234 | Develop |
| Promising | New customers with only one purchase so far | 61 | $6K | $98 | Develop |
| Inactive | Low engagement across all dimensions | 1,420 | $119.6K | $84 | Low-touch |

- **Customer movement**
  - Showed a negative trend, with downgrades exceeding upgrades
  - Customers who declined into At Risk and Inactive segments: 2,197
  - Customers who upgraded into higher-value segments: 1,546
- **At Risk customers**
  - Generated nearly the same revenue per customer as Loyal customers ($517 vs $526)
  - Had not purchased recently (~194 days since last purchase)
  - The most important segment for re-engagement due to their high remaining customer value
- **Champion customers**
  - Generated $2.17M in revenue and averaged 13 orders per customer
  - The most valuable segment and critical to retain
- **Potential Loyalists and Promising customers**
  - Showed early engagement but lower spending
  - Present an opportunity to upgrade them into higher-value customers

---

## Business Recommendations

### Retention & Win-Back Strategy
- **At Risk customers**
  - Prioritise customers who have not purchased within 90–180 days
  - Act early before these customers shift into the Inactive segment
  - Use targeted win-back campaigns, personalised offers, or limited-time incentives to reactivate these customers
- **Inactive customers**
  - Keep reactivation efforts minimal to avoid negative ROI, given their low average revenue of $84 per customer
- **RFM segment movement**
  - Monitor quarterly to identify early signs of customer churn

### Seasonal Strategy
- **February campaign**
  - Launch a targeted campaign to stimulate demand and make use of lower competition during the off-peak period
- **Q2–Q3 spend incentives**
  - Introduce minimum spend promotions, product bundles, or cross-selling campaigns
  - Aim to slow down the decline in order values
- **Q4 marketing campaigns**
  - Launch earlier from late October, to get ahead of peak competition and capture demand early
  - Focus on increasing order value through bundles, gift sets, and upselling strategies, rather than relying solely on higher traffic

### International Market Expansion
- **Japan, UK, and France**
  - Investigate what drives higher revenue per customer in these regions
  - Evaluate whether deeper market investment could accelerate growth
- **Reduce dependence on the US market**
  - Expand marketing and acquisition efforts in high-value international markets

### Age Segment Growth Strategy
- **18–25 customer acquisition**
  - Increase the 18–25 customer base through targeted acquisition campaigns to drive long-term revenue growth
- **66–75 spending behaviour**
  - Investigate the drivers of high spending in this age group to inform product positioning or targeted outreach

### Customer Value & Loyalty
- **Loyalty and spend-based rewards**
  - Encourage Regular and Premium customers to move into higher-value tiers
- **VIP retention**
  - Implement personalised retention strategies for VIP customers
- **Second purchase incentives**
  - Introduce a targeted incentives to increase repeat purchasing

---

## Limitations

### Data Scope
- Revenue metrics are based on **completed transactions only**, excluding cancelled, refunded, and pending orders
- The dataset covers **2023-2024 only**, and does not reflect full customer lifetime behaviour (some customers registered as early as 20220)
- The provided `lifetime_value` column was excluded as it does not match actual transaction totals, indicating it is a synthetic value
- Due to limited historical data, **CLV cannot be calculated**, so RFM and revenue-based metrics are used to estimate customer value

### Customer Coverage
- **270 out of 10,000 customers** were excluded from the RFM analysis due to no completed transactions:
  - 59 never attempted a purchase
  - 211 had only unsuccessful orders
- RFM analysis focuses on customers with at least one completed purchase only

### RFM Methodology
- Recency is calculated using a **year-end reference point** for consistent comparison:
  - 2023 recency: days until 2024-01-01
  - 2024 recency: days until 2025-01-01
- Scoring thresholds are **data-driven**, based on actual distribution rather than standard benchmarks
- RFM reflects a **year-end behavioural snapshot**, not real time behaviour
- The `is_churned` field was excluded due to inconsistencies, therefore **RFM is used as the primary indicator** of churn risk
---

## Suggested Further Analysis

Several areas could be explored further to deepen the analysis:

### Order Failure Analysis
  - Investigate patterns among the 211 customers with only unsuccessful orders to identify whether failures are driven by payment, logistics, or product-related issues

### Excluded Customer Profiling
- Analyse the 270 excluded customers across attributes such as `segment`, `country`, `age`, `email_opt_in`, and `has_app` to understand potential barriers to first purchase

### Conversion Drivers
- Analyse whether `has_app` usage or `email_opt_in` is associated with higher first-purchase conversion rates

### Onboarding & Engagement Trends
- Investigate the increase in never-attempted signups from mid-2023 onward to identify potential onboarding or engagement issues
