-- ============================================================
-- ADVANCED SQL IMPLEMENTATION
-- STUDENT CAFETERIA / FOOD ORDERING MANAGEMENT SYSTEM
-- MySQL 8.0+
-- ============================================================


USE cafeteria_management_system;


-- ============================================================
-- 1. COMPLEX INNER JOIN
-- ============================================================
-- Business Requirement:
-- Display each order with student, cafeteria and total items.
-- ============================================================

SELECT
    o.OrderID,
    s.Name,
    c.CafeteriaName,
    o.TotalAmount,
    o.OrderStatus,
    COUNT(oi.OrderItemID) AS TotalItems
FROM Orders o
INNER JOIN Student s
    ON o.StudentID = s.StudentID
INNER JOIN Cafeteria c
    ON o.CafeteriaID = c.CafeteriaID
INNER JOIN OrderItem oi
    ON o.OrderID = oi.OrderID
GROUP BY
    o.OrderID,
    s.Name,
    c.CafeteriaName,
    o.TotalAmount,
    o.OrderStatus;

-- ============================================================
-- 2. COMPLEX OUTER JOIN
-- ============================================================
-- Business Requirement:
-- Display every cafeteria, including cafeterias
-- that do not have food items.
-- ============================================================

SELECT
    c.CafeteriaID,
    c.CafeteriaName,
    c.Location,
    COUNT(f.FoodID) AS TotalFoodItems
FROM Cafeteria c
LEFT OUTER JOIN FoodItem f
    ON c.CafeteriaID = f.CafeteriaID
GROUP BY
    c.CafeteriaID,
    c.CafeteriaName,
    c.Location
ORDER BY TotalFoodItems DESC;


-- ============================================================
-- 3. COMPLEX MULTI-TABLE OUTER JOIN
-- ============================================================
-- Business Requirement:
-- Display every student, their orders,
-- cafeteria and ordered food items.
-- Students without orders should also appear.
-- ============================================================

SELECT
    s.StudentID,
    s.Name,
    o.OrderID,
    c.CafeteriaName,
    f.FoodName,
    oi.Quantity,
    oi.Price,
    o.TotalAmount,
    o.OrderStatus
FROM Student s
LEFT JOIN Orders o
    ON s.StudentID = o.StudentID
LEFT JOIN Cafeteria c
    ON o.CafeteriaID = c.CafeteriaID
LEFT JOIN OrderItem oi
    ON o.OrderID = oi.OrderID
LEFT JOIN FoodItem f
    ON oi.FoodID = f.FoodID
ORDER BY
    s.StudentID,
    o.OrderID;


-- ============================================================
-- 4. SELF JOIN
-- ============================================================
-- Business Requirement:
-- Find pairs of students belonging to the same department.
-- ============================================================

SELECT
    s1.StudentID AS Student1_ID,
    s1.Name AS Student1,
    s2.StudentID AS Student2_ID,
    s2.Name AS Student2,
    s1.Department
FROM Student s1
INNER JOIN Student s2
    ON s1.Department = s2.Department
    AND s1.StudentID < s2.StudentID
ORDER BY s1.Department;

-- ============================================================
-- 5. CORRELATED SUBQUERY
-- ============================================================
-- Business Requirement:
-- Find orders whose amount is greater than
-- the average order amount of that student.
-- ============================================================

SELECT
    s.StudentID,
    s.Name,
    o.OrderID,
    o.TotalAmount
FROM Student s
INNER JOIN Orders o
    ON s.StudentID = o.StudentID
WHERE o.TotalAmount >
(
    SELECT AVG(o2.TotalAmount)
    FROM Orders o2
    WHERE o2.StudentID = s.StudentID
)
ORDER BY
    s.StudentID,
    o.TotalAmount DESC;


-- ============================================================
-- 6. CORRELATED SUBQUERY WITH EXISTS
-- ============================================================
-- Business Requirement:
-- Find students who have placed at least one order.
-- ============================================================

SELECT
    s.StudentID,
    s.Name,
    s.Email,
    s.Department
FROM Student s
WHERE EXISTS
(
    SELECT 1
    FROM Orders o
    WHERE o.StudentID = s.StudentID
)
ORDER BY s.StudentID;


-- ============================================================
-- 7. AGGREGATE + GROUP BY + HAVING
-- ============================================================
-- Business Requirement:
-- Find cafeterias having more than one order.
-- ============================================================

SELECT
    s.StudentID,
    s.Name,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    COALESCE(SUM(o.TotalAmount), 0) AS TotalSpent
FROM Student s
LEFT JOIN Orders o
    ON s.StudentID = o.StudentID
GROUP BY
    s.StudentID,
    s.Name
HAVING COUNT(DISTINCT o.OrderID) > 0
ORDER BY TotalSpent DESC;

-- ============================================================
-- 8. AGGREGATE BUSINESS REPORT
-- ============================================================
-- Business Requirement:
-- Display student ordering activity.
-- ============================================================

SELECT
    s.StudentID,
    s.Name,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    COALESCE(SUM(o.TotalAmount), 0) AS TotalSpent
FROM Student s
LEFT JOIN Orders o
    ON s.StudentID = o.StudentID
GROUP BY
    s.StudentID,
    s.Name
HAVING
    COUNT(DISTINCT o.OrderID) > 0
ORDER BY
    TotalSpent DESC;


-- ============================================================
-- 9. FOOD ITEM SALES REPORT
-- ============================================================
-- Business Requirement:
-- Display food items with total quantity sold.
-- ============================================================

SELECT
    f.FoodID,
    f.FoodName,
    f.Category,
    SUM(oi.Quantity) AS TotalQuantitySold,
    SUM(oi.Quantity * oi.Price) AS TotalRevenue
FROM FoodItem f
INNER JOIN OrderItem oi
    ON f.FoodID = oi.FoodID
GROUP BY
    f.FoodID,
    f.FoodName,
    f.Category
HAVING SUM(oi.Quantity) > 0
ORDER BY
    TotalQuantitySold DESC;


-- ============================================================
-- 10. STORED PROCEDURE
-- ============================================================
-- Business Requirement:
-- Create a new order after validating Student and Cafeteria.
-- ============================================================

DROP PROCEDURE IF EXISTS sp_create_order;

DELIMITER $$

CREATE PROCEDURE sp_create_order(
    IN p_student_id INT,
    IN p_cafeteria_id INT,
    IN p_total_amount DECIMAL(10,2),
    IN p_order_status VARCHAR(30)
)
BEGIN

    DECLARE v_student_count INT DEFAULT 0;
    DECLARE v_cafeteria_count INT DEFAULT 0;

    START TRANSACTION;

    -- Validate Student
    SELECT COUNT(*)
    INTO v_student_count
    FROM Student
    WHERE StudentID = p_student_id;

    -- Validate Cafeteria
    SELECT COUNT(*)
    INTO v_cafeteria_count
    FROM Cafeteria
    WHERE CafeteriaID = p_cafeteria_id;

    -- Invalid Student
    IF v_student_count = 0 THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Student ID';

    -- Invalid Cafeteria
    ELSEIF v_cafeteria_count = 0 THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Cafeteria ID';

    -- Invalid Amount
    ELSEIF p_total_amount <= 0 THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Total amount must be greater than 0';

    ELSE

        INSERT INTO Orders
        (
            StudentID,
            CafeteriaID,
            TotalAmount,
            OrderStatus
        )
        VALUES
        (
            p_student_id,
            p_cafeteria_id,
            p_total_amount,
            p_order_status
        );

        COMMIT;

        SELECT
            LAST_INSERT_ID() AS NewOrderID,
            'Order created successfully' AS Message;

    END IF;

END$$

DELIMITER ;


-- ============================================================
-- TEST STORED PROCEDURE
-- ============================================================

-- Example:
-- CALL sp_create_order(1, 1, 250.00, 'Pending');


-- ============================================================
-- 11. TRIGGER + AUDIT TABLE
-- ============================================================
-- Business Requirement:
-- Every order update should automatically be recorded.
-- ============================================================

CREATE TABLE IF NOT EXISTS order_update_audit
(
    AuditID INT AUTO_INCREMENT PRIMARY KEY,

    OrderID INT NOT NULL,

    OldAmount DECIMAL(10,2),
    NewAmount DECIMAL(10,2),

    OldStatus VARCHAR(30),
    NewStatus VARCHAR(30),

    ChangedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 12. CREATE UPDATE AUDIT TRIGGER
-- ============================================================

DROP TRIGGER IF EXISTS trg_order_update_audit;

DELIMITER $$

CREATE TRIGGER trg_order_update_audit
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN

    INSERT INTO order_update_audit
    (
        OrderID,
        OldAmount,
        NewAmount,
        OldStatus,
        NewStatus
    )
    VALUES
    (
        OLD.OrderID,
        OLD.TotalAmount,
        NEW.TotalAmount,
        OLD.OrderStatus,
        NEW.OrderStatus
    );

END$$

DELIMITER ;


-- ============================================================
-- TEST TRIGGER
-- ============================================================

-- Example:
-- UPDATE Orders
-- SET OrderStatus = 'Delivered'
-- WHERE OrderID = 1;


-- ============================================================
-- VERIFY AUDIT
-- ============================================================

SELECT *
FROM order_update_audit
ORDER BY AuditID DESC;


-- ============================================================
-- 13. VIRTUAL VIEW 1
-- ============================================================
-- Business Reporting:
-- Complete order details.
-- ============================================================

DROP VIEW IF EXISTS vw_order_business_report;

CREATE VIEW vw_order_business_report AS
SELECT
    o.OrderID,
    s.Name,
    c.CafeteriaName,
    o.TotalAmount,
    o.OrderStatus,
    COUNT(oi.OrderItemID) AS TotalItems
FROM Orders o
INNER JOIN Student s
    ON o.StudentID = s.StudentID
INNER JOIN Cafeteria c
    ON o.CafeteriaID = c.CafeteriaID
LEFT JOIN OrderItem oi
    ON o.OrderID = oi.OrderID
GROUP BY
    o.OrderID,
    s.Name,
    c.CafeteriaName,
    o.TotalAmount,
    o.OrderStatus;


-- Test View 1

SELECT *
FROM vw_order_business_report
ORDER BY TotalAmount DESC;


-- ============================================================
-- 14. VIRTUAL VIEW 2
-- ============================================================
-- Business Reporting:
-- Student order activity.
-- ============================================================

DROP VIEW IF EXISTS vw_student_business_report;

CREATE VIEW vw_student_business_report AS
SELECT
    s.StudentID,
    s.Name,
    s.Email,
    s.Department,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    COALESCE(SUM(o.TotalAmount), 0) AS TotalSpent
FROM Student s
LEFT JOIN Orders o
    ON s.StudentID = o.StudentID
GROUP BY
    s.StudentID,
    s.Name,
    s.Email,
    s.Department;

-- Test View 2

SELECT *
FROM vw_student_business_report
ORDER BY TotalSpent DESC;


-- ============================================================
-- 15. PERFORMANCE TEST - BEFORE INDEXING
-- ============================================================
-- Run EXPLAIN before creating additional indexes.
-- ============================================================

EXPLAIN
SELECT
    o.OrderID,
    s.Name,
    c.CafeteriaName,
    o.TotalAmount,
    o.OrderStatus
FROM Orders o
INNER JOIN Student s
    ON o.StudentID = s.StudentID
INNER JOIN Cafeteria c
    ON o.CafeteriaID = c.CafeteriaID
WHERE o.CafeteriaID = 1
ORDER BY o.TotalAmount DESC;


-- ============================================================
-- 16. SECOND PERFORMANCE QUERY
-- ============================================================

EXPLAIN
SELECT
    o.OrderID,
    o.StudentID,
    COUNT(oi.OrderItemID) AS TotalItems,
    SUM(oi.Quantity * oi.Price) AS OrderValue
FROM Orders o
LEFT JOIN OrderItem oi
    ON o.OrderID = oi.OrderID
WHERE o.CafeteriaID = 1
GROUP BY
    o.OrderID,
    o.StudentID
ORDER BY OrderValue DESC;


-- ============================================================
-- 17. CREATE PERFORMANCE INDEXES
-- ============================================================

-- Composite index:
-- Cafeteria filtering + amount sorting

CREATE INDEX idx_orders_cafeteria_amount
ON Orders(CafeteriaID, TotalAmount);


-- Composite index:
-- Order + Food lookup

CREATE INDEX idx_orderitem_order_food
ON OrderItem(OrderID, FoodID);


-- Additional index:
-- Student order searching

CREATE INDEX idx_orders_student
ON Orders(StudentID);


-- ============================================================
-- 18. PERFORMANCE TEST - AFTER INDEXING
-- ============================================================

EXPLAIN
SELECT
    o.OrderID,
    s.Name,
    c.CafeteriaName,
    o.TotalAmount,
    o.OrderStatus
FROM Orders o
INNER JOIN Student s
    ON o.StudentID = s.StudentID
INNER JOIN Cafeteria c
    ON o.CafeteriaID = c.CafeteriaID
WHERE o.CafeteriaID = 1
ORDER BY o.TotalAmount DESC;


EXPLAIN
SELECT
    o.OrderID,
    o.StudentID,
    COUNT(oi.OrderItemID) AS TotalItems,
    SUM(oi.Quantity * oi.Price) AS OrderValue
FROM Orders o
LEFT JOIN OrderItem oi
    ON o.OrderID = oi.OrderID
WHERE o.CafeteriaID = 1
GROUP BY
    o.OrderID,
    o.StudentID
ORDER BY OrderValue DESC;


-- ============================================================
-- 19. EXPLAIN ANALYZE
-- ============================================================
-- MySQL 8.0.18+
-- ============================================================

EXPLAIN ANALYZE
SELECT
    o.OrderID,
    s.Name,
    c.CafeteriaName,
    o.TotalAmount,
    o.OrderStatus
FROM Orders o
INNER JOIN Student s
    ON o.StudentID = s.StudentID
INNER JOIN Cafeteria c
    ON o.CafeteriaID = c.CafeteriaID
WHERE o.CafeteriaID = 1
ORDER BY o.TotalAmount DESC;


EXPLAIN ANALYZE
SELECT
    o.OrderID,
    o.StudentID,
    COUNT(oi.OrderItemID) AS TotalItems,
    SUM(oi.Quantity * oi.Price) AS OrderValue
FROM Orders o
LEFT JOIN OrderItem oi
    ON o.OrderID = oi.OrderID
WHERE o.CafeteriaID = 1
GROUP BY
    o.OrderID,
    o.StudentID
ORDER BY OrderValue DESC;


-- ============================================================
-- 20. INDEX INFORMATION
-- ============================================================

SHOW INDEX FROM Orders;

SHOW INDEX FROM OrderItem;


-- ============================================================
-- 21. FINAL TABLE CHECK
-- ============================================================

SHOW TABLES;


-- ============================================================
-- 22. FINAL VIEW CHECK
-- ============================================================

SHOW FULL TABLES
WHERE TABLE_TYPE = 'VIEW';


-- ============================================================
-- 23. FINAL PROCEDURE CHECK
-- ============================================================

SHOW PROCEDURE STATUS
WHERE Db = 'cafeteria_management_system';


-- ============================================================
-- 24. FINAL TRIGGER CHECK
-- ============================================================

SHOW TRIGGERS;


-- ============================================================
-- END OF ADVANCED SQL IMPLEMENTATION
-- ============================================================