-- Categories
INSERT INTO categories (name, slug) VALUES
  ('Laptops','laptops'),
  ('Accessories','accessories'),
  ('Phones','phones');

-- Vendors
INSERT INTO vendors (vendor_name, contact_email) VALUES
  ('Acme Tech','vendor@acme.example'),
  ('GadgetCo','sales@gadgetco.example');

-- Products
INSERT INTO products (sku,name,description,price,category_id,vendor_id)
VALUES
  ('SKU-LAP-001','Super Laptop','A powerful laptop',1299.99,1,1),
  ('SKU-MOU-001','Wireless Mouse','Bluetooth mouse',29.99,2,2),
  ('SKU-PHN-001','Smart Phone','Modern smartphone',699.00,3,2);

-- Inventory
INSERT INTO inventory (product_id, quantity, safety_stock) VALUES
  (1, 10, 2),
  (2, 100, 10),
  (3, 25, 5);

-- Customers
INSERT INTO customers (email,password_hash,first_name,last_name,phone)
VALUES
  ('john@example.com','$2y$...','John','Doe','+123456789'),
  ('jane@example.com','$2y$...','Jane','Smith','+123456780');

-- Addresses
INSERT INTO addresses (customer_id,label,recipient_name,line1,city,country,postal_code)
VALUES
  (1,'Home','John Doe','123 Main St','Townsville','USA','10001'),
  (2,'Home','Jane Smith','45 Market Ave','Citytown','USA','20002');
