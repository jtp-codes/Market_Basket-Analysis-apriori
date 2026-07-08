CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

CREATE TABLE order_items (
    order_id INT,
    product_name VARCHAR(255)
);

CREATE TABLE step1_all_single_items AS
SELECT
    product_name,
    COUNT(*) AS total_purchases
FROM order_items
GROUP BY product_name;

CREATE TABLE step1_all_single_items AS
SELECT
    product_name,
    COUNT(*) AS total_purchases
FROM order_items
GROUP BY product_name;

CREATE TABLE step2_popular_single_items AS
SELECT *
FROM step1_all_single_items
WHERE total_purchases > 1;

CREATE TABLE step3_all_pairs AS
SELECT
    a.product_name AS item_a,
    b.product_name AS item_b,
    COUNT(*) AS times_bought_together
FROM order_items a
JOIN order_items b
ON a.order_id=b.order_id
AND a.product_name<b.product_name
GROUP BY
    a.product_name,
    b.product_name;

CREATE TABLE step4_frequent_pairs_only AS
SELECT *
FROM step3_all_pairs
WHERE times_bought_together>1;

CREATE TABLE step5_support AS
SELECT
    item_a,
    item_b,
    times_bought_together,
    ROUND(
        times_bought_together/
        (SELECT COUNT(DISTINCT order_id) FROM order_items),
        4
    ) AS support
FROM step4_frequent_pairs_only;

CREATE TABLE step6_confidence AS
SELECT
    p.item_a,
    p.item_b,
    p.times_bought_together,
    s.total_purchases,
    ROUND(
        p.times_bought_together/s.total_purchases,
        4
    ) AS confidence
FROM step4_frequent_pairs_only p
JOIN step2_popular_single_items s
ON p.item_a=s.product_name;

CREATE TABLE step7_lift AS
SELECT
    c.item_a,
    c.item_b,
    c.confidence,
    b.total_purchases AS item_b_frequency,
    ROUND(
        c.confidence/
        (
            b.total_purchases/
            (SELECT COUNT(DISTINCT order_id) FROM order_items)
        ),
        4
    ) AS lift
FROM step6_confidence c
JOIN step2_popular_single_items b
ON c.item_b=b.product_name;

SELECT *
FROM step1_all_single_items
WHERE total_purchases >
(
    SELECT AVG(total_purchases)
    FROM step1_all_single_items
);

SELECT *
FROM step5_support
WHERE support=
(
    SELECT MAX(support)
    FROM step5_support
);
SELECT *
FROM step6_confidence
WHERE confidence=
(
    SELECT MAX(confidence)
    FROM step6_confidence
);
SELECT *
FROM step7_lift
WHERE lift=
(
    SELECT MAX(lift)
    FROM step7_lift
);
SELECT *
FROM step7_lift
ORDER BY lift DESC, confidence DESC
LIMIT 10;