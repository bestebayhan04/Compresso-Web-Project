CREATE DATABASE IF NOT EXISTS ecommerce_db;

USE ecommerce_db;

-- Create dependent tables first
CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    tax_id VARCHAR(20),
    password_hash VARCHAR(256) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Managers (
    manager_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    role ENUM('sales_manager', 'product_manager') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Managers (manager_id, first_name, last_name, email, password_hash, role)
VALUES
(1, 'Arya', 'Hassibi', 'arya@manager.com', SHA2('admin12345', 256), 'sales_manager'),
(2, 'Beste', 'Bayhan', 'beste@manager.com', SHA2('admin12345', 256), 'product_manager'),
(3, 'Mustafa', 'Topcu', 'mustafa@manager.com', SHA2('admin12345', 256), 'sales_manager'),
(4, 'Orhun', 'Ege Ozpay', 'orhun@manager.com', SHA2('admin12345', 256), 'product_manager'),
(5, 'Eid', 'Alhamali', 'eid@manager.com', SHA2('admin12345', 256), 'sales_manager'),
(6, 'Ecem', 'Akın', 'ecem@manager.com', SHA2('admin12345', 256), 'product_manager'),
(7, 'Zeynep', 'Işık', 'zeynep@manager.com', SHA2('admin12345', 256), 'product_manager'),
(8, 'Cemal', 'Yılmaz', 'cemal@manager.com', SHA2('admin12345', 256), 'product_manager'),
(9, 'Sales', 'Manager', 'sales@manager.com', SHA2('admin12345', 256), 'sales_manager'),
(10, 'Product', 'Manager', 'product@manager.com', SHA2('admin12345', 256), 'product_manager');


CREATE TABLE IF NOT EXISTS Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);


CREATE TABLE IF NOT EXISTS Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    origin VARCHAR(100),
    roast_level ENUM('Light', 'Medium', 'Dark', 'French', 'Espresso') NOT NULL,
    bean_type ENUM('Arabica', 'Robusta', 'Liberica', 'Blend') NOT NULL,
    grind_type ENUM('Whole Bean', 'Ground', 'Other') DEFAULT 'Whole Bean',
    flavor_profile VARCHAR(255),
    processing_method ENUM('Washed', 'Natural', 'Honey-processed', 'Other') DEFAULT 'Other',
    caffeine_content ENUM('High', 'Decaf', 'Half-Caf') DEFAULT 'High',
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    category_id INT,
    description TEXT,
    warranty_status BOOLEAN DEFAULT FALSE,
    distributor_info TEXT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Product_Variant (
    variant_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    weight_grams INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    sku VARCHAR(50),
    serial_number VARCHAR(100) UNIQUE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Product_Images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    variant_id INT NOT NULL,
    image_url VARCHAR(500),
    alt_text VARCHAR(255),
    FOREIGN KEY (variant_id) REFERENCES Product_Variant(variant_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS DeliveryOptions (
    delivery_option_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    description TEXT
);


CREATE TABLE IF NOT EXISTS Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    content TEXT,
    approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('processing', 'in-transit', 'delivered', 'canceled') DEFAULT 'processing',
    delivery_option_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_option_id) REFERENCES DeliveryOptions(delivery_option_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    variant_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES Product_Variant(variant_id) ON DELETE SET NULL  -- I have changed here
);


CREATE TABLE IF NOT EXISTS Address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    address_name VARCHAR(25),
    user_id INT DEFAULT NULL,
    order_id INT DEFAULT NULL,
    address_line VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    phone_number VARCHAR(25) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS Invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    user_id INT,
    invoice_pdf BLOB,  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    discount_type ENUM('percentage', 'fixed') NOT NULL,
    value DECIMAL(10, 2) NOT NULL,  
    start_date DATE,                
    end_date DATE,                 
    variant_id INT,              
    active BOOLEAN DEFAULT TRUE,  
    FOREIGN KEY (variant_id) REFERENCES Product_Variant(variant_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS WishlistItems (
    wishlist_item_id INT AUTO_INCREMENT PRIMARY KEY,
    wishlist_id INT NOT NULL,
    variant_id INT NOT NULL, -- Linked to Product_Variant
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (wishlist_id) REFERENCES Wishlist(wishlist_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES Product_Variant(variant_id) ON DELETE CASCADE,
    UNIQUE(wishlist_id, variant_id) -- Prevent duplicate variants in a single wishlist
);

CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL,
    card_holder_name VARCHAR(100) NOT NULL,
    card_number VARBINARY(256) NOT NULL,  -- Store encrypted card number
    card_expiration DATE NOT NULL,
    cvv VARBINARY(256) NOT NULL,          -- Store encrypted CVV
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS RefundRequests (
    refund_request_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    variant_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',  
    reason TEXT,
    reject_reason TEXT DEFAULT NULL,  
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES Product_Variant(variant_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS ShoppingCart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,  -- Nullable to support guests
    session_id VARCHAR(255),  -- Unique session identifier for guest users
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS ShoppingCartItems (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES ShoppingCart(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES Product_Variant(variant_id) ON DELETE CASCADE
);

GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'root'@'%';
FLUSH PRIVILEGES;

