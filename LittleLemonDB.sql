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


-- Module 2 - Adding sales reports - Create a virtual table to summarize data - Task 1
CREATE VIEW OrdersView AS
SELECT OrderID, Quantity, TotalCost
FROM Orders
WHERE Quantity > 2;

SELECT * FROM OrdersView;

-- Module 2 - Adding sales reports - Create a virtual table to summarize data - Task 2
SELECT cm.CustomerID, cm.FullName, od.OrderID, od.TotalCost, mn.MenuName, mn.CourseName
FROM Customers cm INNER JOIN Orders od ON cm.CustomerID = od.CustomerID
					INNER JOIN Menus mn ON od.MenuID = mn.MenuID
WHERE od.TotalCost > 150
ORDER BY od.TotalCost ASC;

-- Module 2 - Adding sales reports - Create a virtual table to summarize data - Task 3:
SELECT MenuName
FROM Menus
WHERE MenuID = ANY
  (SELECT MenuID
  FROM Orders
  WHERE Quantity > 2);
  
  
-- Module 2 - Adding sales reports - Create optimized queries to manage and analyze data - Task 1:
DELIMITER //

CREATE PROCEDURE GetMaxQuantity()
BEGIN
	SELECT MAX(Quantity) AS 'Max Quantity in Orders' FROM Orders;
END //

DELIMITER ;

CALL GetMaxQuantity();


-- Module 2 - Adding sales reports - Create optimized queries to manage and analyze data - Task 2:
PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, TotalCost FROM Orders WHERE OrderID = ?';

SET @id=4;
EXECUTE GetOrderDetail USING @id;


-- Module 2 - Adding sales reports - Create optimized queries to manage and analyze data - Task 3:
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


-- Module 2 - Table booking system - Create SQL queries to check available bookings based on user input - Task 1:
INSERT INTO Bookings (BookingID, TableNumber, BookingDate, CustomerID)
VALUES
(7, 5, '2025-04-28', 1),
(8, 3, '2025-04-28', 3),
(9, 2, '2025-04-29', 2),
(10, 2, '2025-04-28', 1),
(11, 5, '2025-04-28', 2),
(12, 8, '2025-04-29', 5);

-- Module 2 - Table booking system - Create SQL queries to check available bookings based on user input - Task 2:
DELIMITER //

CREATE PROCEDURE CheckBooking(
	IN CheckDate DATE,
    IN CheckTable INT
)
BEGIN
	DECLARE NoBooking INT DEFAULT 0;
    
    SELECT COUNT(BookingID) INTO NoBooking
    FROM Bookings
    WHERE BookingDate = CheckDate AND TableNumber = CheckTable;
    
    SELECT CONCAT('Table ', CAST(CheckTable AS CHAR), ' is ',
    CASE
		WHEN NoBooking > 0 THEN 'already booked'
        ELSE 'available'
    END
    ) AS 'Booking status';
END //

DELIMITER ;

CALL CheckBooking('2025-04-28', 6);


-- Module 2 - Table booking system - Create SQL queries to check available bookings based on user input - Task 3:
DELIMITER //

CREATE PROCEDURE AddValidBooking(
	IN CheckDate DATE,
    IN CheckTable INT
)
BEGIN
	DECLARE NoBooking INT DEFAULT 0;
    
    START TRANSACTION;
       
    SELECT COUNT(BookingID) INTO NoBooking
    FROM Bookings
    WHERE BookingDate = CheckDate AND TableNumber = CheckTable;
    
    IF NoBooking = 0 THEN
		BEGIN
			INSERT INTO Bookings (BookingID, TableNumber, BookingDate, CustomerID) VALUES (13, CheckTable, CheckDate, 1);
			COMMIT;
            SELECT CONCAT('Table ', CAST(CheckTable AS CHAR), ' is successfully booked') AS 'Booking status';
		END;
    ELSE
		BEGIN
			SELECT CONCAT('Table ', CAST(CheckTable AS CHAR), ' is already booked - booking cancelled') AS 'Booking status';
		END;
	END IF;
    
    ROLLBACK;
    
END //

DELIMITER ;

CALL AddValidBooking('2025-04-28', 6);

SELECT * FROM Bookings;

-- Module 2 - Table booking system - Create SQL queries to add and update bookings - Task 1:
DELIMITER //

CREATE PROCEDURE AddBooking(
	IN AddID INT,
    IN AddTable INT,
    IN AddDate DATE,
    IN AddCustomerID INT
)
BEGIN
	INSERT INTO Bookings (BookingID, TableNumber, BookingDate, CustomerID) VALUES (AddID, AddTable, AddDate, AddCustomerID);
	SELECT CONCAT('New booking added') AS 'Confirmation';
	    
END //

DELIMITER ;

CALL AddBooking(14, 4,'2025-04-28', 3);


-- Module 2 - Table booking system - Create SQL queries to add and update bookings - Task 2:
DELIMITER //

CREATE PROCEDURE UpdateBooking(
	IN UpdateID INT,
    IN UpdateDate DATE
)
BEGIN
	UPDATE Bookings
    SET BookingDate = UpdateDate
    WHERE BookingID = UpdateID;
	SELECT CONCAT('Booking ',CAST(UpdateID AS CHAR) ,' updated') AS 'Confirmation';
	    
END //

DELIMITER ;

CALL UpdateBooking(11, '2025-04-25');


-- Module 2 - Table booking system - Create SQL queries to add and update bookings - Task 3:
DELIMITER //

CREATE PROCEDURE CancelBooking(
	IN DeleteID INT
)
BEGIN
	DELETE FROM Bookings
    WHERE BookingID = DeleteID;
	SELECT CONCAT('Booking ',CAST(DeleteID AS CHAR) ,' cancelled') AS 'Confirmation';
	    
END //

DELIMITER ;

CALL CancelBooking(14);

SELECT * FROM Bookings;