
USE WideWorldImporters
/*
1. ������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� 
(� ������ ������ ������ �� ����� ����������, ��������� ����� � ������� ������� �������).
��������: id �������, �������� �������, ���� �������, ����� �������, ����� ����������� ������
������:
-------------+----------------------------
���� ������� | ����������� ���� �� ������
-------------+----------------------------
 2015-01-29  | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
������� ����� ����� �� ������� Invoices.
����������� ���� ������ ���� ��� ������� �������.
*/
SET STATISTICS TIME  ON
SET STATISTICS io  ON
 
SELECT x.[OrderID], p.FullName, x.[InvoiceDate], 
             (SELECT sum(l.UnitPrice*l.[Quantity])
             FROM [Sales].[InvoiceLines] as l
             JOIN [Sales].[Invoices] as y on y.InvoiceID = l.InvoiceID
             WHERE format(y.[InvoiceDate], 'yyyyMM') <= format(x.[InvoiceDate], 'yyyyMM')
             and y.[InvoiceDate] >= '20150101'
             ) as total
from [Sales].[Invoices] as x
JOIN [Application].[People] as p on p.[PersonID] = x.[CustomerID]
WHERE x.[InvoiceDate] >= '20150101'
order by x.[InvoiceDate]

SET STATISTICS IO OFF; 
GO 
2 ������ 14 ��� � 100% cost

/*
2. �������� ������ ����� ����������� ������ � ���������� ������� � ������� ������� �������.
   �������� ������������������ �������� 1 � 2 � ������� set statistics time, io on
*/

/*������� �������*/
SET STATISTICS TIME  ON
SET STATISTICS io  ON
 
SELECT
	inv.InvoiceID, 
	cust.CustomerName, 
	inv.InvoiceDate, 
	line.Quantity * line.UnitPrice as InvoiceSum,
	SUM(Quantity*UnitPrice) OVER(ORDER BY month(inv.InvoiceDate), year(inv.InvoiceDate))  as RunningTotal
FROM Sales.Invoices as inv
JOIN Sales.InvoiceLines as line on inv.InvoiceID=line.InvoiceID
JOIN Sales.Customers as cust ON inv.CustomerID=cust.CustomerID
WHERE inv.InvoiceDate >= '20150101'
ORDER BY InvoiceDate

SET STATISTICS IO OFF; 
GO 
2.2 ������� � 100% cost - ��� �������

/*���*/

select	*,
		sum(TransactionAmount) over (order by DRNK) as RunningTotalMonth
from(
	select  *, 
			Dense_Rank() OVER (order by Date_1) as DRNK
	from 
		(select 
			CT.CustomerTransactionID,
			(SELECT	Customers.CustomerName 
			FROM Sales.Customers
			WHERE Customers.CustomerID = CT.CustomerID
			) AS CustomerName,  
			format(CT.TransactionDate, 'MM.yyyy') as Date_1,
			CT.TransactionAmount,
			sum(TransactionAmount) over (order by CustomerTransactionID,TransactionAmount) as RunningTotalSort
		from Sales.CustomerTransactions as CT
		where Year(CT.TransactionDate)>=2015 and CT.InvoiceID is not null
	
		) as A
	) as B
order by CustomerTransactionID

/*
3. ������� ������ 2� ����� ���������� ��������� (�� ���������� ���������) 
� ������ ������ �� 2016 ��� (�� 2 ����� ���������� �������� � ������ ������).
*/
SELECT *
FROM 
	(
		select *, row_number() OVER (partition by MonthInv order by SumMonthQuQuantity desc) as RN
			from(
				select	LI.StockItemID,
						Sum(LI.Quantity) as SumMonthQuQuantity,
						Month(I.InvoiceDate) as MonthInv
				from Sales.InvoiceLines as LI
					Left join Sales.Invoices I on
					LI.InvoiceID = I.InvoiceID
				where Year(I.InvoiceDate) = 2016
				group by LI.StockItemID, Month(I.InvoiceDate)
				) as A
		) as B
		WHERE RN <= 2
Order By MonthInv

/*���*/

select top 10 row_number() OVER (partition by MonthInv order by SumMonthQuQuantity desc) AS RN, *
	from(
		select	LI.StockItemID,
				Sum(LI.Quantity) as SumMonthQuQuantity,
				Month(I.InvoiceDate) as MonthInv
		from Sales.InvoiceLines as LI
			Left join Sales.Invoices I on
			LI.InvoiceID = I.InvoiceID
		where Year(I.InvoiceDate) = 2016
		group by LI.StockItemID, Month(I.InvoiceDate)
		) as A
Order By RN, SumMonthQuQuantity desc

/*
4. ������� ����� ��������
���������� �� ������� ������� (� ����� ����� ������ ������� �� ������, ��������, ����� � ����):
* ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
* ���������� ����� ���������� ������� � �������� ����� � ���� �� �������
* ���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
* ���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
* ���������� �� ������ � ��� �� �������� ����������� (�� �����)
* �������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
* ����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
��� ���� ������ �� ����� ������ ������ ��� ������������� �������.
*/

select
		WS.StockItemID, 
		WS.StockItemName, 
		WS.Brand,
		WS.UnitPrice ,
		LEFT(WS.StockItemName, 1)  as First_Leter_ItemName,
		rank() OVER (partition by LEFT(WS.StockItemName, 1) order by StockItemName) as Num,
		count(WS.StockItemID) over () as cnt_all,
		count(WS.StockItemID) over (partition by LEFT(WS.StockItemName, 1) ) as cnt_group,
		LEAD(StockItemID) OVER (ORDER BY StockItemName) AS NextItemID,
		LAG(StockItemID,1,0) OVER (ORDER BY StockItemName) AS PrevItemID , 
		LAG(StockItemName,2,'No items') OVER (ORDER BY StockItemName) AS PrevBack_2_ItemName,
		WS.TypicalWeightPerUnit,
		Ntile(30) over (ORDER BY WS.TypicalWeightPerUnit ) as NtileGr30
from Warehouse.StockItems as WS
order by StockItemName

/*
5. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������.
   � ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������.
*/

select top (1) with ties
			sum(IL.UnitPrice*IL.Quantity) as SumInv, 
			(SELECT People.FullName 
			FROM Application.People
			WHERE People.PersonID = I.SalespersonPersonID
			) AS SalesPersonName,
			(SELECT	Customers.CustomerName 
			FROM Sales.Customers
			WHERE Customers.CustomerID = I.CustomerID
			) AS CustomerName, 
			InvoiceDate,
ROW_NUMBER () over (partition by SalespersonPersonID order by InvoiceDate desc) as RN
from Sales.InvoiceLines as IL
	Left join Sales.Invoices as I on
	IL.InvoiceID = I.InvoiceID
	Group by SalespersonPersonID, CustomerID, InvoiceDate
	order by ROW_NUMBER () over (partition by SalespersonPersonID order by InvoiceDate desc) 

/*
6. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/

SELECT distinct *
FROM 
	(
	select I.CustomerID,
					(SELECT	Customers.CustomerName 
					FROM Sales.Customers
					WHERE Customers.CustomerID = I.CustomerID
					) AS CustomerName,	
					IL.StockItemID,
					IL.UnitPrice,
					I.InvoiceDate,
					Dense_Rank() OVER (PARTITION BY CustomerId ORDER BY UnitPrice DESC) AS DRNK
	From Sales.InvoiceLines as IL
		Left Join Sales.Invoices as I on 
	IL.InvoiceID = I.InvoiceID
	) AS tbl
	WHERE DRNK <= 2
ORDER BY CustomerId, UnitPrice DESC

