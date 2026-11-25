# SQL E-Commerce Report (Week 4)

This repository contains a comprehensive **SQL E-commerce Report** script covering 40 SQL queries that demonstrate a wide range of database concepts and data analysis techniques.

## Overview

The `sql_ecommerce_report.sql` file includes:

*   **DDL & Schema Design:** Creating `Customers`, `Categories`, `Products`, `Orders`, and `Order_Items` tables.
*   **Constraints:** Implementing `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, `CHECK`, and `DEFAULT` constraints, alongside indexes for performance.
*   **DML & Data Insertion:** Populating the tables with sample e-commerce data.
*   **Data Analysis & Aggregation:** Finding top-selling products, calculating total revenue, and determining the highest-spending customers.
*   **NULL Handling:** Using `COALESCE` and `NULLIF` to gracefully handle missing data (e.g., missing phone numbers or cities).
*   **JOINs:** Demonstrating `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`, and `Self-JOIN`.
*   **Advanced Concepts:** Utilizing Subqueries and Window Functions (like `RANK()` and `SUM() OVER()`) for complex reporting such as ranking customers and calculating running totals.

## Usage

You can run this script against any standard relational database such as PostgreSQL or SQLite. 

To execute:
1. Setup a new database instance.
2. Run the full script `sql_ecommerce_report.sql` to generate the schema, insert the mock data, and execute the analytical queries.
