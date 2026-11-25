--How much time does a customer take to did their first purchase??

WITH visitor_stats AS (
    SELECT visitor_id,
           MIN(event_date) FILTER (WHERE event IN ('view','addtocart')) AS earliest_activity_date,
           MIN(event_date) FILTER (WHERE event = 'transaction') AS purchase_time
    FROM events_clean
    GROUP BY visitor_id
),
segmentation AS(
    SELECT *, 
        purchase_time - earliest_activity_date AS time_to_purchase,
        CASE
            WHEN (purchase_time - earliest_activity_date) = 0 THEN 'Same day'
            WHEN (purchase_time - earliest_activity_date) BETWEEN 1 AND 3 THEN 'Upto 3 days'
            WHEN (purchase_time - earliest_activity_date) BETWEEN 3 AND 7  THEN 'Upto a Week'
            WHEN (purchase_time - earliest_activity_date) BETWEEN 7 AND 31 THEN 'Upto a Month'
            WHEN (purchase_time - earliest_activity_date) BETWEEN 31 AND 61 THEN 'Upto two Months'
            WHEN (purchase_time - earliest_activity_date) BETWEEN 61 AND 92 THEN 'Upto three Months'
            ELSE 'More than a Quarter'
        END AS purchase_behaviour_status
    FROM visitor_stats
    WHERE earliest_activity_date IS NOT NULL AND purchase_time >= earliest_activity_date
)

SELECT
    purchase_behaviour_status,

        COUNT(
            CASE
                WHEN purchase_behaviour_status = 'Same day' THEN visitor_id
                 WHEN purchase_behaviour_status = 'Upto 3 days' THEN visitor_id 
                WHEN purchase_behaviour_status = 'Upto a Week' THEN visitor_id
                WHEN purchase_behaviour_status = 'Upto a Month' THEN visitor_id
                WHEN purchase_behaviour_status = 'Upto two Months' THEN visitor_id
                WHEN purchase_behaviour_status = 'Upto three Months' THEN visitor_id
                WHEN purchase_behaviour_status = 'More than a Quarter' THEN visitor_id
            END
        ) AS total_number
FROM segmentation
GROUP BY purchase_behaviour_status



