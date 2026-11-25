--For estimating the upliftment of problem items.

SELECT item_id, category_id, total_viewers, view_to_purchase_pct,
       category_benchmark_pct, est_extra_purchases,
       ROUND(100.0 * SUM(est_extra_purchases) OVER (ORDER BY est_extra_purchases DESC, item_id
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
             / SUM(est_extra_purchases) OVER (), 2) AS cum_share_of_gap
FROM item_segments
WHERE segment = 'Problem item'
ORDER BY est_extra_purchases DESC, item_id
LIMIT 20;