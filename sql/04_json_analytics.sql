-- ============================================================
-- Smart Retail Analytics Hub
-- JSON Analytics & Personalization
-- Oracle SQL / Oracle 23c-compatible JSON
-- ============================================================


-- ============================================================
-- 1. JSON Document Store
-- Stores flexible customer profiles and order information
-- ============================================================

CREATE TABLE customer_profiles (
    customer_id  NUMBER PRIMARY KEY,
    profile_data JSON
);

CREATE TABLE order_history (
    order_id    NUMBER PRIMARY KEY,
    order_data  JSON
);


-- ============================================================
-- 2. Example Customer Profile
-- Demonstrates semi-structured loyalty and preference data
-- ============================================================

INSERT INTO customer_profiles (
    customer_id,
    profile_data
)
VALUES (
    1,
    JSON_OBJECT(
        'customer_id' VALUE 1,
        'name' VALUE 'Alice Mason',
        'email' VALUE 'alice@mail.com',
        'loyalty_points' VALUE 1200,
        'preferences' VALUE JSON_OBJECT(
            'categories' VALUE JSON_ARRAY('snacks', 'beverages'),
            'favorite_store' VALUE 'The Store'
        )
    )
);


-- ============================================================
-- 3. Retrieve Customer JSON Profiles
-- ============================================================

SELECT
    customer_id,
    profile_data
FROM customer_profiles;


-- ============================================================
-- 4. Simulated JSON Relational Duality View
-- Combines relational customer and order data into
-- nested customer-order JSON documents
-- ============================================================

CREATE OR REPLACE VIEW customer_orders_json_v AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,

    JSON_ARRAYAGG(
        JSON_OBJECT(
            'order_id' VALUE o.order_id,
            'order_date' VALUE TO_CHAR(
                o.order_datetime,
                'YYYY-MM-DD'
            ),
            'total_amount' VALUE o.total_amount
        )
    ) AS orders_json

FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;


-- Example lookup
SELECT *
FROM customer_orders_json_v
WHERE customer_id = 1;


-- ============================================================
-- 5. Customer Preferences + Product Recommendations
-- Uses JSON preferences to match customers with products
-- and applies loyalty-based pricing
-- ============================================================

SELECT
    JSON_VALUE(
        cp.profile_data,
        '$.name'
    ) AS customer_name,

    jt.preferred_category,
    p.product_name,

    CASE
        WHEN JSON_VALUE(
            cp.profile_data,
            '$.loyalty_points'
        ) > 1000
        THEN ROUND(p.unit_price * 0.90, 2)
        ELSE p.unit_price
    END AS recommended_price

FROM customer_profiles cp

CROSS JOIN JSON_TABLE(
    cp.profile_data,
    '$.preferences.categories[*]'
    COLUMNS (
        preferred_category VARCHAR2(50) PATH '$'
    )
) jt

JOIN products p
    ON p.category = jt.preferred_category;
