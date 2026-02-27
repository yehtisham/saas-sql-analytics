-- GTM Analytics Warehouse - Analysis Queries (SQLite)

-- 1) Win rate by segment and source
WITH closed AS (
    SELECT
        o.opp_id,
        a.segment,
        o.source,
        o.is_won
    FROM opportunities o
    JOIN accounts a ON a.account_id = o.account_id
    WHERE o.is_closed = 1
)
SELECT
    segment,
    source,
    COUNT(*) AS opp_count,
    SUM(CASE WHEN is_won = 1 THEN 1 ELSE 0 END) AS win_count,
    ROUND(
        100.0 * SUM(CASE WHEN is_won = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS win_rate_pct
FROM closed
GROUP BY segment, source
ORDER BY segment, source;

-- 2) Average deal cycle (days) by segment
SELECT
    a.segment,
    COUNT(*) AS closed_opps,
    ROUND(AVG(
        CASE 
          WHEN o.is_closed = 1 AND o.close_date IS NOT NULL 
          THEN (julianday(o.close_date) - julianday(o.created_date))
        END
    ), 1) AS avg_cycle_days
FROM opportunities o
JOIN accounts a ON a.account_id = o.account_id
WHERE o.is_closed = 1
GROUP BY a.segment
ORDER BY a.segment;

-- 3) Activity volume vs whether an account has ever won a deal
WITH activity_30d AS (
    SELECT
        account_id,
        COUNT(*) AS activities_last_30d
    FROM activities
    WHERE activity_date >= date('2024-02-10','-30 day')
    GROUP BY account_id
),
account_outcomes AS (
    SELECT
        a.account_id,
        a.account_name,
        MAX(CASE WHEN o.is_won = 1 THEN 1 ELSE 0 END) AS ever_won
    FROM accounts a
    LEFT JOIN opportunities o ON o.account_id = a.account_id
    GROUP BY a.account_id, a.account_name
)
SELECT
    ao.account_name,
    COALESCE(a30.activities_last_30d, 0) AS activities_last_30d,
    CASE WHEN ao.ever_won = 1 THEN 'Has Won Deal' ELSE 'No Won Deals' END AS won_flag
FROM account_outcomes ao
LEFT JOIN activity_30d a30 ON a30.account_id = ao.account_id
ORDER BY activities_last_30d DESC, ao.account_name;

-- 4) Campaign-influenced pipeline and revenue
WITH campaign_touch AS (
    SELECT DISTINCT
        c.campaign_id,
        c.campaign_name,
        o.opp_id,
        o.amount,
        o.is_won
    FROM campaigns c
    JOIN activities act  ON act.campaign_id = c.campaign_id
    JOIN opportunities o ON o.account_id    = act.account_id
),
agg AS (
    SELECT
        campaign_id,
        campaign_name,
        COUNT(DISTINCT opp_id) AS influenced_opps,
        COALESCE(SUM(amount), 0) AS influenced_pipeline,
        COALESCE(SUM(CASE WHEN is_won = 1 THEN amount ELSE 0 END), 0) AS influenced_revenue
    FROM campaign_touch
    GROUP BY campaign_id, campaign_name
)
SELECT
    a.campaign_name,
    a.influenced_opps,
    a.influenced_pipeline,
    a.influenced_revenue,
    c.budget,
    CASE WHEN c.budget > 0
         THEN ROUND(a.influenced_revenue / c.budget, 2)
         ELSE NULL
    END AS revenue_to_budget_ratio
FROM agg a
JOIN campaigns c USING (campaign_id)
ORDER BY revenue_to_budget_ratio DESC;

-- 5) Account health score view and ranking
DROP VIEW IF EXISTS account_health_score;

CREATE VIEW account_health_score AS
WITH recent_activity AS (
    SELECT
        account_id,
        COUNT(*) AS activities_30d
    FROM activities
    WHERE activity_date >= date('2024-02-10','-30 day')
    GROUP BY account_id
),
recent_usage AS (
    SELECT
        account_id,
        SUM(active_users)    AS active_users_30d,
        SUM(sessions)        AS sessions_30d,
        SUM(feature_events)  AS feature_events_30d
    FROM product_usage
    WHERE usage_date >= date('2024-02-10','-30 day')
    GROUP BY account_id
)
SELECT
    a.account_id,
    a.account_name,
    a.segment,
    COALESCE(ra.activities_30d, 0)     AS activities_30d,
    COALESCE(ru.active_users_30d, 0)   AS active_users_30d,
    COALESCE(ru.sessions_30d, 0)       AS sessions_30d,
    COALESCE(ru.feature_events_30d, 0) AS feature_events_30d,
    (
      CASE a.segment
        WHEN 'Enterprise' THEN 40
        WHEN 'Mid'        THEN 25
        ELSE 15
      END
      + 0.8 * COALESCE(ra.activities_30d, 0)
      + 0.05 * COALESCE(ru.sessions_30d, 0)
      + 0.1 * COALESCE(ru.feature_events_30d, 0)
    ) AS health_score
FROM accounts a
LEFT JOIN recent_activity ra ON ra.account_id = a.account_id
LEFT JOIN recent_usage   ru ON ru.account_id = a.account_id;

-- 6) Use the health score view
SELECT
    account_name,
    segment,
    ROUND(health_score, 1) AS health_score,
    activities_30d,
    active_users_30d,
    sessions_30d
FROM account_health_score
ORDER BY health_score DESC;
