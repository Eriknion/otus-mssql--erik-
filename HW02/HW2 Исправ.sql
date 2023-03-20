 
USE WideWorldImporters

/*
1. 
*/

 
	use[WideWorldImporters]

SELECT 
		 StockItemID,
		 StockItemName,
		 UnitPrice,
		 RecommendedRetailPrice
	FROM Warehouse.StockItems
	WHERE
		StockItemName LIKE '%urgent%'
		OR StockItemName LIKE 'Animal%'

	GO

/*
2 
*/


	use[WideWorldImporters]
SELECT 
		 ps.SupplierID,
		 ps.SupplierName
	FROM 
		Purchasing.Suppliers as ps
		LEFT JOIN Purchasing.PurchaseOrders as ppo ON ps.SupplierID = ppo.SupplierID
	WHERE
		ppo.PurchaseOrderID IS NULL

/*
3   
*/

SELECT o.OrderID, CONVERT(NVARCHAR, o.OrderDate, 104) AS OrderDate, c.CustomerName, DATENAME(MM, o.OrderDate) AS Mounth, DATEPART(QUARTER, o.OrderDate) AS [Quarter],
CASE WHEN MONTH(o.OrderDate) <5 THEN 1 WHEN MONTH(o.OrderDate) > 8 THEN 3 ELSE 2 END [Quarter1]
FROM Sales.Orders AS o
JOIN Sales.OrderLines AS ol ON o.OrderID = ol.OrderID 
JOIN Sales.Customers AS c ON o.CustomerID = c.CustomerID
WHERE ol.UnitPrice > 100 or ol.Quantity > 20 and ol.PickingCompletedWhen is not null
ORDER BY [Quarter], [Quarter1], o.OrderDate

SELECT o.OrderID, CONVERT(NVARCHAR, o.OrderDate, 104) AS OrderDate, c.CustomerName, DATENAME(MM, o.OrderDate) AS Mounth, DATEPART(QUARTER, o.OrderDate) AS [Quarter],
CASE WHEN MONTH(o.OrderDate) <5 THEN 1 WHEN MONTH(o.OrderDate) > 8 THEN 3 ELSE 2 END [Quarter1]
FROM Sales.Orders AS o
JOIN Sales.OrderLines AS ol ON o.OrderID = ol.OrderID 
JOIN Sales.Customers AS c ON o.CustomerID = c.CustomerID
WHERE ol.UnitPrice > 100 or ol.Quantity > 20 and ol.PickingCompletedWhen is not null
ORDER BY [Quarter], [Quarter1], o.OrderDate OFFSET 1000 rows fetch first 100 rows only

 
	
SELECT
	ppo.PurchaseOrderID,
	ppo.OrderDate,
	ppo.ExpectedDeliveryDate,
	adm.DeliveryMethodName,
	ps.SupplierName,
	ap.FullName AS [Contact Person Name]
	FROM Purchasing.PurchaseOrders AS ppo
	JOIN Application.DeliveryMethods as adm ON ppo.DeliveryMethodID = adm.DeliveryMethodID
	LEFT JOIN Purchasing.Suppliers as ps ON ppo.SupplierID = ps.SupplierID
	LEFT JOIN Application.People as ap ON ppo.ContactPersonID = ap.PersonID
	WHERE
	ppo.ExpectedDeliveryDate BETWEEN '20130101' AND '20130131'
	AND ppo.IsOrderFinalized = 1
	AND adm.DeliveryMethodName IN ('Air Freight', 'Refrigerated Air Freight')

	GO

 

SELECT TOP 10
		 so.OrderID,
		 so.OrderDate,
		 sc.CustomerName,
		 ap.FullName
	FROM Sales.Orders AS so
		LEFT JOIN Sales.Customers AS sc ON so.CustomerID = sc.CustomerID
		LEFT JOIN Application.People AS ap ON so.SalespersonPersonID = ap.PersonID
	ORDER BY
		so.OrderID DESC

	GO

/*
6  
*/

	DECLARE @StockItemName nvarchar(100) = 'Chocolate frogs 250g', @StockItemID int;

	SET @StockItemID = (SELECT StockItemID FROM Warehouse.StockItems WHERE StockItemName = @StockItemName)

	SELECT DISTINCT
		 sc.CustomerID,
		 sc.CustomerName,
		 sc.PhoneNumber
	FROM Warehouse.StockItems as wsi
		 JOIN Sales.OrderLines as sol ON wsi.StockItemID = sol.StockItemID
		 JOIN Sales.Orders as so ON sol.OrderID = so.OrderID
		 JOIN Sales.Customers as sc ON sc.CustomerID = so.CustomerID
	WHERE
		wsi.StockItemID = @StockItemID

	GO