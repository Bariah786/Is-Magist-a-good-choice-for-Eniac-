-- FINAL SCRIPT
USE magist;
-- Translate the products in English.
SELECT DISTINCT pcnt.product_category_name_english, p.product_category_name
FROM product_category_name_translation pcnt
LEFT JOIN products p 
USING (product_category_name);
-- What categories of tech products does Magist have?
-- 'audio' ,  'consoles_games', 'eletronicos', 'informatica_acessorios', 'pc_gamer', 'pcs', 'relogios_presentes', 'telefonia'
-- How many products of these tech categories have been sold ?
SELECT 
    p.product_category_name, 
    COUNT(DISTINCT oi.product_id) AS Sold_products
FROM
    products p
LEFT JOIN order_items oi 
USING (product_id)
WHERE product_category_name IN ('audio' ,  'consoles_games', 'eletronicos', 'informatica_acessorios', 'pc_gamer', 'pcs', 'relogios_presentes', 'telefonia')
GROUP BY product_category_name
ORDER BY COUNT(product_id) DESC;

-- What percentage does that represent from the overall number of products sold?
SELECT COUNT(DISTINCT oi.product_id) AS Total_number_of_TechProducts
FROM
    products p
LEFT JOIN order_items oi 
USING (product_id)
WHERE product_category_name IN ('audio' ,  'consoles_games', 'eletronicos', 'informatica_acessorios', 'pc_gamer', 'pcs', 'relogios_presentes', 'telefonia');

SELECT COUNT(DISTINCT oi.product_id) AS Total_number_of_Products
FROM
    products p
LEFT JOIN order_items oi 
USING (product_id);

SELECT ROUND((5027 / 32951)*100,2) AS Percentage_of_Techproducts;
-- 15.26%

-- What’s the average price of the products being sold?
SELECT ROUND(AVG(price),2) 
FROM order_items AS Average_price_of_products;  -- 120.65

SELECT ROUND(AVG(oi.price),2) AS Average_price_of_TechProducts
FROM
    products p
LEFT JOIN order_items oi 
USING (product_id)
WHERE product_category_name IN ('audio' ,  'consoles_games', 'eletronicos','informatica_acessorios', 
'pc_gamer', 'pcs', 'relogios_presentes', 'telefonia');  -- 132.8

-- Are expensive tech products popular?

SELECT DISTINCT pcnt.product_category_name_english, p.product_category_name, ROUND(AVG(oi.price),2) AS Average_Price,
CASE
  WHEN 1000 > AVG(oi.price) > 300 THEN 'Mid Range'
  WHEN AVG(oi.price) > 1000 THEN 'Expensive'
  ELSE 'Cheap'
END AS 'Comment' 
FROM product_category_name_translation pcnt
LEFT JOIN products p 
USING (product_category_name)
LEFT JOIN order_items oi USING(product_id)
WHERE product_category_name IN ('audio' ,  'consoles_games', 'eletronicos','informatica_acessorios', 
'pc_gamer', 'pcs', 'relogios_presentes', 'telefonia')
GROUP BY (pcnt.product_category_name);
-- NO, cheap Tech products are popular instead.

-- How many months of data are included in the magist database?
SELECT DISTINCT YEAR (order_purchase_timestamp) , MONTH(order_purchase_timestamp)
FROM orders;            -- 25 Months 

-- How many sellers are there?
SELECT COUNT(DISTINCT seller_id) FROM sellers AS Total_Sellers; -- 3095 sellers

-- How many Tech sellers are there?
SELECT COUNT(DISTINCT s.seller_id) AS Tech_Sellers
FROM sellers s  
LEFT JOIN order_items oi USING (seller_id)
LEFT JOIN products p USING (product_id)
WHERE product_category_name IN ('audio' ,  'consoles_games', 'eletronicos','informatica_acessorios', 
'pc_gamer', 'pcs', 'relogios_presentes', 'telefonia');  -- 539 Tech sellers

-- What percentage of overall sellers are Tech sellers?
SELECT ROUND((539/3095)*100,2)AS percentage_of_TechSellers;  -- 17.42

-- What is the total amount earned by all sellers?
SELECT DISTINCT(seller_id), SUM(price) AS Amount_Earned_by_Seller FROM order_items
GROUP BY (seller_id);
SELECT ROUND(SUM(price)) AS Total_Amount_Earned_by_Sellers FROM order_items
LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled'); -- 13494401 Euro

-- What is the total amount earned by all Tech sellers?
SELECT DISTINCT oi.seller_id AS Tech_Sellers, oi.price, p.product_category_name
FROM order_items oi
LEFT JOIN products p USING (product_id)
WHERE product_category_name IN ('audio' ,  'consoles_games', 'eletronicos','informatica_acessorios', 
'pc_gamer', 'pcs', 'relogios_presentes', 'telefonia');
SELECT ROUND(SUM(oi.price))
FROM order_items oi
LEFT JOIN products p USING (product_id)
LEFT JOIN
    orders o USING (order_id)
WHERE product_category_name IN ('audio' ,  'consoles_games', 'eletronicos','informatica_acessorios', 
'pc_gamer', 'pcs', 'relogios_presentes', 'telefonia') AND
o.order_status NOT IN ('unavailable' , 'canceled'); -- 3011795 Euro
SELECT ROUND((3011795/13494401)*100) AS TechSellers_Earning_percentage; -- 22%

-- The average monthly income of all sellers?
SELECT ROUND((13494401/3095)/25);  -- 174 Euro

-- In relation to the delivery time:
-- What’s the average time between the order being placed and the product being delivered?
SELECT order_id,
DATE(order_purchase_timestamp) AS Order_placed_at,
DATE(order_delivered_customer_date) AS Delivery_date,
DATEDIFF(DATE(order_delivered_customer_date) , DATE(order_purchase_timestamp)) AS date_difference
FROM orders;
SELECT ROUND(AVG
(DATEDIFF(DATE(order_delivered_customer_date) , DATE(order_purchase_timestamp)))) AS Average_delivery_days
FROM orders; -- 13 days

-- How many orders are delivered on time vs orders delivered with a delay?

SELECT 
    CASE 
        WHEN DATEDIFF( order_delivered_customer_date,order_estimated_delivery_date) > 0 THEN 'Delayed' 
        ELSE 'In Time'
    END AS delivery_status, 
COUNT(DISTINCT order_id) AS orders_count
FROM orders 
WHERE order_status = 'delivered'
AND order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;   -- Delayed 6665   In Time= 89805

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?

SELECT
CASE 
  WHEN DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) > '100' THEN 'Delay of more than 100 days.'
  WHEN DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) > '60' AND DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) <= '100' THEN 'Delay of more than 3 months.'
  WHEN DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) > '31' AND DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) <= '60' THEN 'Delay of more than a month.'
  WHEN DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) > '14' AND DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) <= '31' THEN 'Delay of more than 2 weeks.'
  WHEN DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) > '7' AND DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) <= '14' THEN 'Delay of more than a week.'
  WHEN DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) > '1' AND DATEDIFF( order_delivered_customer_date , order_estimated_delivery_date) <= '7' THEN 'Delay of few days.'
ELSE 'In Time'
END AS 'Delay_range' ,
ROUND(AVG(product_weight_g),1) AS weight_avg,
    MAX(product_weight_g) AS max_weight,
    MIN(product_weight_g) AS min_weight,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM orders o
LEFT JOIN order_items oi
    USING (order_id)
LEFT JOIN products p
    USING (product_id)
WHERE order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
AND order_status = 'delivered'
GROUP BY delay_range
ORDER BY max_weight DESC;
