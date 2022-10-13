# triggers

DELIMITER ;;

# добавление движения бонусов и текущей скидки при добавлении продажи
DROP TRIGGER after_insert_sales;;
CREATE TRIGGER after_insert_sales
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
#bonuses
  IF new.sale_type = 'sale' THEN
    IF new.payed_bonus > 0 THEN
       INSERT INTO `bonuses` (`client_id`, `sales_id`, `doc_id`, `quantity`, `created_at`) VALUES (new.client_id, new.id, NULL, (-1)*new.payed_bonus, new.sale_date);
    END IF;
    IF new.added_bonus > 0 THEN
       INSERT INTO `bonuses` (`client_id`, `sales_id`, `doc_id`, `quantity`, `created_at`) VALUES (new.client_id, new.id, NULL, new.added_bonus, new.sale_date);
    END IF;
  ELSE
    IF new.payed_bonus > 0 THEN
       INSERT INTO `bonuses` (`client_id`, `sales_id`, `doc_id`, `quantity`, `created_at`) VALUES (new.client_id, new.id, NULL, new.payed_bonus, new.sale_date);
    END IF;
    IF new.added_bonus > 0 THEN
       INSERT INTO `bonuses` (`client_id`, `sales_id`, `doc_id`, `quantity`, `created_at`) VALUES (new.client_id, new.id, NULL, (-1)*new.added_bonus, new.sale_date);
    END IF;
  END IF;

 #скидка
SET @total_sale_sum = 
  (SELECT
  	SUM(sales.total_sum) 
  	FROM sales 
  	WHERE sales.client_id = new.client_id AND sales.sale_type = 'sales'
  	GROUP BY client_id);
  IF @total_sale_sum IS NULL
     OR @total_sale_sum < 1000 THEN

  UPDATE current_discount 
  SET 
    discount = 0
  WHERE
    client_id = new.client_id;

  ELSE 
    IF @total_sale_sum < 20000 THEN 
    UPDATE current_discount 
    SET 
    discount = @total_sale_sum DIV 1000
    WHERE
    client_id = new.client_id;
     
    ELSE 
    UPDATE current_discount 
    SET 
    discount = 20
    WHERE
    client_id = new.client_id;
    
    END IF;
  END IF;
END
;;

# пересчет баланса бонусов при добавлении движения бонусов
CREATE TRIGGER after_insert_bonuses
AFTER INSERT ON bonuses
FOR EACH ROW
BEGIN
  SET @balance = 
  (SELECT
  	SUM(bonuses.quantity) 
  	FROM bonuses 
  	WHERE bonuses.client_id = new.client_id 
  	GROUP BY client_id);
  UPDATE bonus_balance 
  SET 
    quantity = @balance
  WHERE
    client_id = new.client_id ;
END
;;



# пересчет текущей скидки
CREATE TRIGGER after_insert_sales
AFTER INSERT ON bonuses
FOR EACH ROW
BEGIN
  SET @balance = 
  (SELECT
  	SUM(bonuses.quantity) 
  	FROM bonuses 
  	WHERE bonuses.client_id = new.client_id 
  	GROUP BY client_id);
  UPDATE bonus_balance 
  SET 
    quantity = @balance
  WHERE
    client_id = new.client_id ;
END
;;



# function 
# возврат текущей скидки по данным клиента, магазина
CREATE FUNCTION sale_discount(
	client_id VARCHAR(255), 
	shop_id VARCHAR(255),
	sale_date DATE
) 
RETURNS INT UNSIGNED
DETERMINISTIC
BEGIN
    SET @client =
    (SELECT
    	clients.id FROM clients WHERE clients.external_id = client_id);
    SET @shop =
    (SELECT
    	shops.id FROM shops WHERE shops.external_id = shop_id);
    SET @current_discount_client = 
    (SELECT
  	MAX(current_discount.discount) 
  	FROM current_discount WHERE current_discount.client_id = @client GROUP BY current_discount.client_id);
  	SET @shop_discount =
  	(SELECT
      SUM(actions.dicount_percent) 
      FROM actions
      WHERE actions.shop_id = @shop
    GROUP BY actions.shop_id);

    IF @current_discount_client IS NOT NULL AND @current_discount_client > 0 THEN
    SET @total_discount = @current_discount_client;
    
    IF @shop_discount IS NOT NULL AND @shop_discount > 0 THEN
    SET @total_discount = @current_discount_client + @shop_discount;
    END IF;

    ELSE
    IF @shop_discount IS NOT NULL AND @shop_discount > 0 THEN
    SET @total_discount = @shop_discount;
    END IF;
    END IF;

	-- return the customer discount
	RETURN (@total_discount);
END;;
DELIMITER ;

