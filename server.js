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
  query = `
    SELECT 
      c.Customer_id,
      CONCAT(c.Fname, ' ', c.Lname) AS FullName,
      c.Address,
      c.Total_Spent,
      c.Membership_Status,
      GROUP_CONCAT(cp.C_Phone_Number SEPARATOR ', ') AS PhoneNumbers
    FROM customer c
    LEFT JOIN customerphone cp ON c.Customer_id = cp.Customer_id
    GROUP BY c.Customer_id, c.Fname, c.Lname, c.Address, c.Total_Spent, c.Membership_Status
    LIMIT 50;
  `;
} else if (tableName === "employee") {
  query = `
   SELECT 
    e.Employee_id,
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
   GROUP BY e.Employee_id, e.Emp_Fname, e.Emp_Lname, e.Job_title, e.Email, e.E_address, e.Salary, e.Dept_id, e.Manager_id
   LIMIT 50;
  `;
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

// INSERT
app.post("/api/insert", (req, res) => {
 const { table, data } = req.body;
  if (!table || !data) return res.status(400).json({ message: "Missing parameters" });

 const cols = Object.keys(data).join(", ");
 const vals = Object.values(data);
 const placeholders = vals.map(() => "?").join(", ");
 const sql = `INSERT INTO ${table} (${cols}) VALUES (${placeholders})`;
 db.query(sql, vals, (err) => {
  if (err) return res.status(500).json({ message: "Insert failed: " + err.sqlMessage });
  res.json({ message: "Record inserted successfully!" });
 });
});

// UPDATE record
app.put("/api/update", (req, res) => {
 const { table, idColumn, idValue, data } = req.body;

 if (!table || !idColumn || !idValue || !data)
  return res.status(400).json({ message: "Missing parameters" });

 const setClause = Object.keys(data)
  .map(col => `${col} = ?`)
  .join(", ");

 const values = [...Object.values(data), idValue];
 const sql = `UPDATE ${table} SET ${setClause} WHERE ${idColumn} = ?`;

 db.query(sql, values, (err, result) => {
  if (err) return res.status(500).json({ message: err.message });
  res.json({ message: `${result.affectedRows} record(s) updated.` });
 });
});

// DELETE record
app.delete("/api/delete", (req, res) => {
 const { table, idColumn, idValue } = req.body;

 if (!table || !idColumn || !idValue)
  return res.status(400).json({ message: "Missing parameters" });

 const sql = `DELETE FROM ${table} WHERE ${idColumn} = ?`;
 db.query(sql, [idValue], (err, result) => {
  if (err) return res.status(500).json({ message: err.message });
  res.json({ message: `${result.affectedRows} record(s) deleted.` });
 });
});


app.listen(process.env.PORT, () => {
 console.log(`Server running on http://localhost:${process.env.PORT}`);
});
