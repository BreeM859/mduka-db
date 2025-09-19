-- Create DB 
CREATE DATABASE ecommerce_demo;

USE ecommerce_demo;

-- -------------------------------------------------------------------------
-- Customers / Users
-- -------------------------------------------------------------------------
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(30),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active TINYINT(1) DEFAULT 1,
  INDEX (last_name),
  INDEX (created_at)
) ENGINE=InnoDB;


-- Addresses (one customer may have many addresses)

CREATE TABLE addresses (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  label VARCHAR(50), -- e.g., 'Home', 'Work'
  recipient_name VARCHAR(150),
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100) NOT NULL,
  phone VARCHAR(30),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- -------------------------------------------------------------------------
-- Categories (product classification)
-- -------------------------------------------------------------------------
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(120) NOT NULL UNIQUE,
  parent_id INT DEFAULT NULL,
  description TEXT,
  INDEX (name),
  FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- -------------------------------------------------------------------------
-- Vendors (optional suppliers)
-- -------------------------------------------------------------------------
CREATE TABLE vendors (
  vendor_id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_name VARCHAR(150) NOT NULL,
  contact_email VARCHAR(255),
  phone VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------------------
-- Products
-- -------------------------------------------------------------------------
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  cost DECIMAL(10,2) NULL,
  category_id INT,
  vendor_id INT NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX (name),
  INDEX (price),
  FOREIGN KEY (category_id) REFERENCES categories(category_id) 
  FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id) 
);

-- -------------------------------------------------------------------------
-- Product images
-- -------------------------------------------------------------------------
CREATE TABLE product_images (
  image_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  url VARCHAR(1024) NOT NULL,
  is_primary TINYINT(1) DEFAULT 0,
  alt_text VARCHAR(255),
  sort_order INT DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(product_id) 
);

-- -------------------------------------------------------------------------
-- Inventory (simple stock tracking)
-- -------------------------------------------------------------------------
CREATE TABLE inventory (
  product_id INT PRIMARY KEY,
  quantity INT NOT NULL DEFAULT 0,
  safety_stock INT DEFAULT 0,
  last_restocked DATETIME,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- -------------------------------------------------------------------------
-- Product attributes (key-value pairs for flexible attributes)
-- -------------------------------------------------------------------------
CREATE TABLE product_attributes (
  attr_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  `key` VARCHAR(100) NOT NULL,
  `value` VARCHAR(255),
  INDEX (product_id, `key`),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- -------------------------------------------------------------------------
-- Reviews
-- -------------------------------------------------------------------------
CREATE TABLE reviews (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  customer_id INT,
  rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title VARCHAR(200),
  body TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id) 
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

-- -------------------------------------------------------------------------
-- Carts (simple persistent cart)
-- -------------------------------------------------------------------------
CREATE TABLE carts (
  cart_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

CREATE TABLE cart_items (
  cart_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  cart_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cart_id) REFERENCES carts(cart_id) 
  FOREIGN KEY (product_id) REFERENCES products(product_id) 
  UNIQUE KEY(cart_id, product_id)
);

-- -------------------------------------------------------------------------
-- Coupons / discounts
-- -------------------------------------------------------------------------
CREATE TABLE coupons (
  coupon_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255),
  discount_type ENUM('percent','fixed') NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL,
  valid_from DATE,
  valid_to DATE,
  usage_limit INT DEFAULT NULL, -- null = unlimited
  times_used INT DEFAULT 0
);

-- -------------------------------------------------------------------------
-- Orders and order items
-- -------------------------------------------------------------------------
CREATE TABLE orders (
  order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('pending','paid','processing','shipped','delivered','cancelled','refunded') DEFAULT 'pending',
  shipping_address_id INT,
  billing_address_id INT,
  coupon_id INT,
  subtotal DECIMAL(12,2) NOT NULL,
  shipping DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  discount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(12,2) NOT NULL,
  notes TEXT,
  INDEX (customer_id, order_date),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
  FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id)
  FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id)
  FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) 
);

CREATE TABLE order_items (
  order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  sku VARCHAR(50) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL,
  line_total DECIMAL(12,2) NOT NULL,
  INDEX (order_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- -------------------------------------------------------------------------
-- Payments
-- -------------------------------------------------------------------------
CREATE TABLE payments (
  payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  amount DECIMAL(12,2) NOT NULL,
  method ENUM('card','paypal','bank_transfer','cash_on_delivery') DEFAULT 'card',
  status ENUM('pending','completed','failed','refunded') DEFAULT 'pending',
  transaction_ref VARCHAR(255),
  payment_meta JSON,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- -------------------------------------------------------------------------
-- Shipments
-- -------------------------------------------------------------------------
CREATE TABLE shipments (
  shipment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  shipped_date DATETIME,
  carrier VARCHAR(100),
  tracking_number VARCHAR(200),
  status ENUM('label_created','in_transit','delivered','returned') DEFAULT 'label_created',
  shipping_meta JSON,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) 
);

-- -------------------------------------------------------------------------
-- Audit log (simple)
-- -------------------------------------------------------------------------
CREATE TABLE audit_logs (
  audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  entity VARCHAR(100),
  entity_id VARCHAR(50),
  action VARCHAR(50),
  performed_by VARCHAR(100),
  details JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX (entity, entity_id)
);
