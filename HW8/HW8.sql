/*
Домашнее задание по курсу Разработчик MS SQL Server в OTUS.
Занятие "10 - Операторы изменения данных".
Задания зависят от использования базы данных WideWorldImporters.
Бэкап БД скачать можно отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak
Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-------------------------------------------------- _ ---------------------------
-- Задание - написать выборки для получения нижеперечисленного.
-------------------------------------------------- _ ---------------------------

ИСПОЛЬЗОВАТЬ WideWorldImporters

/*
1. Создание в базе пяти записей с использованием вставки в таблицу. Заказчики или поставщики.
*/

объявить @CustomerID INT ,
		@CustomerName varchar ( MAX ),
		@BillToCustomerId INT ,
		@PrimaryContactPersonID INT ,
		@DeliveryCityID INT ,
		@PostalCityID INT ,
		@AccountOpenedDate ДАТА ,
		@DeliveryPostalCode INT ,
		@PostalPostalCode INT ,
		@LastEditedBy INT
		;
установить @CustomerID =  СЛЕДУЮЩЕЕ  ЗНАЧЕНИЕ  ДЛЯ ПОСЛЕДОВАТЕЛЬНОСТЕЙ  . Пользовательский ИД
установить @CustomerName =  ' NEWCustomerName_1'
установить @BillToCustomerId = @CustomerID

Выберите   @PrimaryContactPersonID =   PrimaryContactPersonID /* +1 */  из  Sales . Клиенты  как C
где  С . CustomerID  = ( выберите  MAX ( C1 . CustomerID ) из  Sales . Customers  как C1)

установить @DeliveryCityID =  29158
установить @PostalCityID = @DeliveryCityID
установить @AccountOpenedDate =  GETDATE ()
установить @DeliveryPostalCode =  90760
установить @PostalPostalCode = @DeliveryPostalCode
установить @LastEditedBy =  1

ОБЪЯВИТЬ @I INT  =  2

ПОКА @I <  6
НАЧИНАТЬ

установить @CustomerID =  СЛЕДУЮЩЕЕ  ЗНАЧЕНИЕ  ДЛЯ ПОСЛЕДОВАТЕЛЬНОСТЕЙ  . Пользовательский ИД
set @CustomerName =  ' NEWCustomerName_'  +  CONVERT ( varchar ( max ),@I)
установить @BillToCustomerId = @CustomerID

-- ВЫБЕРИТЕ @CustomerID

вставить  в  Продажи . Клиенты 
           ([Пользовательский ИД]
           ,[Имя Клиента]
           ,[ID БиллКлиента]
           ,[ИдентификаторКатегорииЗаказчика]
           ,[Идентификатор группы закупок]
           ,[Идентификатор основного контактного лица]
           ,[AlternateContactPersonID]
           ,[ID_метода_доставки]
           ,[ID города доставки]
           ,[Идентификатор почтового города]
           ,[Кредитный лимит]
           ,[дата открытия счета]
           ,[Стандартный процент скидки]
           ,[Отправлено Заявление]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[Номер телефона]
           ,[Номер факса]
           ,[Выполнение доставки]
           ,[РаботаПозиция]
           ,[URL веб-сайта]
           ,[ДоставкаАдресСтрока1]
           ,[DeliveryAddressLine2]
           ,[Почтовый индекс доставки]
           ,[Адрес доставки]
           ,[ПочтовыйАдресСтрока1]
           ,[ПочтовыйАдресСтрока2]
           ,[Почтовый индекс]
           ,[Последнее редактирование])
ВЫХОД вставлен. * 

 ЦЕННОСТИ
           (@Пользовательский ИД
           ,@Имя Клиента
           ,@BillToCustomerId
           , 1
           , 1
           , @PrimaryContactPersonID
           , НОЛЬ
           , 3
           ,@DeliveryCityID
           , @PostalCityID
           , 5000
           ,@AccountOpenedDate
           , 0 . 00
           , 0
           , 0
           , 7
           , ' (206) 555-0100'
           , ' (206) 555-0101'
           , НОЛЬ
           , НОЛЬ
           , http://www.microsoft.com/ _
           , ' Магазин 55'
           , " 655 Виктория Лейн"
           ,@DeliveryPostalCode
           ,0xE6100000010C11154FE2182D4740159ADA087A035FC0
           , а /я 811
           , Миликавилль _
           ,@ПочтовыйПочтовыйКод
           ,@LastEditedBy
		   )
		   НАБОР @I = @I +  1
КОНЕЦ
ИДТИ

/*
2. Удалите одну запись от клиентов, которая была добавлена ​​вами
*/

удалить  ИЗ  Продажи . Клиенты  , для которых [CustomerName] =  ' NEWCustomerName_5'


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

Обновить  продажи . Клиенты
установите [CreditLimit] =  4999  , где [CustomerName] =  ' NEWCustomerName_4'

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит, если она уже есть
*/

ОБЪЕДИНИТЬ 
Продажи . Клиенты  как трг
используя ( select  *  FROM  Sales . Customers  where [CustomerName] like  ' NEWCustomerName_1' ) as src
на  трг . ИмяКлиента  =  источник . Имя Клиента
КОГДА СООТВЕТСТВУЕТ ТО 
ОБНОВЛЕНИЕ  УСТАНОВКИ  трг . ИмяКлиента  =  ' NEWCustomerName_101'
КОГДА  НЕ СООТВЕТСТВУЕТ ТО 
ВСТАВИТЬ ( [ID клиента]
           ,[Имя Клиента]
           ,[ID БиллКлиента]
           ,[ИдентификаторКатегорииЗаказчика]
           ,[Идентификатор группы закупок]
           ,[Идентификатор основного контактного лица]
           ,[AlternateContactPersonID]
           ,[ID_метода_доставки]
           ,[ID города доставки]
           ,[Идентификатор почтового города]
           ,[Кредитный лимит]
           ,[дата открытия счета]
           ,[Стандартный процент скидки]
           ,[Отправлено Заявление]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[Номер телефона]
           ,[Номер факса]
           ,[Выполнение доставки]
           ,[РаботаПозиция]
           ,[URL веб-сайта]
           ,[ДоставкаАдресСтрока1]
           ,[DeliveryAddressLine2]
           ,[Почтовый индекс доставки]
           ,[Адрес доставки]
           ,[ПочтовыйАдресСтрока1]
           ,[ПочтовыйАдресСтрока2]
           ,[Почтовый индекс]
           ,[Последнее редактирование])

ЗНАЧЕНИЯ ( src.[CustomerID]
           , ' NEWCustomerName_101'
           , src.[BillToCustomerID]
           ,src.[CustomerCategoryID]
           ,src.[Идентификатор группы закупок]
           ,src.[Идентификатор основного контактного лица]
           ,src.[AlternateContactPersonID]
           , источник.[ID_метода_доставки]
           , источник. [ID города доставки]
           , источник.[PostalCityID]
           , src.[Кредитный лимит]
           , источник. [Дата Открытия Аккаунта]
           ,src.[Стандартный процент скидки]
           , источник.[IsStatementSent]
           ,источник[IsOnCreditHold]
           ,src.[PaymentDays]
           , источник.[Телефонный номер]
           ,источник.[НомерФакса]
           , источник[DeliveryRun]
           ,источник[RunPosition]
           , источник [URL-адрес веб-сайта]
           , источник.[DeliveryAddressLine1]
           , источник.[DeliveryAddressLine2]
           ,src.[DeliveryPostalCode]
           , источник. [Место доставки]
           ,src.[PostalAddressLine1]
           ,src.[PostalAddressLine2]
           ,src.[PostalPostalCode]
           ,src.[LastEditedBy]);


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

----Подготовительные мероприятия (SERVERNAME заменен на свякий случай, но код работает)
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME

----Делаем bcp out 
drop table if exists [dbo].[Sales_FORHW8]

select S.sales_id, S.customer_id, S.item_id 
into Sales_FORHW8 
FROM Sales S 

exec master..xp_cmdshell 'bcp "[WideWorldImporters].dbo.Sales_FORHW8" out  "C:\Intel\Sales_FORHW8.txt" -T -w -t$$$ -S MYSERVER1\SQL2017'

----Делаем простенький bulk insert без первычных ключей

drop table if exists [dbo].[Sales_FORHW8]

CREATE TABLE [dbo].[Sales_FORHW8](
	[sales_id] [int] NOT NULL,
	[customer_id] [int] NOT  NULL ,
	[item_id] [int] НЕ  NULL )
	
ИДТИ
	МАССОВАЯ ВСТАВКА [dbo].[Sales_FORHW8]
				   ИЗ  " C:\Intel\Sales_FORHW8.txt "
				   С 
					 (
						ПАРТИЯ  =  1000 ,
						DATAFILETYPE  =  ' широкий символ' ,
						ПОЛЕТЕРМИНАТОР  =  ' $$$' ,
						ROWTERMINATOR  = ' \n' ,
						КИПНУЛЛС ,
						ТАБЛОК        
					  );
-- --Проверяем результат - работает
выберите  * 
ОТ Sales_FORHW8