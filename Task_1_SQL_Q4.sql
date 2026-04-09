-- Q4: Time Series
-- Growth & churn trends

-- Build monthly aggregates
WITH monthly_data AS (SELECT 
-- Normalize start_date to the first day of the month for grouping
DATE_FORMAT(s.start_date, '%Y-%m-01') AS month, p.plan_tier, 
-- Count of new subscriptions started in that month
COUNT(*) AS new_subscriptions, SUM(CASE WHEN s.status = 'cancelled' THEN 1 ELSE 0 END) AS churned
FROM subscriptions s
JOIN plans p 
ON s.plan_id = p.plan_id
GROUP BY DATE_FORMAT(s.start_date, '%Y-%m-01'), p.plan_tier), 
-- Add window calculations
calc AS (
SELECT month, plan_tier, new_subscriptions, churned, 
-- Previous month's subscription count (per plan tier)
LAG(new_subscriptions) OVER (PARTITION BY plan_tier ORDER BY month) AS prev_month,
 -- Rolling average of churn over the last 3 months (current + 2 preceding)
AVG(churned) OVER (PARTITION BY plan_tier ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg
FROM monthly_data)

-- Final metrics
SELECT month, plan_tier, ROUND((new_subscriptions - prev_month) * 1.0 / NULLIF(prev_month, 0) * 100,2) AS mom_growth,
churned, rolling_avg,
-- Flag churn spikes: if churn > 2x rolling average, mark as "High Churn"
CASE 
WHEN churned > 2 * rolling_avg THEN 'High Churn'
ELSE 'Normal'
END AS churn_flag
FROM calc;