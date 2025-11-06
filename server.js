const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static("public"));

const db = mysql.createConnection({
 host: process.env.DB_HOST,
 user: process.env.DB_USER,
 password: process.env.DB_PASSWORD,
 database: process.env.DB_NAME
});

db.connect(err => {
 if (err) throw err;
 console.log("Connected to MySQL");
});

// Get All Tables
app.get("/api/tables", (req, res) => {
 const query = "SHOW TABLES";
 db.query(query, (err, results) => {
  if (err) {
   console.error("Error fetching tables:", err);
   return res.status(500).send("Error fetching tables");
  }

  const allTables = results.map((row) => Object.values(row)[0]);
  const mainTables = allTables.filter(t => !t.endsWith('phone'));

  const friendlyMap = {
   'transactiontable': 'Transactions', 
   'loyaltyprogram': 'Loyalty Program',
   'paymentmethod' : 'Payment Method'
  };

  const tables = mainTables.map(t => ({
   name: t,
   displayName: friendlyMap[t] || t.charAt(0).toUpperCase() + t.slice(1)
  }));

  res.json(tables);
 });
});

// Get Data from Specific Table 
app.get("/api/data/:name", (req, res) => {
 const tableName = req.params.name;

 let query = "";

 if (tableName === "customer") {
  query = `SELECT c.Customer_id,
    CONCAT(c.Fname, ' ', c.Lname) AS FullName,
    c.Address,
    c.Total_Spent,
    c.Membership_Status,
    GROUP_CONCAT(cp.C_Phone_Number SEPARATOR ', ') AS PhoneNumbers
   FROM customer c
   LEFT JOIN customerphone cp ON c.Customer_id = cp.Customer_id
   GROUP BY c.Customer_id
   LIMIT 50;`;

 } else if (tableName === "employee") {
  query = `SELECT e.Employee_id,
    CONCAT(e.Emp_Fname, ' ', e.Emp_Lname) AS FullName,
    e.Job_title,
    e.Email,
    e.E_address,
    e.Salary,
    e.Dept_id,
    e.Manager_id,
    GROUP_CONCAT(ep.E_Phone_Number SEPARATOR ', ') AS PhoneNumbers
   FROM employee e
   LEFT JOIN employeephone ep ON e.Employee_id = ep.Employee_id
   GROUP BY e.Employee_id
   LIMIT 50;`;

 } else {
  query = `SELECT * FROM \`${tableName}\` LIMIT 50;`;
 }

 db.query(query, (err, results) => {
  if (err) {
   console.error(`Error fetching data for ${tableName}:`, err);
   return res.status(500).send("Error fetching table data");
  }
  res.json(results);
 });
});

app.get("/api/columns/:table", (req, res) => {
 const { table } = req.params;
 if (!table) return res.status(400).json({ message: "Missing table name" });

 const sql = `DESCRIBE \`${table}\``;
 db.query(sql, (err, results) => {
  if (err) {
   console.error("Error fetching columns:", err);
   return res.status(500).json({ message: "Error fetching columns" });
  }
  res.json(results); 
 });
});


app.post("/api/insert", (req, res) => {
 const { table, data, phones } = req.body;
 if (!table || !data) return res.status(400).json({ message: "Missing parameters" });

 if (table === "customer") {
  const { Fname, Lname, Address, Total_Spent, Membership_Status } = data;

  const sql1 = `INSERT INTO customer (Fname, Lname, Address, Total_Spent, Membership_Status)
          VALUES (?, ?, ?, ?, ?)`;

  db.query(sql1, [Fname, Lname, Address, Total_Spent, Membership_Status], (err, result) => {
   if (err) return res.status(500).json({ message: err.sqlMessage });
   const customerId = result.insertId;

   if (phones && phones.length > 0) {
    const phoneArray = phones.split(",").map(p => [customerId, p.trim()]);
    db.query(`INSERT INTO customerphone (Customer_id, C_Phone_Number) VALUES ?`, [phoneArray], (err) => {
     if (err) console.error("Error inserting customer phones:", err);
    });
   }

   res.json({ message: "Customer added successfully!" });
  });
 }

 else if (table === "employee") {
  const { Emp_Fname, Emp_Lname, Job_title, Email, E_address, Salary, Dept_id, Manager_id } = data;

  const sql1 = `INSERT INTO employee (Emp_Fname, Emp_Lname, Job_title, Email, E_address, Salary, Dept_id, Manager_id)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;

  db.query(sql1, [Emp_Fname, Emp_Lname, Job_title, Email, E_address, Salary, Dept_id, Manager_id], (err, result) => {
   if (err) return res.status(500).json({ message: err.sqlMessage });
   const empId = result.insertId;

   if (phones && phones.length > 0) {
    const phoneArray = phones.split(",").map(p => [empId, p.trim()]);
    db.query(`INSERT INTO employeephone (Employee_id, E_Phone_Number) VALUES ?`, [phoneArray], (err) => {
     if (err) console.error("Error inserting employee phones:", err);
    });
   }

   res.json({ message: "Employee added successfully!" });
  });
 }

 else {
  const cols = Object.keys(data).map(col => `\`${col}\``).join(", ");
  const vals = Object.values(data);
  const placeholders = vals.map(() => "?").join(", ");
  const sql = `INSERT INTO \`${table}\` (${cols}) VALUES (${placeholders})`;
  db.query(sql, vals, (err) => {
   if (err) return res.status(500).json({ message: "Insert failed: " + err.sqlMessage });
   res.json({ message: "Record inserted successfully!" });
  });
 }
});

app.put("/api/update", (req, res) => {
 const { table, idColumn, idValue, data, phones } = req.body;

 if (!table || !idColumn || !idValue) {
  return res.status(400).json({ message: "Missing parameters" });
 }

 const dataKeys = Object.keys(data);
 const hasDataUpdate = dataKeys.length > 0;
 const hasPhoneUpdate = phones !== null && phones !== undefined; 

 if (!hasDataUpdate && !hasPhoneUpdate) {
  return res.status(400).json({ message: "Please enter at least one new value to update." });
 }

 const handlePhoneUpdate = (id, phoneString, phoneTable, idColName, phoneColName) => {
  return new Promise((resolve, reject) => {
   db.query(`DELETE FROM ${phoneTable} WHERE ${idColName} = ?`, [id], (err) => {
    if (err) return reject(err);

    if (phoneString && phoneString.length > 0) {
     const phoneArray = phoneString.split(",").map(p => [id, p.trim()]);
     db.query(`INSERT INTO ${phoneTable} (${idColName}, ${phoneColName}) VALUES ?`, [phoneArray], (err) => {
      if (err) return reject(err);
      resolve();
     });
    } else {
     resolve();
    }
   });
  });
 };

 const handleDataUpdate = () => {
  if (!hasDataUpdate) return Promise.resolve(); 

  return new Promise((resolve, reject) => {
   const setClause = dataKeys.map(col => `\`${col}\` = ?`).join(", ");
   const values = [...Object.values(data), idValue];
   const sql = `UPDATE \`${table}\` SET ${setClause} WHERE \`${idColumn}\` = ?`;

   db.query(sql, values, (err, result) => {
    if (err) return reject(err);
    resolve(result);
   });
  });
 };

 let phonePromise = Promise.resolve();
 
 if (hasPhoneUpdate) {
  if (table === "customer") {
   phonePromise = handlePhoneUpdate(idValue, phones, 'customerphone', 'Customer_id', 'C_Phone_Number');
  } else if (table === "employee") {
   phonePromise = handlePhoneUpdate(idValue, phones, 'employeephone', 'Employee_id', 'E_Phone_Number');
  }
 }

 const dataPromise = handleDataUpdate();

 Promise.all([dataPromise, phonePromise])
  .then(() => {
   res.json({ message: "Record updated successfully!" });
  })
  .catch(err => {
   res.status(500).json({ message: "Update failed: " + err.message });
  });
});

// DELETE record
app.delete("/api/delete", (req, res) => {
 const { table, idColumn, idValue } = req.body;

 if (!table || !idColumn || !idValue)
  return res.status(400).json({ message: "Missing parameters" });

 if (table === "customer") {
  db.query(`DELETE FROM customerphone WHERE Customer_id=?`, [idValue], (err) => {
   if (err) return res.status(500).json({ message: "Error deleting phones: " + err.message });
   db.query(`DELETE FROM customer WHERE Customer_id=?`, [idValue], (err, result) => {
    if (err) return res.status(500).json({ message: "Error deleting customer: " + err.message });
    res.json({ message: "Customer and phones deleted successfully." });
   });
  });
 } else if (table === "employee") {
  db.query(`DELETE FROM employeephone WHERE Employee_id=?`, [idValue], (err) => {
   if (err) return res.status(500).json({ message: "Error deleting phones: " + err.message });
   db.query(`DELETE FROM employee WHERE Employee_id=?`, [idValue], (err, result) => {
    if (err) return res.status(500).json({ message: "Error deleting employee: " + err.message });
    res.json({ message: "Employee and phones deleted successfully." });
   });
  });
 } else {
  const sql = `DELETE FROM \`${table}\` WHERE \`${idColumn}\` = ?`;
  db.query(sql, [idValue], (err, result) => {
   if (err) return res.status(500).json({ message: "Delete failed: " + err.message });
   if (result.affectedRows === 0) return res.status(404).json({ message: "Delete failed: Record not found." });
   res.json({ message: `${result.affectedRows} record(s) deleted.` });
  });
 }
});

// ---------------- CUSTOM QUERY ROUTES ----------------

// 1️. Nested Query — Customers spending above average
app.get("/api/query/topCustomers", (req, res) => {
 const sql = `
  SELECT Fname, Lname, Total_Spent
  FROM customer
  WHERE Total_Spent > (SELECT AVG(Total_Spent) FROM customer);
 `;
 db.query(sql, (err, results) => {
  if (err) return res.status(500).json({ message: err.message });
  res.json(results);
 });
});

// 2️. Join Query — Employees with their department names
app.get("/api/query/employeeDepartments", (req, res) => {
 const sql = `
  SELECT e.Employee_id, e.Emp_Fname, e.Emp_Lname, d.Dept_name
  FROM employee e
  JOIN department d ON e.Dept_id = d.Dept_id;
 `;
 db.query(sql, (err, results) => {
  if (err) return res.status(500).json({ message: err.message });
  res.json(results);
 });
});

// 3️. Aggregate Query — Total number of purchases & revenue
app.get("/api/query/transactionSummary", (req, res) => {
 const query = `
  SELECT
   COUNT(Transaction_id) AS TotalTransactions,
   SUM(Total_Amount) AS TotalRevenue,
   AVG(Total_Amount) AS AverageTransactionValue
  FROM transactiontable;
 `; 
 
 db.query(query, (err, results) => {
  if (err) {
   console.error("Error running query:", err);
   return res.status(500).send("Error running query");
  }
  res.json(results);
 });
});

app.listen(process.env.PORT, () => {
 console.log(`Server running on http://localhost:${process.env.PORT}`);
});
