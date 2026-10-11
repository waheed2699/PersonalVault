/*
    T-SQL Practice — setup script
    Creates a small sales database used by exercises.md.
    Requires SQL Server 2016+ (uses DROP TABLE IF EXISTS).
    Safe to re-run: it drops and recreates every table.
*/

IF DB_ID('TsqlPractice') IS NULL
    CREATE DATABASE TsqlPractice;
GO

USE TsqlPractice;
GO

DROP TABLE IF EXISTS dbo.OrderItems;
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Products;
DROP TABLE IF EXISTS dbo.Customers;
DROP TABLE IF EXISTS dbo.Employees;
DROP TABLE IF EXISTS dbo.Departments;
GO

CREATE TABLE dbo.Departments (
    DepartmentID INT          NOT NULL PRIMARY KEY,
    Name         NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.Employees (
    EmployeeID   INT           NOT NULL PRIMARY KEY,
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    DepartmentID INT           NULL REFERENCES dbo.Departments (DepartmentID),
    ManagerID    INT           NULL REFERENCES dbo.Employees (EmployeeID),
    HireDate     DATE          NOT NULL,
    Salary       DECIMAL(10,2) NOT NULL,
    Email        NVARCHAR(100) NULL
);

CREATE TABLE dbo.Customers (
    CustomerID INT           NOT NULL PRIMARY KEY,
    Name       NVARCHAR(100) NOT NULL,
    City       NVARCHAR(50)  NOT NULL,
    Country    NVARCHAR(50)  NOT NULL
);

CREATE TABLE dbo.Products (
    ProductID INT           NOT NULL PRIMARY KEY,
    Name      NVARCHAR(100) NOT NULL,
    Category  NVARCHAR(50)  NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.Orders (
    OrderID    INT         NOT NULL PRIMARY KEY,
    CustomerID INT         NOT NULL REFERENCES dbo.Customers (CustomerID),
    EmployeeID INT         NOT NULL REFERENCES dbo.Employees (EmployeeID),
    OrderDate  DATE        NOT NULL,
    Status     VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.OrderItems (
    OrderID   INT           NOT NULL REFERENCES dbo.Orders (OrderID),
    ProductID INT           NOT NULL REFERENCES dbo.Products (ProductID),
    Quantity  INT           NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, ProductID)
);
GO

INSERT INTO dbo.Departments (DepartmentID, Name) VALUES
    (1, N'Engineering'),
    (2, N'Sales'),
    (3, N'Marketing'),
    (4, N'HR');               -- intentionally has no employees

INSERT INTO dbo.Employees (EmployeeID, FirstName, LastName, DepartmentID, ManagerID, HireDate, Salary, Email) VALUES
    (1, N'Ana',   N'Lopez',  1,    NULL, '2018-03-15', 120000, N'ana.lopez@example.com'),
    (2, N'Ben',   N'Carter', 1,    1,    '2019-07-01',  95000, N'ben.carter@example.com'),
    (3, N'Chloe', N'Kim',    1,    1,    '2021-01-10',  88000, N'chloe.kim@example.com'),
    (4, N'David', N'Osei',   2,    1,    '2017-11-20', 105000, N'david.osei@example.com'),
    (5, N'Emma',  N'Novak',  2,    4,    '2020-05-04',  62000, N'emma.novak@example.com'),
    (6, N'Farid', N'Haddad', 2,    4,    '2022-09-12',  58000, N'farid.haddad@example.com'),
    (7, N'Grace', N'Liu',    3,    1,    '2019-02-25',  79000, N'grace.liu@example.com'),
    (8, N'Hugo',  N'Silva',  3,    7,    '2023-06-01',  54000, NULL),
    (9, N'Ivy',   N'Brooks', NULL, 1,    '2024-01-08',  50000, NULL);  -- no department yet

INSERT INTO dbo.Customers (CustomerID, Name, City, Country) VALUES
    (1, N'Northwind Traders', N'Seattle', N'USA'),
    (2, N'Alpine Goods',      N'Zurich',  N'Switzerland'),
    (3, N'Maple Supplies',    N'Toronto', N'Canada'),
    (4, N'Harbor Retail',     N'Boston',  N'USA'),
    (5, N'Sakura Imports',    N'Osaka',   N'Japan');      -- never ordered

INSERT INTO dbo.Products (ProductID, Name, Category, UnitPrice) VALUES
    (1, N'Laptop',        N'Electronics', 1200.00),
    (2, N'Monitor',       N'Electronics',  300.00),
    (3, N'Keyboard',      N'Accessories',   45.00),
    (4, N'Mouse',         N'Accessories',   25.00),
    (5, N'Desk Chair',    N'Furniture',    250.00),
    (6, N'Standing Desk', N'Furniture',    600.00);       -- never ordered

INSERT INTO dbo.Orders (OrderID, CustomerID, EmployeeID, OrderDate, Status) VALUES
    (1001, 1, 5, '2025-01-15', 'Shipped'),
    (1002, 2, 5, '2025-02-03', 'Shipped'),
    (1003, 1, 6, '2025-02-20', 'Shipped'),
    (1004, 3, 4, '2025-03-11', 'Cancelled'),
    (1005, 4, 6, '2025-04-02', 'Shipped'),
    (1006, 2, 5, '2025-04-18', 'Pending'),
    (1007, 1, 4, '2025-05-07', 'Shipped');

INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
    (1001, 1,  2, 1200.00), (1001, 4,  2, 25.00),
    (1002, 2,  3,  300.00), (1002, 3,  3, 45.00),
    (1003, 1,  1, 1200.00), (1003, 2,  2, 300.00),
    (1004, 5,  4,  250.00),
    (1005, 3, 10,   45.00), (1005, 4, 10, 25.00),
    (1006, 1,  5, 1200.00),
    (1007, 5,  2,  250.00), (1007, 2,  1, 300.00);
GO
