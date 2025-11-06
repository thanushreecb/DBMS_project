# Department Store Management System

## Overview
A DBMS project built using **Node.js**, **Express**, and **MySQL**, providing a web interface for managing customers, employees, transactions, and loyalty programs. CRUD operations, triggers, and SQL queries (join, nested, aggregate) are integrated.

---

## Tech Stack
- **Frontend:** HTML, CSS, JavaScript (Fetch API)
- **Backend:** Node.js, Express, MySQL2
- **Database:** MySQL

---

---

## Database
Main tables:
- customer  
- customerphone  
- employee  
- employeephone
- department
- transactiontable
- product
- purchases
- loyaltyprogram  
- reviews

Customer & employee tables are **merged** with their phone tables using `LEFT JOIN`.  
Insert, update, and delete operations reflect in both related tables.

---

## Features
- View all tables (except phone tables separately)
- CRUD operations through GUI
- Predefined SQL query buttons:
  - **Nested Query:** Customers spending above average  
  - **Join Query:** Employees with department names  
  - **Aggregate Query:** Transaction summary (count, total, average)

---

## How to Run
1. Create a MySQL database and import your `.sql` schema.
2. Set credentials in `.env`:
