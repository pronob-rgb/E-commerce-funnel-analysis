--Pareto analysis to find how many items carry 80% of purchases.

/*CREATE OR REPLACE VIEW item_pareto AS
WITH item_totals AS (
    SELECT item_id,
           COUNT(DISTINCT transaction_id) FILTER (WHERE event = 'transaction') AS purchases,
           COUNT(*) FILTER (WHERE event = 'view') AS views
    FROM events_with_category
    GROUP BY item_id
),
purchased AS (
    SELECT * FROM item_totals WHERE purchases > 0
),
ranked AS (
    SELECT 
        item_id, purchases, views,
        ROW_NUMBER() OVER (ORDER BY purchases DESC, item_id) AS item_rank,

        SUM(purchases) OVER (
            ORDER BY purchases DESC, item_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_purchases,
        
        SUM(purchases) OVER ()  AS total_purchases,

           COUNT(*) OVER () AS purchased_items
    FROM purchased
)
SELECT 
    item_id, 
    purchases, 
    views, 
    item_rank, 
    cum_purchases,

    ROUND(100.0 * cum_purchases / total_purchases, 2) AS cum_purchase_pct,
    ROUND(100.0 * item_rank / purchased_items, 2) AS cum_item_pct,

    CASE WHEN cum_purchases - purchases < 0.8 * total_purchases
        THEN 'Top 80%' ELSE 'Tail' END AS pareto_group
FROM ranked;*/

SELECT 
    (SELECT COUNT(DISTINCT item_id) FROM events_with_category) AS all_items_in_catalog,
    COUNT(*) AS purchased_items,
    COUNT(*) FILTER (WHERE pareto_group = 'Top 80%') AS items_driving_80pct,
       ROUND(100.0 * COUNT(*) FILTER (WHERE pareto_group = 'Top 80%')
             / COUNT(*), 2) AS pct_of_purchased_items
FROM item_pareto;