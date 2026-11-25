--Item funnel rankings through window functions.

WITH category_stats AS(
    SELECT
        item_id,
        category_id,
        visitor_id,
        BOOL_OR(event = 'view') AS viewers,
        BOOL_OR(event = 'addtocart') AS carters,
        BOOL_OR(event = 'transaction') AS buyers
    FROM events_with_category
    GROUP BY item_id,category_id,visitor_id
),
aggregated_data AS(
    SELECT
        category_id::INT,
        item_id,
        COUNT(*) FILTER (WHERE viewers) AS total_viewers,
        COUNT(*) FILTER (WHERE carters) AS total_carters,
        COUNT(*) FILTER (WHERE buyers) AS total_purchases,
        COUNT(*) FILTER (WHERE carters AND NOT buyers) AS cart_abandoners,
        COUNT(*) FILTER (WHERE buyers AND NOT carters AND NOT viewers) AS anonymous_purchases,
        
        COALESCE(ROUND(
            100.0*COUNT(*) FILTER (WHERE carters)/
            NULLIF (COUNT(*) FILTER (WHERE viewers),0),2
        ),0.00) AS view_to_cart_pct,

        COALESCE(ROUND(
            100.0*COUNT(*) FILTER (WHERE buyers)/
            NULLIF (COUNT(*) FILTER (WHERE carters),0),2
        ),0.00) AS cart_to_purchase_pct,

        COALESCE(ROUND(
            100.0*COUNT(*) FILTER (WHERE buyers)/
            NULLIF (COUNT(*) FILTER (WHERE viewers),0),2
        ),0.00) AS view_to_purchase_pct,

        COALESCE(ROUND(
            100.0*COUNT(*) FILTER (WHERE carters AND NOT buyers)/
            NULLIF (COUNT(*) FILTER (WHERE carters),0),2
        ),0.00) AS cart_abandoners_pct,

        COALESCE(ROUND(
            100.0*COUNT(*) FILTER (WHERE buyers AND NOT carters AND NOT viewers)/
            NULLIF (COUNT(*) FILTER (WHERE buyers),0),2
        ),0.00) AS anonymous_purchases_pct
    FROM category_stats
    WHERE category_id <> 'Unknown'
    GROUP BY item_id,category_id
    HAVING COUNT(*) FILTER (WHERE viewers) > 50
),

category_benchmark AS (
    SELECT 
        category_id,
        PERCENTILE_CONT(0.5) WITHIN GROUP 
            (ORDER BY view_to_purchase_pct
            ) AS median_conversion_pct
    FROM aggregated_data
    GROUP BY category_id
),

ranked AS (
    SELECT 
        aggregated_data.category_id,
        item_id,
        median_conversion_pct,

        DENSE_RANK() OVER(
            PARTITION BY aggregated_data.category_id
            ORDER BY total_purchases DESC
        ) AS purchase_rank,

        ROW_NUMBER() OVER(
        PARTITION BY aggregated_data.category_id
        ORDER BY total_purchases DESC, item_id
        ) AS rn,

        PERCENT_RANK() OVER(
        PARTITION BY aggregated_data.category_id
        ORDER BY view_to_purchase_pct
        ) AS conversion_percentile,

        NTILE(4) OVER(
        ORDER BY total_viewers DESC, item_id) AS traffic_quartile

    FROM aggregated_data
    JOIN category_benchmark ON aggregated_data.category_id = category_benchmark.category_id
)
SELECT  
    category_id,
    item_id,
    median_conversion_pct,
    ROUND(conversion_percentile::NUMERIC,3) AS conversion_percentile,
    purchase_rank,
    traffic_quartile,
    rn AS top_items_per_category
FROM ranked
WHERE rn <= 5;