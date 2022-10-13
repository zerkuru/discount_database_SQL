CREATE DATABASE IF NOT EXISTS discount_system;

USE discount_system;

# clients (данные о клиентах) 

DROP TABLE IF EXISTS clients;
CREATE TABLE clients (
  id SERIAL PRIMARY KEY,
  external_id VARCHAR(255) NOT NULL,
  name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Имя покупателя',
  surname VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Фамилия',
  second_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Отчество или второе имя',
  birthday DATE NOT NULL COMMENT 'Дата рождения',
  phone VARCHAR(255) NOT NULL COMMENT 'Телефон', 
  discount_card_code VARCHAR(255) COMMENT 'Код текущей дисконтной карты', 
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

# cities (города)
DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  external_id VARCHAR(255) NOT NULL,
  name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Города';




# shops (магазины)
DROP TABLE IF EXISTS shops;
CREATE TABLE shops(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  external_id VARCHAR(255) NOT NULL,
  name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Название',
  city_id INT UNSIGNED NOT NULL,
  internet_shop BOOLEAN NOT NULL DEFAULT FALSE,
  shop_birthday DATE NOT NULL COMMENT 'Дата открытия магазина',
  delivery_point BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (city_id)  REFERENCES cities (id)
) COMMENT = 'Склады магазины';


# address (адрес клиента)
DROP TABLE IF EXISTS address;
CREATE TABLE address (
	  id SERIAL PRIMARY KEY,
      address_st           varchar(255), 
      city_id           INT UNSIGNED NOT NULL,
      country           varchar(255),
      post_code         int(11),
      client_id 		BIGINT UNSIGNED NOT NULL,
      FOREIGN KEY (client_id)  REFERENCES clients (id),
      FOREIGN KEY (city_id)  REFERENCES cities (id)
);

#catalogs (группы товаров каталога)
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  external_id VARCHAR(255) NOT NULL,
  name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Название раздела'
) COMMENT = 'Разделы каталога продукции';

#product_types (типы товаров для аналитики)
DROP TABLE IF EXISTS product_types;
CREATE TABLE product_types (
  id SERIAL PRIMARY KEY,
  external_id VARCHAR(255) NOT NULL,
  name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Название типа'
) COMMENT = 'Типы товаров для аналитики';

# products (товары)
DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  external_id VARCHAR(255) NOT NULL,
  name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  COMMENT 'Название',
  desription TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  COMMENT 'Описание',
  catalog_id BIGINT UNSIGNED NOT NULL,
  product_type_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id),
FOREIGN KEY (catalog_id)  REFERENCES catalogs (id),
FOREIGN KEY (product_type_id)  REFERENCES product_types (id)
) 
COMMENT = 'Товарные позиции';


# sales (общие данные о продажах и возвратах)
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  external_id VARCHAR(255) NOT NULL,
  client_id BIGINT UNSIGNED NOT NULL,
  sale_type ENUM('sale', 'return') NOT NULL DEFAULT 'sale' COMMENT 'Продажа или возврат',
  discount INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Процент скидки', 
  total_sum DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'Сумма без скидки',
  discount_sum DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'Сумма скидки',
  sum DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'Сумма со скидкой',
  payed_bonus INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Оплачено бонусами',
  added_bonus INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Начислено бонусов',
  sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  shop_id INT UNSIGNED NOT NULL,
  FOREIGN KEY (client_id)  REFERENCES clients (id),
  FOREIGN KEY (shop_id)  REFERENCES shops (id)
) COMMENT = 'Продажи и возвраты';


# sales_products (данные о товарах в продажах и возвратах, сюда вносятся данные из внешнего файла по конкретным продажам)
DROP TABLE IF EXISTS sales_products;
CREATE TABLE sales_products (
  id SERIAL PRIMARY KEY,
  sales_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  line_number INT UNSIGNED NOT NULL,
  quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
  price DECIMAL(15,2) UNSIGNED NOT NULL DEFAULT 0,
  total_sum DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'Сумма без скидки',
  discount_sum DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'Сумма скидки',
  sum DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'Сумма со скидкой',
  payed_bonus INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Оплачено бонусами',
  added_bonus INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Начислено бонусов',
  FOREIGN KEY (sales_id)  REFERENCES sales (id),
  FOREIGN KEY (product_id)  REFERENCES products (id)
) COMMENT = 'Продажи и возвраты данные по товарам';


# bonuses (данные о начислении и списании бонусов, в том числе продажами и возвратами)
DROP TABLE IF EXISTS bonuses;
CREATE TABLE bonuses (
  id SERIAL PRIMARY KEY,
  client_id BIGINT UNSIGNED NOT NULL,
  sales_id BIGINT UNSIGNED,
  doc_id BIGINT UNSIGNED,
  quantity INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id)  REFERENCES clients (id)
) COMMENT = 'начисления и списания бонусов';

# action_types (типы акций)
DROP TABLE IF EXISTS action_types;
CREATE TABLE action_types(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Название',
  external_id VARCHAR(255) NOT NULL,
  desription TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  COMMENT 'Описание',
  summing BOOLEAN DEFAULT TRUE COMMENT 'Суммируется или нет с другими акциями',
  client_birthday BOOLEAN DEFAULT FALSE COMMENT 'Действует только в день рождения',
  shop_birthday BOOLEAN DEFAULT FALSE COMMENT 'Действует только в годовщину открытия магазина',
  internet BOOLEAN DEFAULT FALSE COMMENT 'Действует только в интернет-магазинах',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT = 'Акции типы';


# actions (все текущие акции компании)
DROP TABLE IF EXISTS actions;
CREATE TABLE actions(
  id SERIAL PRIMARY KEY,
  action_type_id INT UNSIGNED NOT NULL,
  shop_id INT UNSIGNED NOT NULL,
  product_type_id BIGINT UNSIGNED,
  catalog_id BIGINT UNSIGNED,
  dicount_percent INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (action_type_id)  REFERENCES action_types (id),
  FOREIGN KEY (shop_id)  REFERENCES shops (id)
) COMMENT = 'Акции текущие';


# bonus_docs (дополнительные документы начисления и списания бонусов в честь какой-то акции или коррекции баланса по запросу клиента, независимо от продаж)
DROP TABLE IF EXISTS bonus_docs;
CREATE TABLE bonus_docs (
  id SERIAL PRIMARY KEY,
  client_id BIGINT UNSIGNED NOT NULL,
  external_id VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  operation_description VARCHAR(255) NOT NULL,
  operation_type ENUM('birthday', 'shop_birthday', 'decreasing', 'increasing') NOT NULL,
  bonus INT NOT NULL DEFAULT 0 COMMENT 'сумма бонусов',
  discount INT UNSIGNED DEFAULT 0 COMMENT 'процент постоянной скидки',
  FOREIGN KEY (client_id)  REFERENCES clients (id)
) COMMENT = 'иные операции по бонусам';



# bonus_balance (текущий баланс бонусов клиента, изменяется после каждого движения бонусов)
DROP TABLE IF EXISTS bonus_balance;
CREATE TABLE bonus_balance (
  id SERIAL PRIMARY KEY,
  client_id BIGINT UNSIGNED NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id)  REFERENCES clients (id)
) COMMENT = 'текущий баланс бонусов';




#current_discount (текущая постоянная скидка клиента)


DROP TABLE IF EXISTS current_discount;
CREATE TABLE current_discount (
  id SERIAL PRIMARY KEY,
  client_id BIGINT UNSIGNED NOT NULL,
  discount INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id)  REFERENCES clients (id)
) COMMENT = 'текущий процент постоянной скидки';




ALTER TABLE products ADD INDEX (external_id);
ALTER TABLE sales ADD INDEX (external_id);
ALTER TABLE clients ADD INDEX (external_id);
ALTER TABLE action_types ADD INDEX (external_id);
ALTER TABLE products ADD INDEX (external_id);
ALTER TABLE products ADD INDEX place_catalog (id, catalog_id, product_type_id);
ALTER TABLE clients ADD INDEX age (birthday);
ALTER TABLE sales ADD INDEX (sum, total_sum, discount_sum);