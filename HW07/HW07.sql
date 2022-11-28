/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "07 - ������������ SQL".
������� ����������� � �������������� ���� ������ WideWorldImporters.
����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak
�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
��� ������� �� ������� "��������� CROSS APPLY, PIVOT, UNPIVOT."
����� ��� ���� �������� ������������ PIVOT, ������������ ���������� �� ���� ��������.
��� ������� ��������� ��������� �� ���� CustomerName.
��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.
������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (������ �������)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


DECLARE @dml as nvarchar(max)
DECLARE @ColumnName as nvarchar(max)

SELECT @ColumnName= ISNULL(@ColumnName + ',','') + QUOTENAME(CustomerName)
from(

	select distinct (SELECT  CustomerName 
		FROM Sales.Customers as C
		WHERE C.CustomerID = I.CustomerID
		) AS CustomerName
		from Sales.InvoiceLines as LI
		Left join Sales.Invoices I on LI.InvoiceID = I.InvoiceID
	--where CustomerID between 2 and 6 /*�������� ��� ������� ��������*/
	) as A

  
set @dml=
	N'SELECT MonthInv, '+ @ColumnName +' From
	(
		select (SELECT CustomerName 
		FROM Sales.Customers as C
		WHERE C.CustomerID = I.CustomerID
		) AS CustomerName, 
		I.OrderID,
		cast(DATEADD(mm,Datediff(mm,0,InvoiceDate),0) as DATE) as MonthInv 
		from Sales.InvoiceLines as LI
		Left join Sales.Invoices I on LI.InvoiceID = I.InvoiceID
	--where CustomerID between 2 and 6 /*�������� ��� ������� ��������*/
	) as A
 PIVOT
	(
	count(OrderID) for CustomerName in ('+ @ColumnName + ')
	) as pvt
 order by MonthInv'


exec(@dml)