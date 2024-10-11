USE db_new_hw2;

-- non-optimized

EXPLAIN SELECT
    p.product_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.price * o.quantity) AS total_sales
FROM
    orders o
JOIN
    products p ON o.product_id = p.product_id
JOIN
    customers c ON o.customer_id = c.customer_id
WHERE
    o.order_date >= CURDATE() - INTERVAL 1 YEAR
GROUP BY
    p.product_id, c.customer_id;


-- optimized

CREATE INDEX idx_order_time ON orders(order_date);
CREATE INDEX idx_order_product_customer ON orders(product_id, customer_id);
CREATE INDEX idx_product_id ON products(product_id);
CREATE INDEX idx_customer_id ON customers(customer_id);

-- cte (for date filtering, for orders that are not within last year)
EXPLAIN WITH RecentOrders AS (
    SELECT
        product_id,
        customer_id,
        quantity
    FROM
        orders
    WHERE
        order_date >= CURDATE() - INTERVAL 1 YEAR
)
SELECT
    p.product_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.price * ro.quantity) AS total_sales
FROM
    RecentOrders ro
JOIN
    products p ON ro.product_id = p.product_id
JOIN
    customers c ON ro.customer_id = c.customer_id
GROUP BY
    p.product_id, c.customer_id;

-- filtered data from the ro CTE is joined with products and customers thus reducing the overall processing required as compared to a non-optimized version
