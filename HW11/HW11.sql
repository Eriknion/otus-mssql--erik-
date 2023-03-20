������ ��������� ������.
�������� ������ � ������������� ��� ������ �������.
����� �������� ��������� DDL ��� �������� �� ������ �������:
1. ������� ���� ������.
2. 3-4 �������� ������� ��� ������ �������.
3. ��������� � ������� ����� ��� ���� ��������� ������.
4. 1-2 ������� �� �������.
5. �������� �� ������ ����������� � ������ ������� �� ���� ������.
����������� (���� ��� ���) ������ ���� �������� ���������� �������.

CREATE DATABASE [otus_project]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'otus_project', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\otus_project.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'otus_project_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\otus_project_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [otus_project].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

--������� 
����������

CREATE TABLE customers(

	id int not null identity(1, 1)  primary key,

	fio varchar(255),

	email varchar(255),

	phone int,
birth_date date

);


--������� ������ 

CREATE TABLE sku(

	sku_id int not null identity(1, 1)  primary key,
       id_supplier int,

	sku_name varchar(255),

	price decimal(18,3),

	collection_name varchar(255)

	

);



--������� ������

CREATE TABLE orders(

	order_num 	int not null identity(1, 1)  primary key,

	order_date datetime,

	customer_id int,

       cancel_reason_id int,

	source_id int,
       state varchar(255),

	CONSTRAINT FK_customer_id FOREIGN KEY (customer_id)

    REFERENCES customers(id)

);



--������ ������

CREATE TABLE order_rows(

	order_num 	int identity(1, 1)  primary key,

sku_id int

);


--�������� �����������

ALTER TABLE order_rows  ADD  CONSTRAINT FK_v_k FOREIGN KEY(order_num)
REFERENCES orders (order_num)

ALTER TABLE customers  ADD  CONSTRAINT FK_customers FOREIGN KEY(id)
REFERENCES customers (id)

ALTER TABLE sku  ADD  CONSTRAINT FK_sku FOREIGN KEY(sku_id)
REFERENCES sku (sku_id)

ALTER TABLE orders  ADD  CONSTRAINT FK_order_num FOREIGN KEY(order_num)
REFERENCES orders (order_num)




----�������� �������� 




--������� ���������� (customers)



CREATE UNIQUE INDEX idx_fio ON dbo.customers  (fio);




--������� ������ (orders)

CREATE UNIQUE INDEX idx_orders ON dbo.orders (order_num, order_date);




--������� ������ (sku)

CREATE UNIQUE INDEX sku_name ON dbo.products (sku_name);