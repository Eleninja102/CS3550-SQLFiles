---- Shopping Database Creation Script
-- CS 3550
--Coleton Watt
SET NOCOUNT ON;
-------------------------------------------
-- Move to Master Database
-------------------------------------------
USE Master;
GO
-------------------------------------------
-- Drop Database if necessary
-------------------------------------------
IF EXISTS (SELECT * FROM sysdatabases WHERE name = N'ShoppingDatabase')
	DROP DATABASE ShoppingDatabase;

GO
-------------------------------------------
-- Create Database
-------------------------------------------
CREATE DATABASE [ShoppingDatabase]
ON PRIMARY 
( 
	NAME = N'ShoppingDatabase'
	, filename = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ShoppingDatabase.mdf'
	, SIZE = 5MB
	, FILEGROWTH = 1MB
)
LOG ON
(
	NAME = N'ShoppingDatabase_Log'
	, filename = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ShoppingDatabase_Log.ldf'
	, SIZE = 2MB
	, FILEGROWTH = 1MB
)
GO

-------------------------------------------
-- Use The Shopping Database
-------------------------------------------
USE ShoppingDatabase;
GO
-------------------------------------------
-- DROP TABLES
-------------------------------------------

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = N'OrderItem')
	DROP TABLE OrderItem;

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = N'VendorProduct')
	DROP TABLE VendorProduct;

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = N'OrderTable')
	DROP TABLE OrderTable;

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = N'Product')
	DROP TABLE Product;

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = N'Vendor')
	DROP TABLE Vendor;

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = N'Supplier')
	DROP TABLE Supplier;

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = N'Customer')
	DROP TABLE Customer;

GO
-------------------------------------------
-- CREATE TABLES
-------------------------------------------
-- Create Customer Table
CREATE TABLE Customer
(
	sdCustomer_id INT NOT NULL		IDENTITY(1,1) --stat at 1 increment by 1
	, customerEmailAddress NVARCHAR(255) NOT NULL
	, customerFirstName NVARCHAR(50) NOT NULL
	, customerLastName NVARCHAR(50) NOT NULL
	, customerStreetAddress NVARCHAR(255) NOT NULL
	, customerCity NVARCHAR(50) NOT NULL
	, customerState NVARCHAR(2) NOT NULL
	, customerZip NVARCHAR(9) NOT NULL
);
-- Create Vendor Table
CREATE TABLE Vendor
(
	sdVendor_id				INT				NOT NULL		IDENTITY(1,1)
	, vendorEmailAddress	NVARCHAR(255)	NULL
	, vendorPhone			NVARCHAR(10)	NULL
	, vendorName			NVARCHAR(50)	NOT NULL
	, vendorStreetAddress	NVARCHAR(255)	NOT NULL
	, vendorCity			NVARCHAR(50)	NOT NULL
	, vendorState			NVARCHAR(2)		NOT NULL
	, vendorZip				NVARCHAR(9)		NOT NULL
);
-- Create Supplier Table
CREATE TABLE Supplier
(
	sdSupplier_id			INT				NOT NULL		IDENTITY(1,1)
	, supplierName			NVARCHAR(50)	NOT NULL
	, supplierStreetAddress	NVARCHAR(255)	NOT NULL
	, supplierCity			NVARCHAR(50)	NOT NULL
	, supplierState			NVARCHAR(2)		NOT NULL
	, supplierZip			NVARCHAR(9)		NOT NULL
);
-- Create Product Table
CREATE TABLE Product(
	sdProduct_id	INT				NOT NULL		IDENTITY(1,1)
	, sdSupplier_id INT			NOT NULL
	, productName	NVARCHAR(255)	NOT NULL
);

-- Create VendorProduct Table
CREATE TABLE VendorProduct(
	sdVendor_id INT NOT NULL
	, sdProduct_id INT NOT NULL
	, quantityOnHand INT NOT NULL
	, vendorProductPrice SMALLMONEY NOT NULL
);
-- Create Order Table
CREATE TABLE OrderTable(
	sdOrderTable_id	INT	NOT NULL	IDENTITY(1,1)
	, sdCustomer_id INT NOT NULL
	, orderDateTime DATETIME NOT NULL
	, subTotal SMALLMONEY NULL
	, taxAmount SMALLMONEY NULL
	, shippingCost SMALLMONEY NULL
	, orderTotal SMALLMONEY NULL
);
-- Create OrderItem Table
CREATE TABLE OrderItem(
	sdOrderTable_id INT NOT NULL
	, sdProduct_id INT NOT NULL
	, sdVendor_id INT NOT NULL
	, quantity SMALLINT NOT NULL
);

GO
-------------------------------------------
-- CREATE Primary Keys
-------------------------------------------
ALTER TABLE Customer
	ADD CONSTRAINT PK_Customer
	PRIMARY KEY (sdCustomer_id);

ALTER TABLE Vendor
	ADD CONSTRAINT PK_Vendor
	PRIMARY KEY (sdVendor_id);

ALTER TABLE Supplier
	ADD CONSTRAINT PK_Supplier
	PRIMARY KEY (sdSupplier_id);

ALTER TABLE Product
	ADD CONSTRAINT PK_Product
	PRIMARY KEY (sdProduct_id);

ALTER TABLE VendorProduct
	ADD CONSTRAINT PK_VendorProduct
	PRIMARY KEY (sdVendor_id, sdProduct_id);

ALTER TABLE OrderTable
	ADD CONSTRAINT PK_OrderTable
	PRIMARY KEY (sdOrderTable_id);

ALTER TABLE OrderItem
	ADD CONSTRAINT PK_OrderItem
	PRIMARY KEY (sdOrderTable_id, sdProduct_id, sdVendor_id);

GO
-------------------------------------------
-- CREATE Foreign Keys
-------------------------------------------
ALTER TABLE VendorProduct
	ADD CONSTRAINT FK_VendorProduct_VendorID
	FOREIGN KEY (sdVendor_id) REFERENCES Vendor (sdVendor_id);
ALTER TABLE VendorProduct
	ADD CONSTRAINT FK_VendorProduct_ProudctID
	FOREIGN KEY (sdProduct_id) REFERENCES Product (sdProduct_id);


ALTER TABLE Product
	ADD CONSTRAINT FK_Product_SupplierID
	FOREIGN KEY (sdSupplier_id) REFERENCES Supplier (sdSupplier_id);

ALTER TABLE OrderTable
	ADD CONSTRAINT FK_OrderTable_CustomerID
	FOREIGN KEY (sdCustomer_id) REFERENCES Customer (sdCustomer_id);


ALTER TABLE OrderItem
	ADD CONSTRAINT FK_OrderTable_OrderTableID
	FOREIGN KEY (sdOrderTable_id) REFERENCES OrderTable (sdOrderTable_id);
ALTER TABLE OrderItem
	ADD CONSTRAINT FK_OrderTable_VendorID
	FOREIGN KEY (sdVendor_id) REFERENCES Vendor (sdVendor_id);
ALTER TABLE OrderItem
	ADD CONSTRAINT FK_OrderTable_ProductID
	FOREIGN KEY (sdProduct_id) REFERENCES Product (sdProduct_id);


GO

-------------------------------------------
-- CREATE Alternate Keys
-------------------------------------------
ALTER TABLE Customer
	ADD CONSTRAINT AK_Customer_customerEmailAddress
	UNIQUE (customerEmailAddress);

ALTER TABLE Supplier
	ADD CONSTRAINT AK_Supplier_supplierName
	UNIQUE (supplierName);

ALTER TABLE Vendor
	ADD CONSTRAINT AK_Vendor_VendorName
	UNIQUE (vendorName);

ALTER TABLE Product
	ADD CONSTRAINT AK_Product_ProductName
	UNIQUE (productName);

ALTER TABLE OrderTable
	ADD CONSTRAINT AK_OrderTable_OrderDateTime_CustomerID
	UNIQUE (orderDateTime, sdCustomer_id);

GO
-------------------------------------------
-- CREATE Data Constraints
-------------------------------------------
ALTER TABLE Customer
	ADD CONSTRAINT CK_Customer_Zip
	CHECK (customerZip LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		OR customerZip LIKE '[0-9][0-9][0-9][0-9][0-9]');

ALTER TABLE Customer
	ADD CONSTRAINT CK_Customer_emailAddress
	CHECK (customerEmailAddress LIKE '%@%.%');


ALTER TABLE Vendor
	ADD CONSTRAINT CK_Vendor_Phone
	CHECK (vendorPhone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')

ALTER TABLE Vendor
	ADD CONSTRAINT CK_Vendor_Zip
	CHECK (vendorZip LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		OR vendorZip LIKE '[0-9][0-9][0-9][0-9][0-9]');

ALTER TABLE Vendor
	ADD CONSTRAINT CK_Vendor_emailAddress
	CHECK (vendorEmailAddress LIKE '%@%.%');
	

ALTER TABLE Supplier
	ADD CONSTRAINT CK_Supplier_Zip
	CHECK (supplierZip LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		OR supplierZip LIKE '[0-9][0-9][0-9][0-9][0-9]');


GO

------------------------
--- CREATE FUNCTIONS 
------------------------

-----
--ConvertDate Function
-----
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].udf_getDateTime'))
	DROP FUNCTION [dbo].udf_getDateTime;
GO


CREATE FUNCTION [dbo].udf_getDateTime(@orderDateTimeInt NVARCHAR(255))
RETURNS dateTime
AS
BEGIN
	DECLARE @orderDateTimeDateTime dateTime;
	
	SELECT @orderDateTimeDateTime = CONVERT(dateTime, @orderDateTimeInt)
	
	IF @orderDateTimeDateTime IS NULL
	SET @orderDateTimeDateTime = -1
	
	RETURN @orderDateTimeDateTime
END
GO

-----
--ConvertNumber Function
-----
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].udf_convertToInt'))
	DROP FUNCTION [dbo].udf_convertToInt;
GO


CREATE FUNCTION [dbo].udf_convertToInt(@numberChar NVARCHAR(50))
RETURNS INT
AS
BEGIN
	DECLARE @numberInt INT;
	
	SELECT @numberInt = CONVERT(INT, @numberChar)
	
	IF @numberInt IS NULL
	SET @numberInt = -1
	
	RETURN @numberInt
END
GO

-----
--ConvertSmallMoney Function
-----
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].udf_convertToSmallMoney'))
	DROP FUNCTION [dbo].udf_convertToSmallMoney;
GO


CREATE FUNCTION [dbo].udf_convertToSmallMoney(@numberChar NVARCHAR(50))
RETURNS SMALLMONEY
AS
BEGIN
	DECLARE @returnSmallMoney SMALLMONEY;
	
	SELECT @returnSmallMoney = CONVERT(SMALLMONEY, @numberChar)
	
	IF @returnSmallMoney IS NULL
	SET @returnSmallMoney = -1
	
	RETURN @returnSmallMoney
END
GO

-----
--CustomerID Function
-----
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].udf_getCustomerID'))
	DROP FUNCTION [dbo].udf_getCustomerID;
GO


CREATE FUNCTION [dbo].udf_getCustomerID(@customerEmailAddress NVARCHAR(255))
RETURNS INT
AS
BEGIN
	DECLARE @sdCustomer_id INT;
	
	SELECT @sdCustomer_id = sdCustomer_id 
	FROM Customer 
	WHERE customerEmailAddress = @customerEmailAddress
	
	IF @sdCustomer_id IS NULL
	SET @sdCustomer_id = -1
	
	RETURN @sdCUstomer_id
END
GO

-----
--SupplierID Function
-----
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].udf_getSupplierID'))
	DROP FUNCTION [dbo].udf_getSupplierID;
GO

CREATE FUNCTION [dbo].udf_getSupplierID(@supplierName NVARCHAR(255))
RETURNS INT
AS
BEGIN
	DECLARE @sdSupplier_id INT;
	
	SELECT @sdSupplier_id = sdSupplier_id
	FROM Supplier
	WHERE supplierName = @supplierName
	
	IF @sdSupplier_id IS NULL
	SET @sdSupplier_id = -1
	
	RETURN @sdSupplier_id
END 
GO

-----
--VendorID Function
-----
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].udf_getVendorID'))
	DROP FUNCTION [dbo].udf_getVendorID;
GO

CREATE FUNCTION [dbo].udf_getVendorID(@vendorName NVARCHAR(50))
RETURNS INT
AS
BEGIN
	DECLARE @sdVendor_id INT;
	
	SELECT @sdVendor_id = sdVendor_id 
	FROM Vendor 
	WHERE vendorName = @vendorName
	
	
	IF @sdVendor_id IS NULL
	SET @sdVendor_id = -1
	
	RETURN @sdVendor_id
END 
GO

-----
--ProductID Function
-----
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].udf_getProductID'))
	DROP FUNCTION [dbo].udf_getProductID;
GO

CREATE FUNCTION [dbo].udf_getProductID(@productName NVARCHAR(255))
RETURNS INT
AS
BEGIN
	DECLARE @sdProduct_id INT;
	
	SELECT @sdProduct_id = sdProduct_id 
	FROM Product 
	WHERE productName = @productName		
	IF @sdProduct_id IS NULL
	SET @sdProduct_id = -1
	
	RETURN @sdProduct_id
END 
GO

-----
--getOrderTableId Function
-----
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].udf_getOrderTableId'))
	DROP FUNCTION [dbo].udf_getOrderTableId;
GO

CREATE FUNCTION [dbo].udf_getOrderTableId(@orderDateTime NVARCHAR(50), @customerEmailAddress NVARCHAR(255))
RETURNS INT
AS
BEGIN
	DECLARE @sdOrderTable_id INT;
	
	SELECT @sdOrderTable_id = sdOrderTable_id 
	FROM orderTable 
	WHERE orderDateTime = ([dbo].udf_getDateTime(@orderDateTime)) 
	AND sdCustomer_id = ([dbo].udf_getCustomerID(@customerEmailAddress))	
	IF @sdOrderTable_id IS NULL
	SET @sdOrderTable_id = -1
	
	RETURN @sdOrderTable_id
END 
GO
-------------------------------------------
-- CREATE PROCEDURES
-------------------------------------------
-----
--Customer Procedure
-----
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = N'usp_addCustomer')
	DROP PROCEDURE dbo.usp_addCustomer;
GO

CREATE PROCEDURE dbo.usp_addCustomer
	@customerEmailAddress NVARCHAR(255)
	, @customerFirstName NVARCHAR(50)
	, @customerLastName NVARCHAR(50)
	, @customerStreetAddress NVARCHAR(255)
	, @customerCity NVARCHAR(50)
	, @customerState NVARCHAR(2)
	, @customerZip NVARCHAR(9)
AS 
BEGIN
	BEGIN TRY
	
		INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) 
		VALUES(
			@customerEmailAddress
			, @customerFirstName
			, @customerLastName
			, @customerStreetAddress
			, @customerCity
			, @customerState
			, @customerZip
		);
	END TRY
	
	BEGIN CATCH
		PRINT 'The Insert into CUSTOMER failed for:
		customerEmailAddress: ' + @customerEmailAddress
		+ ', customerFirstname: ' + @customerFirstName
		+ ', customerLastname: ' + @customerLastName
		+ ', customerStreetAddress: ' + @customerStreetAddress
		+ ', customerCity: ' + @customerCity
		+ ', customerSate: ' + @customerState
		+ ', customerZip: ' + @customerZip
		+ ', error message: ' + ERROR_MESSAGE();
	END CATCH
END
GO
------
--Vendor Procedure
------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = N'usp_addVendor')
	DROP PROCEDURE dbo.usp_addVendor;
GO

CREATE PROCEDURE dbo.usp_addVendor
	@vendorEmailAddress NVARCHAR(255)
	, @vendorPhone		NVARCHAR(10)
	, @vendorName NVARCHAR(50)
	, @vendorStreetAddress NVARCHAR(255)
	, @vendorCity NVARCHAR(50)
	, @vendorState NVARCHAR(2)
	, @vendorZip NVARCHAR(9)
AS 
BEGIN
	BEGIN TRY
		INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) 
		VALUES(
			@vendorEmailAddress
			, @vendorPhone
			, @vendorName
			, @vendorStreetAddress
			, @vendorCity
			, @vendorState
			, @vendorZip
		);
	END TRY
	
	BEGIN CATCH
		PRINT 'The Insert into VENDOR failed for:
		vendorEmailAddress: ' + @vendorEmailAddress
		+ ', vendorPhone: ' + @vendorPhone
		+ ', vendorName: ' + @vendorName
		+ ', vendorStreetAddress: ' + @vendorStreetAddress
		+ ', vendorCity: ' + @vendorCity
		+ ', vendorState: ' + @vendorState
		+ ', vendorZip: ' + @vendorZip
		+ ', error message: ' + ERROR_MESSAGE();
	END CATCH
END
GO

------
--Supplier Procedure
------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = N'usp_addSupplier')
	DROP PROCEDURE dbo.usp_addSupplier;
GO

CREATE PROCEDURE dbo.usp_addSupplier
	@supplierName NVARCHAR(50)
	, @supplierStreetAddress NVARCHAR(255)
	, @supplierCity NVARCHAR(50)
	, @supplierState NVARCHAR(2)
	, @supplierZip NVARCHAR(9)
AS 
BEGIN
	BEGIN TRY
		INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) 
		VALUES(
			@supplierName
			, @supplierStreetAddress
			, @supplierCity
			, @supplierState
			, @supplierZip
		);
	END TRY
	
	BEGIN CATCH
		PRINT 'The Insert into SUPPLIER failed for:
		supplierName: ' + @supplierName
		+ ', supplierStreetAddress: ' + @supplierStreetAddress
		+ ', supplierCity: ' + @supplierCity
		+ ', supplierState: ' + @supplierState
		+ ', supplierZip: ' + @supplierZip
		+ ', error message: ' + ERROR_MESSAGE();
	END CATCH
END
GO
------
--Product Procedure
------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = N'usp_addProduct')
	DROP PROCEDURE dbo.usp_addProduct;
GO

CREATE PROCEDURE dbo.usp_addProduct
	@supplierName NVARCHAR(50)
	, @productName NVARCHAR(255)
AS 
BEGIN
	BEGIN TRY
		INSERT INTO product(sdSupplier_id, productName) 
		VALUES(
			([dbo].udf_getSupplierID(@supplierName))
			,@productName
		);
	END TRY
	
	BEGIN CATCH
		PRINT 'The Insert into PRODUCT failed for:
		supplierName: ' + @supplierName
		+ ', productName: ' + @productName
		+ ', error message: ' + ERROR_MESSAGE();
	END CATCH
END
GO

-------
--Order Table Procedure
-------

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = N'usp_addOrder')
	DROP PROCEDURE dbo.usp_addOrder;
GO


CREATE PROCEDURE dbo.usp_addOrder
	@customerEmailAddress NVARCHAR(255)
	, @orderDateTime NVARCHAR(50)
	, @subTotal NVARCHAR(10)
	, @taxAmount NVARCHAR(10)
	, @shippingCost NVARCHAR(10)
	, @orderTotal NVARCHAR(10)
AS 
BEGIN
	BEGIN TRY
	
		INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal)
		VALUES(
			([dbo].udf_getCustomerID(@customerEmailAddress))
			, ([dbo].udf_getDateTime(@orderDateTime))
			, ([dbo].udf_convertToSmallMoney(@subTotal))
			, ([dbo].udf_convertToSmallMoney(@taxAmount))
			, ([dbo].udf_convertToSmallMoney(@shippingCost))
			, ([dbo].udf_convertToSmallMoney(@orderTotal))
		);
	END TRY
	
	BEGIN CATCH
		PRINT 'The Insert into Order Table failed for:
		customerEmailAddress: ' + @customerEmailAddress
		+ ', orderDateTime: ' + @orderDateTime
		+ ', subTotal: ' + @subTotal
		+ ', taxAmount: ' + @taxAmount
		+ ', shippingCost: ' + @shippingCost
		+ ', orderTotal: ' + @orderTotal
		+ ', error message: ' + ERROR_MESSAGE();
	END CATCH
END
GO

-------
--Vendor Product Procedure
-------

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = N'usp_addVendorProductItem')
	DROP PROCEDURE dbo.usp_addVendorProductItem;
GO


CREATE PROCEDURE dbo.usp_addVendorProductItem
	@vendorName NVARCHAR(50)
	, @productName NVARCHAR(255)
	, @quantityOnHand NVARCHAR(10)
	, @vendorProductPrice NVARCHAR(10)	
AS 
BEGIN
	BEGIN TRY
		INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quantityOnHand, vendorProductPrice) 
		VALUES(
			([dbo].udf_getVendorID(@vendorName))
			, ([dbo].udf_getProductID(@productName))
			, ([dbo].udf_convertToInt(@quantityOnHand))
			, ([dbo].udf_convertToSmallMoney(@vendorProductPrice))
		);
	END TRY
	
	BEGIN CATCH
		PRINT 'The Insert into VENDOR PRODUCT failed for:
		vendorName: ' + @vendorName
		+ ', productName: ' + @productName
		+ ', quantityOnHand: ' + @quantityOnHand
		+ ', vendorProductPrice: ' + @vendorProductPrice
		+ ', error message: ' + ERROR_MESSAGE();
	END CATCH
END
GO

-------
--orderItem Procedure
-------
			
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = N'usp_addItemToOrder')
	DROP PROCEDURE dbo.usp_addItemToOrder;
GO
			
			
CREATE PROCEDURE dbo.usp_addItemToOrder
	@vendorName NVARCHAR(50)
	, @customerEmailAddress NVARCHAR(255)
	, @orderDateTime NVARCHAR(50)
	, @productName NVARCHAR(255)
	, @quantity NVARCHAR(10)
AS 
BEGIN
	BEGIN TRY
		INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quantity) 
		VALUES(
			([dbo].udf_getOrderTableId(@orderDateTime, @customerEmailAddress))
			, ([dbo].udf_getProductID(@productName))
			, ([dbo].udf_getVendorID(@vendorName))
			, ([dbo].udf_convertToInt(@quantity))
		);
	END TRY
			
	BEGIN CATCH
		PRINT 'The Insert into ITEM ORDER failed for:
		vendorName: ' + @vendorName
		+ ', customerEmailAddress: ' + @customerEmailAddress
		+ ', orderDateTime: ' + @orderDateTime
		+ ', productName: ' + @productName
		+ ', quantity: ' + @quantity
		+ ', error message: ' + ERROR_MESSAGE();
	END CATCH
END
GO

------------------
--Excute Date Entry
------------------
-----
-- Enter Customer Table Data
-----
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='noah.kalafatis@aol.com',@customerFirstname ='Noah', @customerLastName ='Kalafatis', @customerStreetAddress ='1950 5th Ave', @customerCity ='Milwaukee', @customerState ='WI', @customerZip ='53209';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='csweigard@sweigard.com',@customerFirstname ='Carmen', @customerLastName ='Sweigard', @customerStreetAddress ='61304 N French Rd', @customerCity ='Somerset', @customerState ='NJ', @customerZip ='08873';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='lavonda@cox.net',@customerFirstname ='Lavonda', @customerLastName ='Hengel', @customerStreetAddress ='87 Imperial Ct #79', @customerCity ='Fargo', @customerState ='ND', @customerZip ='58102';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='junita@aol.com',@customerFirstname ='Junita', @customerLastName ='Stoltzman', @customerStreetAddress ='94 W Dodge Rd', @customerCity ='Carson City', @customerState ='NV', @customerZip ='89701';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='herminia@nicolozakes.org',@customerFirstname ='Herminia', @customerLastName ='Nicolozakes', @customerStreetAddress ='4 58th St #3519', @customerCity ='Scottsdale', @customerState ='AZ', @customerZip ='85254';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='casie.good@aol.com',@customerFirstname ='Casie', @customerLastName ='Good', @customerStreetAddress ='5221 Bear Valley Rd', @customerCity ='Nashville', @customerState ='TN', @customerZip ='37211';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='reena@hotmail.com',@customerFirstname ='Reena', @customerLastName ='Maisto', @customerStreetAddress ='9648 S Main', @customerCity ='Salisbury', @customerState ='MD', @customerZip ='21801';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='mirta_mallett@gmail.com',@customerFirstname ='Mirta', @customerLastName ='Mallett', @customerStreetAddress ='7 S San Marcos Rd', @customerCity ='New York', @customerState ='NY', @customerZip ='10004';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='cathrine.pontoriero@pontoriero.com',@customerFirstname ='Cathrine', @customerLastName ='Pontoriero', @customerStreetAddress ='812 S Haven St', @customerCity ='Amarillo', @customerState ='TX', @customerZip ='79109';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='ftawil@hotmail.com',@customerFirstname ='Filiberto', @customerLastName ='Tawil', @customerStreetAddress ='3882 W Congress St #799', @customerCity ='Los Angeles', @customerState ='CA', @customerZip ='90016';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='rupthegrove@yahoo.com',@customerFirstname ='Raul', @customerLastName ='Upthegrove', @customerStreetAddress ='4 E Colonial Dr', @customerCity ='La Mesa', @customerState ='CA', @customerZip ='91942';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='sarah.candlish@gmail.com',@customerFirstname ='Sarah', @customerLastName ='Candlish', @customerStreetAddress ='45 2nd Ave #9759', @customerCity ='Atlanta', @customerState ='GA', @customerZip ='30328';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='lucy@cox.net',@customerFirstname ='Lucy', @customerLastName ='Treston', @customerStreetAddress ='57254 Brickell Ave #372', @customerCity ='Worcester', @customerState ='MA', @customerZip ='01602';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='jaquas@aquas.com',@customerFirstname ='Judy', @customerLastName ='Aquas', @customerStreetAddress ='8977 Connecticut Ave Nw #3', @customerCity ='Niles', @customerState ='MI', @customerZip ='49120';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='yvonne.tjepkema@hotmail.com',@customerFirstname ='Yvonne', @customerLastName ='Tjepkema', @customerStreetAddress ='9 Waydell St', @customerCity ='Fairfield', @customerState ='NJ', @customerZip ='07004';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kayleigh.lace@yahoo.com',@customerFirstname ='Kayleigh', @customerLastName ='Lace', @customerStreetAddress ='43 Huey P Long Ave', @customerCity ='Lafayette', @customerState ='LA', @customerZip ='70508';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='felix_hirpara@cox.net',@customerFirstname ='Felix', @customerLastName ='Hirpara', @customerStreetAddress ='7563 Cornwall Rd #4462', @customerCity ='Denver', @customerState ='PA', @customerZip ='17517';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='tresa_sweely@hotmail.com',@customerFirstname ='Tresa', @customerLastName ='Sweely', @customerStreetAddress ='22 Bridle Ln', @customerCity ='Valley Park', @customerState ='MO', @customerZip ='63088';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kristeen@gmail.com',@customerFirstname ='Kristeen', @customerLastName ='Turinetti', @customerStreetAddress ='70099 E North Ave', @customerCity ='Arlington', @customerState ='TX', @customerZip ='76013';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='jregusters@regusters.com',@customerFirstname ='Jenelle', @customerLastName ='Regusters', @customerStreetAddress ='3211 E Northeast Loop', @customerCity ='Tampa', @customerState ='FL', @customerZip ='33619';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='renea@hotmail.com',@customerFirstname ='Renea', @customerLastName ='Monterrubio', @customerStreetAddress ='26 Montgomery St', @customerCity ='Atlanta', @customerState ='GA', @customerZip ='30328';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='olive@aol.com',@customerFirstname ='Olive', @customerLastName ='Matuszak', @customerStreetAddress ='13252 Lighthouse Ave', @customerCity ='Cathedral City', @customerState ='CA', @customerZip ='92234';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='lreiber@cox.net',@customerFirstname ='Ligia', @customerLastName ='Reiber', @customerStreetAddress ='206 Main St #2804', @customerCity ='Lansing', @customerState ='MI', @customerZip ='48933';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='christiane.eschberger@yahoo.com',@customerFirstname ='Christiane', @customerLastName ='Eschberger', @customerStreetAddress ='96541 W Central Blvd', @customerCity ='Phoenix', @customerState ='AZ', @customerZip ='85034';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='goldie.schirpke@yahoo.com',@customerFirstname ='Goldie', @customerLastName ='Schirpke', @customerStreetAddress ='34 Saint George Ave #2', @customerCity ='Bangor', @customerState ='ME', @customerZip ='04401';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='loreta.timenez@hotmail.com',@customerFirstname ='Loreta', @customerLastName ='Timenez', @customerStreetAddress ='47857 Coney Island Ave', @customerCity ='Clinton', @customerState ='MD', @customerZip ='20735';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='fabiola.hauenstein@hauenstein.org',@customerFirstname ='Fabiola', @customerLastName ='Hauenstein', @customerStreetAddress ='8573 Lincoln Blvd', @customerCity ='York', @customerState ='PA', @customerZip ='17404';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='amie.perigo@yahoo.com',@customerFirstname ='Amie', @customerLastName ='Perigo', @customerStreetAddress ='596 Santa Maria Ave #7913', @customerCity ='Mesquite', @customerState ='TX', @customerZip ='75150';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='raina.brachle@brachle.org',@customerFirstname ='Raina', @customerLastName ='Brachle', @customerStreetAddress ='3829 Ventura Blvd', @customerCity ='Butte', @customerState ='MT', @customerZip ='59701';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='erinn.canlas@canlas.com',@customerFirstname ='Erinn', @customerLastName ='Canlas', @customerStreetAddress ='13 S Hacienda Dr', @customerCity ='Livingston', @customerState ='NJ', @customerZip ='07039';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='cherry@lietz.com',@customerFirstname ='Cherry', @customerLastName ='Lietz', @customerStreetAddress ='40 9th Ave Sw #91', @customerCity ='Waterford', @customerState ='MI', @customerZip ='48329';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kattie@vonasek.org',@customerFirstname ='Kattie', @customerLastName ='Vonasek', @customerStreetAddress ='2845 Boulder Crescent St', @customerCity ='Cleveland', @customerState ='OH', @customerZip ='44103';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='lilli@aol.com',@customerFirstname ='Lilli', @customerLastName ='Scriven', @customerStreetAddress ='33 State St', @customerCity ='Abilene', @customerState ='TX', @customerZip ='79601';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='whitley.tomasulo@aol.com',@customerFirstname ='Whitley', @customerLastName ='Tomasulo', @customerStreetAddress ='2 S 15th St', @customerCity ='Fort Worth', @customerState ='TX', @customerZip ='76107';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='badkin@hotmail.com',@customerFirstname ='Barbra', @customerLastName ='Adkin', @customerStreetAddress ='4 Kohler Memorial Dr', @customerCity ='Brooklyn', @customerState ='NY', @customerZip ='11230';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='hermila_thyberg@hotmail.com',@customerFirstname ='Hermila', @customerLastName ='Thyberg', @customerStreetAddress ='1 Rancho Del Mar Shopping C', @customerCity ='Providence', @customerState ='RI', @customerZip ='02903';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='jesusita.flister@hotmail.com',@customerFirstname ='Jesusita', @customerLastName ='Flister', @customerStreetAddress ='3943 N Highland Ave', @customerCity ='Lancaster', @customerState ='PA', @customerZip ='17601';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='caitlin.julia@julia.org',@customerFirstname ='Caitlin', @customerLastName ='Julia', @customerStreetAddress ='5 Williams St', @customerCity ='Johnston', @customerState ='RI', @customerZip ='02919';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='roosevelt.hoffis@aol.com',@customerFirstname ='Roosevelt', @customerLastName ='Hoffis', @customerStreetAddress ='60 Old Dover Rd', @customerCity ='Hialeah', @customerState ='FL', @customerZip ='33014';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='hhalter@yahoo.com',@customerFirstname ='Helaine', @customerLastName ='Halter', @customerStreetAddress ='8 Sheridan Rd', @customerCity ='Jersey City', @customerState ='NJ', @customerZip ='07304';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='lorean.martabano@hotmail.com',@customerFirstname ='Lorean', @customerLastName ='Martabano', @customerStreetAddress ='85092 Southern Blvd', @customerCity ='San Antonio', @customerState ='TX', @customerZip ='78204';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='france.buzick@yahoo.com',@customerFirstname ='France', @customerLastName ='Buzick', @customerStreetAddress ='64 Newman Springs Rd E', @customerCity ='Brooklyn', @customerState ='NY', @customerZip ='11219';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='jferrario@hotmail.com',@customerFirstname ='Justine', @customerLastName ='Ferrario', @customerStreetAddress ='48 Stratford Ave', @customerCity ='Pomona', @customerState ='CA', @customerZip ='91768';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='adelina_nabours@gmail.com',@customerFirstname ='Adelina', @customerLastName ='Nabours', @customerStreetAddress ='80 Pittsford Victor Rd #9', @customerCity ='Cleveland', @customerState ='OH', @customerZip ='44103';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='ddhamer@cox.net',@customerFirstname ='Derick', @customerLastName ='Dhamer', @customerStreetAddress ='87163 N Main Ave', @customerCity ='New York', @customerState ='NY', @customerZip ='10013';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='jerry.dallen@yahoo.com',@customerFirstname ='Jerry', @customerLastName ='Dallen', @customerStreetAddress ='393 Lafayette Ave', @customerCity ='Richmond', @customerState ='VA', @customerZip ='23219';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='leota.ragel@gmail.com',@customerFirstname ='Leota', @customerLastName ='Ragel', @customerStreetAddress ='99 5th Ave #33', @customerCity ='Trion', @customerState ='GA', @customerZip ='30753';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='jamyot@hotmail.com',@customerFirstname ='Jutta', @customerLastName ='Amyot', @customerStreetAddress ='49 N Mays St', @customerCity ='Broussard', @customerState ='LA', @customerZip ='70518';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='aja_gehrett@hotmail.com',@customerFirstname ='Aja', @customerLastName ='Gehrett', @customerStreetAddress ='993 Washington Ave', @customerCity ='Nutley', @customerState ='NJ', @customerZip ='07110';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kirk.herritt@aol.com',@customerFirstname ='Kirk', @customerLastName ='Herritt', @customerStreetAddress ='88 15th Ave Ne', @customerCity ='Vestal', @customerState ='NY', @customerZip ='13850';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='leonora@yahoo.com',@customerFirstname ='Leonora', @customerLastName ='Mauson', @customerStreetAddress ='3381 E 40th Ave', @customerCity ='Passaic', @customerState ='NJ', @customerZip ='07055';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='winfred_brucato@hotmail.com',@customerFirstname ='Winfred', @customerLastName ='Brucato', @customerStreetAddress ='201 Ridgewood Rd', @customerCity ='Moscow', @customerState ='ID', @customerZip ='83843';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='tarra.nachor@cox.net',@customerFirstname ='Tarra', @customerLastName ='Nachor', @customerStreetAddress ='39 Moccasin Dr', @customerCity ='San Francisco', @customerState ='CA', @customerZip ='94104';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='corinne@loder.org',@customerFirstname ='Corinne', @customerLastName ='Loder', @customerStreetAddress ='4 Carroll St', @customerCity ='North Attleboro', @customerState ='MA', @customerZip ='02760';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='dulce_labreche@yahoo.com',@customerFirstname ='Dulce', @customerLastName ='Labreche', @customerStreetAddress ='9581 E Arapahoe Rd', @customerCity ='Rochester', @customerState ='MI', @customerZip ='48307';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kate_keneipp@yahoo.com',@customerFirstname ='Kate', @customerLastName ='Keneipp', @customerStreetAddress ='33 N Michigan Ave', @customerCity ='Green Bay', @customerState ='WI', @customerZip ='54301';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kaitlyn.ogg@gmail.com',@customerFirstname ='Kaitlyn', @customerLastName ='Ogg', @customerStreetAddress ='2 S Biscayne Blvd', @customerCity ='Baltimore', @customerState ='MD', @customerZip ='21230';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='sherita.saras@cox.net',@customerFirstname ='Sherita', @customerLastName ='Saras', @customerStreetAddress ='8 Us Highway 22', @customerCity ='Colorado Springs', @customerState ='CO', @customerZip ='80937';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='lstuer@cox.net',@customerFirstname ='Lashawnda', @customerLastName ='Stuer', @customerStreetAddress ='7422 Martin Ave #8', @customerCity ='Toledo', @customerState ='OH', @customerZip ='43607';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='ernest@cox.net',@customerFirstname ='Ernest', @customerLastName ='Syrop', @customerStreetAddress ='94 Chase Rd', @customerCity ='Hyattsville', @customerState ='MD', @customerZip ='20785';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='nobuko.halsey@yahoo.com',@customerFirstname ='Nobuko', @customerLastName ='Halsey', @customerStreetAddress ='8139 I Hwy 10 #92', @customerCity ='New Bedford', @customerState ='MA', @customerZip ='02745';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='lavonna.wolny@hotmail.com',@customerFirstname ='Lavonna', @customerLastName ='Wolny', @customerStreetAddress ='5 Cabot Rd', @customerCity ='Mc Lean', @customerState ='VA', @customerZip ='22102';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='llizama@cox.net',@customerFirstname ='Lashaunda', @customerLastName ='Lizama', @customerStreetAddress ='3387 Ryan Dr', @customerCity ='Hanover', @customerState ='MD', @customerZip ='21076';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='mariann.bilden@aol.com',@customerFirstname ='Mariann', @customerLastName ='Bilden', @customerStreetAddress ='3125 Packer Ave #9851', @customerCity ='Austin', @customerState ='TX', @customerZip ='78753';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='helene@aol.com',@customerFirstname ='Helene', @customerLastName ='Rodenberger', @customerStreetAddress ='347 Chestnut St', @customerCity ='Peoria', @customerState ='AZ', @customerZip ='85381';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='roselle.estell@hotmail.com',@customerFirstname ='Roselle', @customerLastName ='Estell', @customerStreetAddress ='8116 Mount Vernon Ave', @customerCity ='Bucyrus', @customerState ='OH', @customerZip ='44820';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='sheintzman@hotmail.com',@customerFirstname ='Samira', @customerLastName ='Heintzman', @customerStreetAddress ='8772 Old County Rd #5410', @customerCity ='Kent', @customerState ='WA', @customerZip ='98032';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='margart_meisel@yahoo.com',@customerFirstname ='Margart', @customerLastName ='Meisel', @customerStreetAddress ='868 State St #38', @customerCity ='Cincinnati', @customerState ='OH', @customerZip ='45251';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kristofer.bennick@yahoo.com',@customerFirstname ='Kristofer', @customerLastName ='Bennick', @customerStreetAddress ='772 W River Dr', @customerCity ='Bloomington', @customerState ='IN', @customerZip ='47404';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='wacuff@gmail.com',@customerFirstname ='Weldon', @customerLastName ='Acuff', @customerStreetAddress ='73 W Barstow Ave', @customerCity ='Arlington Heights', @customerState ='IL', @customerZip ='60004';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='shalon@cox.net',@customerFirstname ='Shalon', @customerLastName ='Shadrick', @customerStreetAddress ='61047 Mayfield Ave', @customerCity ='Brooklyn', @customerState ='NY', @customerZip ='11223';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='denise@patak.org',@customerFirstname ='Denise', @customerLastName ='Patak', @customerStreetAddress ='2139 Santa Rosa Ave', @customerCity ='Orlando', @customerState ='FL', @customerZip ='32801';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='louvenia.beech@beech.com',@customerFirstname ='Louvenia', @customerLastName ='Beech', @customerStreetAddress ='598 43rd St', @customerCity ='Beverly Hills', @customerState ='CA', @customerZip ='90210';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='audry.yaw@yaw.org',@customerFirstname ='Audry', @customerLastName ='Yaw', @customerStreetAddress ='70295 Pioneer Ct', @customerCity ='Brandon', @customerState ='FL', @customerZip ='33511';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kristel.ehmann@aol.com',@customerFirstname ='Kristel', @customerLastName ='Ehmann', @customerStreetAddress ='92899 Kalakaua Ave', @customerCity ='El Paso', @customerState ='TX', @customerZip ='79925';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='vzepp@gmail.com',@customerFirstname ='Vincenza', @customerLastName ='Zepp', @customerStreetAddress ='395 S 6th St #2', @customerCity ='El Cajon', @customerState ='CA', @customerZip ='92020';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='egwalthney@yahoo.com',@customerFirstname ='Elouise', @customerLastName ='Gwalthney', @customerStreetAddress ='9506 Edgemore Ave', @customerCity ='Bladensburg', @customerState ='MD', @customerZip ='20710';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='venita_maillard@gmail.com',@customerFirstname ='Venita', @customerLastName ='Maillard', @customerStreetAddress ='72119 S Walker Ave #63', @customerCity ='Anaheim', @customerState ='CA', @customerZip ='92801';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='kasandra_semidey@semidey.com',@customerFirstname ='Kasandra', @customerLastName ='Semidey', @customerStreetAddress ='369 Latham St #500', @customerCity ='Saint Louis', @customerState ='MO', @customerZip ='63102';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='donette.foller@cox.net',@customerFirstname ='Donette', @customerLastName ='Foller', @customerStreetAddress ='34 Center St', @customerCity ='Hamilton', @customerState ='OH', @customerZip ='45011';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='mroyster@royster.com',@customerFirstname ='Maryann', @customerLastName ='Royster', @customerStreetAddress ='74 S Westgate St', @customerCity ='Albany', @customerState ='NY', @customerZip ='12204';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='ernie_stenseth@aol.com',@customerFirstname ='Ernie', @customerLastName ='Stenseth', @customerStreetAddress ='45 E Liberty St', @customerCity ='Ridgefield Park', @customerState ='NJ', @customerZip ='07660';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='jina_briddick@briddick.com',@customerFirstname ='Jina', @customerLastName ='Briddick', @customerStreetAddress ='38938 Park Blvd', @customerCity ='Boston', @customerState ='MA', @customerZip ='02128';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='sabra@uyetake.org',@customerFirstname ='Sabra', @customerLastName ='Uyetake', @customerStreetAddress ='98839 Hawthorne Blvd #6101', @customerCity ='Columbia', @customerState ='SC', @customerZip ='29201';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='brhym@rhym.com',@customerFirstname ='Bobbye', @customerLastName ='Rhym', @customerStreetAddress ='30 W 80th St #1995', @customerCity ='San Carlos', @customerState ='CA', @customerZip ='94070';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='viva.toelkes@gmail.com',@customerFirstname ='Viva', @customerLastName ='Toelkes', @customerStreetAddress ='4284 Dorigo Ln', @customerCity ='Chicago', @customerState ='IL', @customerZip ='60647';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='dominque.dickerson@dickerson.org',@customerFirstname ='Dominque', @customerLastName ='Dickerson', @customerStreetAddress ='69 Marquette Ave', @customerCity ='Hayward', @customerState ='CA', @customerZip ='94545';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='latrice.tolfree@hotmail.com',@customerFirstname ='Latrice', @customerLastName ='Tolfree', @customerStreetAddress ='81 Norris Ave #525', @customerCity ='Ronkonkoma', @customerState ='NY', @customerZip ='11779';
EXECUTE dbo.usp_addCustomer @customerEmailAddress ='stephaine@cox.net',@customerFirstname ='Stephaine', @customerLastName ='Vinning', @customerStreetAddress ='3717 Hamann Industrial Pky', @customerCity ='San Francisco', @customerState ='CA', @customerZip ='94104';

GO

-----
-- Enter Vendor Table Data
-----
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@accurelsystemsintrntlcorp.com', @vendorPhone = '3059884162', @vendorName = 'Accurel Systems Intrntl Corp', @vendorStreetAddress = '19 Amboy Ave', @vendorCity = 'Miami', @vendorState = 'FL', @vendorZip = '33142';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@acquagroup.com', @vendorPhone = '6108091818', @vendorName = 'Acqua Group', @vendorStreetAddress = '810 N La Brea Ave', @vendorCity = 'King of Prussia', @vendorState = 'PA', @vendorZip = '19406';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@alinabalinc.com', @vendorPhone = '5135087371', @vendorName = 'Alinabal Inc', @vendorStreetAddress = '72 Mannix Dr', @vendorCity = 'Cincinnati', @vendorState = 'OH', @vendorZip = '45203';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@alpenliteinc.com', @vendorPhone = '4019608259', @vendorName = 'Alpenlite Inc', @vendorStreetAddress = '201 Hawk Ct', @vendorCity = 'Providence', @vendorState = 'RI', @vendorZip = '02904';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@anchorcomputerinc.com', @vendorPhone = '9737673008', @vendorName = 'Anchor Computer Inc', @vendorStreetAddress = '13 S Hacienda Dr', @vendorCity = 'Livingston', @vendorState = 'NJ', @vendorZip = '07039';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@artcrafters.com', @vendorPhone = '3056709628', @vendorName = 'Art Crafters', @vendorStreetAddress = '703 Beville Rd', @vendorCity = 'Opa Locka', @vendorState = 'FL', @vendorZip = '33054';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@binswanger.com', @vendorPhone = '7182013751', @vendorName = 'Binswanger', @vendorStreetAddress = '4 Kohler Memorial Dr', @vendorCity = 'Brooklyn', @vendorState = 'NY', @vendorZip = '11230';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@burtondavis.com', @vendorPhone = '8188644875', @vendorName = 'Burton & Davis', @vendorStreetAddress = '70 Mechanic St', @vendorCity = 'Northridge', @vendorState = 'CA', @vendorZip = '91325';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@cnetworkinc.com', @vendorPhone = '4085401785', @vendorName = 'C 4 Network Inc', @vendorStreetAddress = '6 Greenleaf Ave', @vendorCity = 'San Jose', @vendorState = 'CA', @vendorZip = '95111';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@calaverasprospect.com', @vendorPhone = '7326289909', @vendorName = 'Calaveras Prospect', @vendorStreetAddress = '6201 S Nevada Ave', @vendorCity = 'Toms River', @vendorState = 'NJ', @vendorZip = '08755';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@cantron.com', @vendorPhone = '3147329131', @vendorName = 'Can Tron', @vendorStreetAddress = '369 Latham St #500', @vendorCity = 'Saint Louis', @vendorState = 'MO', @vendorZip = '63102';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@cascoservicesinc.com', @vendorPhone = '6023904944', @vendorName = 'Casco Services Inc', @vendorStreetAddress = '96541 W Central Blvd', @vendorCity = 'Phoenix', @vendorState = 'AZ', @vendorZip = '85034';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@centroinc.com', @vendorPhone = '5125875746', @vendorName = 'Centro Inc', @vendorStreetAddress = '17 Us Highway 111', @vendorCity = 'Round Rock', @vendorState = 'TX', @vendorZip = '78664';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'answers@circuitsolutioninc.com', @vendorPhone = '4154111775', @vendorName = 'Circuit Solution Inc', @vendorStreetAddress = '39 Moccasin Dr', @vendorCity = 'San Francisco', @vendorState = 'CA', @vendorZip = '94104';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@computerrepairservice.com', @vendorPhone = '6317486479', @vendorName = 'Computer Repair Service', @vendorStreetAddress = '70 Euclid Ave #722', @vendorCity = 'Bohemia', @vendorState = 'NY', @vendorZip = '11716';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@cowankelly.com', @vendorPhone = '8586177834', @vendorName = 'Cowan & Kelly', @vendorStreetAddress = '469 Outwater Ln', @vendorCity = 'San Diego', @vendorState = 'CA', @vendorZip = '92126';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@deltamsystemsinc.com', @vendorPhone = '6312586558', @vendorName = 'Deltam Systems Inc', @vendorStreetAddress = '3270 Dequindre Rd', @vendorCity = 'Deer Park', @vendorState = 'NY', @vendorZip = '11729';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@eaielectronicassocsinc.com', @vendorPhone = '5109933758', @vendorName = 'E A I Electronic Assocs Inc', @vendorStreetAddress = '69 Marquette Ave', @vendorCity = 'Hayward', @vendorState = 'CA', @vendorZip = '94545';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'info@eaglesoftwareinc.com', @vendorPhone = '7705078791', @vendorName = 'Eagle Software Inc', @vendorStreetAddress = '5384 Southwyck Blvd', @vendorCity = 'Douglasville', @vendorState = 'GA', @vendorZip = '30135';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@feinerbros.com', @vendorPhone = '3104985651', @vendorName = 'Feiner Bros', @vendorStreetAddress = '25 E 75th St #69', @vendorCity = 'Los Angeles', @vendorState = 'CA', @vendorZip = '90034';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@franzinc.com', @vendorPhone = '5087695250', @vendorName = 'Franz Inc', @vendorStreetAddress = '57254 Brickell Ave #372', @vendorCity = 'Worcester', @vendorState = 'MA', @vendorZip = '01602';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@garrisonind.com', @vendorPhone = '5059758559', @vendorName = 'Garrison Ind', @vendorStreetAddress = '31 Douglas Blvd #950', @vendorCity = 'Clovis', @vendorState = 'NM', @vendorZip = '88101';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@geonexmartelinc.com', @vendorPhone = '7756389963', @vendorName = 'Geonex Martel Inc', @vendorStreetAddress = '94 W Dodge Rd', @vendorCity = 'Carson City', @vendorState = 'NV', @vendorZip = '89701';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@hhhenterprisesinc.com', @vendorPhone = '2126749610', @vendorName = 'H H H Enterprises Inc', @vendorStreetAddress = '3305 Nabell Ave #679', @vendorCity = 'New York', @vendorState = 'NY', @vendorZip = '10009';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@harriscorporation.com', @vendorPhone = '4108907866', @vendorName = 'Harris Corporation', @vendorStreetAddress = '4 Iwaena St', @vendorCity = 'Baltimore', @vendorState = 'MD', @vendorZip = '21202';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@hermarinc.com', @vendorPhone = '5744991454', @vendorName = 'Hermar Inc', @vendorStreetAddress = '2 Sw Nyberg Rd', @vendorCity = 'Elkhart', @vendorState = 'IN', @vendorZip = '46514';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'info@jetscybernetics.com', @vendorPhone = '2144282285', @vendorName = 'Jets Cybernetics', @vendorStreetAddress = '99586 Main St', @vendorCity = 'Dallas', @vendorState = 'TX', @vendorZip = '75207';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@johnwagnerassociates.com', @vendorPhone = '2038016193', @vendorName = 'John Wagner Associates', @vendorStreetAddress = '759 Eldora St', @vendorCity = 'New Haven', @vendorState = 'CT', @vendorZip = '06515';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@killionindustries.com', @vendorPhone = '8143935571', @vendorName = 'Killion Industries', @vendorStreetAddress = '7 W 32nd St', @vendorCity = 'Erie', @vendorState = 'PA', @vendorZip = '16502';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@lanepromotions.com', @vendorPhone = '4103511863', @vendorName = 'Lane Promotions', @vendorStreetAddress = '9648 S Main', @vendorCity = 'Salisbury', @vendorState = 'MD', @vendorZip = '21801';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'help@linguisticsystemsinc.com', @vendorPhone = '6092285265', @vendorName = 'Linguistic Systems Inc', @vendorStreetAddress = '506 S Hacienda Dr', @vendorCity = 'Atlantic City', @vendorState = 'NJ', @vendorZip = '08401';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@mcauleymfgco.com', @vendorPhone = '3108585079', @vendorName = 'Mcauley Mfg Co', @vendorStreetAddress = '2972 Lafayette Ave', @vendorCity = 'Gardena', @vendorState = 'CA', @vendorZip = '90248';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@meca.com', @vendorPhone = '4195444900', @vendorName = 'Meca', @vendorStreetAddress = '6 Harry L Dr #6327', @vendorCity = 'Perrysburg', @vendorState = 'OH', @vendorZip = '43551';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@mitsumielectronicscorp.com', @vendorPhone = '8045505097', @vendorName = 'Mitsumi Electronics Corp', @vendorStreetAddress = '9677 Commerce Dr', @vendorCity = 'Richmond', @vendorState = 'VA', @vendorZip = '23219';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@morlongassociates.com', @vendorPhone = '7735736914', @vendorName = 'Morlong Associates', @vendorStreetAddress = '7 Eads St', @vendorCity = 'Chicago', @vendorState = 'IL', @vendorZip = '60632';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@newtecinc.com', @vendorPhone = '6029069419', @vendorName = 'Newtec Inc', @vendorStreetAddress = '1 Huntwood Ave', @vendorCity = 'Phoenix', @vendorState = 'AZ', @vendorZip = '85017';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@panasystems.com', @vendorPhone = '4149592540', @vendorName = 'Panasystems', @vendorStreetAddress = '9 N College Ave #3', @vendorCity = 'Milwaukee', @vendorState = 'WI', @vendorZip = '53216';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@polykoteinc.com', @vendorPhone = '5122138574', @vendorName = 'Polykote Inc', @vendorStreetAddress = '2026 N Plankinton Ave #3', @vendorCity = 'Austin', @vendorState = 'TX', @vendorZip = '78754';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@pricebusinessservices.com', @vendorPhone = '8472221734', @vendorName = 'Price Business Services', @vendorStreetAddress = '7 West Ave #1', @vendorCity = 'Palatine', @vendorState = 'IL', @vendorZip = '60067';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@professionalsunlimited.com', @vendorPhone = '3073427795', @vendorName = 'Professionals Unlimited', @vendorStreetAddress = '66697 Park Pl #3224', @vendorCity = 'Riverton', @vendorState = 'WY', @vendorZip = '82501';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@qaservice.com', @vendorPhone = '4105204832', @vendorName = 'Q A Service', @vendorStreetAddress = '6 Kains Ave', @vendorCity = 'Baltimore', @vendorState = 'MD', @vendorZip = '21215';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@ravaalenterprisesinc.com', @vendorPhone = '5122331831', @vendorName = 'Ravaal Enterprises Inc', @vendorStreetAddress = '3158 Runamuck Pl', @vendorCity = 'Round Rock', @vendorState = 'TX', @vendorZip = '78664';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@www.reeseplastics.com', @vendorPhone = '7175288996', @vendorName = 'Reese Plastics', @vendorStreetAddress = '2 W Beverly Blvd', @vendorCity = 'Harrisburg', @vendorState = 'PA', @vendorZip = '17110';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@www.remacoinc.com', @vendorPhone = '2156057570', @vendorName = 'Remaco Inc', @vendorStreetAddress = '73 Southern Blvd', @vendorCity = 'Philadelphia', @vendorState = 'PA', @vendorZip = '19103';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@www.replicai.com', @vendorPhone = '3522422570', @vendorName = 'Replica I', @vendorStreetAddress = '9 Wales Rd Ne #914', @vendorCity = 'Homosassa', @vendorState = 'FL', @vendorZip = '34448';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@robertssupplycoinc.com', @vendorPhone = '9148685965', @vendorName = 'Roberts Supply Co Inc', @vendorStreetAddress = '8429 Miller Rd', @vendorCity = 'Pelham', @vendorState = 'NY', @vendorZip = '10803';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@sampler.com', @vendorPhone = '8144602655', @vendorName = 'Sampler', @vendorStreetAddress = '555 Main St', @vendorCity = 'Erie', @vendorState = 'PA', @vendorZip = '16502';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@scatenterprises.com', @vendorPhone = '7755018109', @vendorName = 'Scat Enterprises', @vendorStreetAddress = '73 Saint Ann St #86', @vendorCity = 'Reno', @vendorState = 'NV', @vendorZip = '89502';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@sebringco.com', @vendorPhone = '2489806904', @vendorName = 'Sebring & Co', @vendorStreetAddress = '40 9th Ave Sw #91', @vendorCity = 'Waterford', @vendorState = 'MI', @vendorZip = '48329';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'helpdesk@sidewinderproductscorp.com', @vendorPhone = '7178093119', @vendorName = 'Sidewinder Products Corp', @vendorStreetAddress = '8573 Lincoln Blvd', @vendorCity = 'York', @vendorState = 'PA', @vendorZip = '17404';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@sigmacorpofamerica.com', @vendorPhone = '5106863407', @vendorName = 'Sigma Corp Of America', @vendorStreetAddress = '38 Pleasant Hill Rd', @vendorCity = 'Hayward', @vendorState = 'CA', @vendorZip = '94545';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@silverbrosinc.com', @vendorPhone = '2123328435', @vendorName = 'Silver Bros Inc', @vendorStreetAddress = '8 Industry Ln', @vendorCity = 'New York', @vendorState = 'NY', @vendorZip = '10002';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@smcinc.com', @vendorPhone = '9047754480', @vendorName = 'Smc Inc', @vendorStreetAddress = '11279 Loytan St', @vendorCity = 'Jacksonville', @vendorState = 'FL', @vendorZip = '32254';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@sportenart.com', @vendorPhone = '6105453615', @vendorName = 'Sport En Art', @vendorStreetAddress = '6 S 33rd St', @vendorCity = 'Aston', @vendorState = 'PA', @vendorZip = '19014';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@switchcraftinc.com', @vendorPhone = '6083824541', @vendorName = 'Switchcraft Inc', @vendorStreetAddress = '4 Nw 12th St #3849', @vendorCity = 'Madison', @vendorState = 'WI', @vendorZip = '53717';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@tipiakinc.com', @vendorPhone = '9367517961', @vendorName = 'Tipiak Inc', @vendorStreetAddress = '80312 W 32nd St', @vendorCity = 'Conroe', @vendorState = 'TX', @vendorZip = '77301';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@valeriecompany.com', @vendorPhone = '9014124381', @vendorName = 'Valerie & Company', @vendorStreetAddress = '1 S Pine St', @vendorCity = 'Memphis', @vendorState = 'TN', @vendorZip = '38112';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@wheatonplasticproducts.com', @vendorPhone = '3105109713', @vendorName = 'Wheaton Plastic Products', @vendorStreetAddress = '22 Spruce St #595', @vendorCity = 'Gardena', @vendorState = 'CA', @vendorZip = '90248';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@wyetechnologiesinc.com', @vendorPhone = '4014582547', @vendorName = 'Wye Technologies Inc', @vendorStreetAddress = '65895 S 16th St', @vendorCity = 'Providence', @vendorState = 'RI', @vendorZip = '02909';

GO
-----
-- Enter Supplier Table Data
-----
EXECUTE dbo.usp_addSupplier @supplierName = 'Acer', @supplierStreetAddress = '20 Sw Brookman Rd', @supplierCity = 'Chicago', @supplierState = 'IL', @supplierZip = '60618';
EXECUTE dbo.usp_addSupplier @supplierName = 'Alpine', @supplierStreetAddress = '6 Cavanaugh Rd #3069', @supplierCity = 'Newark', @supplierState = 'OH', @supplierZip = '43055';
EXECUTE dbo.usp_addSupplier @supplierName = 'Apple', @supplierStreetAddress = '599 Hall Rd', @supplierCity = 'Lansing', @supplierState = 'MI', @supplierZip = '48933';
EXECUTE dbo.usp_addSupplier @supplierName = 'ASUS', @supplierStreetAddress = '87 20th St E', @supplierCity = 'Brooklyn', @supplierState = 'NY', @supplierZip = '11219';
EXECUTE dbo.usp_addSupplier @supplierName = 'Bose', @supplierStreetAddress = '97 W Culver St #301', @supplierCity = 'Bucyrus', @supplierState = 'OH', @supplierZip = '44820';
EXECUTE dbo.usp_addSupplier @supplierName = 'CORSAIR', @supplierStreetAddress = '537 2nd St', @supplierCity = 'Greenville', @supplierState = 'NC', @supplierZip = '27834';
EXECUTE dbo.usp_addSupplier @supplierName = 'Denon', @supplierStreetAddress = '46055 Metropolitan Sq', @supplierCity = 'Great Neck', @supplierState = 'NY', @supplierZip = '11021';
EXECUTE dbo.usp_addSupplier @supplierName = 'JBL', @supplierStreetAddress = '63248 Elm St', @supplierCity = 'Modesto', @supplierState = 'CA', @supplierZip = '95354';
EXECUTE dbo.usp_addSupplier @supplierName = 'LG', @supplierStreetAddress = '2 I 55s S', @supplierCity = 'Salinas', @supplierState = 'CA', @supplierZip = '93912';
EXECUTE dbo.usp_addSupplier @supplierName = 'Logitech', @supplierStreetAddress = '2 N Midland Blvd #8151', @supplierCity = 'Abilene', @supplierState = 'TX', @supplierZip = '79602';
EXECUTE dbo.usp_addSupplier @supplierName = 'Onkyo', @supplierStreetAddress = '74 Ridgewood Rd', @supplierCity = 'New York', @supplierState = 'NY', @supplierZip = '10017';
EXECUTE dbo.usp_addSupplier @supplierName = 'Panamax', @supplierStreetAddress = '7 E Pacific Pl', @supplierCity = 'Irving', @supplierState = 'TX', @supplierZip = '75062';
EXECUTE dbo.usp_addSupplier @supplierName = 'Pioneer', @supplierStreetAddress = '24270 E 67th St', @supplierCity = 'Annandale', @supplierState = 'VA', @supplierZip = '22003';
EXECUTE dbo.usp_addSupplier @supplierName = 'Samsung', @supplierStreetAddress = '8537 10th St W', @supplierCity = 'San Anselmo', @supplierState = 'CA', @supplierZip = '94960';
EXECUTE dbo.usp_addSupplier @supplierName = 'SanDisk', @supplierStreetAddress = '20332 Bernardo Cent #8', @supplierCity = 'New York', @supplierState = 'NY', @supplierZip = '10019';
EXECUTE dbo.usp_addSupplier @supplierName = 'Sennheiser', @supplierStreetAddress = '41 S Washington Ave', @supplierCity = 'Houston', @supplierState = 'TX', @supplierZip = '77084';
EXECUTE dbo.usp_addSupplier @supplierName = 'Sony', @supplierStreetAddress = '463 E Jackson St', @supplierCity = 'Van Nuys', @supplierState = 'CA', @supplierZip = '91401';
EXECUTE dbo.usp_addSupplier @supplierName = 'Printing Dimensions', @supplierStreetAddress = '34 Center St', @supplierCity = 'Hamilton', @supplierState = 'OH', @supplierZip = '45011';
EXECUTE dbo.usp_addSupplier @supplierName = 'Franklin Peters Inc', @supplierStreetAddress = '74 S Westgate St', @supplierCity = 'Albany', @supplierState = 'NY', @supplierZip = '12204';
EXECUTE dbo.usp_addSupplier @supplierName = 'Knwz Products', @supplierStreetAddress = '45 E Liberty St', @supplierCity = 'Ridgefield Park', @supplierState = 'NJ', @supplierZip = '07660';
EXECUTE dbo.usp_addSupplier @supplierName = 'Grace Pastries Inc', @supplierStreetAddress = '38938 Park Blvd', @supplierCity = 'Boston', @supplierState = 'MA', @supplierZip = '02128';
EXECUTE dbo.usp_addSupplier @supplierName = 'Lowy Products and Service', @supplierStreetAddress = '98839 Hawthorne Blvd #6101', @supplierCity = 'Columbia', @supplierState = 'SC', @supplierZip = '29201';
EXECUTE dbo.usp_addSupplier @supplierName = 'Smits, Patricia Garity', @supplierStreetAddress = '30 W 80th St #1995', @supplierCity = 'San Carlos', @supplierState = 'CA', @supplierZip = '94070';
EXECUTE dbo.usp_addSupplier @supplierName = 'Mark Iv Press', @supplierStreetAddress = '4284 Dorigo Ln', @supplierCity = 'Chicago', @supplierState = 'IL', @supplierZip = '60647';
EXECUTE dbo.usp_addSupplier @supplierName = 'E A I Electronic Assocs Inc', @supplierStreetAddress = '69 Marquette Ave', @supplierCity = 'Hayward', @supplierState = 'CA', @supplierZip = '94545';
EXECUTE dbo.usp_addSupplier @supplierName = 'United Product Lines', @supplierStreetAddress = '81 Norris Ave #525', @supplierCity = 'Ronkonkoma', @supplierState = 'NY', @supplierZip = '11779';
EXECUTE dbo.usp_addSupplier @supplierName = 'Birite Foodservice', @supplierStreetAddress = '3717 Hamann Industrial Pky', @supplierCity = 'San Francisco', @supplierState = 'CA', @supplierZip = '94104';
EXECUTE dbo.usp_addSupplier @supplierName = 'Roberts Supply Co Inc', @supplierStreetAddress = '8429 Miller Rd', @supplierCity = 'Pelham', @supplierState = 'NY', @supplierZip = '10803';
EXECUTE dbo.usp_addSupplier @supplierName = 'Harris Corporation', @supplierStreetAddress = '4 Iwaena St', @supplierCity = 'Baltimore', @supplierState = 'MD', @supplierZip = '21202';
EXECUTE dbo.usp_addSupplier @supplierName = 'Armon Communications', @supplierStreetAddress = '9 State Highway 57 #22', @supplierCity = 'Jersey City', @supplierState = 'NJ', @supplierZip = '07306';
EXECUTE dbo.usp_addSupplier @supplierName = 'Tipiak Inc', @supplierStreetAddress = '80312 W 32nd St', @supplierCity = 'Conroe', @supplierState = 'TX', @supplierZip = '77301';
EXECUTE dbo.usp_addSupplier @supplierName = 'Sportmaster International', @supplierStreetAddress = '6 Sunrise Ave', @supplierCity = 'Utica', @supplierState = 'NY', @supplierZip = '13501';
EXECUTE dbo.usp_addSupplier @supplierName = 'Acme Supply Co', @supplierStreetAddress = '1953 Telegraph Rd', @supplierCity = 'Saint Joseph', @supplierState = 'MO', @supplierZip = '64504';
EXECUTE dbo.usp_addSupplier @supplierName = 'Warehouse Office & Paper Prod', @supplierStreetAddress = '61556 W 20th Ave', @supplierCity = 'Seattle', @supplierState = 'WA', @supplierZip = '98104';
GO
-----
-- Enter Product Table Data
-----
EXECUTE dbo.usp_addProduct @supplierName = 'Acer', @productName = 'Acer 15.6 Chromebook CB5-571-C4G4';
EXECUTE dbo.usp_addProduct @supplierName = 'Acme Supply Co', @productName = 'Silver Weber State University Money Clip';
EXECUTE dbo.usp_addProduct @supplierName = 'Acme Supply Co', @productName = 'Weber State University Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Alpine', @productName = 'Alpine - Rear View Camera - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Alpine', @productName = 'Alpine PDXM12 1200W Mono RMS Digital Amplifier';
EXECUTE dbo.usp_addProduct @supplierName = 'Apple', @productName = '128GB iPod touch (Gold) (6th Generation)';
EXECUTE dbo.usp_addProduct @supplierName = 'Apple', @productName = 'Apple iPod Touch 128GB Blue';
EXECUTE dbo.usp_addProduct @supplierName = 'Armon Communications', @productName = 'Weber State University Dad Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'ASUS', @productName = 'PA248Q 24 LED Backlit IPS Widescreen Monitor';
EXECUTE dbo.usp_addProduct @supplierName = 'ASUS', @productName = 'VE278Q 27 Widescreen LCD Computer Display';
EXECUTE dbo.usp_addProduct @supplierName = 'ASUS', @productName = 'VS278Q-P 27 16:9 LCD Monitor';
EXECUTE dbo.usp_addProduct @supplierName = 'Birite Foodservice', @productName = 'Weber State University Lip Balm';
EXECUTE dbo.usp_addProduct @supplierName = 'Bose', @productName = '251 Outdoor Environmental Speakers (White)';
EXECUTE dbo.usp_addProduct @supplierName = 'Bose', @productName = 'Bose SoundLink Color Bluetooth Speaker (Black)';
EXECUTE dbo.usp_addProduct @supplierName = 'CORSAIR', @productName = 'CORSAIR - AX760 760-Watt ATX Power Supply - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'CORSAIR', @productName = 'CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting';
EXECUTE dbo.usp_addProduct @supplierName = 'CORSAIR', @productName = 'CORSAIR - ML Series 140mm Case Cooling Fan - White';
EXECUTE dbo.usp_addProduct @supplierName = 'CORSAIR', @productName = 'CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'CORSAIR', @productName = 'CORSAIR - Vengeance LPX 32GB (2PK x 16GB) 2.6 GHz DDR4 DRAM Desktop Memory Kit - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Denon', @productName = 'AVR-S530BT 5.2-Channel A/V Receiver';
EXECUTE dbo.usp_addProduct @supplierName = 'Denon', @productName = 'AVR-X1400H 7.2-Channel Network A/V Receiver';
EXECUTE dbo.usp_addProduct @supplierName = 'E A I Electronic Assocs Inc', @productName = 'Weber State University OtterBox iPhone 7/8 Symmetry Series Case';
EXECUTE dbo.usp_addProduct @supplierName = 'Franklin Peters Inc', @productName = 'Black Weber State University Women''s Hooded Sweatshirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Franklin Peters Inc', @productName = 'Weber State University Crew Neck Sweatshirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Franklin Peters Inc', @productName = 'Weber State University Jersey';
EXECUTE dbo.usp_addProduct @supplierName = 'Grace Pastries Inc', @productName = 'Weber State University .75L Camelbak Bottle';
EXECUTE dbo.usp_addProduct @supplierName = 'Harris Corporation', @productName = 'Weber State University Alumni T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'JBL', @productName = 'JBL - Free True Wireless In-Ear Headphones - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'JBL', @productName = 'JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Knwz Products', @productName = 'Steel Grey Weber State University Women''s Cropped Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Knwz Products', @productName = 'Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'LG', @productName = 'LG - 55 Class - LED - UJ7700 Series - 2160p - Smart - 4K UHD TV with HDR';
EXECUTE dbo.usp_addProduct @supplierName = 'LG', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR';
EXECUTE dbo.usp_addProduct @supplierName = 'LG', @productName = 'LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR';
EXECUTE dbo.usp_addProduct @supplierName = 'Logitech', @productName = 'Circle 2 2MP Wire-Free Network Camera with Night Vision';
EXECUTE dbo.usp_addProduct @supplierName = 'Logitech', @productName = 'Logitech - Harmony 950 Universal Remote - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Logitech', @productName = 'MX Anywhere 2S Wireless Mouse';
EXECUTE dbo.usp_addProduct @supplierName = 'Lowy Products and Service', @productName = 'Yellow Weber State University 16 oz. Tumbler';
EXECUTE dbo.usp_addProduct @supplierName = 'Mark Iv Press', @productName = 'Silver Weber State University Wildcats Keytag';
EXECUTE dbo.usp_addProduct @supplierName = 'Onkyo', @productName = 'Onkyo - 5.1-Ch. Home Theater System - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Onkyo', @productName = 'Onkyo M-5010 2-Channel Amplifier (Black)';
EXECUTE dbo.usp_addProduct @supplierName = 'Panamax', @productName = 'Panamax - 11-Outlet Surge Protector - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Panamax', @productName = 'Panamax - 2-Outlet Surge Protector - White';
EXECUTE dbo.usp_addProduct @supplierName = 'Pioneer', @productName = 'Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Pioneer', @productName = 'Pioneer - XDP-300R 32GB* Video MP3 Player - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Printing Dimensions', @productName = 'Weber State University Mom Decal';
EXECUTE dbo.usp_addProduct @supplierName = 'Printing Dimensions', @productName = 'Weber State University Wildcats Decal';
EXECUTE dbo.usp_addProduct @supplierName = 'Printing Dimensions', @productName = 'White Weber State University Women''s Tank Top';
EXECUTE dbo.usp_addProduct @supplierName = 'Roberts Supply Co Inc', @productName = 'Weber State University Coaches Hat';
EXECUTE dbo.usp_addProduct @supplierName = 'Samsung', @productName = 'Gear 360 Spherical VR Camera';
EXECUTE dbo.usp_addProduct @supplierName = 'Samsung', @productName = 'Samsung - 55 Class - LED - Q8F Series - 2160p - Smart - 4K UHD TV with HDR';
EXECUTE dbo.usp_addProduct @supplierName = 'Samsung', @productName = 'Samsung - 65 Class - LED - MU6290 Series - 2160p - Smart - 4K Ultra HD TV with HDR';
EXECUTE dbo.usp_addProduct @supplierName = 'Samsung', @productName = 'Samsung - 850 PRO 1TB Internal SATA III Solid State Drive for Laptops';
EXECUTE dbo.usp_addProduct @supplierName = 'SanDisk', @productName = 'SanDisk - Ultra 500GB Internal SATA Solid State Drive for Laptops';
EXECUTE dbo.usp_addProduct @supplierName = 'SanDisk', @productName = 'SanDisk - Ultra II 960GB Internal SATA Solid State Drive for Laptops';
EXECUTE dbo.usp_addProduct @supplierName = 'Sennheiser', @productName = 'Sennheiser - Digital Headphone Amplifier - Silver';
EXECUTE dbo.usp_addProduct @supplierName = 'Sennheiser', @productName = 'Sennheiser - Earbud Headphones - Black';
EXECUTE dbo.usp_addProduct @supplierName = 'Smits, Patricia Garity', @productName = 'Weber State University Crew Socks';
EXECUTE dbo.usp_addProduct @supplierName = 'Smits, Patricia Garity', @productName = 'White Weber State University Orbiter Pen';
EXECUTE dbo.usp_addProduct @supplierName = 'Sony', @productName = 'GTK-XB90 Bluetooth Speaker';
EXECUTE dbo.usp_addProduct @supplierName = 'Sony', @productName = 'Sony Ultra-Portable Bluetooth Speaker';
EXECUTE dbo.usp_addProduct @supplierName = 'Sportmaster International', @productName = 'Weber State University Wildcats Rambler 20 oz. Tumbler';
EXECUTE dbo.usp_addProduct @supplierName = 'Tipiak Inc', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'United Product Lines', @productName = 'Weber State University Putter Cover';
EXECUTE dbo.usp_addProduct @supplierName = 'United Product Lines', @productName = 'Weber State University Rain Poncho';
EXECUTE dbo.usp_addProduct @supplierName = 'Warehouse Office & Paper Prod', @productName = 'Weber State University Academic Year Planner';
EXECUTE dbo.usp_addProduct @supplierName = 'Warehouse Office & Paper Prod', @productName = 'Weber State University Wildcats State Decal';

GO
---
-- Enter Order Table Data
---
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'noah.kalafatis@aol.com', @orderDateTime = '2023-01-11 05:51 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'csweigard@sweigard.com', @orderDateTime = '2023-02-07 06:41 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'lavonda@cox.net', @orderDateTime = '2023-01-13 01:08 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'junita@aol.com', @orderDateTime = '2023-01-12 02:10 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'herminia@nicolozakes.org', @orderDateTime = '2023-01-07 07:37 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'casie.good@aol.com', @orderDateTime = '2023-01-23 05:09 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'reena@hotmail.com', @orderDateTime = '2023-01-25 02:51 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'mirta_mallett@gmail.com', @orderDateTime = '2023-02-11 07:10 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'cathrine.pontoriero@pontoriero.com', @orderDateTime = '2023-02-16 10:36 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'ftawil@hotmail.com', @orderDateTime = '2023-02-02 06:50 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'rupthegrove@yahoo.com', @orderDateTime = '2023-02-10 06:16 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'sarah.candlish@gmail.com', @orderDateTime = '2023-02-11 05:03 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'lucy@cox.net', @orderDateTime = '2023-01-16 09:18 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'jaquas@aquas.com', @orderDateTime = '2023-02-03 07:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'yvonne.tjepkema@hotmail.com', @orderDateTime = '2023-02-12 07:09 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kayleigh.lace@yahoo.com', @orderDateTime = '2023-02-03 11:36 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'felix_hirpara@cox.net', @orderDateTime = '2023-01-18 07:59 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'tresa_sweely@hotmail.com', @orderDateTime = '2023-01-20 04:23 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kristeen@gmail.com', @orderDateTime = '2023-01-04 01:19 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'jregusters@regusters.com', @orderDateTime = '2023-02-13 07:51 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'renea@hotmail.com', @orderDateTime = '2023-02-18 03:21 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'olive@aol.com', @orderDateTime = '2023-02-11 01:47 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'lreiber@cox.net', @orderDateTime = '2023-01-23 10:15 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'christiane.eschberger@yahoo.com', @orderDateTime = '2023-02-21 01:23 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'goldie.schirpke@yahoo.com', @orderDateTime = '2023-01-09 03:41 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'loreta.timenez@hotmail.com', @orderDateTime = '2023-02-06 10:52 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'fabiola.hauenstein@hauenstein.org', @orderDateTime = '2023-01-13 10:20 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'amie.perigo@yahoo.com', @orderDateTime = '2023-02-16 02:52 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'raina.brachle@brachle.org', @orderDateTime = '2023-02-06 09:42 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'erinn.canlas@canlas.com', @orderDateTime = '2023-01-25 10:26 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'cherry@lietz.com', @orderDateTime = '2023-01-08 12:23 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kattie@vonasek.org', @orderDateTime = '2023-01-07 08:08 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'lilli@aol.com', @orderDateTime = '2023-02-21 11:50 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'whitley.tomasulo@aol.com', @orderDateTime = '2023-01-14 12:09 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'badkin@hotmail.com', @orderDateTime = '2023-01-17 09:10 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'hermila_thyberg@hotmail.com', @orderDateTime = '2023-02-20 01:58 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'jesusita.flister@hotmail.com', @orderDateTime = '2023-02-09 05:33 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'caitlin.julia@julia.org', @orderDateTime = '2023-01-22 11:13 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'roosevelt.hoffis@aol.com', @orderDateTime = '2023-01-13 12:23 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'hhalter@yahoo.com', @orderDateTime = '2023-01-04 03:01 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'lorean.martabano@hotmail.com', @orderDateTime = '2023-02-13 01:28 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'france.buzick@yahoo.com', @orderDateTime = '2023-02-09 12:06 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'jferrario@hotmail.com', @orderDateTime = '2023-01-10 01:17 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'adelina_nabours@gmail.com', @orderDateTime = '2023-01-27 07:54 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'ddhamer@cox.net', @orderDateTime = '2023-02-09 11:15 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'jerry.dallen@yahoo.com', @orderDateTime = '2023-01-29 08:27 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'leota.ragel@gmail.com', @orderDateTime = '2023-01-27 11:04 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'jamyot@hotmail.com', @orderDateTime = '2023-01-22 05:57 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'aja_gehrett@hotmail.com', @orderDateTime = '2023-02-13 05:55 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kirk.herritt@aol.com', @orderDateTime = '2023-01-18 05:46 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'leonora@yahoo.com', @orderDateTime = '2023-02-05 09:28 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'winfred_brucato@hotmail.com', @orderDateTime = '2023-02-20 08:26 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'tarra.nachor@cox.net', @orderDateTime = '2023-01-16 12:57 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'corinne@loder.org', @orderDateTime = '2023-01-12 09:01 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'dulce_labreche@yahoo.com', @orderDateTime = '2023-02-10 04:22 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kate_keneipp@yahoo.com', @orderDateTime = '2023-01-15 12:55 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kaitlyn.ogg@gmail.com', @orderDateTime = '2023-02-11 04:07 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'sherita.saras@cox.net', @orderDateTime = '2023-01-17 11:51 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'lstuer@cox.net', @orderDateTime = '2023-01-05 03:30 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'ernest@cox.net', @orderDateTime = '2023-02-04 12:49 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'nobuko.halsey@yahoo.com', @orderDateTime = '2023-02-09 02:41 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'lavonna.wolny@hotmail.com', @orderDateTime = '2023-02-16 07:50 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'llizama@cox.net', @orderDateTime = '2023-01-21 05:06 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'mariann.bilden@aol.com', @orderDateTime = '2023-02-06 04:16 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'helene@aol.com', @orderDateTime = '2023-02-08 07:21 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'roselle.estell@hotmail.com', @orderDateTime = '2023-02-08 12:45 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'sheintzman@hotmail.com', @orderDateTime = '2023-01-07 02:38 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'margart_meisel@yahoo.com', @orderDateTime = '2023-01-09 07:13 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kristofer.bennick@yahoo.com', @orderDateTime = '2023-02-04 05:49 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'wacuff@gmail.com', @orderDateTime = '2023-01-06 06:38 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'shalon@cox.net', @orderDateTime = '2023-01-22 06:28 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'denise@patak.org', @orderDateTime = '2023-01-16 04:38 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'louvenia.beech@beech.com', @orderDateTime = '2023-02-03 05:08 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'audry.yaw@yaw.org', @orderDateTime = '2023-02-21 01:40 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kristel.ehmann@aol.com', @orderDateTime = '2023-01-21 05:37 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'vzepp@gmail.com', @orderDateTime = '2023-02-08 04:46 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'egwalthney@yahoo.com', @orderDateTime = '2023-02-10 01:43 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'venita_maillard@gmail.com', @orderDateTime = '2023-02-12 04:28 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'kasandra_semidey@semidey.com', @orderDateTime = '2023-02-13 12:17 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'donette.foller@cox.net', @orderDateTime = '02/14/2023  7:18:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'mroyster@royster.com', @orderDateTime = '02/18/2023  5:54:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'ernie_stenseth@aol.com', @orderDateTime = '01/19/2023  10:03:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'jina_briddick@briddick.com', @orderDateTime = '01/21/2023  8:26:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'sabra@uyetake.org', @orderDateTime = '01/14/2023  9:16:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'brhym@rhym.com', @orderDateTime = '02/24/2023  8:14:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'viva.toelkes@gmail.com', @orderDateTime = '01/03/2023  8:49:00 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'dominque.dickerson@dickerson.org', @orderDateTime = '02/17/2023  10:36:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'latrice.tolfree@hotmail.com', @orderDateTime = '02/16/2023  1:54:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'stephaine@cox.net', @orderDateTime = '01/24/2023  2:50:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'ernie_stenseth@aol.com', @orderDateTime = '01/8/2023  10:28:00 PM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;
EXECUTE  dbo.usp_addOrder  @customerEmailAddress = 'dominque.dickerson@dickerson.org', @orderDateTime = '01/20/2023  4:24:00 AM', @subTotal = NULL, @taxAmount =  NULL, @shippingCost = NULL,@orderTotal = NULL;


GO
---
--Enter Vendor Product Table Data
---
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Accurel Systems Intrntl Corp', @productName ='MX Anywhere 2S Wireless Mouse', @quantityOnHand = 10,  @vendorProductPrice = 49;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Acqua Group', @productName ='MX Anywhere 2S Wireless Mouse', @quantityOnHand = 5,  @vendorProductPrice = 49.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Alinabal Inc', @productName ='SanDisk - Ultra 500GB Internal SATA Solid State Drive for Laptops', @quantityOnHand = 11,  @vendorProductPrice = 149.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Alpenlite Inc', @productName ='CORSAIR - Vengeance LPX 32GB (2PK x 16GB) 2.6 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 5,  @vendorProductPrice = 269.65;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Anchor Computer Inc', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 9,  @vendorProductPrice = 62.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Art Crafters', @productName ='Black Weber State University Women''s Hooded Sweatshirt', @quantityOnHand = 24,  @vendorProductPrice = 62.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Art Crafters', @productName ='CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 12,  @vendorProductPrice = 147.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Art Crafters', @productName ='Weber State University Coaches Hat', @quantityOnHand = 9,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Art Crafters', @productName ='Yellow Weber State University 16 oz. Tumbler', @quantityOnHand = 5,  @vendorProductPrice = 42;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Binswanger', @productName ='Circle 2 2MP Wire-Free Network Camera with Night Vision', @quantityOnHand = 18,  @vendorProductPrice = 253.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='Black Weber State University Women''s Hooded Sweatshirt', @quantityOnHand = 12,  @vendorProductPrice = 253.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 20,  @vendorProductPrice = 194.82;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='PA248Q 24 LED Backlit IPS Widescreen Monitor', @quantityOnHand = 24,  @vendorProductPrice = 224.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='VE278Q 27 Widescreen LCD Computer Display', @quantityOnHand = 17,  @vendorProductPrice = 202.21;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='VS278Q-P 27 16:9 LCD Monitor', @quantityOnHand = 6,  @vendorProductPrice = 159.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='Weber State University Rain Poncho', @quantityOnHand = 11,  @vendorProductPrice = 5.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='Yellow Weber State University 16 oz. Tumbler', @quantityOnHand = 21,  @vendorProductPrice = 42;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'C 4 Network Inc', @productName ='LG - 55 Class - LED - UJ7700 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 24,  @vendorProductPrice = 1299;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'C 4 Network Inc', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 21,  @vendorProductPrice = 2999;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'C 4 Network Inc', @productName ='LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 23,  @vendorProductPrice = 3193.98;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'C 4 Network Inc', @productName ='Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @quantityOnHand = 23,  @vendorProductPrice = 479;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'C 4 Network Inc', @productName ='Samsung - 65 Class - LED - MU6290 Series - 2160p - Smart - 4K Ultra HD TV with HDR', @quantityOnHand = 20,  @vendorProductPrice = 1177.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Calaveras Prospect', @productName ='Onkyo - 5.1-Ch. Home Theater System - Black', @quantityOnHand = 13,  @vendorProductPrice = 399.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Acer 15.6 Chromebook CB5-571-C4G4', @quantityOnHand = 19,  @vendorProductPrice = 198.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Alpine - Rear View Camera - Black', @quantityOnHand = 25,  @vendorProductPrice = 149.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Alpine PDXM12 1200W Mono RMS Digital Amplifier', @quantityOnHand = 18,  @vendorProductPrice = 849.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Apple iPod Touch 128GB Blue', @quantityOnHand = 15,  @vendorProductPrice = 279.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='AVR-S530BT 5.2-Channel A/V Receiver', @quantityOnHand = 9,  @vendorProductPrice = 279.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='AVR-X1400H 7.2-Channel Network A/V Receiver', @quantityOnHand = 12,  @vendorProductPrice = 349.98;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Bose SoundLink Color Bluetooth Speaker (Black)', @quantityOnHand = 25,  @vendorProductPrice = 116.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Circle 2 2MP Wire-Free Network Camera with Night Vision', @quantityOnHand = 13,  @vendorProductPrice = 199.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='CORSAIR - AX760 760-Watt ATX Power Supply - Black', @quantityOnHand = 12,  @vendorProductPrice = 159.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting', @quantityOnHand = 12,  @vendorProductPrice = 76.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='CORSAIR - ML Series 140mm Case Cooling Fan - White', @quantityOnHand = 10,  @vendorProductPrice = 34.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 9,  @vendorProductPrice = 219.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='CORSAIR - Vengeance LPX 32GB (2PK x 16GB) 2.6 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 17,  @vendorProductPrice = 262.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 20,  @vendorProductPrice = 279.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='GTK-XB90 Bluetooth Speaker', @quantityOnHand = 16,  @vendorProductPrice = 349.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='JBL - Free True Wireless In-Ear Headphones - Black', @quantityOnHand = 11,  @vendorProductPrice = 149.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @quantityOnHand = 19,  @vendorProductPrice = 199.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='LG - 55 Class - LED - UJ7700 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 5,  @vendorProductPrice = 799.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 16,  @vendorProductPrice = 1299.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 7,  @vendorProductPrice = 2499.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Logitech - Harmony 950 Universal Remote - Black', @quantityOnHand = 22,  @vendorProductPrice = 249.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='MX Anywhere 2S Wireless Mouse', @quantityOnHand = 16,  @vendorProductPrice = 79.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Onkyo - 5.1-Ch. Home Theater System - Black', @quantityOnHand = 8,  @vendorProductPrice = 399.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Onkyo M-5010 2-Channel Amplifier (Black)', @quantityOnHand = 5,  @vendorProductPrice = 249.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='PA248Q 24 LED Backlit IPS Widescreen Monitor', @quantityOnHand = 8,  @vendorProductPrice = 329.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Panamax - 11-Outlet Surge Protector - Black', @quantityOnHand = 16,  @vendorProductPrice = 353.98;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Panamax - 2-Outlet Surge Protector - White', @quantityOnHand = 13,  @vendorProductPrice = 149.98;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @quantityOnHand = 9,  @vendorProductPrice = 379.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Pioneer - XDP-300R 32GB* Video MP3 Player - Black', @quantityOnHand = 18,  @vendorProductPrice = 699.98;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Samsung - 55 Class - LED - Q8F Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 10,  @vendorProductPrice = 2199.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Samsung - 65 Class - LED - MU6290 Series - 2160p - Smart - 4K Ultra HD TV with HDR', @quantityOnHand = 18,  @vendorProductPrice = 5999.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Samsung - 850 PRO 1TB Internal SATA III Solid State Drive for Laptops', @quantityOnHand = 8,  @vendorProductPrice = 479.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='SanDisk - Ultra 500GB Internal SATA Solid State Drive for Laptops', @quantityOnHand = 8,  @vendorProductPrice = 199.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='SanDisk - Ultra II 960GB Internal SATA Solid State Drive for Laptops', @quantityOnHand = 6,  @vendorProductPrice = 399.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Sennheiser - Digital Headphone Amplifier - Silver', @quantityOnHand = 5,  @vendorProductPrice = 2199.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Sennheiser - Earbud Headphones - Black', @quantityOnHand = 24,  @vendorProductPrice = 799.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='Sony Ultra-Portable Bluetooth Speaker', @quantityOnHand = 8,  @vendorProductPrice = 69.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='VE278Q 27 Widescreen LCD Computer Display', @quantityOnHand = 11,  @vendorProductPrice = 199.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Can Tron', @productName ='VS278Q-P 27 16:9 LCD Monitor', @quantityOnHand = 24,  @vendorProductPrice = 209.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Apple iPod Touch 128GB Blue', @quantityOnHand = 14,  @vendorProductPrice = 299;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='AVR-S530BT 5.2-Channel A/V Receiver', @quantityOnHand = 11,  @vendorProductPrice = 279;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='AVR-X1400H 7.2-Channel Network A/V Receiver', @quantityOnHand = 18,  @vendorProductPrice = 599;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Circle 2 2MP Wire-Free Network Camera with Night Vision', @quantityOnHand = 13,  @vendorProductPrice = 179.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting', @quantityOnHand = 21,  @vendorProductPrice = 83.78;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 6,  @vendorProductPrice = 239;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 23,  @vendorProductPrice = 439;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='GTK-XB90 Bluetooth Speaker', @quantityOnHand = 11,  @vendorProductPrice = 298;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='JBL - Free True Wireless In-Ear Headphones - Black', @quantityOnHand = 19,  @vendorProductPrice = 129.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @quantityOnHand = 6,  @vendorProductPrice = 149.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='LG - 55 Class - LED - UJ7700 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 12,  @vendorProductPrice = 1296.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 11,  @vendorProductPrice = 1496.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 8,  @vendorProductPrice = 2496.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='MX Anywhere 2S Wireless Mouse', @quantityOnHand = 7,  @vendorProductPrice = 59.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Onkyo - 5.1-Ch. Home Theater System - Black', @quantityOnHand = 17,  @vendorProductPrice = 399;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Onkyo M-5010 2-Channel Amplifier (Black)', @quantityOnHand = 25,  @vendorProductPrice = 314.6;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='PA248Q 24 LED Backlit IPS Widescreen Monitor', @quantityOnHand = 6,  @vendorProductPrice = 327.72;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @quantityOnHand = 17,  @vendorProductPrice = 379;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Pioneer - XDP-300R 32GB* Video MP3 Player - Black', @quantityOnHand = 5,  @vendorProductPrice = 699.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Samsung - 55 Class - LED - Q8F Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 19,  @vendorProductPrice = 2197.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Samsung - 65 Class - LED - MU6290 Series - 2160p - Smart - 4K Ultra HD TV with HDR', @quantityOnHand = 7,  @vendorProductPrice = 1397.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Samsung - 850 PRO 1TB Internal SATA III Solid State Drive for Laptops', @quantityOnHand = 20,  @vendorProductPrice = 449;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='SanDisk - Ultra 500GB Internal SATA Solid State Drive for Laptops', @quantityOnHand = 6,  @vendorProductPrice = 199.74;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='SanDisk - Ultra II 960GB Internal SATA Solid State Drive for Laptops', @quantityOnHand = 23,  @vendorProductPrice = 298.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Sennheiser - Digital Headphone Amplifier - Silver', @quantityOnHand = 19,  @vendorProductPrice = 2199.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Sennheiser - Earbud Headphones - Black', @quantityOnHand = 7,  @vendorProductPrice = 799.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='Sony Ultra-Portable Bluetooth Speaker', @quantityOnHand = 13,  @vendorProductPrice = 68;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='VE278Q 27 Widescreen LCD Computer Display', @quantityOnHand = 8,  @vendorProductPrice = 189;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Casco Services Inc', @productName ='VS278Q-P 27 16:9 LCD Monitor', @quantityOnHand = 23,  @vendorProductPrice = 189.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Centro Inc', @productName ='Onkyo - 5.1-Ch. Home Theater System - Black', @quantityOnHand = 6,  @vendorProductPrice = 339.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Circuit Solution Inc', @productName ='AVR-S530BT 5.2-Channel A/V Receiver', @quantityOnHand = 18,  @vendorProductPrice = 279;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Circuit Solution Inc', @productName ='Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt', @quantityOnHand = 17,  @vendorProductPrice = 279;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Circuit Solution Inc', @productName ='Weber State University Crew Socks', @quantityOnHand = 17,  @vendorProductPrice = 18;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Circuit Solution Inc', @productName ='Weber State University Short Sleeve T-Shirt', @quantityOnHand = 18,  @vendorProductPrice = 30;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Computer Repair Service', @productName ='Bose SoundLink Color Bluetooth Speaker (Black)', @quantityOnHand = 9,  @vendorProductPrice = 81;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Cowan & Kelly', @productName ='Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @quantityOnHand = 17,  @vendorProductPrice = 379;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Deltam Systems Inc', @productName ='PA248Q 24 LED Backlit IPS Widescreen Monitor', @quantityOnHand = 22,  @vendorProductPrice = 329.47;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'E A I Electronic Assocs Inc', @productName ='JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @quantityOnHand = 6,  @vendorProductPrice = 71.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Eagle Software Inc', @productName ='Black Weber State University Women''s Hooded Sweatshirt', @quantityOnHand = 10,  @vendorProductPrice = 71.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Eagle Software Inc', @productName ='Bose SoundLink Color Bluetooth Speaker (Black)', @quantityOnHand = 24,  @vendorProductPrice = 89;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Eagle Software Inc', @productName ='Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt', @quantityOnHand = 15,  @vendorProductPrice = 15.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Eagle Software Inc', @productName ='Weber State University Coaches Hat', @quantityOnHand = 6,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Feiner Bros', @productName ='CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting', @quantityOnHand = 10,  @vendorProductPrice = 89.98;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Franz Inc', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 19,  @vendorProductPrice = 129.94;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Franz Inc', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 16,  @vendorProductPrice = 1595.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Garrison Ind', @productName ='CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 18,  @vendorProductPrice = 94.48;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Geonex Martel Inc', @productName ='CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 25,  @vendorProductPrice = 176.45;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'H H H Enterprises Inc', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 6,  @vendorProductPrice = 1545;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Harris Corporation', @productName ='PA248Q 24 LED Backlit IPS Widescreen Monitor', @quantityOnHand = 16,  @vendorProductPrice = 180;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Hermar Inc', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 5,  @vendorProductPrice = 1510;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Jets Cybernetics', @productName ='Sony Ultra-Portable Bluetooth Speaker', @quantityOnHand = 8,  @vendorProductPrice = 31.87;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Jets Cybernetics', @productName ='Weber State University Alumni T-Shirt', @quantityOnHand = 5,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Jets Cybernetics', @productName ='Weber State University Rain Poncho', @quantityOnHand = 23,  @vendorProductPrice = 5.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Jets Cybernetics', @productName ='Yellow Weber State University 16 oz. Tumbler', @quantityOnHand = 25,  @vendorProductPrice = 42;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'John Wagner Associates', @productName ='JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @quantityOnHand = 5,  @vendorProductPrice = 98.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Killion Industries', @productName ='Apple iPod Touch 128GB Blue', @quantityOnHand = 19,  @vendorProductPrice = 399;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Lane Promotions', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 15,  @vendorProductPrice = 1596.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Linguistic Systems Inc', @productName ='MX Anywhere 2S Wireless Mouse', @quantityOnHand = 21,  @vendorProductPrice = 49.93;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Linguistic Systems Inc', @productName ='Weber State University Alumni T-Shirt', @quantityOnHand = 12,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Linguistic Systems Inc', @productName ='Weber State University Volleyball Short Sleeve T-Shirt', @quantityOnHand = 20,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Linguistic Systems Inc', @productName ='Weber State University Wildcats State Decal', @quantityOnHand = 12,  @vendorProductPrice = 6.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mcauley Mfg Co', @productName ='AVR-S530BT 5.2-Channel A/V Receiver', @quantityOnHand = 9,  @vendorProductPrice = 229;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mcauley Mfg Co', @productName ='JBL - Free True Wireless In-Ear Headphones - Black', @quantityOnHand = 8,  @vendorProductPrice = 149.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mcauley Mfg Co', @productName ='Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @quantityOnHand = 24,  @vendorProductPrice = 399;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Meca', @productName ='AVR-S530BT 5.2-Channel A/V Receiver', @quantityOnHand = 14,  @vendorProductPrice = 299.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Meca', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 14,  @vendorProductPrice = 54.9;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Meca', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 5,  @vendorProductPrice = 1496.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mitsumi Electronics Corp', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 12,  @vendorProductPrice = 69.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mitsumi Electronics Corp', @productName ='Weber State University Crew Socks', @quantityOnHand = 20,  @vendorProductPrice = 18;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mitsumi Electronics Corp', @productName ='Weber State University Putter Cover', @quantityOnHand = 19,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mitsumi Electronics Corp', @productName ='Weber State University Wildcats State Decal', @quantityOnHand = 10,  @vendorProductPrice = 6.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Morlong Associates', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 23,  @vendorProductPrice = 69;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Newtec Inc', @productName ='Circle 2 2MP Wire-Free Network Camera with Night Vision', @quantityOnHand = 9,  @vendorProductPrice = 188.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Newtec Inc', @productName ='JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @quantityOnHand = 7,  @vendorProductPrice = 96.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Panasystems', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 14,  @vendorProductPrice = 1544.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Polykote Inc', @productName ='Sony Ultra-Portable Bluetooth Speaker', @quantityOnHand = 16,  @vendorProductPrice = 19;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Price Business Services', @productName ='LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 23,  @vendorProductPrice = 3296.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Price Business Services', @productName ='Weber State University Putter Cover', @quantityOnHand = 18,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Price Business Services', @productName ='Weber State University Volleyball Short Sleeve T-Shirt', @quantityOnHand = 12,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Price Business Services', @productName ='Weber State University Wildcats State Decal', @quantityOnHand = 13,  @vendorProductPrice = 6.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Acer 15.6 Chromebook CB5-571-C4G4', @quantityOnHand = 9,  @vendorProductPrice = 294.36;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Apple iPod Touch 128GB Blue', @quantityOnHand = 8,  @vendorProductPrice = 289.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting', @quantityOnHand = 19,  @vendorProductPrice = 85.26;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='CORSAIR - ML Series 140mm Case Cooling Fan - White', @quantityOnHand = 11,  @vendorProductPrice = 32.1;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 10,  @vendorProductPrice = 221.04;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='LG - 55 Class - LED - UJ7700 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 11,  @vendorProductPrice = 1299.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 12,  @vendorProductPrice = 3299;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='PA248Q 24 LED Backlit IPS Widescreen Monitor', @quantityOnHand = 20,  @vendorProductPrice = 329;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Samsung - 55 Class - LED - Q8F Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 14,  @vendorProductPrice = 2599.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Samsung - 65 Class - LED - MU6290 Series - 2160p - Smart - 4K Ultra HD TV with HDR', @quantityOnHand = 13,  @vendorProductPrice = 6999.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='SanDisk - Ultra II 960GB Internal SATA Solid State Drive for Laptops', @quantityOnHand = 15,  @vendorProductPrice = 292.44;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Sony Ultra-Portable Bluetooth Speaker', @quantityOnHand = 11,  @vendorProductPrice = 69.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='VE278Q 27 Widescreen LCD Computer Display', @quantityOnHand = 12,  @vendorProductPrice = 182.64;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='VS278Q-P 27 16:9 LCD Monitor', @quantityOnHand = 5,  @vendorProductPrice = 199.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Weber State University Alumni T-Shirt', @quantityOnHand = 23,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Weber State University Rain Poncho', @quantityOnHand = 13,  @vendorProductPrice = 5.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Weber State University Volleyball Short Sleeve T-Shirt', @quantityOnHand = 9,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Q A Service', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 20,  @vendorProductPrice = 1449;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Ravaal Enterprises Inc', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 22,  @vendorProductPrice = 108;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Reese Plastics', @productName ='CORSAIR - ML Series 140mm Case Cooling Fan - White', @quantityOnHand = 25,  @vendorProductPrice = 62;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Reese Plastics', @productName ='CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @quantityOnHand = 7,  @vendorProductPrice = 466;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Remaco Inc', @productName ='Logitech - Harmony 950 Universal Remote - Black', @quantityOnHand = 24,  @vendorProductPrice = 186.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Replica I', @productName ='Onkyo - 5.1-Ch. Home Theater System - Black', @quantityOnHand = 13,  @vendorProductPrice = 329.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Roberts Supply Co Inc', @productName ='AVR-S530BT 5.2-Channel A/V Receiver', @quantityOnHand = 24,  @vendorProductPrice = 259.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sampler', @productName ='Onkyo M-5010 2-Channel Amplifier (Black)', @quantityOnHand = 5,  @vendorProductPrice = 229.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Scat Enterprises', @productName ='Sennheiser - Earbud Headphones - Black', @quantityOnHand = 14,  @vendorProductPrice = 609.98;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sebring & Co', @productName ='Acer 15.6 Chromebook CB5-571-C4G4', @quantityOnHand = 12,  @vendorProductPrice = 259;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sebring & Co', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 20,  @vendorProductPrice = 64.89;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sebring & Co', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 17,  @vendorProductPrice = 1497.36;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sidewinder Products Corp', @productName ='LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @quantityOnHand = 18,  @vendorProductPrice = 2796.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sidewinder Products Corp', @productName ='Weber State University Crew Socks', @quantityOnHand = 25,  @vendorProductPrice = 18;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sidewinder Products Corp', @productName ='Weber State University Putter Cover', @quantityOnHand = 9,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sidewinder Products Corp', @productName ='Weber State University Short Sleeve T-Shirt', @quantityOnHand = 24,  @vendorProductPrice = 30;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sigma Corp Of America', @productName ='Panamax - 11-Outlet Surge Protector - Black', @quantityOnHand = 13,  @vendorProductPrice = 139.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Silver Bros Inc', @productName ='Sony Ultra-Portable Bluetooth Speaker', @quantityOnHand = 6,  @vendorProductPrice = 31.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Smc Inc', @productName ='AVR-S530BT 5.2-Channel A/V Receiver', @quantityOnHand = 23,  @vendorProductPrice = 279;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sport En Art', @productName ='Circle 2 2MP Wire-Free Network Camera with Night Vision', @quantityOnHand = 12,  @vendorProductPrice = 185;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Switchcraft Inc', @productName ='VS278Q-P 27 16:9 LCD Monitor', @quantityOnHand = 25,  @vendorProductPrice = 189.5;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Tipiak Inc', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 19,  @vendorProductPrice = 131.98;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Valerie & Company', @productName ='Gear 360 Spherical VR Camera', @quantityOnHand = 18,  @vendorProductPrice = 377.71;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Wheaton Plastic Products', @productName ='AVR-S530BT 5.2-Channel A/V Receiver', @quantityOnHand = 8,  @vendorProductPrice = 279;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Wheaton Plastic Products', @productName ='AVR-X1400H 7.2-Channel Network A/V Receiver', @quantityOnHand = 16,  @vendorProductPrice = 399;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Wheaton Plastic Products', @productName ='Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @quantityOnHand = 12,  @vendorProductPrice = 379;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Wye Technologies Inc', @productName ='MX Anywhere 2S Wireless Mouse', @quantityOnHand = 8,  @vendorProductPrice = 51.99;
GO

-----
-- Enter Order Item Table Data
-----
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-11 05:51 PM', @customerEmailAddress = 'noah.kalafatis@aol.com', @productName = 'AVR-S530BT 5.2-Channel A/V Receiver', @vendorName ='Wheaton Plastic Products', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-07 06:41 PM', @customerEmailAddress = 'csweigard@sweigard.com', @productName = 'GTK-XB90 Bluetooth Speaker', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-13 01:08 PM', @customerEmailAddress = 'lavonda@cox.net', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Morlong Associates', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-13 01:08 PM', @customerEmailAddress = 'lavonda@cox.net', @productName = 'JBL - Free True Wireless In-Ear Headphones - Black', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-12 02:10 AM', @customerEmailAddress = 'junita@aol.com', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Franz Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-07 07:37 AM', @customerEmailAddress = 'herminia@nicolozakes.org', @productName = 'VE278Q 27 Widescreen LCD Computer Display', @vendorName ='Burton & Davis', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-07 07:37 AM', @customerEmailAddress = 'herminia@nicolozakes.org', @productName = 'LG - 55 Class - LED - UJ7700 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Professionals Unlimited', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-23 05:09 PM', @customerEmailAddress = 'casie.good@aol.com', @productName = 'Sennheiser - Earbud Headphones - Black', @vendorName ='Scat Enterprises', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-25 02:51 PM', @customerEmailAddress = 'reena@hotmail.com', @productName = 'Bose SoundLink Color Bluetooth Speaker (Black)', @vendorName ='Eagle Software Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-11 07:10 PM', @customerEmailAddress = 'mirta_mallett@gmail.com', @productName = 'SanDisk - Ultra II 960GB Internal SATA Solid State Drive for Laptops', @vendorName ='Casco Services Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-11 07:10 PM', @customerEmailAddress = 'mirta_mallett@gmail.com', @productName = 'AVR-S530BT 5.2-Channel A/V Receiver', @vendorName ='Casco Services Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-16 10:36 AM', @customerEmailAddress = 'cathrine.pontoriero@pontoriero.com', @productName = 'MX Anywhere 2S Wireless Mouse', @vendorName ='Linguistic Systems Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-02 06:50 AM', @customerEmailAddress = 'ftawil@hotmail.com', @productName = 'Circle 2 2MP Wire-Free Network Camera with Night Vision', @vendorName ='Binswanger', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-10 06:16 PM', @customerEmailAddress = 'rupthegrove@yahoo.com', @productName = 'CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @vendorName ='Reese Plastics', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-11 05:03 AM', @customerEmailAddress = 'sarah.candlish@gmail.com', @productName = 'LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='C 4 Network Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-16 09:18 AM', @customerEmailAddress = 'lucy@cox.net', @productName = 'Apple iPod Touch 128GB Blue', @vendorName ='Killion Industries', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-03 07:00 AM', @customerEmailAddress = 'jaquas@aquas.com', @productName = 'VS278Q-P 27 16:9 LCD Monitor', @vendorName ='Professionals Unlimited', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-03 07:00 AM', @customerEmailAddress = 'jaquas@aquas.com', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Sebring & Co', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-12 07:09 AM', @customerEmailAddress = 'yvonne.tjepkema@hotmail.com', @productName = 'Bose SoundLink Color Bluetooth Speaker (Black)', @vendorName ='Computer Repair Service', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-03 11:36 AM', @customerEmailAddress = 'kayleigh.lace@yahoo.com', @productName = 'Onkyo M-5010 2-Channel Amplifier (Black)', @vendorName ='Can Tron', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-18 07:59 PM', @customerEmailAddress = 'felix_hirpara@cox.net', @productName = 'Logitech - Harmony 950 Universal Remote - Black', @vendorName ='Remaco Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-20 04:23 PM', @customerEmailAddress = 'tresa_sweely@hotmail.com', @productName = 'VS278Q-P 27 16:9 LCD Monitor', @vendorName ='Burton & Davis', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-20 04:23 PM', @customerEmailAddress = 'tresa_sweely@hotmail.com', @productName = 'VS278Q-P 27 16:9 LCD Monitor', @vendorName ='Switchcraft Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-04 01:19 PM', @customerEmailAddress = 'kristeen@gmail.com', @productName = 'MX Anywhere 2S Wireless Mouse', @vendorName ='Accurel Systems Intrntl Corp', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-13 07:51 AM', @customerEmailAddress = 'jregusters@regusters.com', @productName = 'CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @vendorName ='Geonex Martel Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-18 03:21 PM', @customerEmailAddress = 'renea@hotmail.com', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-18 03:21 PM', @customerEmailAddress = 'renea@hotmail.com', @productName = 'Onkyo - 5.1-Ch. Home Theater System - Black', @vendorName ='Can Tron', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-18 03:21 PM', @customerEmailAddress = 'renea@hotmail.com', @productName = 'AVR-S530BT 5.2-Channel A/V Receiver', @vendorName ='Smc Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-11 01:47 AM', @customerEmailAddress = 'olive@aol.com', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Mitsumi Electronics Corp', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-23 10:15 AM', @customerEmailAddress = 'lreiber@cox.net', @productName = 'VE278Q 27 Widescreen LCD Computer Display', @vendorName ='Casco Services Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-21 01:23 AM', @customerEmailAddress = 'christiane.eschberger@yahoo.com', @productName = 'AVR-S530BT 5.2-Channel A/V Receiver', @vendorName ='Roberts Supply Co Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-09 03:41 PM', @customerEmailAddress = 'goldie.schirpke@yahoo.com', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='C 4 Network Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-06 10:52 AM', @customerEmailAddress = 'loreta.timenez@hotmail.com', @productName = 'Sony Ultra-Portable Bluetooth Speaker', @vendorName ='Professionals Unlimited', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-06 10:52 AM', @customerEmailAddress = 'loreta.timenez@hotmail.com', @productName = 'CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting', @vendorName ='Feiner Bros', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-13 10:20 AM', @customerEmailAddress = 'fabiola.hauenstein@hauenstein.org', @productName = 'Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @vendorName ='C 4 Network Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-16 02:52 AM', @customerEmailAddress = 'amie.perigo@yahoo.com', @productName = 'Panamax - 2-Outlet Surge Protector - White', @vendorName ='Can Tron', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-16 02:52 AM', @customerEmailAddress = 'amie.perigo@yahoo.com', @productName = 'Samsung - 65 Class - LED - MU6290 Series - 2160p - Smart - 4K Ultra HD TV with HDR', @vendorName ='Professionals Unlimited', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-06 09:42 AM', @customerEmailAddress = 'raina.brachle@brachle.org', @productName = 'CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting', @vendorName ='Can Tron', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-25 10:26 AM', @customerEmailAddress = 'erinn.canlas@canlas.com', @productName = 'AVR-X1400H 7.2-Channel Network A/V Receiver', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-08 12:23 AM', @customerEmailAddress = 'cherry@lietz.com', @productName = 'Onkyo M-5010 2-Channel Amplifier (Black)', @vendorName ='Sampler', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-07 08:08 PM', @customerEmailAddress = 'kattie@vonasek.org', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Valerie & Company', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-07 08:08 PM', @customerEmailAddress = 'kattie@vonasek.org', @productName = 'Samsung - 850 PRO 1TB Internal SATA III Solid State Drive for Laptops', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-21 11:50 AM', @customerEmailAddress = 'lilli@aol.com', @productName = 'Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @vendorName ='Mcauley Mfg Co', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-14 12:09 PM', @customerEmailAddress = 'whitley.tomasulo@aol.com', @productName = 'Logitech - Harmony 950 Universal Remote - Black', @vendorName ='Can Tron', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-17 09:10 AM', @customerEmailAddress = 'badkin@hotmail.com', @productName = 'Samsung - 55 Class - LED - Q8F Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Professionals Unlimited', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-17 09:10 AM', @customerEmailAddress = 'badkin@hotmail.com', @productName = 'CORSAIR - ML Series 140mm Case Cooling Fan - White', @vendorName ='Reese Plastics', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-20 01:58 PM', @customerEmailAddress = 'hermila_thyberg@hotmail.com', @productName = 'Samsung - 65 Class - LED - MU6290 Series - 2160p - Smart - 4K Ultra HD TV with HDR', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-20 01:58 PM', @customerEmailAddress = 'hermila_thyberg@hotmail.com', @productName = 'SanDisk - Ultra 500GB Internal SATA Solid State Drive for Laptops', @vendorName ='Casco Services Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-09 05:33 AM', @customerEmailAddress = 'jesusita.flister@hotmail.com', @productName = 'Panamax - 11-Outlet Surge Protector - Black', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-09 05:33 AM', @customerEmailAddress = 'jesusita.flister@hotmail.com', @productName = 'Samsung - 65 Class - LED - MU6290 Series - 2160p - Smart - 4K Ultra HD TV with HDR', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-22 11:13 AM', @customerEmailAddress = 'caitlin.julia@julia.org', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-22 11:13 AM', @customerEmailAddress = 'caitlin.julia@julia.org', @productName = 'Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @vendorName ='Cowan & Kelly', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-13 12:23 PM', @customerEmailAddress = 'roosevelt.hoffis@aol.com', @productName = 'Samsung - 850 PRO 1TB Internal SATA III Solid State Drive for Laptops', @vendorName ='Casco Services Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-04 03:01 PM', @customerEmailAddress = 'hhalter@yahoo.com', @productName = 'MX Anywhere 2S Wireless Mouse', @vendorName ='Wye Technologies Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-13 01:28 PM', @customerEmailAddress = 'lorean.martabano@hotmail.com', @productName = 'MX Anywhere 2S Wireless Mouse', @vendorName ='Casco Services Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-13 01:28 PM', @customerEmailAddress = 'lorean.martabano@hotmail.com', @productName = 'Circle 2 2MP Wire-Free Network Camera with Night Vision', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-09 12:06 AM', @customerEmailAddress = 'france.buzick@yahoo.com', @productName = 'VE278Q 27 Widescreen LCD Computer Display', @vendorName ='Can Tron', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-10 01:17 PM', @customerEmailAddress = 'jferrario@hotmail.com', @productName = 'Pioneer - XDP-300R 32GB* Video MP3 Player - Black', @vendorName ='Casco Services Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-10 01:17 PM', @customerEmailAddress = 'jferrario@hotmail.com', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Franz Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-27 07:54 PM', @customerEmailAddress = 'adelina_nabours@gmail.com', @productName = 'PA248Q 24 LED Backlit IPS Widescreen Monitor', @vendorName ='Can Tron', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-09 11:15 AM', @customerEmailAddress = 'ddhamer@cox.net', @productName = 'VS278Q-P 27 16:9 LCD Monitor', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-29 08:27 PM', @customerEmailAddress = 'jerry.dallen@yahoo.com', @productName = 'Alpine PDXM12 1200W Mono RMS Digital Amplifier', @vendorName ='Can Tron', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-29 08:27 PM', @customerEmailAddress = 'jerry.dallen@yahoo.com', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Professionals Unlimited', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-27 11:04 AM', @customerEmailAddress = 'leota.ragel@gmail.com', @productName = 'Sennheiser - Digital Headphone Amplifier - Silver', @vendorName ='Casco Services Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-22 05:57 PM', @customerEmailAddress = 'jamyot@hotmail.com', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Sebring & Co', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-22 05:57 PM', @customerEmailAddress = 'jamyot@hotmail.com', @productName = 'JBL - Free True Wireless In-Ear Headphones - Black', @vendorName ='Casco Services Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-13 05:55 AM', @customerEmailAddress = 'aja_gehrett@hotmail.com', @productName = 'AVR-S530BT 5.2-Channel A/V Receiver', @vendorName ='Circuit Solution Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-18 05:46 PM', @customerEmailAddress = 'kirk.herritt@aol.com', @productName = 'CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @vendorName ='Garrison Ind', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-05 09:28 AM', @customerEmailAddress = 'leonora@yahoo.com', @productName = 'SanDisk - Ultra II 960GB Internal SATA Solid State Drive for Laptops', @vendorName ='Professionals Unlimited', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-20 08:26 PM', @customerEmailAddress = 'winfred_brucato@hotmail.com', @productName = 'Sennheiser - Earbud Headphones - Black', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-16 12:57 PM', @customerEmailAddress = 'tarra.nachor@cox.net', @productName = 'Sony Ultra-Portable Bluetooth Speaker', @vendorName ='Polykote Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-16 12:57 PM', @customerEmailAddress = 'tarra.nachor@cox.net', @productName = 'Acer 15.6 Chromebook CB5-571-C4G4', @vendorName ='Sebring & Co', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-12 09:01 AM', @customerEmailAddress = 'corinne@loder.org', @productName = 'CORSAIR - Vengeance LPX 32GB (2PK x 16GB) 2.6 GHz DDR4 DRAM Desktop Memory Kit - Black', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-10 04:22 PM', @customerEmailAddress = 'dulce_labreche@yahoo.com', @productName = 'CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting', @vendorName ='Casco Services Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-15 12:55 AM', @customerEmailAddress = 'kate_keneipp@yahoo.com', @productName = 'AVR-S530BT 5.2-Channel A/V Receiver', @vendorName ='Mcauley Mfg Co', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-11 04:07 PM', @customerEmailAddress = 'kaitlyn.ogg@gmail.com', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Meca', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-17 11:51 AM', @customerEmailAddress = 'sherita.saras@cox.net', @productName = 'AVR-X1400H 7.2-Channel Network A/V Receiver', @vendorName ='Can Tron', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-17 11:51 AM', @customerEmailAddress = 'sherita.saras@cox.net', @productName = 'LG - 55 Class - LED - UJ7700 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Can Tron', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-05 03:30 PM', @customerEmailAddress = 'lstuer@cox.net', @productName = 'Gear 360 Spherical VR Camera', @vendorName ='Tipiak Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-04 12:49 PM', @customerEmailAddress = 'ernest@cox.net', @productName = 'CORSAIR - Vengeance LPX 32GB (2PK x 16GB) 2.6 GHz DDR4 DRAM Desktop Memory Kit - Black', @vendorName ='Alpenlite Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-09 02:41 PM', @customerEmailAddress = 'nobuko.halsey@yahoo.com', @productName = 'VS278Q-P 27 16:9 LCD Monitor', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-16 07:50 PM', @customerEmailAddress = 'lavonna.wolny@hotmail.com', @productName = 'LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Price Business Services', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-21 05:06 AM', @customerEmailAddress = 'llizama@cox.net', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Hermar Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-06 04:16 PM', @customerEmailAddress = 'mariann.bilden@aol.com', @productName = 'Onkyo - 5.1-Ch. Home Theater System - Black', @vendorName ='Replica I', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-06 04:16 PM', @customerEmailAddress = 'mariann.bilden@aol.com', @productName = 'JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @vendorName ='E A I Electronic Assocs Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-08 07:21 PM', @customerEmailAddress = 'helene@aol.com', @productName = 'JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @vendorName ='Can Tron', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-08 12:45 AM', @customerEmailAddress = 'roselle.estell@hotmail.com', @productName = 'CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-08 12:45 AM', @customerEmailAddress = 'roselle.estell@hotmail.com', @productName = 'Alpine - Rear View Camera - Black', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-07 02:38 PM', @customerEmailAddress = 'sheintzman@hotmail.com', @productName = 'Onkyo - 5.1-Ch. Home Theater System - Black', @vendorName ='Calaveras Prospect', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-09 07:13 AM', @customerEmailAddress = 'margart_meisel@yahoo.com', @productName = 'JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @vendorName ='Newtec Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-04 05:49 AM', @customerEmailAddress = 'kristofer.bennick@yahoo.com', @productName = 'CORSAIR - Vengeance LPX 16GB (2PK x 8GB) 3.2 GHz DDR4 DRAM Desktop Memory Kit - Black', @vendorName ='Art Crafters', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-06 06:38 AM', @customerEmailAddress = 'wacuff@gmail.com', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Q A Service', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-06 06:38 AM', @customerEmailAddress = 'wacuff@gmail.com', @productName = 'Pioneer - 5.1-Ch. 4K Ultra HD HDR Compatible A/V Home Theater Receiver - Black', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-22 06:28 AM', @customerEmailAddress = 'shalon@cox.net', @productName = 'CORSAIR - ML Series 140mm Case Cooling Fan - White', @vendorName ='Can Tron', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-16 04:38 AM', @customerEmailAddress = 'denise@patak.org', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Panasystems', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-03 05:08 PM', @customerEmailAddress = 'louvenia.beech@beech.com', @productName = 'LG - 65 Class - LED - SJ8500 Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Sidewinder Products Corp', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-03 05:08 PM', @customerEmailAddress = 'louvenia.beech@beech.com', @productName = 'MX Anywhere 2S Wireless Mouse', @vendorName ='Acqua Group', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-21 01:40 PM', @customerEmailAddress = 'audry.yaw@yaw.org', @productName = 'LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-21 05:37 PM', @customerEmailAddress = 'kristel.ehmann@aol.com', @productName = 'PA248Q 24 LED Backlit IPS Widescreen Monitor', @vendorName ='Casco Services Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-21 05:37 PM', @customerEmailAddress = 'kristel.ehmann@aol.com', @productName = 'CORSAIR - HD Series 120mm Case Cooling Fan Kit with RGB lighting', @vendorName ='Professionals Unlimited', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-01-21 05:37 PM', @customerEmailAddress = 'kristel.ehmann@aol.com', @productName = 'PA248Q 24 LED Backlit IPS Widescreen Monitor', @vendorName ='Deltam Systems Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-08 04:46 PM', @customerEmailAddress = 'vzepp@gmail.com', @productName = 'Pioneer - XDP-300R 32GB* Video MP3 Player - Black', @vendorName ='Can Tron', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-08 04:46 PM', @customerEmailAddress = 'vzepp@gmail.com', @productName = 'LG - 65 Class - OLED - B7A Series - 2160p - Smart - 4K UHD TV with HDR', @vendorName ='Can Tron', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-10 01:43 AM', @customerEmailAddress = 'egwalthney@yahoo.com', @productName = 'CORSAIR - ML Series 140mm Case Cooling Fan - White', @vendorName ='Professionals Unlimited', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-12 04:28 AM', @customerEmailAddress = 'venita_maillard@gmail.com', @productName = 'Circle 2 2MP Wire-Free Network Camera with Night Vision', @vendorName ='Newtec Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-12 04:28 AM', @customerEmailAddress = 'venita_maillard@gmail.com', @productName = 'Acer 15.6 Chromebook CB5-571-C4G4', @vendorName ='Can Tron', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-13 12:17 PM', @customerEmailAddress = 'kasandra_semidey@semidey.com', @productName = 'JBL - Free True Wireless In-Ear Headphones - Black', @vendorName ='Mcauley Mfg Co', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-13 12:17 PM', @customerEmailAddress = 'kasandra_semidey@semidey.com', @productName = 'JBL Under Armour Sport Wireless Heart Rate In-Ear Headphones Black', @vendorName ='John Wagner Associates', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '2023-02-13 12:17 PM', @customerEmailAddress = 'kasandra_semidey@semidey.com', @productName = 'PA248Q 24 LED Backlit IPS Widescreen Monitor', @vendorName ='Harris Corporation', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/14/2023  7:18:00 AM', @customerEmailAddress = 'donette.foller@cox.net', @productName = 'Black Weber State University Women''s Hooded Sweatshirt ', @vendorName ='Eagle Software Inc ', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/14/2023  7:18:00 AM', @customerEmailAddress = 'donette.foller@cox.net', @productName = 'Weber State University Rain Poncho ', @vendorName ='Burton & Davis ', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/18/2023  5:54:00 AM', @customerEmailAddress = 'mroyster@royster.com', @productName = 'Weber State University Rain Poncho ', @vendorName ='Jets Cybernetics ', @quantity = 4;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/18/2023  5:54:00 AM', @customerEmailAddress = 'mroyster@royster.com', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt ', @vendorName ='Linguistic Systems Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/19/2023  10:03:00 AM', @customerEmailAddress = 'ernie_stenseth@aol.com', @productName = 'Black Weber State University Women''s Hooded Sweatshirt ', @vendorName ='Burton & Davis', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/19/2023  10:03:00 AM', @customerEmailAddress = 'ernie_stenseth@aol.com', @productName = 'Weber State University Rain Poncho ', @vendorName ='Professionals Unlimited', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/21/2023  8:26:00 AM', @customerEmailAddress = 'jina_briddick@briddick.com', @productName = 'Weber State University Putter Cover ', @vendorName ='Sidewinder Products Corp', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/21/2023  8:26:00 AM', @customerEmailAddress = 'jina_briddick@briddick.com', @productName = 'Weber State University Crew Socks ', @vendorName ='Circuit Solution Inc ', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/21/2023  8:26:00 AM', @customerEmailAddress = 'jina_briddick@briddick.com', @productName = 'Weber State University Coaches Hat ', @vendorName ='Eagle Software Inc ', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/14/2023  9:16:00 AM', @customerEmailAddress = 'sabra@uyetake.org', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt ', @vendorName ='Price Business Services', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/14/2023  9:16:00 AM', @customerEmailAddress = 'sabra@uyetake.org', @productName = 'Weber State University Wildcats State Decal ', @vendorName ='Mitsumi Electronics Corp', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/24/2023  8:14:00 AM', @customerEmailAddress = 'brhym@rhym.com', @productName = 'Weber State University Rain Poncho ', @vendorName ='Burton & Davis ', @quantity = 4;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/24/2023  8:14:00 AM', @customerEmailAddress = 'brhym@rhym.com', @productName = 'Weber State University Putter Cover ', @vendorName ='Sidewinder Products Corp', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/03/2023  8:49:00 PM', @customerEmailAddress = 'viva.toelkes@gmail.com', @productName = 'Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt ', @vendorName ='Eagle Software Inc ', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/03/2023  8:49:00 PM', @customerEmailAddress = 'viva.toelkes@gmail.com', @productName = 'Black Weber State University Women''s Hooded Sweatshirt ', @vendorName ='Art Crafters ', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/17/2023  10:36:00 AM', @customerEmailAddress = 'dominque.dickerson@dickerson.org', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt ', @vendorName ='Linguistic Systems Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/16/2023  1:54:00 AM', @customerEmailAddress = 'latrice.tolfree@hotmail.com', @productName = 'Weber State University Crew Socks ', @vendorName ='Circuit Solution Inc ', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/16/2023  1:54:00 AM', @customerEmailAddress = 'latrice.tolfree@hotmail.com', @productName = 'Weber State University Rain Poncho ', @vendorName ='Professionals Unlimited', @quantity = 4;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/24/2023  2:50:00 AM', @customerEmailAddress = 'stephaine@cox.net', @productName = 'Black Weber State University Women''s Hooded Sweatshirt ', @vendorName ='Eagle Software Inc ', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/8/2023  10:28:00 PM', @customerEmailAddress = 'ernie_stenseth@aol.com', @productName = 'Weber State University Rain Poncho ', @vendorName ='Jets Cybernetics ', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/08/2023  10:28:00 PM', @customerEmailAddress = 'ernie_stenseth@aol.com', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt ', @vendorName ='Linguistic Systems Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/20/2023  4:24:00 AM', @customerEmailAddress = 'dominque.dickerson@dickerson.org', @productName = 'Weber State University Rain Poncho ', @vendorName ='Burton & Davis ', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/20/2023  4:24:00 AM', @customerEmailAddress = 'dominque.dickerson@dickerson.org', @productName = 'Weber State University Putter Cover ', @vendorName ='Price Business Services', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/20/2023  4:24:00 AM', @customerEmailAddress = 'dominque.dickerson@dickerson.org', @productName = 'Weber State University Coaches Hat ', @vendorName ='Eagle Software Inc ', @quantity = 1;

GO
-----
--Print Tables
-----
--SELECT 'This is table' AS "Customer";
--SELECT * FROM Customer;
--SELECT 'This is Table' AS "Supplier";
--SELECT * FROM Supplier;

--SELECT 'This is Table' AS "Vendor";
--SELECT * FROM Vendor;

--SELECT 'This is Table' AS "Product";
--SELECT * FROM Product;

--SELECT 'This is table' AS "OrderTable";
--SELECT * FROM OrderTable;
	
--SELECT 'This is table' AS "OrderItem";
--SELECT * FROM OrderItem;

--SELECT 'This is Table' AS "VendorProduct";
--SELECT * FROM VendorProduct;


----
--Test Functions
----

--udf_getDateTime
SELECT [dbo].udf_getDateTime('01/8/2023  10:28:00 PM');
SELECT [dbo].udf_getDateTime('02/24/2023  8:14:00 AM');
SELECT [dbo].udf_getDateTime('2023-01-22 06:28 AM');
SELECT [dbo].udf_getDateTime('01/19/2023  10:03:00 AM');
SELECT [dbo].udf_getDateTime('2023-01-29 08:27 PM');

SELECT [dbo].udf_getDateTime('14-41-10 30:40');


--udf_getCustomerID
SELECT [dbo].udf_getCustomerID('dominque.dickerson@dickerson.org');
SELECT [dbo].udf_getCustomerID('goldie.schirpke@yahoo.com');
SELECT [dbo].udf_getCustomerID('amie.perigo@yahoo.com');
SELECT [dbo].udf_getCustomerID('mirta_mallett@gmail.com');
SELECT [dbo].udf_getCustomerID('jamyot@hotmail.com');

SELECT [dbo].udf_getCustomerID('ColetonWattt@weber.edu');

--udf_getSupplierID
SELECT [dbo].udf_getSupplierID('Acer');
SELECT [dbo].udf_getSupplierID('Franklin Peters Inc');
SELECT [dbo].udf_getSupplierID('CORSAIR');
SELECT [dbo].udf_getSupplierID('Grace Pastries Inc');

SELECT [dbo].udf_getSupplierID('TSMC SemiConductors');

--udf_getVendorID
SELECT [dbo].udf_getVendorID('H H H Enterprises Inc');
SELECT [dbo].udf_getVendorID('Franz Inc');
SELECT [dbo].udf_getVendorID('Professionals Unlimited');
SELECT [dbo].udf_getVendorID('Sampler');

SELECT [dbo].udf_getVendorID('EleLabs');

--udf_getProductID
SELECT [dbo].udf_getProductID('Weber State University Rain Poncho');
SELECT [dbo].udf_getProductID('Panamax - 11-Outlet Surge Protector - Black');
SELECT [dbo].udf_getProductID('CORSAIR - Vengeance LPX 32GB (2PK x 16GB) 2.6 GHz DDR4 DRAM Desktop Memory Kit - Black');
SELECT [dbo].udf_getProductID('Black Weber State University Women''s Hooded Sweatshirt ');

SELECT [dbo].udf_getProductID('M2 Max Macbook-Pro 14in');

--udf_getOrderTableId
SELECT [dbo].udf_getOrderTableId('01/20/2023  4:24:00 AM', 'dominque.dickerson@dickerson.org');
SELECT [dbo].udf_getOrderTableId('02/24/2023  8:14:00 AM', 'brhym@rhym.com');
SELECT [dbo].udf_getOrderTableId('2023-01-21 05:37 PM', 'kristel.ehmann@aol.com');
SELECT [dbo].udf_getOrderTableId('2023-01-17 09:10 AM', 'badkin@hotmail.com');

SELECT [dbo].udf_getOrderTableId('02/22/2024', 'ColetonWattt@weber.edu');

GO
			