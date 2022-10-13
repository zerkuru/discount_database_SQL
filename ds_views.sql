#views
# название товара, суммарное количество в продажах 

CREATE VIEW sold_products
AS
SELECT 
sales_products.product_id AS product_id,
products.name AS product_name, 
SUM(sales_products.sum) AS sum
FROM
sales_products LEFT JOIN products ON sales_products.product_id = products.id
GROUP BY product_id, product_name
ORDER BY product_name; 



# клиент, его ИД, полное имя, возраст, баланс бонусов, текущая скидка

CREATE VIEW clients_information
AS
SELECT 
cl.id AS client,
CONCAT(cl.name, ' ', SUBSTRING(cl.second_name, 1, 1), '. ', cl.surname) as full_name,
cl.external_id AS id,
(YEAR(CURRENT_DATE)-YEAR(cl.birthday))-(RIGHT(CURRENT_DATE,5)< RIGHT(cl.birthday,5)) as age,
bb.balance as b_balance,
cd.discount as discount
FROM clients cl
LEFT JOIN 
(SELECT  
bonus_balance.client_id AS client_id,
MAX(bonus_balance.quantity) AS balance
FROM bonus_balance GROUP BY client_id) AS bb ON cl.id = bb.client_id
LEFT JOIN 
(SELECT
current_discount.client_id AS client_id,
MAX(current_discount.discount) AS discount
FROM current_discount
GROUP BY client_id) AS cd ON cl.id = cd.client_id;





