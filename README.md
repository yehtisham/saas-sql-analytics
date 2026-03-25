# SaaS Analytics Warehouse

> A SQL-backed customer intelligence system for a simulated B2B SaaS business — covering revenue performance, customer health scoring, churn risk detection, and upsell identification.

---

## Overview

This project mirrors the analytics infrastructure a Customer Success or Revenue Operations team would use to monitor subscription health and prioritize outreach. The data layer is built entirely in SQLite with six structured SQL views. The presentation layer is an interactive HTML dashboard built with Chart.js, surfacing actionable insights across 238 simulated accounts.

---

## Business Questions Answered

- How is monthly revenue trending across regions and customer segments?
- Where is revenue accelerating or declining month-over-month?
- Which accounts show declining engagement or payment risk and may churn?
- Which accounts have strong usage but low revenue and should be prioritized for upsell?
- How does customer health vary across the portfolio, and where should Customer Success focus?

---

## Data Model

Five core tables form the foundation of the warehouse:

| Table | Description |
|---|---|
| `accounts` | Company-level attributes — region, segment, industry, employee count |
| `products` | Product catalog with pricing tiers |
| `invoices` | Invoice history with payment status (Paid, Overdue, Written-Off) |
| `usage_daily` | Daily active users and feature-level engagement events per account |
| `subscriptions` | Account-product subscription records |

---

## SQL Views

Six analytical views are built on top of the core tables, each answering a distinct business question:

| View | Purpose |
|---|---|
| `vw_monthly_revenue` | Total revenue by month, region, and segment |
| `vw_monthly_revenue_mom` | Month-over-month growth rate using SQL window functions |
| `vw_account_monthly_revenue` | Per-account revenue breakdown with payment status flags |
| `vw_account_monthly_usage` | Monthly active users and feature engagement per account |
| `vw_account_health_latest` | Latest-period composite health score (0–100) per account |
| `vw_upsell_candidates` | High-usage, below-median-revenue accounts with no write-offs |

---

## Customer Health Score

Each account receives a composite health score from 0 to 100, calculated from three components:

- **Usage activity** — active users, total logins, feature A and feature B engagement events
- **Payment behavior** — penalties applied for overdue invoices and written-off amounts
- **Revenue recency** — whether the account has generated paid revenue in the latest period

Accounts are then bucketed into four tiers based on their score:

| Tier | Score Range | Meaning |
|---|---|---|
| Healthy | 35 – 100 | Strong engagement and clean payment history |
| Stable | 20 – 34 | Adequate usage, no major payment issues |
| At-Risk | 5 – 19 | Declining engagement or minor payment concerns |
| Critical | Below 5 | Low usage and/or overdue or written-off revenue |

---

## Interactive Dashboard

The dashboard is a single-page HTML report built with Chart.js — open it directly in any browser, no software installation required.

**[View Dashboard](dashboard/saas_dashboard.html)**

Components:

- **Monthly Revenue by Segment** — stacked line chart across Enterprise, Mid-Market, and SMB
- **Month-over-Month Growth** — bar/line combo chart using window function output, green/red bars for growth vs decline
- **Customer Health Distribution** — donut chart across all 238 accounts by tier
- **Revenue by Region** — horizontal bar breakdown across North America, APAC, LATAM, and Europe
- **At-Risk Accounts Table** — 22 accounts flagged for overdue or written-off invoices, sorted by health score
- **Upsell Opportunities Table** — accounts with above-median usage and below-median revenue, prioritized for Sales outreach
- **Filters** — interactive segment and region dropdowns that update both tables live

---

## Key Findings

- **85%** of accounts fall in the At-Risk or Critical health tier, signaling a portfolio-wide engagement gap
- **22 accounts** carry overdue or written-off invoice risk, concentrated in SMB and Europe
- **3 Mid-Market accounts** are high-usage but below revenue median — strong upsell candidates
- **North America and APAC** are the top revenue regions, contributing ~64% of total 2-year revenue combined
- Mid-Market drives the majority of monthly revenue, with Enterprise showing high volatility month-to-month

---

## Tech Stack

| Layer | Tools |
|---|---|
| Data warehouse | SQLite |
| Data modeling & transformation | SQL (window functions, CTEs, aggregations) |
| Data preparation & export | Python (pandas) |
| Visualization | Chart.js (HTML dashboard) |

---

## Repository Structure

```
saas-analytics-warehouse/
│
├── data/
│   ├── accounts.csv
│   ├── invoices.csv
│   ├── products.csv
│   └── usage_daily.csv
│
├── views/
│   ├── vw_monthly_revenue.sql
│   ├── vw_monthly_revenue_mom.sql
│   ├── vw_account_monthly_revenue.sql
│   ├── vw_account_monthly_usage.sql
│   ├── vw_account_health_latest.sql
│   └── vw_upsell_candidates.sql
│
├── dashboard/
│   └── saas_dashboard.html
│
├── saas_analytics.sqlite
└── README.md
```

---

## How to Run

1. Clone the repository
2. Open `saas_analytics.sqlite` in any SQLite client (e.g. DB Browser for SQLite) to explore the schema and views
3. Open `dashboard/saas_dashboard.html` in any browser to view the interactive dashboard — no installation required
4. All data is pre-embedded in the dashboard; CSV exports are in `/data` for reference

---

*Built as part of a portfolio of SQL and BI projects. Data is fully simulated.*
