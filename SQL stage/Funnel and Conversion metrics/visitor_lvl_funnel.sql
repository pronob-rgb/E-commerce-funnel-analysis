/* Aggregate visitor level funnel
    a) View-to-cart rate
    b) Cart-to-purchase rate
    c) Overall view-to-purchase conversion rate
    d) Cart abandonment rate (visitors who added to cart but never bought)
    e) Time from first view to purchase*/

WITH visitor_flags AS (
    SELECT 
        visitor_id,
        BOOL_OR(event = 'view') AS viewed,
        BOOL_OR(event = 'addtocart') AS carted,
        BOOL_OR(event = 'transaction') AS bought
    FROM events_clean
    GROUP BY visitor_id
    
)

SELECT 
       COUNT(*) FILTER (WHERE viewed) AS viewers,
       COUNT(*) FILTER (WHERE carted) AS carters,
       COUNT(*) FILTER (WHERE bought) AS buyers,
       COUNT(*) FILTER (WHERE carted AND NOT bought) AS abandoners,
       COUNT(*) FILTER (WHERE bought AND NOT viewed AND NOT carted) AS anonymous_buyers,

       ROUND(100.0 * COUNT(*) FILTER (WHERE carted)
             / NULLIF(COUNT(*) FILTER (WHERE viewed), 0), 2) AS carters_pct,

       ROUND(100.0 * COUNT(*) FILTER (WHERE bought)
             / NULLIF(COUNT(*) FILTER (WHERE carted), 0), 2) AS buyers_pct,

       ROUND(100.0 * COUNT(*) FILTER (WHERE carted AND NOT bought)
             / NULLIF(COUNT(*) FILTER (WHERE carted), 0), 2) AS cart_abandonment_pct,

       ROUND(100.0 * COUNT(*) FILTER (WHERE bought AND NOT viewed AND NOT carted)
             / NULLIF(COUNT(*) FILTER (WHERE bought), 0), 2) AS anonymous_buyers_pct
FROM visitor_flags



