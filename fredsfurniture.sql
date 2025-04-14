set search_path ='cc_user';

-- Ejercicio 1: Se inspecciona la tabla 'store' y se describe su contenido
SELECT *
FROM store
LIMIT 10;
/* La tabla 'store' contiene información combinada sobre órdenes, clientes e ítems. 
   Esta información puede ser dividida para lograr una base de datos normalizada. */

-- Ejercicio 2: Conteo de órdenes y clientes únicos
SELECT COUNT(DISTINCT(order_id)) FROM store;
SELECT COUNT(DISTINCT(customer_id)) FROM store;

-- Ejercicio 3: Información del cliente con ID 1
SELECT customer_id, customer_email, customer_phone
FROM store
WHERE customer_id = 1;

-- Ejercicio 4: Información del ítem con ID 4
SELECT item_1_id, item_1_name, item_1_price
FROM store
WHERE item_1_id = 4;

-- Ejercicio 5: Creación de tabla 'customers' con datos únicos
CREATE TABLE customers AS 
SELECT DISTINCT customer_id, customer_email, customer_phone
FROM store;

-- Ejercicio 6: Asignación de clave primaria en 'customers'
ALTER TABLE customers ADD PRIMARY KEY (customer_id);

-- Ejercicio 7: Creación de tabla 'items' consolidando ítems únicos
CREATE TABLE items AS 
SELECT DISTINCT item_1_id AS item_id, item_1_name AS item_name, item_1_price AS item_price
FROM store WHERE item_1_id IS NOT NULL
UNION
SELECT DISTINCT item_2_id, item_2_name, item_2_price FROM store WHERE item_2_id IS NOT NULL
UNION
SELECT DISTINCT item_3_id, item_3_name, item_3_price FROM store WHERE item_3_id IS NOT NULL;

-- Ejercicio 8: Asignación de clave primaria a 'items'
ALTER TABLE items ADD PRIMARY KEY (item_id);

-- Ejercicio 9: Creación de 'order_items' para la relación muchos-a-muchos entre órdenes e ítems
CREATE TABLE order_items AS 
SELECT order_id, item_1_id AS item_id FROM store WHERE item_1_id IS NOT NULL
UNION ALL
SELECT order_id, item_2_id FROM store WHERE item_2_id IS NOT NULL
UNION ALL
SELECT order_id, item_3_id FROM store WHERE item_3_id IS NOT NULL;

-- Ejercicio 10: Creación de tabla 'orders' con datos únicos
CREATE TABLE orders AS 
SELECT DISTINCT order_id, order_date, customer_id FROM store;

-- Ejercicio 11: Asignación de clave primaria a 'orders'
ALTER TABLE orders ADD PRIMARY KEY (order_id);

-- Ejercicio 12: Creación de claves foráneas entre tablas relacionadas
ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE order_items ADD FOREIGN KEY (item_id) REFERENCES items(item_id);

-- Ejercicio 13: Agregar clave foránea en 'order_items' para referenciar a 'orders'
ALTER TABLE order_items ADD CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Ejercicio 14: Consulta en 'store' para obtener emails de órdenes posteriores al 25 de julio de 2019
SELECT customer_email FROM store WHERE order_date > '2019-07-25';

-- Ejercicio 15: Misma consulta pero usando tablas normalizadas
SELECT customers.customer_email
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.order_date > '2019-07-25';

-- Ejercicio 16: Conteo de ítems por órdenes en tabla no normalizada
WITH all_items AS (
  SELECT item_1_id AS item_id FROM store WHERE item_1_id IS NOT NULL
  UNION ALL
  SELECT item_2_id FROM store WHERE item_2_id IS NOT NULL
  UNION ALL
  SELECT item_3_id FROM store WHERE item_3_id IS NOT NULL
)
SELECT item_id, COUNT(*) AS order_count
FROM all_items
GROUP BY item_id
ORDER BY item_id;

-- Ejercicio 17: Conteo de órdenes por ítem en tabla normalizada
SELECT item_id, COUNT(DISTINCT order_id) AS num_orders
FROM order_items
GROUP BY item_id
ORDER BY num_orders DESC;

-- Ejercicio 18.1: Clientes con más de una orden
SELECT c.customer_email, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_email
HAVING COUNT(o.order_id) > 1;

-- Ejercicio 18.2: Órdenes posteriores al 15 de julio 2019 que incluyen una 'lámpara'
SELECT COUNT(DISTINCT o.order_id) AS lamp_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN items i ON oi.item_id = i.item_id
WHERE o.order_date > '2019-07-15'
  AND LOWER(i.item_name) LIKE '%lamp%';

-- Ejercicio 18.3: Órdenes que incluyen una 'silla'
SELECT COUNT(DISTINCT o.order_id) AS chair_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN items i ON oi.item_id = i.item_id
WHERE LOWER(i.item_name) LIKE '%chair%';
