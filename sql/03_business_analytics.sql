-- ============================================================
-- Smart Retail Analytics Hub
-- Business Analytics Queries
-- Oracle SQL
-- ============================================================


-- ============================================================
-- 1. Daily KPI Dashboard
-- Tracks today's orders, revenue, and average order value
-- ============================================================

SELECT
    COUNT(*) AS orders_today,
    ROUND(SUM(total_amount), 2) AS revenue_today,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE TRUNC(order_datetime) = TRUNC(SYSDATE);


-- ============================================================
-- 2. Revenue Trend by Year and Month
-- Supports trend and seasonality analysis
-- ============================================================

SELECT
    dt.year_num,
    dt.month_num,
    SUM(fs.sales_revenue) AS total_revenue
FROM fact_sales fs
JOIN dim_time dt
    ON fs.time_key = dt.time_key
GROUP BY
    dt.year_num,
    dt.month_num
ORDER BY
    dt.year_num,
    dt.month_num;


-- ============================================================
-- 3. Product and Category Performance
-- Identifies high- and low-performing product lines
-- ============================================================

SELECT
    dp.category,
    dp.product_name,
    SUM(fs.units_sold) AS total_units,
    SUM(fs.sales_revenue) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_key = dp.product_key
GROUP BY
    dp.category,
    dp.product_name
ORDER BY
    dp.category,
    dp.product_name;


-- ============================================================
-- 4. Store Performance
-- Compares revenue across stores and locations
-- ============================================================

SELECT
    ds.location,
    ds.store_name,
    SUM(fs.sales_revenue) AS total_revenue
FROM fact_sales fs
JOIN dim_store ds
    ON fs.store_key = ds.store_key
GROUP BY
    ds.location,
    ds.store_name
ORDER BY
    ds.location,
    ds.store_name;


-- ============================================================
-- 5. Top 5 Customers by Lifetime Spending
-- Supports loyalty, retention, and targeted marketing
-- ============================================================

SELECT
    dc.first_name || ' ' || dc.last_name AS customer_name,
    SUM(fs.sales_revenue) AS total_spent
FROM fact_sales fs
JOIN dim_customer dc
    ON fs.customer_key = dc.customer_key
GROUP BY
    dc.first_name,
    dc.last_name
ORDER BY
    total_spent DESC
FETCH FIRST 5 ROWS ONLY;


-- ============================================================
-- 6. Multi-Dimensional Sales Analysis
-- Aggregates sales across category, location, and year
-- ============================================================

SELECT
    NVL(dp.category, 'ALL CATEGORIES') AS category,
    NVL(ds.location, 'ALL LOCATIONS') AS location,
    NVL(TO_CHAR(dt.year_num), 'ALL YEARS') AS year,
    SUM(fs.sales_revenue) AS total_sales
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_key = dp.product_key
JOIN dim_store ds
    ON fs.store_key = ds.store_key
JOIN dim_time dt
    ON fs.time_key = dt.time_key
GROUP BY CUBE(
    dp.category,
    ds.location,
    dt.year_num
)
ORDER BY
    dp.category,
    ds.location,
    dt.year_num;
