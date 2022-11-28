
USE WideWorldImporters

/*
1. ��������� ������� ���� ������, ����� ����� ������� �� �������.
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/

SELECT 
	YEAR(i.InvoiceDate)				as [year], 
	MONTH(i.InvoiceDate)			as [month], 
	AVG(il.UnitPrice)				as Price_AVG, 
	SUM(il.UnitPrice*il.Quantity)	as Price_SUM
FROM [Sales].[Invoices] as i
	JOIN [Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY [year], [month]

/*
2. ���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
SELECT 
	YEAR(i.InvoiceDate)				as [year], 
	MONTH(i.InvoiceDate)			as [month], 
	SUM(il.UnitPrice*il.Quantity)	as Price_SUM
FROM [Sales].[Invoices] as i
	JOIN [Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(il.UnitPrice*il.Quantity) > 4600000
ORDER BY [year], [month]

/*
3. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.
�������:
* ��� �������
* ����� �������n
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
SELECT 
	YEAR(i.InvoiceDate)				as [year], 
	MONTH(i.InvoiceDate)			as [month],
	il.[Description]				as ItemName,
	SUM(il.UnitPrice*il.Quantity)	as Price_SUM,
	MIN(i.InvoiceDate)				as FirstSale,
	SUM(il.Quantity)				as Quantity_SUM
FROM [Sales].[Invoices] as i
	JOIN [Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), il.[Description]
HAVING SUM(il.Quantity) < 50
ORDER BY [year], [month], il.[Description]

