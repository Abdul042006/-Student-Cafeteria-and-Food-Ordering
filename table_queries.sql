-- =========================================
-- 1. DATABASE
-- =========================================

DROP DATABASE IF EXISTS cafeteria_management_system;

CREATE DATABASE cafeteria_management_system;

USE cafeteria_management_system;


-- =========================================
-- 2. STUDENT TABLE
-- =========================================

CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    Department VARCHAR(100),
    Year INT
);

DROP TABLE Student;
SELECT * FROM Student;


-- =========================================
-- 3. CAFETERIA TABLE
-- =========================================

CREATE TABLE Cafeteria (
    CafeteriaID INT PRIMARY KEY,
    CafeteriaName VARCHAR(100) NOT NULL,
    Location VARCHAR(100),
    Phone VARCHAR(15),
    Status VARCHAR(20)
);

SELECT * FROM Cafeteria;


-- =========================================
-- 4. FOOD ITEM TABLE
-- =========================================

CREATE TABLE FoodItem (
    FoodID INT PRIMARY KEY,
    CafeteriaID INT NOT NULL,
    FoodName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (CafeteriaID)
        REFERENCES Cafeteria(CafeteriaID)
);

SELECT * FROM FoodItem;


-- =========================================
-- 5. ORDERS TABLE
-- =========================================

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    StudentID INT NOT NULL,
    CafeteriaID INT NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    OrderStatus VARCHAR(30),

    FOREIGN KEY (StudentID)
        REFERENCES Student(StudentID),

    FOREIGN KEY (CafeteriaID)
        REFERENCES Cafeteria(CafeteriaID)
);

SELECT * FROM Orders;

-- =========================================
-- 6. ORDER ITEM TABLE
-- =========================================

CREATE TABLE OrderItem (
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    FoodID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    FOREIGN KEY (FoodID)
        REFERENCES FoodItem(FoodID)
);

SELECT * FROM OrderItem;

-- =========================================
-- 7. PAYMENT TABLE
-- =========================================

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(30),
    PaymentStatus VARCHAR(30),

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
);

SELECT * FROM Payment;

-- =========================================
-- 8. DELIVERY TABLE
-- =========================================

CREATE TABLE Delivery (
    DeliveryID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    DeliveryAddress VARCHAR(200),
    DeliveryStatus VARCHAR(30),

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
);

SELECT * FROM Delivery;

-- =========================================
-- CHECK ALL TABLES
-- =========================================

SHOW TABLES;

DESC Student;
DESC Cafeteria;
DESC FoodItem;
DESC Orders;
DESC OrderItem;
DESC Payment;
DESC Delivery;