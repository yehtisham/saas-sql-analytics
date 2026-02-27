# GTM Analytics Warehouse (SQLite)

This project simulates a SaaS company's go-to-market (GTM) analytics warehouse in **SQLite**, and answers sales and marketing questions using SQL.

## Data Model

Six core tables:

- `accounts` – companies (industry, employee_count, segment, revenue, customer flag)
- `contacts` – people at those companies (titles and role groups like Economic Buyer / Champion)
- `campaigns` – marketing campaigns with channel, dates, and budget
- `opportunities` – sales deals with stage, amount, source, and outcome flags
- `activities` – touchpoints (emails, calls, demos, meetings, proposal sent) linked to accounts, contacts, and campaigns
- `product_usage` – post-sale activity (active users, sessions, feature events) for live customers

The schema and sample data are defined in [`schema.sql`](schema.sql).

## Example Analytics

All queries live in [`analytics.sql`](analytics.sql). They answer questions such as:

1. **Win rate by segment and source**  
   Which combinations of segment (SMB, Mid, Enterprise) and lead source (Inbound, Outbound, Event, Partner) close at the highest rates?

2. **Average deal cycle**  
   How many days on average does it take to close deals by segment?

3. **Activity vs outcomes**  
   For each account, how many activities occurred in the last 30 days, and has that account ever closed a deal?

4. **Campaign ROI**  
   For each campaign, how much pipeline and closed revenue did it influence relative to its budget?

5. **Account health score**  
   A view (`account_health_score`) that combines segment, recent activities, and product usage into a numeric score to help Sales prioritize accounts.

## How to Run (SQLite + DB Browser)

1. Create a new SQLite database (e.g., `gtm_analytics_warehouse.sqlite`) with DB Browser for SQLite.
2. In the **Execute SQL** tab, paste and run everything from [`schema.sql`](schema.sql) to create tables and load data.
3. Paste and run queries from [`analytics.sql`](analytics.sql) to reproduce the analysis results.
4. Connect the database to a BI tool (Power BI, Tableau, etc.) and visualize:
   - Win rate by segment/source,
   - Campaign ROI,
   - Ranked account health scores.
