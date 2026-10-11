/*
    T-SQL Practice — solutions for exercises.md
    Run 01-setup.sql first. Many exercises have more than one valid answer.
*/

USE TsqlPractice;
GO

-- 1. All employees, highest salary first
SELECT FirstName, LastName, Salary
FROM dbo.Employees
ORDER BY Salary DESC;

-- 2. Hired on or after 2020-01-01
SELECT FirstName, LastName, HireDate
FROM dbo.Employees
WHERE HireDate >= '2020-01-01';

-- 3. Products priced 40–300 inclusive
SELECT Name, UnitPrice
FROM dbo.Products
WHERE UnitPrice BETWEEN 40 AND 300;

-- 4. Customers in the USA
SELECT Name, City
FROM dbo.Customers
WHERE Country = N'USA';

-- 5. Employees without an email (NULL must be tested with IS NULL)
SELECT FirstName, LastName
FROM dbo.Employees
WHERE Email IS NULL;

-- 6. Top 3 earners
SELECT TOP (3) FirstName, LastName, Salary
FROM dbo.Employees
ORDER BY Salary DESC;

-- 7. Full name and whole years since hire
--    DATEDIFF(YEAR, ...) counts year boundaries, so adjust when the anniversary hasn't happened yet.
SELECT CONCAT(FirstName, N' ', LastName) AS FullName,
       HireDate,
       DATEDIFF(YEAR, HireDate, GETDATE())
         - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, HireDate, GETDATE()), HireDate) > GETDATE()
                THEN 1 ELSE 0 END AS YearsEmployed
FROM dbo.Employees;

-- 8. Email with a fallback
SELECT FirstName, LastName, COALESCE(Email, N'(none)') AS Email
FROM dbo.Employees;

-- 9. Salary bands
SELECT FirstName, LastName, Salary,
       CASE
           WHEN Salary >= 100000 THEN 'High'
           WHEN Salary >=  70000 THEN 'Mid'
           ELSE 'Low'
       END AS SalaryBand
FROM dbo.Employees;

-- 10. Headcount and average salary per department
SELECT DepartmentID,
       COUNT(*)    AS Employees,
       AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY DepartmentID;

-- 11. Departments with average salary above 80000 (filter on an aggregate -> HAVING)
SELECT DepartmentID, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY DepartmentID
HAVING AVG(Salary) > 80000;

-- 12. Orders per status
SELECT Status, COUNT(*) AS Orders
FROM dbo.Orders
GROUP BY Status;

-- 13. Employees with their department name (INNER JOIN drops Ivy)
SELECT e.FirstName, e.LastName, d.Name AS Department
FROM dbo.Employees AS e
JOIN dbo.Departments AS d ON d.DepartmentID = e.DepartmentID;

-- 14. Every department with its headcount; COUNT(e.EmployeeID) ignores the NULLs for HR
SELECT d.Name AS Department, COUNT(e.EmployeeID) AS Employees
FROM dbo.Departments AS d
LEFT JOIN dbo.Employees AS e ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name;

-- 15. Employee and manager (self join)
SELECT CONCAT(e.FirstName, N' ', e.LastName) AS Employee,
       CONCAT(m.FirstName, N' ', m.LastName) AS Manager
FROM dbo.Employees AS e
LEFT JOIN dbo.Employees AS m ON m.EmployeeID = e.ManagerID;
-- Note: CONCAT turns NULLs into '' (giving ' ' for Ana). To get a real NULL use:
--   m.FirstName + N' ' + m.LastName

-- 16. Total value per order
SELECT OrderID, SUM(Quantity * UnitPrice) AS OrderTotal
FROM dbo.OrderItems
GROUP BY OrderID;

-- 17. Products never ordered
SELECT p.Name
FROM dbo.Products AS p
WHERE NOT EXISTS (SELECT 1 FROM dbo.OrderItems AS oi WHERE oi.ProductID = p.ProductID);

-- 18. Customers with no orders (LEFT JOIN / IS NULL pattern)
SELECT c.Name
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL;

-- 19. Above the company-wide average salary
SELECT FirstName, LastName, Salary
FROM dbo.Employees
WHERE Salary > (SELECT AVG(Salary) FROM dbo.Employees);

-- 20. Revenue per customer excluding cancelled orders, ranked
WITH CustomerRevenue AS (
    SELECT o.CustomerID, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM dbo.Orders AS o
    JOIN dbo.OrderItems AS oi ON oi.OrderID = o.OrderID
    WHERE o.Status <> 'Cancelled'
    GROUP BY o.CustomerID
)
SELECT c.Name, cr.Revenue,
       RANK() OVER (ORDER BY cr.Revenue DESC) AS RevenueRank
FROM CustomerRevenue AS cr
JOIN dbo.Customers AS c ON c.CustomerID = cr.CustomerID
ORDER BY RevenueRank;

-- 21. Highest-paid employee per department
WITH Ranked AS (
    SELECT e.FirstName, e.LastName, e.Salary, d.Name AS Department,
           ROW_NUMBER() OVER (PARTITION BY e.DepartmentID ORDER BY e.Salary DESC) AS rn
    FROM dbo.Employees AS e
    JOIN dbo.Departments AS d ON d.DepartmentID = e.DepartmentID
)
SELECT Department, FirstName, LastName, Salary
FROM Ranked
WHERE rn = 1;

-- 22. Order totals with a running total by date
WITH OrderTotals AS (
    SELECT o.OrderID, o.OrderDate, SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
    FROM dbo.Orders AS o
    JOIN dbo.OrderItems AS oi ON oi.OrderID = o.OrderID
    GROUP BY o.OrderID, o.OrderDate
)
SELECT OrderID, OrderDate, OrderTotal,
       SUM(OrderTotal) OVER (ORDER BY OrderDate, OrderID
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM OrderTotals
ORDER BY OrderDate, OrderID;

-- 23. Insert / update inside a transaction, then roll back
BEGIN TRANSACTION;

    INSERT INTO dbo.Products (ProductID, Name, Category, UnitPrice)
    VALUES (7, N'Webcam', N'Accessories', 80.00);

    UPDATE dbo.Products
    SET UnitPrice = UnitPrice * 1.10
    WHERE Category = N'Accessories';

    SELECT Name, UnitPrice FROM dbo.Products WHERE Category = N'Accessories';

ROLLBACK TRANSACTION;

SELECT Name, UnitPrice FROM dbo.Products WHERE Category = N'Accessories';
GO
