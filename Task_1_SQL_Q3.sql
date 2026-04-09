-- Q3: CTE + Subquery
-- Customers who downgraded + high ticket activity

-- Identify plan changes for each customer
WITH plan_changes AS (SELECT s.customer_id, s.plan_id, p.plan_tier, s.start_date,
LAG(p.plan_tier) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS prev_tier
FROM subscriptions s
JOIN plans p 
ON s.plan_id = p.plan_id),

-- Filter only downgrades in the last 90 days
downgrades AS (SELECT *
FROM plan_changes
WHERE prev_tier IS NOT NULL AND plan_tier < prev_tier AND start_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY))

-- Count support tickets before downgrade
SELECT d.customer_id, d.prev_tier AS previous_plan, d.plan_tier AS current_plan,
COUNT(t.ticket_id) AS tickets_before_downgrade
FROM downgrades d
JOIN support_tickets t 
ON d.customer_id = t.customer_id
AND t.created_at BETWEEN DATE_SUB(d.start_date, INTERVAL 30 DAY) AND d.start_date
GROUP BY d.customer_id, d.prev_tier, d.plan_tier

-- Only include customers with high ticket activity (>3 tickets)
HAVING COUNT(t.ticket_id) > 3;