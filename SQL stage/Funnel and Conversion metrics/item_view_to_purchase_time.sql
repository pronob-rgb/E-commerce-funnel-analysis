--How much time it takes for the item to did the first purchase??

WITH item_stats AS (
    SELECT 
        item_id,
        MIN(event_date) FILTER (WHERE event IN ('view','addtocart')) AS earliest_activity_date,
        MIN(event_date) FILTER (WHERE event = 'transaction') AS purchase_time
    FROM events_clean
    GROUP BY item_id
)

SELECT item_id,
    purchase_time - earliest_activity_date AS time_to_purchase,
    CASE
        WHEN (purchase_time - earliest_activity_date) = 0 THEN 'Same day'
        WHEN (purchase_time - earliest_activity_date) BETWEEN 1 AND 3 THEN 'Upto 3 days'
        WHEN (purchase_time - earliest_activity_date) BETWEEN 3 AND 7 THEN 'Upto a Week'
        WHEN (purchase_time - earliest_activity_date) BETWEEN 7 AND 14 THEN 'Upto two Weeks'
        WHEN (purchase_time - earliest_activity_date) BETWEEN 14 AND 31 THEN 'Upto a Month'
        WHEN (purchase_time - earliest_activity_date) BETWEEN 31 AND 61 THEN 'Upto two Months'
        WHEN (purchase_time - earliest_activity_date) BETWEEN 61 AND 92 THEN 'Upto three Months'
        ELSE 'More than a Quarter'
    END AS purchase_behaviour_status
FROM item_stats
WHERE earliest_activity_date IS NOT NULL AND purchase_time >= earliest_activity_date



