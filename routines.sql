USE department_store;

DROP FUNCTION IF EXISTS line_total;
DELIMITER $$
CREATE FUNCTION line_total(
  price DECIMAL(10,2),
  qty INT,
  disc DECIMAL(5,2)
) RETURNS DECIMAL(12,2)
DETERMINISTIC
RETURN ROUND(price * qty * (1 - disc/100), 2);
$$
DELIMITER ;


DROP TRIGGER IF EXISTS Stock_Update;
DELIMITER $$
CREATE TRIGGER Stock_Update
AFTER INSERT ON Purchases
FOR EACH ROW
BEGIN
  UPDATE Product
     SET Stock_quantity = Stock_quantity - NEW.Quantity
   WHERE Product_ID = NEW.Product_id;  
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS cust_total;
DELIMITER $$
CREATE PROCEDURE cust_total(IN p_customer_id INT)
BEGIN
  SELECT
    c.Customer_id,
    CONCAT(c.Fname, ' ', c.Lname) AS customer_name,
    COUNT(t.Transaction_id)       AS txn_count,
    ROUND(COALESCE(SUM(t.Total_Amount), 0), 2) AS total_amount
  FROM Customer c
  LEFT JOIN TransactionTable t
         ON t.Customer_id = c.Customer_id
  WHERE c.Customer_id = p_customer_id
  GROUP BY c.Customer_id, customer_name;
END$$
DELIMITER ;