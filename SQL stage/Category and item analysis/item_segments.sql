--Segmentation of items based on traffic and purchase.
WITH visitor_item AS (
    SELECT 
        item_id, 
        category_id, 
        visitor_id,
        BOOL_OR(event = 'view') AS viewed,
        BOOL_OR(event = 'addtocart') AS carted,
        BOOL_OR(event = 'transaction') AS bought
    FROM events_with_category
    WHERE category_id <> 'Unknown'
    GROUP BY item_id, category_id, visitor_id
),
item_funnel AS (
    SELECT category_id::INT AS category_id,
           item_id,
           COUNT(*) FILTER (WHERE viewed) AS total_viewers,
           COUNT(*) FILTER (WHERE viewed AND bought) AS viewers_who_bought,
           ROUND(100.0 * COUNT(*) FILTER (WHERE viewed AND bought)
                 / NULLIF(COUNT(*) FILTER (WHERE viewed), 0), 2) AS view_to_purchase_pct
    FROM visitor_item
    GROUP BY category_id, item_id
    HAVING COUNT(*) FILTER (WHERE viewed) > 50
),
category_benchmark AS (
    SELECT 
        category_id,
        COUNT(*) AS items_in_category,
        100.0 * SUM(viewers_who_bought) / NULLIF(SUM(total_viewers), 0) AS benchmark_pct
    FROM item_funnel
    GROUP BY category_id
),

scored AS (
    SELECT 
        item_funnel.*,
        items_in_category,
        benchmark_pct,
        NTILE(4) OVER (ORDER BY item_funnel.total_viewers DESC, item_funnel.item_id) AS traffic_quartile
    FROM item_funnel
    JOIN category_benchmark ON item_funnel.category_id = category_benchmark.category_id
),
segmented AS (
    SELECT *,
           CASE
               WHEN items_in_category < 5 THEN 'Insufficient peers'
               WHEN traffic_quartile <= 2 AND view_to_purchase_pct >= benchmark_pct THEN 'Star'
               WHEN traffic_quartile <= 2 THEN 'Problem item'
               WHEN view_to_purchase_pct >= benchmark_pct THEN 'Hidden gem'
               ELSE 'Long tail'
           END AS segment
    FROM scored
),
SELECT category_id,
       item_id,
       total_viewers,
       viewers_who_bought,
       view_to_purchase_pct,
       ROUND(benchmark_pct::NUMERIC, 2) AS category_benchmark_pct,
       traffic_quartile,
       segment,
       CASE WHEN segment = 'Problem item'
            THEN ROUND((total_viewers * (benchmark_pct - view_to_purchase_pct) / 100.0)::NUMERIC, 1)
       END AS est_extra_purchases
FROM segmented
ORDER BY est_extra_purchases DESC NULLS LAST, total_viewers DESC