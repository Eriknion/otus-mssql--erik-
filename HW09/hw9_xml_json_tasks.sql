/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "08 - ������� �� XML � JSON �����".

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
���������� � �������� 1, 2:
* ���� � ��������� � ���� ����� ��������, �� ����� ������� ������ SELECT c ����������� � ���� XML. 
* ���� � ��� � ������� ������������ �������/������ � XML, �� ������ ����� ���� XML � ���� �������.
* ���� � ���� XML ��� ����� ������, �� ������ ����� ����� �������� ������ � ������������� �� � ������� (��������, � https://data.gov.ru).
* ������ ��������/������� � ���� https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. � ������ �������� ���� ���� StockItems.xml.
��� ������ �� ������� Warehouse.StockItems.
������������� ��� ������ � ������� ������� � ������, ������������ Warehouse.StockItems.
����: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

��������� ��� ������ � ������� Warehouse.StockItems: 
������������ ������ � ������� ��������, ������������� �������� (������������ ������ �� ���� StockItemName). 

������� ��� ��������: � ������� OPENXML � ����� XQuery.
*/
------------------------------------------------------------
/*1 ������ XQuery, ���� UPDATE � INSERT ����� ������� �����, ���� �� ������ ��� ����*/

Declare @x XML

set @x = (select * from OPENROWSET (BULK 'C:\Users\annaakh\Documents\StockItems.xml', SINGLE_CLOB) as d) 


select 
  t.StockItem.value ('@Name', 'nvarchar(100)') as [StockItemName]
 ,t.StockItem.value('SupplierID[1]', 'int') as [SupplierID]
 ,t.StockItem.value('Package[1]/UnitPackageID[1]', 'int') as [UnitPackageID]
 ,t.StockItem.value('Package[1]/OuterPackageID[1]', 'int') as [OuterPackageID]
 ,t.StockItem.value('Package[1]/QuantityPerOuter[1]', 'int') as [QuantityPerOuter]
 ,t.StockItem.value('Package[1]/TypicalWeightPerUnit[1]', 'decimal(18, 3)') as [TypicalWeightPerUnit]
 ,t.StockItem.value('LeadTimeDays[1]', 'int') as [LeadTimeDays]
 ,t.StockItem.value('IsChillerStock[1]', 'bit') as [IsChillerStock]
 ,t.StockItem.value('TaxRate[1]', 'decimal(18, 3)') as [TaxRate]
 ,t.StockItem.value('UnitPrice[1]', 'decimal(18, 2)') as [UnitPrice]
--,t.StockItem.query('.')

from @x.nodes('/StockItems/Item') as t(StockItem)
go

/*2 ������ OPENXML*/

Declare
@handle int
,@xmlDOC xml

select @xmlDOC = BulkColumn
from OPENROWSET
(BULK 'C:\Users\annaakh\Documents\StockItems.xml',
SINGLE_CLOB)
as data
EXEC sp_xml_preparedocument @handle OUTPUT, @xmlDOC

Drop table if exists #StockItemsForHW9
create table #StockItemsForHW9
(
StockItemName nvarchar(100) COLLATE Latin1_General_100_CI_AS
, SupplierID int
, UnitPackageID int
, OuterPackageID int
, QuantityPerOuter int, TypicalWeightPerUnit decimal(18, 3)
, LeadTimeDays int , IsChillerStock bit , TaxRate decimal(18, 3)
, UnitPrice decimal(18, 2) 
)

Insert into #StockItemsForHW9
select * 
from OPENXML(@handle, N'/StockItems/Item')
with(StockItemName nvarchar(100) '@Name'
	, SupplierID int 'SupplierID'
	, UnitPackageID int 'Package/UnitPackageID'
	, OuterPackageID int 'Package/OuterPackageID'
	, QuantityPerOuter int 'Package/QuantityPerOuter'
	, TypicalWeightPerUnit decimal(18, 3) 'Package/TypicalWeightPerUnit'
	, LeadTimeDays int 'LeadTimeDays'
	, IsChillerStock bit 'IsChillerStock'
	, TaxRate decimal(18, 3) 'TaxRate'
	, UnitPrice decimal(18, 2) 'UnitPrice'
	)
GO	

/*������ - ����� ��� ���� ��������*/

UPDATE trg SET
 trg.SupplierID = src.SupplierID
,trg.UnitPackageID = src.UnitPackageID
,trg.OuterPackageID = src.OuterPackageID
,trg.QuantityPerOuter = src.QuantityPerOuter
,trg.TypicalWeightPerUnit = src.TypicalWeightPerUnit
,trg.LeadTimeDays = src.LeadTimeDays
,trg.IsChillerStock = src.IsChillerStock
,trg.TaxRate = src.TaxRate
,trg.UnitPrice = src.UnitPrice
FROM #StockItemsForHW9 src LEFT JOIN Warehouse.StockItems trg on trg.StockItemName = src.StockItemName
WHERE trg.StockItemID IS NOT NULL

INSERT INTO Warehouse.StockItems ([StockItemID],[StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[QuantityPerOuter],[TypicalWeightPerUnit],[LeadTimeDays],[IsChillerStock],[TaxRate],[UnitPrice],[LastEditedBy])
SELECT NEXT VALUE FOR Sequences.StockItemID AS [StockItemID],src.*,1 AS [LastEditedBy] FROM #StockItemsForHW9 src LEFT JOIN Warehouse.StockItems trg on trg.StockItemName = src.StockItemName
WHERE trg.StockItemID IS NULL

--select * from #StockItemsForHW9
--select * from Warehouse.StockItems

/*
2. ��������� ������ �� ������� StockItems � ����� �� xml-����, ��� StockItems.xml
*/

select  [StockItemName] as [@Name]
		,[SupplierID] as [SupplierID]
		,[UnitPackageID] as [Package/UnitPackageID]
		,[OuterPackageID] as [Package/OuterPackageID]
		,[QuantityPerOuter] as [Package/QuantityPerOuter]
		,[TypicalWeightPerUnit] as [Package/TypicalWeightPerUnit]
		,[LeadTimeDays] as [LeadTimeDays]
		,[IsChillerStock] as [IsChillerStock]
		,[TaxRate] as [TaxRate]
		,[UnitPrice] as [UnitPrice]
from Warehouse.StockItems 

Where StockItemName in (
'"The Gu" red shirt XML tag t-shirt (Black) 3XXL',
'Developer joke mug (Yellow)',
'Dinosaur battery-powered slippers (Green) L',
'Dinosaur battery-powered slippers (Green) M',
'Dinosaur battery-powered slippers (Green) S',
'Furry gorilla with big eyes slippers (Black) XL',
'Large  replacement blades 18mm',
'Large sized bubblewrap roll 50m',
'Medium sized bubblewrap roll 20m',
'Shipping carton (Brown) 356x229x229mm',
'Shipping carton (Brown) 356x356x279mm',
'Shipping carton (Brown) 413x285x187mm',
'Shipping carton (Brown) 457x279x279mm',
'USB food flash drive - sushi roll',
'USB missile launcher (Green)')
order by StockItemName
FOR XML PATH('Item'), ROOT('StockItems')

/*
3. � ������� Warehouse.StockItems � ������� CustomFields ���� ������ � JSON.
�������� SELECT ��� ������:
- StockItemID
- StockItemName
- CountryOfManufacture (�� CustomFields)
- FirstTag (�� ���� CustomFields, ������ �������� �� ������� Tags)
*/

select StockItemID, StockItemName, JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture, JSON_VALUE(CustomFields, '$.Tags[0]') as FirstTag
from Warehouse.StockItems

/*
4. ����� � StockItems ������, ��� ���� ��� "Vintage".
�������: 
- StockItemID
- StockItemName
- (�����������) ��� ���� (�� CustomFields) ����� ������� � ����� ����

���� ������ � ���� CustomFields, � �� � Tags.
������ �������� ����� ������� ������ � JSON.
��� ������ ������������ ���������, ������������ LIKE ���������.

������ ���� � ����� ����:
... where ... = 'Vintage'

��� ������� �� �����:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT  StockItemID,
		StockItemName,
		JSON_QUERY(CustomFields, '$.Tags') as Tags
		,sites.[value]
FROM Warehouse.StockItems
cross apply  OPENJSON(CustomFields, '$.Tags') sites
where 	sites.[value] = 'Vintage'


 -------������������

 drop table if exists #A

select * into #A from
	(
	SELECT  StockItemID,
			StockItemName,
			sites.[value] as Tag
	FROM Warehouse.StockItems
	cross apply  OPENJSON(CustomFields, '$.Tags') sites
	) as d
;
---select * from #A

select #A.StockItemID,
	   STRING_AGG(cast(#A.[Tag] as nvarchar(max)),', ') as TAGS
FROM #A 
cross apply (select StockItemID from Warehouse.StockItems) c2 where #A.StockItemID=c2.StockItemID
group by #A.StockItemID