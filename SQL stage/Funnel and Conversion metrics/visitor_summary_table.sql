--Visitor summary table.

WITH visitor_stats AS(
    SELECT
        visitor_id,
        MIN(event_date) AS first_activity_date,
        MAX(event_date) AS last_activity_date,

        COUNT(
            CASE
                WHEN event = 'view' THEN event
            END
        ) AS total_views,

        COUNT(
            CASE
                WHEN event = 'addtocart' THEN event
            END
        ) AS total_added_to_cart,

        COUNT(
            CASE
                WHEN event = 'transaction' THEN event
            END
        ) AS total_purchase
    FROM events_clean
    GROUP BY visitor_id
)

SELECT *,
    CASE
        WHEN total_added_to_cart > 0 AND total_purchase = 0 THEN 'Potential Customer'
        WHEN total_purchase BETWEEN 1 AND 3 THEN 'Customer'
        WHEN total_purchase >= 4 THEN 'Regular Customer'
        ELSE 'Viewer'
    END AS Flag_status
FROM visitor_stats
WHERE total_views > 10


