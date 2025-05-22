--1
SELECT DISTINCT (JobTitle)
FROM HumanResources.Employee
ORDER BY 1;

--2
SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate <= '2024-12-31' 
    AND OrderDate >= '2024-12-01'
    AND [Status] NOT IN ('4', '6') 


--3
SELECT HireDate, JobTitle
FROM HumanResources.Employee
WHERE HireDate > '2013-01-01' AND JobTitle LIKE '%Manager%';

--4
SELECT OnlineOrderFlag, OrderDate
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = '1' 
    AND OrderDate BETWEEN '2024-02-01' AND '2024-02-28';

--5
SELECT SellStartDate, ProductLine
FROM Production.Product
WHERE SellStartDate IS NOT NULL
    AND ProductLine = 'T'
ORDER BY SellStartDate ASC;

--6
SELECT 
    SalesOrderID, 
    CustomerID, 
    OrderDate, 
    SubTotal, 
    (TaxAmt/SubTotal * 100) AS TaxPercentage
FROM Sales.SalesOrderHeader
ORDER BY SubTotal DESC;

--7
SELECT CustomerID,
    SUM(Freight) AS TotalFreight
FROM Sales.SalesOrderHeader
GROUP By CustomerID
ORDER BY CustomerID ASC;

--8
SELECT CustomerID,
    SUM(SubTotal) AS Total,
    avg(SubTotal) AS Average
FROM Sales.SalesOrderHeader
GROUP By CustomerID, SalesPersonID
ORDER BY CustomerID DESC;

--9
SELECT ProductID,
    SUM(Quantity) AS Total
FROM Production.ProductInventory
WHERE Shelf IN ('A', 'C', 'H')
GROUP BY ProductID
HAVING SUM(Quantity) >= 500
ORDER BY ProductID ASC;

--10
SELECT
        ProductID,
    UnitPrice,
    UnitPriceDiscount,
    (UnitPriceDiscount * UnitPrice) AS DiscountPrice
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = '46672'
    AND UnitPriceDiscount >= 0.02






--Practice 2

--1

SELECT 
    p.BusinessEntityID,
    p.FirstName,
    p.LastName
FROM Person.Person p
INNER JOIN Person.BusinessEntityContact bec
    ON p.BusinessEntityID = bec.BusinessEntityID
WHERE bec.ContactTypeID = (
    SELECT ContactTypeID
    FROM Person.ContactType
    WHERE ContactTypeID = '15'
)
ORDER BY p.FirstName ASC, p.LastName ASC;

--2

SELECT
    RateChangeDate,
    Rate * 40 AS WekklySalary,
    CONCAT(FirstName, 
           ISNULL(' ' + MiddleName, ''), 
           ' ', 
           LastName) AS NameInFull
FROM HumanResources.EmployeePayHistory eph
JOIN Person.Person p
ON eph.BusinessEntityID = p.BusinessEntityID
ORDER BY NameInFull ASC

--3

SELECT 
    [Name],
    Color,
    ListPrice
FROM Production.Product
WHERE Color IN ('Red', 'Blue')
ORDER BY ListPrice


--4

SELECT 
    [Name],
    SalesOrderID
FROM Production.Product p 
JOIN Sales.SalesOrderDetail sod 
ON p.ProductID = sod.ProductID
ORDER BY [Name]

--5

SELECT
    [Name],
    SalesOrderID
FROM Production.Product p 
LEFT JOIN Sales.SalesOrderDetail sod 
ON p.ProductID = sod.ProductID

--6

SELECT
    BusinessEntityID,
    [Name]
FROM Sales.SalesPerson sp 
LEFT JOIN Sales.SalesTerritory t 
ON sp.TerritoryID = t.TerritoryID

--7

SELECT
    CONCAT(FirstName , ' ' , LastName) AS FullName,
    City
FROM Person.Person p
JOIN Person.BusinessEntityAddress bea 
    ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a
    on bea.AddressID = a.AddressID
ORDER BY p.LastName, p.FirstName

WITH t AS (
  SELECT 
    SalesOrderID, 
    CustomerID, 
    RANK()
OVER (PARTITION BY CustomerID ORDER BY SubTotal DESC ) as RANK
FROM Sales.SalesOrderHeader  
)
SELECT * FROM t WHERE RANK = 1

WITH t AS(
    SELECT
    CustomerID,
    SUM(SubTotal) AS Total
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
),
t2 AS (
   SELECT *,
    RANK() OVER (ORDER BY Total ASC) Rank,
    DENSE_RANK() OVER( ORDER BY Total ASC) DenseRank
FROM t 
)
SELECT * FROM t2 
WHERE DenseRank < 11
ORDER BY 2 



WITH t AS(
    SELECT CustomerID, OrderDate,
    LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) LagTime,
    LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) LeadTime
    FROM Sales.SalesOrderHeader
),
t2 AS(
    SELECT *,
    DATEDIFF(Day, LagTime, OrderDate) AS DateDiff
    FROM t
),
t3 AS(
    SELECT *
    FROM t2
    WHERE [DateDiff] = 1
)

SELECT DISTINCT CustomerID
FROM t3


--7

WITH t1 AS(
    SELECT 
    d.Name AS 'Name',
    MIN(eph.Rate) AS MinSalary,
    MAX(eph.Rate) AS MaxSalary,
    AVG(eph.Rate) AS AvgSalary,
    COUNT( DISTINCT edh.BusinessEntityID) AS NumEmployeesPerDept
FROM HumanResources.Department d
JOIN HumanResources.EmployeeDepartmentHistory edh 
    ON d.DepartmentID = edh.DepartmentID
JOIN HumanResources.EmployeePayHistory eph 
    ON edh.BusinessEntityID = eph.BusinessEntityID
GROUP BY d.Name
)
SELECT 
    Name,
    AvgSalary
FROM t1
WHERE AvgSalary > 20










