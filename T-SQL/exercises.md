# Basic T-SQL Exercises

Run [`01-setup.sql`](01-setup.sql) first (SQL Server 2016+ or Azure SQL). It creates a
`TsqlPractice` database with six small tables:

| Table         | Columns                                                                        |
|---------------|--------------------------------------------------------------------------------|
| `Departments` | DepartmentID, Name                                                             |
| `Employees`   | EmployeeID, FirstName, LastName, DepartmentID, ManagerID, HireDate, Salary, Email |
| `Customers`   | CustomerID, Name, City, Country                                                |
| `Products`    | ProductID, Name, Category, UnitPrice                                           |
| `Orders`      | OrderID, CustomerID, EmployeeID, OrderDate, Status                             |
| `OrderItems`  | OrderID, ProductID, Quantity, UnitPrice                                        |

Each exercise lists the expected result so you can check yourself. Solutions are in
[`solutions.sql`](solutions.sql) — try first, peek later.

---

## Level 1 — SELECT, WHERE, ORDER BY

1. List every employee's first name, last name and salary, highest salary first.
   *Expected: 9 rows, starting with Ana Lopez (120000).*
2. Find employees hired on or after 1 January 2020.
   *Expected: 5 rows (Chloe, Emma, Farid, Hugo, Ivy).*
3. List products priced between 40 and 300 (inclusive).
   *Expected: Monitor, Keyboard, Desk Chair.*
4. List customers located in the USA.
   *Expected: Northwind Traders, Harbor Retail.*
5. Find employees who have no email address.
   *Expected: Hugo Silva, Ivy Brooks. Hint: `= NULL` does not work.*
6. Return the three highest-paid employees.
   *Expected: Ana, David, Ben. Hint: `TOP`.*

## Level 2 — Expressions and built-in functions

7. Show each employee's full name as one column (`FullName`) and the number of whole years
   between their hire date and today.
   *Hint: `CONCAT`, `DATEDIFF`, `GETDATE()`.*
8. Show every employee's name and email, displaying `(none)` when the email is missing.
   *Hint: `COALESCE` or `ISNULL`.*
9. Label each employee's salary band: `High` (≥ 100000), `Mid` (≥ 70000), otherwise `Low`.
   *Expected: 2 High, 3 Mid, 4 Low. Hint: `CASE`.*

## Level 3 — Aggregation, GROUP BY, HAVING

10. For each `DepartmentID`, show the number of employees and their average salary.
    *Expected: 4 rows — 1 → 3 / 101000, 2 → 3 / 75000, 3 → 2 / 66500, NULL → 1 / 50000.*
11. Show only the departments whose average salary is above 80000.
    *Expected: DepartmentID 1 only.*
12. Count orders by `Status`.
    *Expected: Shipped 5, Cancelled 1, Pending 1.*

## Level 4 — Joins

13. List employees with their department **name**. Employees without a department should not appear.
    *Expected: 8 rows (Ivy is missing).*
14. List **every** department with its employee count, including departments with no employees.
    *Expected: Engineering 3, Sales 3, Marketing 2, HR 0. Hint: `LEFT JOIN` and count a column, not `*`.*
15. List each employee next to their manager's full name. Keep employees who have no manager.
    *Expected: 9 rows; Ana's manager is NULL. Hint: join `Employees` to itself.*
16. Show the total value (`Quantity * UnitPrice`) of every order.
    *Expected: 1001 → 2450, 1002 → 1035, 1003 → 1800, 1004 → 1000, 1005 → 700, 1006 → 6000, 1007 → 800.*
17. Find products that have never been ordered.
    *Expected: Standing Desk.*
18. Find customers who have never placed an order.
    *Expected: Sakura Imports.*

## Level 5 — Subqueries, CTEs and window functions

19. List employees who earn more than the company-wide average salary.
    *Expected: Ana, Ben, Chloe, David (the average is exactly 79000, so Grace is not included).*
20. Using a CTE, compute total revenue per customer **excluding cancelled orders**, and rank
    the customers by revenue.
    *Expected: Alpine Goods 7035 (rank 1), Northwind Traders 5050 (2), Harbor Retail 700 (3).*
21. Return the highest-paid employee in each department (ignore employees without a department).
    *Expected: Ana (Engineering), David (Sales), Grace (Marketing). Hint: `ROW_NUMBER() OVER (PARTITION BY …)`.*
22. For each order, show the order date, the order total, and a running total of all order
    totals by date.
    *Expected: the last running total is 13785. Hint: `SUM(...) OVER (ORDER BY ...)`.*

## Level 6 — Modifying data

23. Inside a transaction:
    1. insert a new product `Webcam` (ID 7, Accessories, 80.00),
    2. raise the price of every Accessories product by 10%,
    3. select the Accessories products to see the change,
    4. roll the transaction back and confirm nothing changed.

    *Expected inside the transaction: Keyboard 49.50, Mouse 27.50, Webcam 88.00.
    After rollback: Keyboard 45.00, Mouse 25.00, no Webcam.*

---

### Bonus ideas

- Monthly revenue for 2025 (`YEAR`, `MONTH`, or `DATETRUNC` on SQL Server 2022+).
- Which salesperson (Orders.EmployeeID) brought in the most revenue?
- Turn exercise 16 into a view called `dbo.OrderTotals`.
- Write a stored procedure `dbo.GetCustomerOrders @CustomerID INT`.
