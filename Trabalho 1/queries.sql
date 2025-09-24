/* QUESTÃO 1
	Consulta de Vendas */

-- questão 1a foi utilizado o ano de 2017
SELECT
    s.store_id,
    s.store_name,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount / 100)), 2) AS total_sales_value
FROM
    stores s
JOIN
    orders o ON s.store_id = o.store_id
JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status = 4
    AND o.order_date BETWEEN '2017-1-1' AND '2017-12-31'
GROUP BY
    s.store_id, s.store_name
ORDER BY
    total_sales_value DESC;

-- questão 1b 
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,  
    EXTRACT(MONTH FROM order_date) AS month, 
    COUNT(order_id) AS total_orders  
FROM 
    orders
GROUP BY 
    EXTRACT(YEAR FROM order_date), 
    EXTRACT(MONTH FROM order_date)  
ORDER BY 
    year, month;
-- valor de venda por ano
SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount / 100)), 2) AS total_sales_value
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status = 4
GROUP BY
    EXTRACT(YEAR FROM o.order_date)
ORDER BY
    year;
-- valor de venda por mês
SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    EXTRACT(MONTH FROM o.order_date) AS month,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount / 100)), 2) AS total_sales_value
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status = 4
    AND o.order_date BETWEEN '2017-01-01' AND '2017-12-31'
GROUP BY
    EXTRACT(YEAR FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date)
ORDER BY
    year,
    month;

-- questão 1c
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_quantity_sold DESC;
-- razão entre o valor de venda e quantidade vendida
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount / 100)), 2) AS total_sales_value,
    ROUND(SUM(oi.list_price * (1 - oi.discount / 100)) / SUM(oi.quantity), 2) AS value_per_quantity_ratio
FROM
    order_items oi
JOIN
    products p ON oi.product_id = p.product_id
WHERE
	
GROUP BY
    p.product_id, p.product_name
ORDER BY
    value_per_quantity_ratio DESC;

-- questão 1d
SELECT 
    c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(o.order_id) AS total_orders
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, full_name
ORDER BY 
    total_orders DESC;

/* QUESTÃO 2 
	Consulta de Estoque */

-- Questão 2a
SELECT 
    p.product_id,
    p.product_name,
    COALESCE(SUM(st.quantity), 0) AS current_stock
FROM 
    products p
LEFT JOIN 
    stocks st ON p.product_id = st.product_id
GROUP BY 
    p.product_id, p.product_name
HAVING 
    COALESCE(SUM(st.quantity), 0) > 0
ORDER BY 
    p.product_id ASC;
-- questão 2b, foi utilizado o valor de 15 ou menos para o estoque
SELECT 
    p.product_id,
    p.product_name,
    COALESCE(SUM(st.quantity), 0) AS current_stock
FROM 
    products p
LEFT JOIN 
    stocks st ON p.product_id = st.product_id
GROUP BY 
    p.product_id, p.product_name
HAVING 
    COALESCE(SUM(st.quantity), 0) < 15
ORDER BY 
    p.product_id ASC;
-- questão 2c
SELECT 
    c.category_id,
    c.category_name,
    COALESCE(SUM(st.quantity), 0) AS total_stock
FROM 
    categories c
LEFT JOIN 
    products p ON c.category_id = p.category_id
LEFT JOIN 
    stocks st ON p.product_id = st.product_id
GROUP BY 
    c.category_id, c.category_name
ORDER BY 
    total_stock DESC;


/* QUESTÃO 3 
	Consulta de Desempenho de Vendas */
-- Questão 3a foi feita já ordenando por quem mais contribuiu em venda
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS staff_name,
    COALESCE(SUM(oi.quantity * (oi.list_price - oi.discount)), 0) AS total_sales_value
FROM
    staffs s
LEFT JOIN
    orders o ON s.staff_id = o.staff_id
LEFT JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY
    s.staff_id, s.first_name, s.last_name
ORDER BY
    total_sales_value DESC;
-- podemos olhar os que mais venderam em volume de itens vendidos
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS staff_name,
    COUNT(o.order_id) AS total_sales
FROM
    staffs s
LEFT JOIN
    orders o ON s.staff_id = o.staff_id
WHERE
    o.order_status = 4
GROUP BY
    s.staff_id, s.first_name, s.last_name
ORDER BY
    total_sales DESC;
-- podemos ter uma razão entre o valor de venda e a quantidade vendida
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS staff_name,
    COUNT(DISTINCT o.order_id) AS total_sales,
    SUM(oi.quantity * (oi.list_price - oi.discount)) AS total_sales_value,
    ROUND(SUM(oi.quantity * (oi.list_price - oi.discount)) / SUM(oi.quantity), 2) AS sales_to_value_ratio
FROM
    staffs s
LEFT JOIN
    orders o ON s.staff_id = o.staff_id
LEFT JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status = 4
GROUP BY
    s.staff_id, s.first_name, s.last_name
ORDER BY
    sales_to_value_ratio DESC;


/* QUESTÃO 4 
	Consulta de Análise de Clientes */
-- Consultar que periodo temos na base
SELECT
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date
FROM
    orders;

-- Questão 4a foi utilizado o ano de 2017
SELECT
    COUNT(DISTINCT customer_id) AS new_customers
FROM
    orders
WHERE
    order_date BETWEEN '2017-01-01' AND '2017-12-31'
    AND customer_id NOT IN (
        SELECT DISTINCT customer_id
        FROM orders
        WHERE order_date < '2017-01-01'
    );
-- Questão 4b
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    ROUND(COALESCE(SUM(oi.quantity * oi.list_price * (1 - oi.discount / 100)), 0), 2) AS total_spent
FROM
    customers c
LEFT JOIN
    orders o ON c.customer_id = o.customer_id
LEFT JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status = 4
GROUP BY
    c.customer_id, c.first_name, c.last_name
ORDER BY
    total_spent DESC;
-- Consultando novos clientes por ano
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM
        orders
    WHERE
        order_status = 4
    GROUP BY
        customer_id
)
SELECT
    EXTRACT(YEAR FROM fo.first_order_date) AS year,
    COUNT(*) AS new_customers
FROM
    first_orders fo
GROUP BY
    EXTRACT(YEAR FROM fo.first_order_date)
ORDER BY
    year;
-- Consultando novos clientes por mês
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM
        orders
    WHERE
        order_status = 4
    GROUP BY
        customer_id
)
SELECT
    EXTRACT(YEAR FROM fo.first_order_date) AS year,
    EXTRACT(MONTH FROM fo.first_order_date) AS month,
    COUNT(*) AS new_customers
FROM
    first_orders fo
GROUP BY
    EXTRACT(YEAR FROM fo.first_order_date),
    EXTRACT(MONTH FROM fo.first_order_date)
ORDER BY
    year, month;

/* QUESTÃO 5
	Consulta de Gerenciamento de Estoque */
-- Questão 5a, esta de forma descendente com minimo de 10 itens
SELECT
    s.store_id,
    p.product_id,
    p.product_name,
    SUM(st.quantity) AS total_stock
FROM
    products p
JOIN
    stocks st ON p.product_id = st.product_id
JOIN
    stores s ON st.store_id = s.store_id
GROUP BY
    s.store_id, p.product_id, p.product_name
HAVING
    SUM(st.quantity) > 10
ORDER BY
    total_stock DESC;

-- Questão 5b
WITH store_totals AS (
    SELECT
        s.store_id,
        s.store_name,
        SUM(st.quantity) AS total_stock
    FROM
        stores s
    JOIN
        stocks st ON s.store_id = st.store_id
    GROUP BY
        s.store_id, s.store_name
)
SELECT
    store_id,
    store_name,
    total_stock
FROM
    store_totals
WHERE
    total_stock = (SELECT MAX(total_stock) FROM store_totals)
   OR
    total_stock = (SELECT MIN(total_stock) FROM store_totals);



-- Verificação de gasto por pedido
SELECT
    o.order_id,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount / 100)), 2) AS total_order_value
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status = 4
GROUP BY
    o.order_id
ORDER BY
    o.order_id;
