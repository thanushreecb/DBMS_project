USE department_store;

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS Department (
    Dept_id           INT            NOT NULL,
    Dept_name         VARCHAR(100)   NOT NULL,
    Dept_type         VARCHAR(50)    NOT NULL,
    Manager_id        INT            NULL,  
    ParentDept_id     INT            NULL,  
    PRIMARY KEY (Dept_id),
    INDEX ix_department_parent (ParentDept_id),
    INDEX ix_department_manager (Manager_id),
    CONSTRAINT fk_department_parent
        FOREIGN KEY (ParentDept_id) REFERENCES Department(Dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Employee (
    Employee_id   INT            NOT NULL,
    Manager_id    INT            NULL,            
    Dept_id       INT            NOT NULL,
    Emp_Fname     VARCHAR(50)    NOT NULL,
    Emp_Lname     VARCHAR(50)    NOT NULL,
    E_address     VARCHAR(150)   NULL,
    Email         VARCHAR(100)   NOT NULL,
    Salary        DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    Job_title     VARCHAR(50)    NOT NULL,
    PRIMARY KEY (Employee_id),
    UNIQUE KEY uq_employee_email (Email),
    INDEX ix_employee_manager (Manager_id),
    INDEX ix_employee_dept (Dept_id),
    CONSTRAINT chk_employee_salary_nonneg CHECK (Salary >= 0),
    CONSTRAINT fk_employee_dept
        FOREIGN KEY (Dept_id) REFERENCES Department(Dept_id),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (Manager_id) REFERENCES Employee(Employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS EmployeePhone (
    Employee_id     INT          NOT NULL,
    E_Phone_Number  VARCHAR(15)  NOT NULL,
    PRIMARY KEY (Employee_id, E_Phone_Number),
    INDEX ix_empphone_emp (Employee_id),
    CONSTRAINT fk_empphone_emp
        FOREIGN KEY (Employee_id) REFERENCES Employee(Employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Product (
    Product_ID      INT            NOT NULL,
    Prod_Name       VARCHAR(100)   NOT NULL,
    Description     TEXT           NULL,
    Dept_id         INT            NOT NULL,
    Stock_quantity  INT            NOT NULL DEFAULT 0,
    Brand           VARCHAR(50)    NULL,
    PRIMARY KEY (Product_ID),
    INDEX ix_product_dept (Dept_id),
    CONSTRAINT chk_product_stock_nonneg CHECK (Stock_quantity >= 0),
    CONSTRAINT fk_product_dept
        FOREIGN KEY (Dept_id) REFERENCES Department(Dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Customer (
    Customer_id        INT            NOT NULL,
    Fname              VARCHAR(50)    NOT NULL,
    Lname              VARCHAR(50)    NOT NULL,
    Address            VARCHAR(150)   NULL,
    Total_Spent        DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    Membership_Status  VARCHAR(20)    NOT NULL,
    PRIMARY KEY (Customer_id),
    CONSTRAINT chk_customer_total_nonneg CHECK (Total_Spent >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS CustomerPhone (
    Customer_id     INT          NOT NULL,
    C_Phone_Number  VARCHAR(15)  NOT NULL,
    PRIMARY KEY (Customer_id, C_Phone_Number),
    INDEX ix_custphone_cust (Customer_id),
    CONSTRAINT fk_custphone_cust
        FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS TransactionTable (
    Transaction_id   INT            NOT NULL,
    Customer_id      INT            NOT NULL,
    Transaction_date DATE           NOT NULL,
    `Return`         BOOLEAN        NOT NULL DEFAULT FALSE,
    Total_Amount     DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    PRIMARY KEY (Transaction_id),
    INDEX ix_txn_customer (Customer_id),
    CONSTRAINT chk_transaction_total_nonneg CHECK (Total_Amount >= 0),
    CONSTRAINT fk_transaction_customer
        FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS PaymentMethod (
    Transaction_id  INT           NOT NULL,
    Method          VARCHAR(50)   NOT NULL,
    PRIMARY KEY (Transaction_id, Method),
    INDEX ix_paymethod_txn (Transaction_id),
    CONSTRAINT fk_paymethod_txn
        FOREIGN KEY (Transaction_id) REFERENCES TransactionTable(Transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS LoyaltyProgram (
    Customer_id     INT            NOT NULL,
    Transaction_id  INT            NOT NULL,
    Amount          DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    Type            VARCHAR(50)    NOT NULL,
    Date_earned     DATE           NOT NULL,
    Date_redeemed   DATE           NULL,
    PRIMARY KEY (Customer_id, Transaction_id),
    INDEX ix_loyalty_customer (Customer_id),
    INDEX ix_loyalty_txn (Transaction_id),
    CONSTRAINT chk_loyalty_amount_nonneg CHECK (Amount >= 0),
    CONSTRAINT fk_loyalty_customer
        FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id),
    CONSTRAINT fk_loyalty_txn
        FOREIGN KEY (Transaction_id) REFERENCES TransactionTable(Transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Purchases (
    Transaction_id  INT            NOT NULL,
    Product_id      INT            NOT NULL,
    Quantity        INT            NOT NULL,
    Discount        DECIMAL(5,2)   NOT NULL DEFAULT 0.00,  -- interpret as percent
    Unit_Price      DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (Transaction_id, Product_id),
    INDEX ix_purchases_txn (Transaction_id),
    INDEX ix_purchases_product (Product_id),
    CONSTRAINT chk_purchases_qty_pos CHECK (Quantity > 0),
    CONSTRAINT chk_purchases_discount_range CHECK (Discount >= 0 AND Discount <= 100),
    CONSTRAINT chk_purchases_price_nonneg CHECK (Unit_Price >= 0),
    CONSTRAINT fk_purchases_txn
        FOREIGN KEY (Transaction_id) REFERENCES TransactionTable(Transaction_id),
    CONSTRAINT fk_purchases_product
        FOREIGN KEY (Product_id) REFERENCES Product(Product_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

 
CREATE TABLE IF NOT EXISTS Reviews (
    Customer_id  INT         NOT NULL,
    Product_id   INT         NOT NULL,
    Comment      TEXT        NULL,
    Rating       INT         NOT NULL,
    `Timestamp`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Customer_id, Product_id, `Timestamp`),
    INDEX ix_reviews_customer (Customer_id),
    INDEX ix_reviews_product (Product_id),
    CONSTRAINT chk_reviews_rating_range CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT fk_reviews_customer
        FOREIGN KEY (Customer_id) REFERENCES Customer(Customer_id),
    CONSTRAINT fk_reviews_product
        FOREIGN KEY (Product_id) REFERENCES Product(Product_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
