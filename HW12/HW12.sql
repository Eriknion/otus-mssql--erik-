�� ���� �������� �������� �������� ��������� / ������� � ������������������ �� �������������.

1 �������� ������� ������������ ������� � ���������� ������ �������.

CREATE FUNCTION GetCustomerWithBiggestSumOfPurchase2()
    RETURNS INT
    AS
    BEGIN
    DECLARE @CustomerID INT
    SELECT @CustomerID = CustomerID FROM [Sales].[Invoices] inv 
    JOIN (
        SELECT TOP(1) InvoiceID, SUM(Quantity*UnitPrice) AS SumOfInvoice
        FROM [Sales].[InvoiceLines]
        GROUP BY InvoiceID
        ORDER BY SumOfInvoice DESC) AS invLines ON inv.InvoiceID = invLines.InvoiceID
    RETURN @CustomerID
    END

	
	select dbo.GetCustomerWithBiggestSumOfPurchase2() as CustomerID; ---������� ���������� ���������, �� ���������� ������. ������� ������ ��� �������� ����������?




2 �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
������������ ������� :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines


CREATE PROCEDURE CB_PriceForCustomer
(@CastCustomerID int)
AS
begin
select SUM(ExtendedPrice) as suminv from Sales.InvoiceLines invl with (nolock)
		inner join Sales.Invoices inv on inv.InvoiceID = invl.InvoiceID
		inner join Sales.Customers cus on cus.CustomerID = inv.CustomerID
		where inv.CustomerID = @CastCustomerID
		
END;

exec CB_PriceForCustomer @CastCustomerID = 10 --- ����� ������� ���������� ���������, �� ���������� ������� ���������� ����������. ����������� �������� ��� � ����� �� ���


3 ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.(������� � ������������������ �� ��������)
CREATE OR ALTER PROCEDURE GetSumOfPurchase3
    @CustomerID INT
AS
BEGIN
 SET NOCOUNT ON;  
 WITH InvoicesByCustomer AS (
     SELECT inv.CustomerID AS CustomerID
     , inv.InvoiceID AS InvoiceID
     , invLines.SumOfInvoice
       FROM [Sales].[Invoices] inv
  JOIN (
	SELECT InvoiceID, SUM(Quantity*UnitPrice) AS SumOfInvoice
    FROM [Sales].[InvoiceLines]
    GROUP BY InvoiceID
        ) AS invLines ON inv.InvoiceID = invLines.InvoiceID
  WHERE CustomerID = @CustomerID
 )
 
 SELECT SUM(SumOfInvoice) AS SumOfPurchases
  FROM InvoicesByCustomer
  GROUP BY CustomerID
END

GO

CREATE OR ALTER FUNCTION fGetSumOfPurchase(@CustomerID INT)
RETURNS FLOAT
AS
BEGIN
DECLARE @sum FLOAT;
WITH InvoicesByCustomer AS (
     SELECT inv.CustomerID AS CustomerID
     , inv.InvoiceID AS InvoiceID
     , invLines.SumOfInvoice
       FROM [Sales].[Invoices] inv
  JOIN (
	SELECT InvoiceID, SUM(Quantity*UnitPrice) AS SumOfInvoice
  FROM [Sales].[InvoiceLines]
  GROUP BY InvoiceID
  ) AS invLines ON inv.InvoiceID = invLines.InvoiceID
  WHERE CustomerID = @CustomerID
 )
 SELECT @sum = SUM(SumOfInvoice)
  FROM InvoicesByCustomer
  GROUP BY CustomerID
  RETURN @sum
END

4�������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����.'

Create function GetSumInvoiceByInvoiceID(@InvoiceID int)
Returns Table
as
Return
(
Select distinct Sum(il.UnitPrice) OVER (Partition by i.InvoiceID) as 'SumUnitPrice'
      ,i.InvoiceID as 'InvoiceID'
  from Sales.Invoices i
 inner join Sales.InvoiceLines il
    on il.InvoiceID = i.InvoiceID
);

Select top 10 i.InvoiceDate
      ,i.InvoiceID
	  ,(Select f.SumUnitPrice from GetSumInvoiceByInvoiceID(i.InvoiceID) f where i.InvoiceID = f.InvoiceID) as 'SumUnitPrice'
  from Sales.Invoices i