-- Q2: Window Functions
-- Rank customers by LTV within each plan tier

WITH customer_ltv AS (SELECT c.customer_id,p.plan_tier,SUM(s.mrr_usd) AS ltv
FROM customers c
JOIN subscriptions s 
ON c.customer_id = s.customer_id
JOIN plans p 
ON s.plan_id = p.plan_id
GROUP BY c.customer_id, p.plan_tier
)
SELECT customer_id, plan_tier, ltv,
-- Rank customers within each plan tier by LTV (highest first)
RANK() OVER (PARTITION BY plan_tier ORDER BY ltv DESC) AS rank_in_tier,
-- Compare each customer's LTV to the average LTV of their plan tier
ROUND((ltv - AVG(ltv) OVER (PARTITION BY plan_tier)) / AVG(ltv) OVER (PARTITION BY plan_tier) * 100, 2) AS pct_diff_from_avg
FROM customer_ltv;