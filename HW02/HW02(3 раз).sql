/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, JOIN".
������� ����������� � �������������� ���� ������ WideWorldImporters.
����� �� WideWorldImporters ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak
�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/

SELECT StockItemID,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName like '%urgent%' OR StockItemName like 'Animal%'



/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

SELECT supplier.SupplierID,supplier.SupplierName
FROM Purchasing.Suppliers as supplier
LEFT JOIN Purchasing.PurchaseOrders as orders
ON supplier.SupplierID = orders.SupplierID
WHERE orders.SupplierID IS NULL


/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.
���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).
�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/


	 SELECT orders.orderid, format(orders.OrderDate, 'dd.MM.yyyy') as date,
                DATENAME(month, orders.OrderDate) as Month,
	        DATEPART(quarter, orders.OrderDate) as Quarter,
		((DATEPART(month, orders.OrderDate)-1)/4 +1) as Third,
	        sales.Description,
		sales.UnitPrice,
		sales.Quantity,
	        sales.OrderLineID
	 FROM Sales.Orders as orders
		LEFT JOIN Sales.OrderLines as sales ON sales.OrderID = orders.OrderID
	 WHERE sales.UnitPrice > 100 OR (sales.Quantity > 20 and sales.PickingCompletedWhen is not null)
	 ORDER BY Quarter, Third, orders.OrderDate 
	 OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY


/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
SELECT delivery.DeliveryMethodName,date.ExpectedDeliveryDate,supplier.SupplierName, contact.FullName
FROM Purchasing.Suppliers supplier
join Purchasing.PurchaseOrders date on date.SupplierID = supplier.SupplierID
join Application.DeliveryMethods delivery on delivery.DeliveryMethodID = date.DeliveryMethodID
join Application.People contact on contact.PersonID = date.ContactPersonID
WHERE 
date.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
and delivery.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight');

/*
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/
SELECT top 10
date.OrderDate,
customer.CustomerName,
personal.FullName
FROM Sales.Orders date
join Sales.Customers customer on customer.CustomerID = date.CustomerID
join Application.People personal on personal.PersonID = date.SalespersonPersonID
order by date.OrderDate desc

/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
*/
SELECT sale.CustomerID, sale.CustomerName,sale.PhoneNumber
FROM Sales.Customers sale
join Sales.Orders orders on orders.CustomerID = sale.CustomerID
join Sales.OrderLines a on a.OrderID = orders.OrderID
join Warehouse.StockItems items on items.StockItemID = a.StockItemID
WHERE items.StockItemName = 'Chocolate frogs 250g';