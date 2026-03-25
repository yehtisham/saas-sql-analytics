SaaS Analytics Warehouse
A SQL-backed analytics warehouse and BI dashboard built to simulate a real B2B SaaS customer intelligence workflow. Covers revenue performance, customer health scoring, churn risk detection, and upsell identification across 238 simulated accounts.
Overview
This project mirrors the kind of analytics infrastructure a Customer Success or Revenue Operations team would use to monitor subscription health and prioritize outreach. The data layer is built entirely in SQLite with structured SQL views; the presentation layer is a Power BI dashboard consuming those views directly.
Data Model
Five core tables: accounts, products, invoices, usage_daily, and a derived subscriptions layer. All analytical views are built on top of these.
SQL Views
ViewPurposevw_monthly_revenueTotal revenue by month, region, and segmentvw_monthly_revenue_momMonth-over-month growth using window functionsvw_account_monthly_revenuePer-account revenue breakdown with payment statusvw_account_monthly_usageMonthly active users and feature engagement per accountvw_account_health_latestLatest-period health score (0–100) per accountvw_upsell_candidatesHigh-usage, below-median-revenue accounts with no write-offs
Health Score Logic
Each account receives a 0–100 health score calculated from three components: usage activity (active users, logins, feature events), payment behavior (overdue and written-off invoice flags), and revenue recency. Accounts are bucketed into four tiers: Healthy, Stable, At-Risk, and Critical.
Dashboard (Power BI)

Monthly revenue trend by segment (Enterprise, Mid-Market, SMB)
Month-over-month growth — bar/line combo using window function output
Customer health distribution across all 238 accounts
At-risk accounts table — 22 accounts flagged for overdue or written-off invoices
Upsell opportunities — 3 accounts with high usage and below-median revenue
Revenue by region — North America, APAC, LATAM, Europe

Tech Stack
SQLite · SQL · Python (pandas) · Power BI
