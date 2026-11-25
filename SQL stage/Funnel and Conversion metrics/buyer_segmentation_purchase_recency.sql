--Segments visitor's based on purchase recency. 

WITH purchase_stats AS(
    SELECT 
        visitor_id,
        transaction_id,
        MIN(event_date) AS purchase_date
    FROM events_clean
    WHERE transaction_id IS NOT NULL
    GROUP BY visitor_id,transaction_id
), 

gaps AS(
    SELECT *,
        LAG(purchase_date) OVER(
            PARTITION BY visitor_id
            ORDER BY purchase_date
        ) AS prev_purchase_date
    FROM purchase_stats
),
 segmentation AS(
SELECT 
    visitor_id,
    purchase_date,
    prev_purchase_date,
    (purchase_date - prev_purchase_date) AS gap_days,

    CASE
        WHEN (purchase_date - prev_purchase_date) <= 3  THEN 'Active Customer'
        WHEN (purchase_date - prev_purchase_date) BETWEEN 3 AND 7  THEN 'Weekly Customer'
        WHEN (purchase_date - prev_purchase_date) BETWEEN 7 AND 31 THEN 'Monthly Customer'
        WHEN (purchase_date - prev_purchase_date) BETWEEN 31 AND 61 THEN 'Lapsing Customer'
        ELSE 'Occasional Customer'
    END AS recency_behaviour
FROM gaps
WHERE prev_purchase_date IS NOT NULL
)

SELECT COUNT(
            CASE
                WHEN recency_behaviour = 'Active Customer' THEN visitor_id END) AS Active,
        
        COUNT(
            CASE
                WHEN recency_behaviour = 'Weekly Customer' THEN visitor_id END) AS Weekly,

        COUNT(
            CASE
                WHEN recency_behaviour = 'Monthly Customer' THEN visitor_id END) AS Monthly,

        COUNT(
            CASE
                WHEN recency_behaviour = 'Lapsing Customer' THEN visitor_id END) AS Lapsing,

        COUNT(
            CASE
                WHEN recency_behaviour = 'Occasional Customer' THEN visitor_id END) AS Occasional
FROM segmentation