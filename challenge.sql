USE SAKILA;

-- 1.
CREATE OR REPLACE VIEW customer_rental_summary AS
WITH customer_full_name AS (
    SELECT 
        customer_id,
        CONCAT(first_name, ' ', last_name) AS customer_name,
        email
    FROM customer
)
SELECT 
    cfn.customer_id,
    cfn.customer_name,
    cfn.email,
    COUNT(rental.rental_id) AS rental_count
FROM customer_full_name cfn
JOIN rental ON cfn.customer_id = rental.customer_id
GROUP BY cfn.customer_id, cfn.customer_name, cfn.email;

-- 2.
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id;

-- 3.

WITH final_report_cte AS (
    SELECT 
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM customer_rental_summary crs
    JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM final_report_cte
ORDER BY total_paid DESC;
