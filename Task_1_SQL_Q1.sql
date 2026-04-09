-- Q1: Joins + Aggregation
-- Plan-wise performance (last 6 months)

SELECT p.plan_name, COUNT(DISTINCT s.customer_id) AS active_customers,
-- Average monthly recurring revenue (MRR) per plan
ROUND(AVG(s.mrr_usd), 2) AS avg_monthly_revenue,
-- Tickets per customer per month: Total tickets in last 6 months / (customers * 6 months)
ROUND(COUNT(t.ticket_id) * 1.0 / NULLIF(COUNT(DISTINCT s.customer_id) * 6, 0),2) AS tickets_per_customer_per_month
FROM subscriptions s

-- Join to plans table to get plan names
JOIN plans p 
ON s.plan_id = p.plan_id

-- Left join to support_tickets to capture tickets raised by customers
LEFT JOIN support_tickets t 
ON s.customer_id = t.customer_id
AND t.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)

-- Only include currently active subscriptions
WHERE s.status = 'active'

-- Group results by plan name so metrics are calculated per plan
GROUP BY p.plan_name;

















