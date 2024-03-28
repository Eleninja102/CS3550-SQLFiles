---- Shopping Database Creation Script
-- CS 3550
--Coleton Watt
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
	, quanityOnHand INT NOT NULL
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
	, quanity SMALLINT NOT NULL
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
			(SELECT sdSupplier_id FROM Supplier WHERE supplierName = @supplierName)
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
			(SELECT sdCustomer_id FROM CUSTOMER WHERE customerEmailAddress = @customerEmailAddress) 
			, (SELECT CONVERT (DATETIME, @orderDateTime))
			, (SELECT CONVERT (SMALLMONEY, @subTotal))
			, (SELECT CONVERT (SMALLMONEY, @taxAmount))
			, (SELECT CONVERT (SMALLMONEY, @shippingCost))
			, (SELECT CONVERT (SMALLMONEY, @orderTotal))
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
		INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) 
		VALUES(
			(SELECT sdVendor_id FROM Vendor WHERE vendorName = @vendorName)
			, (SELECT sdProduct_id FROM Product WHERE productName = @productName)
			, (SELECT CONVERT (INT, @quantityOnHand))
			, (SELECT CONVERT (SMALLMONEY, @vendorProductPrice))
		);
	END TRY
	
	BEGIN CATCH
		PRINT 'The Insert into VENDOR PRODUCT failed for:
		vendorName: ' + @vendorName
		+ ', productName: ' + @productName
		+ ', quanityOnHand: ' + @quantityOnHand
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
		INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) 
		VALUES(
			(SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, @orderDateTime)) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  @customerEmailAddress))
			, (SELECT sdProduct_id FROM Product WHERE productName = @productName)
			, (SELECT sdVendor_id FROM Vendor WHERE vendorName =@vendorName)
			, (SELECT CONVERT (INT, @quantity))
		);
	END TRY
			
	BEGIN CATCH
		PRINT 'The Insert into ITEM ORDER failed for:
		vendorName: ' + @vendorName
		+ ', customerEmailAddress: ' + @customerEmailAddress
		+ ', orderDateTime: ' + @orderDateTime
		+ ', productName: ' + @productName
		+ ', quanity: ' + @quantity
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
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'info@eaglesoftwareinc.com', @vendorPhone = '7705078791', @vendorName = 'Eagle Software Inc', @vendorStreetAddress = '5384 Southwyck Blvd', @vendorCity = 'Douglasville', @vendorState = 'GA', @vendorZip = '30135';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@artcrafters.com', @vendorPhone = '3056709628', @vendorName = 'Art Crafters', @vendorStreetAddress = '703 Beville Rd', @vendorCity = 'Opa Locka', @vendorState = 'FL', @vendorZip = '33054';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'helpdesk@burtondavis.com', @vendorPhone = '8188644875', @vendorName = 'Burton & Davis', @vendorStreetAddress = '70 Mechanic St', @vendorCity = 'Northridge', @vendorState = 'CA', @vendorZip = '91325';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'info@jetscybernetics.com', @vendorPhone = '2144282285', @vendorName = 'Jets Cybernetics', @vendorStreetAddress = '99586 Main St', @vendorCity = 'Dallas', @vendorState = 'TX', @vendorZip = '75207';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'inquiry@professionalsunlimited.com', @vendorPhone = '3073427795', @vendorName = 'Professionals Unlimited', @vendorStreetAddress = '66697 Park Pl #3224', @vendorCity = 'Riverton', @vendorState = 'WY', @vendorZip = '82501';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'help@linguisticsystemsinc.com', @vendorPhone = '6092285265', @vendorName = 'Linguistic Systems Inc', @vendorStreetAddress = '506 S Hacienda Dr', @vendorCity = 'Atlantic City', @vendorState = 'NJ', @vendorZip = '08401';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@pricebusinessservices.com', @vendorPhone = '8472221734', @vendorName = 'Price Business Services', @vendorStreetAddress = '7 West Ave #1', @vendorCity = 'Palatine', @vendorState = 'IL', @vendorZip = '60067';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'support@mitsumielectronicscorp.com', @vendorPhone = '8045505097', @vendorName = 'Mitsumi Electronics Corp', @vendorStreetAddress = '9677 Commerce Dr', @vendorCity = 'Richmond', @vendorState = 'VA', @vendorZip = '23219';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'helpdesk@sidewinderproductscorp.com', @vendorPhone = '7178093119', @vendorName = 'Sidewinder Products Corp', @vendorStreetAddress = '8573 Lincoln Blvd', @vendorCity = 'York', @vendorState = 'PA', @vendorZip = '17404';
EXECUTE dbo.usp_addVendor @vendorEmailAddress = 'answers@circuitsolutioninc.com', @vendorPhone = '4154111775', @vendorName = 'Circuit Solution Inc', @vendorStreetAddress = '39 Moccasin Dr', @vendorCity = 'San Francisco', @vendorState = 'CA', @vendorZip = '94104';
GO
-----
-- Enter Supplier Table Data
-----
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
EXECUTE dbo.usp_addProduct @supplierName = 'Printing Dimensions', @productName = 'White Weber State University Women''s Tank Top';
EXECUTE dbo.usp_addProduct @supplierName = 'Franklin Peters Inc', @productName = 'Black Weber State University Women''s Hooded Sweatshirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Knwz Products', @productName = 'Steel Grey Weber State University Women''s Cropped Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Lowy Products and Service', @productName = 'Yellow Weber State University 16 oz. Tumbler';
EXECUTE dbo.usp_addProduct @supplierName = 'Warehouse Office & Paper Prod', @productName = 'Weber State University Academic Year Planner';
EXECUTE dbo.usp_addProduct @supplierName = 'Smits, Patricia Garity', @productName = 'White Weber State University Orbiter Pen';
EXECUTE dbo.usp_addProduct @supplierName = 'Mark Iv Press', @productName = 'Silver Weber State University Wildcats Keytag';
EXECUTE dbo.usp_addProduct @supplierName = 'Acme Supply Co', @productName = 'Silver Weber State University Money Clip';
EXECUTE dbo.usp_addProduct @supplierName = 'United Product Lines', @productName = 'Weber State University Rain Poncho';
EXECUTE dbo.usp_addProduct @supplierName = 'Franklin Peters Inc', @productName = 'Weber State University Crew Neck Sweatshirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Birite Foodservice', @productName = 'Weber State University Lip Balm';
EXECUTE dbo.usp_addProduct @supplierName = 'Harris Corporation', @productName = 'Weber State University Alumni T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Armon Communications', @productName = 'Weber State University Dad Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Tipiak Inc', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Sportmaster International', @productName = 'Weber State University Wildcats Rambler 20 oz. Tumbler';
EXECUTE dbo.usp_addProduct @supplierName = 'E A I Electronic Assocs Inc', @productName = 'Weber State University OtterBox iPhone 7/8 Symmetry Series Case';
EXECUTE dbo.usp_addProduct @supplierName = 'Warehouse Office & Paper Prod', @productName = 'Weber State University Wildcats State Decal';
EXECUTE dbo.usp_addProduct @supplierName = 'Printing Dimensions', @productName = 'Weber State University Mom Decal';
EXECUTE dbo.usp_addProduct @supplierName = 'Printing Dimensions', @productName = 'Weber State University Wildcats Decal';
EXECUTE dbo.usp_addProduct @supplierName = 'United Product Lines', @productName = 'Weber State University Putter Cover';
EXECUTE dbo.usp_addProduct @supplierName = 'Franklin Peters Inc', @productName = 'Weber State University Jersey';
EXECUTE dbo.usp_addProduct @supplierName = 'Smits, Patricia Garity', @productName = 'Weber State University Crew Socks';
EXECUTE dbo.usp_addProduct @supplierName = 'Acme Supply Co', @productName = 'Weber State University Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Grace Pastries Inc', @productName = 'Weber State University .75L Camelbak Bottle';
EXECUTE dbo.usp_addProduct @supplierName = 'Knwz Products', @productName = 'Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt';
EXECUTE dbo.usp_addProduct @supplierName = 'Roberts Supply Co Inc', @productName = 'Weber State University Coaches Hat';
GO
---
-- Enter Order Table Data
---
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
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Eagle Software Inc', @productName ='Black Weber State University Women''s Hooded Sweatshirt', @quantityOnHand = 10,  @vendorProductPrice = 48;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Art Crafters', @productName ='Yellow Weber State University 16 oz. Tumbler', @quantityOnHand = 10,  @vendorProductPrice = 42;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='Weber State University Rain Poncho', @quantityOnHand = 10,  @vendorProductPrice = 5.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Jets Cybernetics', @productName ='Weber State University Alumni T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Weber State University Volleyball Short Sleeve T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Linguistic Systems Inc', @productName ='Weber State University Wildcats State Decal', @quantityOnHand = 10,  @vendorProductPrice = 6.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Price Business Services', @productName ='Weber State University Putter Cover', @quantityOnHand = 10,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mitsumi Electronics Corp', @productName ='Weber State University Crew Socks', @quantityOnHand = 10,  @vendorProductPrice = 18;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sidewinder Products Corp', @productName ='Weber State University Short Sleeve T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 30;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Circuit Solution Inc', @productName ='Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 15.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Eagle Software Inc', @productName ='Weber State University Coaches Hat', @quantityOnHand = 10,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Art Crafters', @productName ='Black Weber State University Women''s Hooded Sweatshirt', @quantityOnHand = 10,  @vendorProductPrice = 48;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='Yellow Weber State University 16 oz. Tumbler', @quantityOnHand = 10,  @vendorProductPrice = 42;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Jets Cybernetics', @productName ='Weber State University Rain Poncho', @quantityOnHand = 10,  @vendorProductPrice = 5.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Weber State University Alumni T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Linguistic Systems Inc', @productName ='Weber State University Volleyball Short Sleeve T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Price Business Services', @productName ='Weber State University Wildcats State Decal', @quantityOnHand = 10,  @vendorProductPrice = 6.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mitsumi Electronics Corp', @productName ='Weber State University Putter Cover', @quantityOnHand = 10,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sidewinder Products Corp', @productName ='Weber State University Crew Socks', @quantityOnHand = 10,  @vendorProductPrice = 18;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Circuit Solution Inc', @productName ='Weber State University Short Sleeve T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 30;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Eagle Software Inc', @productName ='Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 15.99;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Art Crafters', @productName ='Weber State University Coaches Hat', @quantityOnHand = 10,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Burton & Davis', @productName ='Black Weber State University Women''s Hooded Sweatshirt', @quantityOnHand = 10,  @vendorProductPrice = 48;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Jets Cybernetics', @productName ='Yellow Weber State University 16 oz. Tumbler', @quantityOnHand = 10,  @vendorProductPrice = 42;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Professionals Unlimited', @productName ='Weber State University Rain Poncho', @quantityOnHand = 10,  @vendorProductPrice = 5.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Linguistic Systems Inc', @productName ='Weber State University Alumni T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Price Business Services', @productName ='Weber State University Volleyball Short Sleeve T-Shirt', @quantityOnHand = 10,  @vendorProductPrice = 19.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Mitsumi Electronics Corp', @productName ='Weber State University Wildcats State Decal', @quantityOnHand = 10,  @vendorProductPrice = 6.95;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Sidewinder Products Corp', @productName ='Weber State University Putter Cover', @quantityOnHand = 10,  @vendorProductPrice = 25;
EXECUTE dbo.usp_addVendorProductItem @vendorName = 'Circuit Solution Inc', @productName ='Weber State University Crew Socks', @quantityOnHand = 10,  @vendorProductPrice = 18;
GO
-----
-- Enter Order Item Table Data
-----
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/14/2023  7:18:00 AM', @customerEmailAddress = 'donette.foller@cox.net', @productName = 'Black Weber State University Women''s Hooded Sweatshirt', @vendorName ='Eagle Software Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/14/2023  7:18:00 AM', @customerEmailAddress = 'donette.foller@cox.net', @productName = 'Weber State University Rain Poncho', @vendorName ='Burton & Davis', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/18/2023  5:54:00 AM', @customerEmailAddress = 'mroyster@royster.com', @productName = 'Weber State University Rain Poncho', @vendorName ='Jets Cybernetics', @quantity = 4;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/18/2023  5:54:00 AM', @customerEmailAddress = 'mroyster@royster.com', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt', @vendorName ='Linguistic Systems Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/19/2023  10:03:00 AM', @customerEmailAddress = 'ernie_stenseth@aol.com', @productName = 'Black Weber State University Women''s Hooded Sweatshirt', @vendorName ='Burton & Davis', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/19/2023  10:03:00 AM', @customerEmailAddress = 'ernie_stenseth@aol.com', @productName = 'Weber State University Rain Poncho', @vendorName ='Professionals Unlimited', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/21/2023  8:26:00 AM', @customerEmailAddress = 'jina_briddick@briddick.com', @productName = 'Weber State University Putter Cover', @vendorName ='Sidewinder Products Corp', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/21/2023  8:26:00 AM', @customerEmailAddress = 'jina_briddick@briddick.com', @productName = 'Weber State University Crew Socks', @vendorName ='Circuit Solution Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/21/2023  8:26:00 AM', @customerEmailAddress = 'jina_briddick@briddick.com', @productName = 'Weber State University Coaches Hat', @vendorName ='Eagle Software Inc', @quantity = 3;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/14/2023  9:16:00 AM', @customerEmailAddress = 'sabra@uyetake.org', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt', @vendorName ='Price Business Services', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/14/2023  9:16:00 AM', @customerEmailAddress = 'sabra@uyetake.org', @productName = 'Weber State University Wildcats State Decal', @vendorName ='Mitsumi Electronics Corp', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/24/2023  8:14:00 AM', @customerEmailAddress = 'brhym@rhym.com', @productName = 'Weber State University Rain Poncho', @vendorName ='Burton & Davis', @quantity = 4;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/24/2023  8:14:00 AM', @customerEmailAddress = 'brhym@rhym.com', @productName = 'Weber State University Putter Cover', @vendorName ='Sidewinder Products Corp', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/03/2023  8:49:00 PM', @customerEmailAddress = 'viva.toelkes@gmail.com', @productName = 'Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt', @vendorName ='Eagle Software Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/03/2023  8:49:00 PM', @customerEmailAddress = 'viva.toelkes@gmail.com', @productName = 'Black Weber State University Women''s Hooded Sweatshirt', @vendorName ='Art Crafters', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/17/2023  10:36:00 AM', @customerEmailAddress = 'dominque.dickerson@dickerson.org', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt', @vendorName ='Linguistic Systems Inc', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/16/2023  1:54:00 AM', @customerEmailAddress = 'latrice.tolfree@hotmail.com', @productName = 'Weber State University Crew Socks', @vendorName ='Circuit Solution Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '02/16/2023  1:54:00 AM', @customerEmailAddress = 'latrice.tolfree@hotmail.com', @productName = 'Weber State University Rain Poncho', @vendorName ='Professionals Unlimited', @quantity = 4;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/24/2023  2:50:00 AM', @customerEmailAddress = 'stephaine@cox.net', @productName = 'Black Weber State University Women''s Hooded Sweatshirt', @vendorName ='Eagle Software Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/8/2023  10:28:00 PM', @customerEmailAddress = 'ernie_stenseth@aol.com', @productName = 'Weber State University Rain Poncho', @vendorName ='Jets Cybernetics', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/08/2023  10:28:00 PM', @customerEmailAddress = 'ernie_stenseth@aol.com', @productName = 'Weber State University Volleyball Short Sleeve T-Shirt', @vendorName ='Linguistic Systems Inc', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/20/2023  4:24:00 AM', @customerEmailAddress = 'dominque.dickerson@dickerson.org', @productName = 'Weber State University Rain Poncho', @vendorName ='Burton & Davis', @quantity = 1;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/20/2023  4:24:00 AM', @customerEmailAddress = 'dominque.dickerson@dickerson.org', @productName = 'Weber State University Putter Cover', @vendorName ='Price Business Services', @quantity = 2;
EXECUTE dbo.usp_addItemToOrder @orderDateTime = '01/20/2023  4:24:00 AM', @customerEmailAddress = 'dominque.dickerson@dickerson.org', @productName = 'Weber State University Coaches Hat', @vendorName ='Eagle Software Inc', @quantity = 1;

GO
-----
--Print Table
-----


SELECT 'This is table' AS "Customer";
SELECT * FROM Customer;

SELECT 'This is Table' AS "Supplier";
SELECT * FROM Supplier;

SELECT 'This is Table' AS "Vendor";
SELECT * FROM Vendor;

SELECT 'This is Table' AS "Product";
SELECT * FROM Product;

SELECT 'This is table' AS "OrderTable";
SELECT * FROM OrderTable;
	
SELECT 'This is table' AS "OrderItem";
SELECT * FROM OrderItem;

SELECT 'This is Table' AS "VendorProduct";
SELECT * FROM VendorProduct;


GO
