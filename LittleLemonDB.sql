USE little_lemon_db;

INSERT INTO Staffs (StaffID, StaffRole, StaffSalary)
VALUES
(1, 'Manager', 70000),
(2, 'Assistant Manager', 65000),
(3, 'Head Chef', 50000),
(4, 'Assistant Chef', 45000),
(5, 'Head Waiter', 40000),
(6, 'Receptionist', 35000);

INSERT INTO Customers (CustomerID, FullName, Email)
VALUES
(1, 'Anna Iversen','abc@gmail.com'),
(2, 'Joakim Iversen', 'xyz@a.com'),
(3, 'Vanessa McCarthy', 'hello@me.com'),
(4, 'Marcos Romero', 'mr@company.com'),
(5, 'Hiroki Yamane', 'hiroki@yamane'),
(6, 'Diana Pinto', 'dpinto@chef.net');

INSERT INTO Bookings (BookingID, TableNumber, BookingDate, CustomerID)
VALUES
(1, 12, '2025-04-26', 1),
(2, 12, '2025-04-27', 1),
(3, 19, '2025-04-26', 3),
(4, 15, '2025-04-26', 4),
(5, 5, '2025-04-26', 2),
(6, 8, '2025-04-26', 5);

INSERT INTO Menus (MenuID, MenuName, Cuisine, StarterName, CourseName, DrinkName, DesertName)
VALUES
(1, 'Menu Greek', 'Greek', 'Olives', 'Greek salad', 'Athens White wine', 'Greek yoghurt'),
(2, 'Menu Italian', 'Italian', 'Minestrone', 'Pizza', 'Italian Coffee', 'Cheesecake'),
(3, 'Menu Turkish', 'Turkish', 'Falafel', 'Kabasa', 'Turkish Coffee', 'Ice cream'),
(4, 'Menu Other', 'Other', 'Flatbread', 'Bean soup', 'Corfu Red Wine', 'Ice cream');

INSERT INTO Orders (OrderID, MenuID, CustomerID, TotalCost, OrderDate, Quantity, StaffID)
VALUES
(1, 1, 6, 100.50, '2025-04-26', 2, 3),
(2, 4, 4, 200.00, '2025-04-26', 1, 4),
(3, 3, 5, 60.90, '2025-04-26', 1, 2),
(4, 2, 2, 900.50, '2025-04-26', 1, 1),
(5, 3, 1, 85.00, '2025-04-26', 1, 4);

INSERT INTO Delivery (DeliveryID, DeliveryDate, DeliveryStatus, OrderID)
VALUES
(1, '2025-04-26', 'Done', 3),
(2, '2025-04-26', 'Cancelled', 4),
(3, '2025-04-26', 'On hold', 2),
(4, '2025-04-26', 'Done', 1),
(5, '2025-04-26', 'Done', 5);

INSERT INTO Orders (OrderID, MenuID, CustomerID, TotalCost, OrderDate, Quantity, StaffID)
VALUES
(6, 4, 4, 100.50, '2025-04-27', 5, 3),
(7, 2, 2, 200.00, '2025-04-27', 1, 4),
(8, 1, 1, 60.90, '2025-04-27', 3, 2),
(9, 2, 5, 900.50, '2025-04-27', 6, 1),
(10, 3, 3, 805.00, '2025-04-27', 7, 4);


-- Module 2 - Create a virtual table to summarize data - Task 1
CREATE VIEW OrdersView AS
SELECT OrderID, Quantity, TotalCost
FROM Orders
WHERE Quantity > 2;

SELECT * FROM OrdersView;

-- Module 2 - Create a virtual table to summarize data - Task 2
SELECT cm.CustomerID, cm.FullName, od.OrderID, od.TotalCost, mn.MenuName, mn.CourseName
FROM Customers cm INNER JOIN Orders od ON cm.CustomerID = od.CustomerID
					INNER JOIN Menus mn ON od.MenuID = mn.MenuID
WHERE od.TotalCost > 150
ORDER BY od.TotalCost ASC;

-- Module 2 - Create a virtual table to summarize data - Task 3:
SELECT MenuName
FROM Menus
WHERE MenuID = ANY
  (SELECT MenuID
  FROM Orders
  WHERE Quantity > 2);
  
  
-- Module 2 - Create optimized queries to manage and analyze data - Task 1:
DELIMITER //

CREATE PROCEDURE GetMaxQuantity()
BEGIN
	SELECT MAX(Quantity) AS 'Max Quantity in Orders' FROM Orders;
END //

DELIMITER ;

CALL GetMaxQuantity();


-- Module 2 - Create optimized queries to manage and analyze data - Task 2:
PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, TotalCost FROM Orders WHERE OrderID = ?';

SET @id=4;
EXECUTE GetOrderDetail USING @id;


-- Module 2 - Create optimized queries to manage and analyze data - Task 3:
DELIMITER //

CREATE PROCEDURE CancelOrder(
	IN CancelID INT
)
BEGIN
	DELETE FROM Orders
    WHERE OrderID = CancelID;
    
    SELECT CONCAT('Order ', CAST(CancelID AS CHAR), ' is cancelled') AS Confirmation;
END //

DELIMITER ;

CALL CancelOrder(5);

