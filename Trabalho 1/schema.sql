/* Query's feitas no pgAdmin utilizando Query Tool em PostgreSQL 16 */

CREATE DATABASE trabalho1_sql;

SELECT current_database();

/* Criar as tabelas com as PK, FK e restrições. */
CREATE TABLE brands(
  brand_id INTEGER PRIMARY KEY, brand_name VARCHAR(50)
  );

CREATE TABLE products(
  product_id INTEGER PRIMARY KEY, product_name VARCHAR(250),
  brand_id INTEGER, category_id INTEGER,
  model_year INTEGER,list_price NUMERIC(15,2) CHECK (list_price > 0)
);

CREATE TABLE stores(
  store_id INTEGER PRIMARY KEY, store_name VARCHAR(50), 
  phone VARCHAR(15),email VARCHAR(50),street VARCHAR(100),
  city VARCHAR(50),state VARCHAR(50),zip_code INTEGER
);

CREATE TABLE stocks(
  store_id INTEGER, product_id INTEGER, quantity INTEGER CHECK (quantity >= 0),
  FOREIGN KEY (store_id) REFERENCES stores (store_id),
  FOREIGN KEY (product_id) REFERENCES products (product_id)
  );

CREATE TABLE categories(
  category_id INTEGER PRIMARY KEY, category_name VARCHAR(50)
);

CREATE TABLE customers(
  customer_id INTEGER PRIMARY KEY, first_name VARCHAR (50),
  last_name VARCHAR (100), phone VARCHAR (50), email VARCHAR (150),
  street VARCHAR (50), city VARCHAR (50), state VARCHAR (2), zip_code INTEGER
);

CREATE TABLE staffs(
  staff_id INTEGER PRIMARY KEY, first_name VARCHAR (50),
  last_name VARCHAR (100), email VARCHAR (150), phone VARCHAR (50),
  active INTEGER, store_id INTEGER, manager_id INTEGER,
  FOREIGN KEY (store_id) REFERENCES stores (store_id)
);

CREATE TABLE orders(
  order_id INTEGER PRIMARY KEY, customer_id INTEGER, 
  order_status INTEGER, order_date DATE, required_date DATE, 
  shipped_date DATE, store_id INTEGER, staff_id INTEGER,
  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  FOREIGN KEY (store_id) REFERENCES stores (store_id),
  FOREIGN KEY (staff_id) REFERENCES staffs (staff_id)
);

CREATE TABLE order_items(
  order_id INTEGER, item_id INTEGER, product_id INTEGER, 
  quantity INTEGER CHECK (quantity > 0), list_price NUMERIC(15,2) CHECK (list_price > 0), 
  discount NUMERIC(5,2) CHECK (discount >=0), CHECK (list_price > discount),
  FOREIGN KEY (order_id) REFERENCES orders (order_id),
  FOREIGN KEY (product_id) REFERENCES products (product_id)
);


/* copiar os dados do CSV. */

COPY brands(brand_id,brand_name)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\brands.csv'
DELIMITER ','
CSV HEADER;

COPY products(product_id,product_name,brand_id,category_id,model_year,list_price)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\products.csv'
DELIMITER ','
CSV HEADER;

COPY stores(store_id,store_name,phone,email,street,city,state,zip_code)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\stores.csv'
DELIMITER ','
CSV HEADER;

COPY stocks(store_id,product_id,quantity)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\stocks.csv'
DELIMITER ','
CSV HEADER;

COPY categories(category_id,category_name)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\categories.csv'
DELIMITER ','
CSV HEADER;

COPY customers(customer_id,first_name,last_name,phone,email,street,city,state,zip_code)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\customers.csv'
DELIMITER ','
CSV HEADER;

COPY staffs(staff_id,first_name,last_name,email,phone,active,store_id,manager_id)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\staffs.csv'
DELIMITER ','
CSV HEADER
NULL AS 'NULL';

COPY orders(order_id,customer_id,order_status,order_date,required_date,shipped_date,store_id,staff_id)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\orders.csv'
DELIMITER ','
CSV HEADER
NULL AS 'NULL';

COPY order_items(order_id,item_id,product_id,quantity,list_price,discount)
FROM 'D:\Users\Choko\Downloads\dados_bike_store\order_items.csv'
DELIMITER ','
CSV HEADER;


