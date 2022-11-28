
USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
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
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
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
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.
Вывести:
* Год продажи
* Месяц продажиn
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
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

