--Segments visitor's based on purchase volume.

WITH purchase_stats AS(
    SELECT 
        visitor_id,
        COUNT(DISTINCT transaction_id) AS total_purchase
    FROM events_clean
    WHERE transaction_id IS NOT NULL
    GROUP BY visitor_id
),

purchase_frequency AS(
SELECT *,
    CASE
        WHEN total_purchase = 1 THEN 'One-time Customer'
        WHEN total_purchase <= 5 THEN 'Repeat Customer'
        ELSE 'Loyal Customer'
    END AS frequency_behaviour
FROM purchase_stats
)

SELECT 
    COUNT(
        CASE 
            WHEN frequency_behaviour = 'One-time Customer' THEN 
            visitor_id END) AS one_time_customer,
    
    COUNT(
        CASE 
            WHEN frequency_behaviour = 'Repeat Customer' THEN
            visitor_id END) AS repeat_customer,
    
    COUNT(
        CASE 
            WHEN frequency_behaviour = 'Loyal Customer' THEN
            visitor_id END) AS loyal_customer
FROM purchase_frequency
