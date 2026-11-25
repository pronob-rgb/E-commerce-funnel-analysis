--Item based funnel.

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
)

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



