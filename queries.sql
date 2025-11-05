-- Nested Query: Customers spending above average
SELECT Fname, Lname, Total_Spent
FROM customer
WHERE Total_Spent > (SELECT AVG(Total_Spent) FROM customer);

-- Join Query: Employees with Department Names
SELECT e.Employee_id, e.Emp_Fname, e.Emp_Lname, d.Dept_name
FROM employee e
JOIN department d ON e.Dept_id = d.Dept_id;

-- Aggregate Query: Total number of transactions and revenue
SELECT COUNT(*) AS TotalTransactions, SUM(Amount) AS TotalRevenue
FROM transactiontable;
