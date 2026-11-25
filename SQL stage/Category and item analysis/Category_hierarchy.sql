--Category hierarchy step.

CREATE TABLE category_hierarchy AS

WITH RECURSIVE category_hierarchy AS (

    -- ANCHOR: start with the top-level categories (the roots)
    SELECT
        category_id,
        category_id AS top_level_id,   -- a root is its own top level
        1 AS depth
    FROM category_tree_clean ct
    WHERE ct.parent_id IS NULL
       OR NOT EXISTS (                 -- also treat orphans (parent missing from the table) as roots
            SELECT 1 FROM category_tree_clean p
            WHERE p.category_id = ct.parent_id
       )

    UNION ALL

    -- RECURSIVE STEP: find children of anything already found
    SELECT
        c.category_id,
        h.top_level_id,                -- children inherit their parent's top level
        h.depth + 1
    FROM category_tree_clean c
    JOIN category_hierarchy h ON c.parent_id = h.category_id
    WHERE h.depth < 10                 -- safety stop in case of a loop
)
SELECT * FROM category_hierarchy;

