USE department_store;

INSERT INTO Customer (Customer_id, Fname, Lname, Address, Total_Spent, Membership_Status) VALUES
(101, 'Priya',  'Sharma', 'A-101, Koregaon Park, Pune', 145000.00, 'Platinum'),
(102, 'Rohan',  'Mehta',  'B-202, Juhu, Mumbai',         89000.50, 'Gold'),
(103, 'Anjali', 'Singh',  'C-303, Indiranagar, Bengaluru',12500.75, 'Silver'),
(104, 'Vikram', 'Patel',  'D-404, Adyar, Chennai',         5600.00, 'Bronze'),
(105, 'Sunita', 'Rao',    'E-505, Salt Lake, Kolkata',    98000.00, 'Gold')
ON DUPLICATE KEY UPDATE
  Fname=VALUES(Fname), Lname=VALUES(Lname),
  Address=VALUES(Address), Total_Spent=VALUES(Total_Spent),
  Membership_Status=VALUES(Membership_Status);

INSERT INTO CustomerPhone (Customer_id, C_Phone_Number) VALUES
(101, '9820098200'),
(102, '9819098190'),
(103, '9611096110'),
(104, '9940099400'),
(105, '9830098300')
ON DUPLICATE KEY UPDATE C_Phone_Number = VALUES(C_Phone_Number);

INSERT INTO Department (Dept_id, Dept_name, Dept_type, Manager_id, ParentDept_id) VALUES
(1, 'Electronics',      'Retail', NULL, NULL),
(2, 'Mobiles & Laptops','Sales',  NULL, 1),
(3, 'Home Audio',       'Sales',  NULL, 1),
(4, 'Home Appliances',  'Retail', NULL, NULL),
(5, 'Kitchen Appliances','Sales', NULL, 4)
ON DUPLICATE KEY UPDATE
  Dept_name=VALUES(Dept_name), Dept_type=VALUES(Dept_type),
  ParentDept_id=VALUES(ParentDept_id);

INSERT INTO Employee (Employee_id, Manager_id, Dept_id, Emp_Fname, Emp_Lname, E_address, Email, Salary, Job_title) VALUES
(1, NULL, 1, 'Rajesh', 'Kumar', 'Flat 1, MG Road',  'rajesh.k@example.com', 120000.00, 'Director of Electronics'),
(2, 1,    2, 'Meera',  'Desai', 'Flat 2, SV Road',  'meera.d@example.com',   85000.00, 'Manager, Mobiles'),
(3, 2,    2, 'Sameer', 'Verma', 'Flat 3, FC Road',  'sameer.v@example.com',  55000.00, 'Sales Lead'),
(4, NULL, 4, 'Kavita', 'Nair',  'Flat 4, JM Road',  'kavita.n@example.com', 115000.00, 'Director of Appliances'),
(5, 4,    5, 'Deepak', 'Joshi', 'Flat 5, SB Road',  'deepak.j@example.com',  82000.00, 'Manager, Kitchen')
ON DUPLICATE KEY UPDATE
  Manager_id=VALUES(Manager_id), Dept_id=VALUES(Dept_id),
  Emp_Fname=VALUES(Emp_Fname), Emp_Lname=VALUES(Emp_Lname),
  E_address=VALUES(E_address), Email=VALUES(Email),
  Salary=VALUES(Salary), Job_title=VALUES(Job_title);

UPDATE Department SET Manager_id = 1 WHERE Dept_id = 1;
UPDATE Department SET Manager_id = 2 WHERE Dept_id IN (2, 3);
UPDATE Department SET Manager_id = 4 WHERE Dept_id = 4;
UPDATE Department SET Manager_id = 5 WHERE Dept_id = 5;

INSERT INTO EmployeePhone (Employee_id, E_Phone_Number) VALUES
(1, '8888800001'),
(2, '8888800002'),
(3, '8888800003'),
(4, '8888800004'),
(5, '8888800005')
ON DUPLICATE KEY UPDATE E_Phone_Number = VALUES(E_Phone_Number);

INSERT INTO Product (Product_ID, Prod_Name, Description, Dept_id, Stock_quantity, Brand) VALUES
(1001, 'ZenBook Pro Laptop', '15-inch OLED, 32GB RAM',         2,  50, 'Asus'),
(1002, 'Galaxy S25 Ultra',   '200MP Camera, AI Features',       2, 120, 'Samsung'),
(1003, 'SoundBar 9000',      'Dolby Atmos, Wireless Sub',       3,  80, 'SoundWave'),
(1004, 'Smart Air Purifier', 'HEPA filter, App controlled',     4, 100, 'AerPure'),
(1005, 'QuickMix Grinder',   '750W motor, 3 jars',              5, 200, 'Bharat Electrics'),
(1006, 'InstaPot Cooker',    '10-in-1 Electric Cooker',         5,  90, 'QuickCook')
ON DUPLICATE KEY UPDATE
  Prod_Name=VALUES(Prod_Name), Description=VALUES(Description),
  Dept_id=VALUES(Dept_id), Stock_quantity=VALUES(Stock_quantity),
  Brand=VALUES(Brand);

INSERT INTO TransactionTable (Transaction_id, Customer_id, Transaction_date, `Return`, Total_Amount) VALUES
(5001, 101, '2025-09-10', FALSE, 120000.00),
(5002, 102, '2025-09-12', FALSE,  84999.00),
(5003, 103, '2025-09-15', TRUE,    4999.00),  
(5004, 104, '2025-09-18', FALSE,   5600.00),
(5005, 101, '2025-09-22', FALSE,  25000.00),
(5006, 105, '2025-09-25', FALSE,  98000.00)
ON DUPLICATE KEY UPDATE
  Customer_id=VALUES(Customer_id),
  Transaction_date=VALUES(Transaction_date),
  `Return`=VALUES(`Return`),
  Total_Amount=VALUES(Total_Amount);

INSERT INTO Purchases (Transaction_id, Product_id, Quantity, Discount, Unit_Price) VALUES
(5001, 1001, 1,  4.00, 125000.00),
(5002, 1002, 1,  0.00,  84999.00),
(5003, 1005, 1,  0.00,   4999.00),
(5004, 1006, 1,  6.67,   6000.00),
(5005, 1003, 1,  0.00,  25000.00),
(5006, 1001, 1, 21.60, 125000.00)
ON DUPLICATE KEY UPDATE
  Quantity=VALUES(Quantity),
  Discount=VALUES(Discount),
  Unit_Price=VALUES(Unit_Price);

INSERT INTO PaymentMethod (Transaction_id, Method) VALUES
(5001, 'Credit Card'),
(5002, 'UPI'),
(5003, 'Debit Card'),
(5004, 'Cash'),
(5005, 'Credit Card'),
(5006, 'Finance')
ON DUPLICATE KEY UPDATE Method=VALUES(Method);

INSERT INTO LoyaltyProgram (Customer_id, Transaction_id, Amount, Type, Date_earned, Date_redeemed) VALUES
(101, 5001, 1200.00, 'Earned',   '2025-09-10', NULL),
(102, 5002,  850.00, 'Earned',   '2025-09-12', NULL),
(103, 5003,   50.00, 'Returned', '2025-09-20', NULL), 
(101, 5005,  250.00, 'Earned',   '2025-09-22', NULL),
(105, 5006,  980.00, 'Earned',   '2025-09-25', NULL)
ON DUPLICATE KEY UPDATE
  Amount=VALUES(Amount), Type=VALUES(Type),
  Date_earned=VALUES(Date_earned),
  Date_redeemed=VALUES(Date_redeemed);

INSERT INTO Reviews (Customer_id, Product_id, Comment, Rating, `Timestamp`) VALUES
(101, 1001, 'Absolute beast of a laptop, worth every rupee!', 5, '2025-09-15 10:00:00'),
(102, 1002, 'The camera quality is unbelievable. A bit expensive though.', 4, '2025-09-18 20:30:00'),
(103, 1005, 'Motor burned out in a week. Very poor quality.', 1, '2025-09-22 12:00:00'),
(101, 1003, 'Fills the whole room with sound. Easy to set up.', 5, '2025-09-28 16:00:00')
ON DUPLICATE KEY UPDATE
  Comment=VALUES(Comment), Rating=VALUES(Rating), `Timestamp`=VALUES(`Timestamp`);