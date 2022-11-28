
USE WideWorldImporters

/*
1. ��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.
�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys.
��� ������� ����� �������� ��� ����� �������� ������ ���������.
��������, �������� �������� "Tailspin Toys (Gasport, NY)" - �� �������� ������ "Gasport, NY".
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.
������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

 select * from 
 (
 select	(SELECT SUBSTRING(C.CustomerName,CHARINDEX('(',C.CustomerName)+1,(CHARINDEX(')',C.CustomerName)-CHARINDEX('(',C.CustomerName))-1) 
		FROM Sales.Customers as C
		WHERE C.CustomerID = I.CustomerID
		) AS CustomerName,
		I.OrderID,
		cast(DATEADD(mm,Datediff(mm,0,InvoiceDate),0) as DATE) as MonthInv 
		from Sales.InvoiceLines as LI
		Left join Sales.Invoices I on LI.InvoiceID = I.InvoiceID
	where CustomerID between 2 and 6 
	) as A
 PIVOT
(
count(OrderID) for CustomerName in ("Peeples Valley, AZ", "Jessie, ND", "Gasport, NY", "Medicine Lodge, KS", "Sylvanite, MT" )
) as pvt
order by MonthInv

/*
2. ��� ���� �������� � ������, � ������� ���� "Tailspin Toys"
������� ��� ������, ������� ���� � �������, � ����� �������.
������ ����������:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select unpt.CustomerName, unpt.Adress
from (select C.CustomerName, C.DeliveryAddressLine1, C.DeliveryAddressLine2, C.PostalAddressLine1, C.PostalAddressLine2
	from Sales.Customers C where C.CustomerName Like '%Tailspin Toys%') as Adr
Unpivot (Adress FOR Name in (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)) as unpt

/*
3. � ������� ����� (Application.Countries) ���� ���� � �������� ����� ������ � � ���������.
�������� ������� �� ������, �������� � �� ���� ���, 
����� � ���� � ����� ��� ���� �������� ���� ��������� ���.
������ ����������:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryID, CountryName, Code
from	(select C.CountryID, C.CountryName, C.IsoAlpha3Code, convert(nvarchar(3),C.IsoNumericCode) as IsoNumericCode
		from Application.Countries as C ) as A

Unpivot (Code FOR name in (A.IsoAlpha3Code, A.IsoNumericCode)) as B

/*
4. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/

;with CTE as 
(
	select I.CustomerID, C.CustomerName, I.InvoiceDate, IL.UnitPrice
	From Sales.Invoices I
	left join Sales.InvoiceLines IL on I.InvoiceID = IL.InvoiceID
	left join Sales.Customers C on I.CustomerID=C.CustomerID
)
select O.CustomerID, O.CustomerName, O.InvoiceDate, O.UnitPrice 
from Sales.Customers C
cross apply (
			select top 2 *
			From CTE 
			Where C.CustomerID = CTE.CustomerID
			order by UnitPrice desc
			) as O
order by C.CustomerName 