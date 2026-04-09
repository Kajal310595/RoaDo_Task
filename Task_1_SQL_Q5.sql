-- Q5: Advanced (Duplicate Detection)
-- Q5: Detect potential duplicate customers based on email domain and company name similarity


SELECT c1.customer_id AS cust1, c2.customer_id AS cust2,
c1.company_name, c2.company_name,
c1.contact_email, c2.contact_email
FROM customers c1
JOIN customers c2 
-- Self-join customers table to compare pairs of customers
ON c1.customer_id < c2.customer_id
WHERE 
-- Condition 1: Same email domain
SUBSTRING_INDEX(c1.contact_email, '@', -1) = SUBSTRING_INDEX(c2.contact_email, '@', -1)
-- Condition 2: Similar company name
AND LOWER(c1.company_name) LIKE CONCAT('%', LOWER(c2.company_name), '%');