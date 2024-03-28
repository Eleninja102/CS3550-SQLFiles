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
-- Insert Data Into tables
-------------------------------------------

-----
--Customer
-----

INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('donette.foller@cox.net','Donette','Foller', '34 Center St','Hamilton','OH','45011');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('mroyster@royster.com','Maryann','Royster', '74 S Westgate St','Albany','NY','12204');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('ernie_stenseth@aol.com','Ernie','Stenseth', '45 E Liberty St','Ridgefield Park','NJ','07660');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('jina_briddick@briddick.com','Jina','Briddick', '38938 Park Blvd','Boston','MA','02128');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('sabra@uyetake.org','Sabra','Uyetake', '98839 Hawthorne Blvd #6101','Columbia','SC','29201');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('brhym@rhym.com','Bobbye','Rhym', '30 W 80th St #1995','San Carlos','CA','94070');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('viva.toelkes@gmail.com','Viva','Toelkes', '4284 Dorigo Ln','Chicago','IL','60647');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('dominque.dickerson@dickerson.org','Dominque','Dickerson', '69 Marquette Ave','Hayward','CA','94545');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('latrice.tolfree@hotmail.com','Latrice','Tolfree', '81 Norris Ave #525','Ronkonkoma','NY','11779');
INSERT INTO customer(customerEmailAddress,customerFirstName,customerLastName, customerStreetAddress, customerCity, customerState, customerZip) VALUES('stephaine@cox.net','Stephaine','Vinning', '3717 Hamann Industrial Pky','San Francisco','CA','94104');



-- =CONCATENATE("INSERT INTO Customer
-- (
-- 	customerEmailAddress
-- 	, customerFirstName 
-- 	, customerLastName
-- 	, customerStreetAddress
-- 	, customerCity
-- 	, customerState
-- 	, customerZip
-- )
-- VALUES ('",C2,"' , '",A2,"' , '",B2,"' , '",D2,"' , '",E2,"' , '",F2,"' , '",G2,"');")



--="INSERT INTO customer(`"&$A$1&"`,`"&$B$1&"`,`"&$C$1&"`, `"&$D$1&"`, `"&$E$1&"`, `"&F$1&"`, `"&$G$1&"`) VALUES('"&SUBSTITUTE(A2, "'", "\'")&"','"&SUBSTITUTE(B2, "'", "\'")&"','"&SUBSTITUTE(C2, "'", "\'")&"', '"&SUBSTITUTE(D2, "'", "\'")&"','"&SUBSTITUTE(E2, "'", "\'")&"','"&SUBSTITUTE(F2, "'", "\'")&"','"&SUBSTITUTE(G2, "'", "\'")&"');"
--="INSERT INTO customer(`"&$A$1&"`,`"&$B$1&"`,`"&$C$1&"`, `"&$D$1&"`, `"&$E$1&"`, `"&F$1&"`, `"&$G$1&"`) VALUES('"&SUBSTITUTE(A2, "'", "\'")&"','"&SUBSTITUTE(B2, "'", "\'")&"','"&SUBSTITUTE(C2, "'", "\'")&"', '"&SUBSTITUTE(D2, "'", "\'")&"','"&SUBSTITUTE(E2, "'", "\'")&"','"&SUBSTITUTE(F2, "'", "\'")&"','"&SUBSTITUTE(G2, "'", "\'")&"',);"





--SELECT Convert(datetime, 'Jan 29 2023 11:05 PM');
--SELECT CONVERT(SMALLMONEY, '24.00')
--="INSERT INTO vendor("&$A$1&","&$B$1&","&$C$1&", "&$D$1&", "&$E$1&", "&F$1&", "&$G$1&") VALUES('"&SUBSTITUTE(A2, "'", "\'")&"','"&SUBSTITUTE(B2, "'", "\'")&"','"&SUBSTITUTE(C2, "'", "\'")&"', '"&SUBSTITUTE(D2, "'", "\'")&"','"&SUBSTITUTE(E2, "'", "\'")&"','"&SUBSTITUTE(F2, "'", "\'")&"','"&SUBSTITUTE(G2, "'", "\'")&"');"


---
--Vendor
---
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('info@eaglesoftwareinc.com','7705078791','Eagle Software Inc', '5384 Southwyck Blvd','Douglasville','GA','30135');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('support@artcrafters.com','3056709628','Art Crafters', '703 Beville Rd','Opa Locka','FL','33054');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('helpdesk@burtondavis.com','8188644875','Burton & Davis', '70 Mechanic St','Northridge','CA','91325');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('info@jetscybernetics.com','2144282285','Jets Cybernetics', '99586 Main St','Dallas','TX','75207');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('inquiry@professionalsunlimited.com','3073427795','Professionals Unlimited', '66697 Park Pl #3224','Riverton','WY','82501');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('help@linguisticsystemsinc.com','6092285265','Linguistic Systems Inc', '506 S Hacienda Dr','Atlantic City','NJ','08401');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('support@pricebusinessservices.com','8472221734','Price Business Services', '7 West Ave #1','Palatine','IL','60067');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('support@mitsumielectronicscorp.com','8045505097','Mitsumi Electronics Corp', '9677 Commerce Dr','Richmond','VA','23219');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('helpdesk@sidewinderproductscorp.com','7178093119','Sidewinder Products Corp', '8573 Lincoln Blvd','York','PA','17404');
INSERT INTO vendor(vendorEmailAddress,vendorPhone,vendorName, vendorStreetAddress, vendorCity, vendorState, vendorZip) VALUES('answers@circuitsolutioninc.com','4154111775','Circuit Solution Inc', '39 Moccasin Dr','San Francisco','CA','94104');

---
--Supplier
---
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Printing Dimensions','34 Center St','Hamilton', 'OH','45011');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Franklin Peters Inc','74 S Westgate St','Albany', 'NY','12204');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Knwz Products','45 E Liberty St','Ridgefield Park', 'NJ','07660');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Grace Pastries Inc','38938 Park Blvd','Boston', 'MA','02128');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Lowy Products and Service','98839 Hawthorne Blvd #6101','Columbia', 'SC','29201');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Smits, Patricia Garity','30 W 80th St #1995','San Carlos', 'CA','94070');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Mark Iv Press','4284 Dorigo Ln','Chicago', 'IL','60647');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('E A I Electronic Assocs Inc','69 Marquette Ave','Hayward', 'CA','94545');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('United Product Lines','81 Norris Ave #525','Ronkonkoma', 'NY','11779');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Birite Foodservice','3717 Hamann Industrial Pky','San Francisco', 'CA','94104');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Roberts Supply Co Inc','8429 Miller Rd','Pelham', 'NY','10803');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Harris Corporation','4 Iwaena St','Baltimore', 'MD','21202');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Armon Communications','9 State Highway 57 #22','Jersey City', 'NJ','07306');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Tipiak Inc','80312 W 32nd St','Conroe', 'TX','77301');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Sportmaster International','6 Sunrise Ave','Utica', 'NY','13501');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Acme Supply Co','1953 Telegraph Rd','Saint Joseph', 'MO','64504');
INSERT INTO supplier(supplierName,supplierStreetAddress,supplierCity, supplierState, supplierZip) VALUES('Warehouse Office & Paper Prod','61556 W 20th Ave','Seattle', 'WA','98104');

---
--Product
---
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Printing Dimensions'),'White Weber State University Women''s Tank Top');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Franklin Peters Inc'),'Black Weber State University Women''s Hooded Sweatshirt');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Knwz Products'),'Steel Grey Weber State University Women''s Cropped Short Sleeve T-Shirt');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Lowy Products and Service'),'Yellow Weber State University 16 oz. Tumbler');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Warehouse Office & Paper Prod'),'Weber State University Academic Year Planner');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Smits, Patricia Garity'),'White Weber State University Orbiter Pen');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Mark Iv Press'),'Silver Weber State University Wildcats Keytag');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Acme Supply Co'),'Silver Weber State University Money Clip');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='United Product Lines'),'Weber State University Rain Poncho');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Franklin Peters Inc'),'Weber State University Crew Neck Sweatshirt');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Birite Foodservice'),'Weber State University Lip Balm');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Harris Corporation'),'Weber State University Alumni T-Shirt');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Armon Communications'),'Weber State University Dad Short Sleeve T-Shirt');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Tipiak Inc'),'Weber State University Volleyball Short Sleeve T-Shirt');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Sportmaster International'),'Weber State University Wildcats Rambler 20 oz. Tumbler');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='E A I Electronic Assocs Inc'),'Weber State University OtterBox iPhone 7/8 Symmetry Series Case');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Warehouse Office & Paper Prod'),'Weber State University Wildcats State Decal');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Printing Dimensions'),'Weber State University Mom Decal');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Printing Dimensions'),'Weber State University Wildcats Decal');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='United Product Lines'),'Weber State University Putter Cover');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Franklin Peters Inc'),'Weber State University Jersey');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Smits, Patricia Garity'),'Weber State University Crew Socks');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Acme Supply Co'),'Weber State University Short Sleeve T-Shirt');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Grace Pastries Inc'),'Weber State University .75L Camelbak Bottle');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Knwz Products'),'Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt');
INSERT INTO product(sdSupplier_id, productName) VALUES((SELECT sdSupplier_id FROM Supplier WHERE supplierName ='Roberts Supply Co Inc'),'Weber State University Coaches Hat');

---
--Order Table
---
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='donette.foller@cox.net'), (SELECT CONVERT(datetime, '02/14/2023  7:18:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='mroyster@royster.com'), (SELECT CONVERT(datetime, '02/18/2023  5:54:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='ernie_stenseth@aol.com'), (SELECT CONVERT(datetime, '01/19/2023  10:03:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='jina_briddick@briddick.com'), (SELECT CONVERT(datetime, '01/21/2023  8:26:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='sabra@uyetake.org'), (SELECT CONVERT(datetime, '01/14/2023  9:16:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='brhym@rhym.com'), (SELECT CONVERT(datetime, '02/24/2023  8:14:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='viva.toelkes@gmail.com'), (SELECT CONVERT(datetime, '01/03/2023  8:49:00 PM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='dominque.dickerson@dickerson.org'), (SELECT CONVERT(datetime, '02/17/2023  10:36:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='latrice.tolfree@hotmail.com'), (SELECT CONVERT(datetime, '02/16/2023  1:54:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='stephaine@cox.net'), (SELECT CONVERT(datetime, '01/24/2023  2:50:00 AM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='ernie_stenseth@aol.com'), (SELECT CONVERT(datetime, '01/8/2023  10:28:00 PM')),NULL, NULL, NULL, NULL);
INSERT INTO orderTable(sdCustomer_id, orderDateTime, subTotal, taxAmount, shippingCost, orderTotal) VALUES((SELECT sdCustomer_id FROM Customer WHERE customerEmailAddress ='dominque.dickerson@dickerson.org'), (SELECT CONVERT(datetime, '01/20/2023  4:24:00 AM')),NULL, NULL, NULL, NULL);

---
--Vendor Product
---
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Eagle Software Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Black Weber State University Women''s Hooded Sweatshirt'), 48,  822);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Art Crafters'), (SELECT sdProduct_id FROM Product WHERE productName ='Yellow Weber State University 16 oz. Tumbler'), 42,  599);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Burton & Davis'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), 5.95,  225);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Jets Cybernetics'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Alumni T-Shirt'), 19.95,  862);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Professionals Unlimited'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Volleyball Short Sleeve T-Shirt'), 19.95,  182);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Linguistic Systems Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Wildcats State Decal'), 6.95,  630);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Price Business Services'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Putter Cover'), 25,  359);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Mitsumi Electronics Corp'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Crew Socks'), 18,  406);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Sidewinder Products Corp'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Short Sleeve T-Shirt'), 30,  651);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Circuit Solution Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt'), 15.99,  116);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Eagle Software Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Coaches Hat'), 25,  610);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Art Crafters'), (SELECT sdProduct_id FROM Product WHERE productName ='Black Weber State University Women''s Hooded Sweatshirt'), 48,  674);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Burton & Davis'), (SELECT sdProduct_id FROM Product WHERE productName ='Yellow Weber State University 16 oz. Tumbler'), 42,  344);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Jets Cybernetics'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), 5.95,  635);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Professionals Unlimited'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Alumni T-Shirt'), 19.95,  901);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Linguistic Systems Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Volleyball Short Sleeve T-Shirt'), 19.95,  368);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Price Business Services'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Wildcats State Decal'), 6.95,  817);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Mitsumi Electronics Corp'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Putter Cover'), 25,  794);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Sidewinder Products Corp'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Crew Socks'), 18,  197);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Circuit Solution Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Short Sleeve T-Shirt'), 30,  162);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Eagle Software Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt'), 15.99,  546);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Art Crafters'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Coaches Hat'), 25,  512);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Burton & Davis'), (SELECT sdProduct_id FROM Product WHERE productName ='Black Weber State University Women''s Hooded Sweatshirt'), 48,  684);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Jets Cybernetics'), (SELECT sdProduct_id FROM Product WHERE productName ='Yellow Weber State University 16 oz. Tumbler'), 42,  544);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Professionals Unlimited'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), 5.95,  122);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Linguistic Systems Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Alumni T-Shirt'), 19.95,  334);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Price Business Services'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Volleyball Short Sleeve T-Shirt'), 19.95,  475);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Mitsumi Electronics Corp'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Wildcats State Decal'), 6.95,  399);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Sidewinder Products Corp'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Putter Cover'), 25,  211);
INSERT INTO vendorProduct(sdVendor_id, sdProduct_id, quanityOnHand, vendorProductPrice) VALUES( (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Circuit Solution Inc'), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Crew Socks'), 18,  505);

---
-- Order Item
---
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/14/2023  7:18:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'donette.foller@cox.net')), (SELECT sdProduct_id FROM Product WHERE productName ='Black Weber State University Women''s Hooded Sweatshirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Eagle Software Inc'),1);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/14/2023  7:18:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'donette.foller@cox.net')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Burton & Davis'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/18/2023  5:54:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'mroyster@royster.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Jets Cybernetics'),4);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/18/2023  5:54:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'mroyster@royster.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Volleyball Short Sleeve T-Shirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Linguistic Systems Inc'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/19/2023  10:03:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'ernie_stenseth@aol.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Black Weber State University Women''s Hooded Sweatshirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Burton & Davis'),1);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/19/2023  10:03:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'ernie_stenseth@aol.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Professionals Unlimited'),3);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/21/2023  8:26:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'jina_briddick@briddick.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Putter Cover'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Sidewinder Products Corp'),3);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/21/2023  8:26:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'jina_briddick@briddick.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Crew Socks'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Circuit Solution Inc'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/21/2023  8:26:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'jina_briddick@briddick.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Coaches Hat'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Eagle Software Inc'),3);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/14/2023  9:16:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'sabra@uyetake.org')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Volleyball Short Sleeve T-Shirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Price Business Services'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/14/2023  9:16:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'sabra@uyetake.org')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Wildcats State Decal'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Mitsumi Electronics Corp'),1);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/24/2023  8:14:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'brhym@rhym.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Burton & Davis'),4);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/24/2023  8:14:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'brhym@rhym.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Putter Cover'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Sidewinder Products Corp'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/03/2023  8:49:00 PM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'viva.toelkes@gmail.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Boys'' Tri-Blend Short Sleeve T-Shirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Eagle Software Inc'),1);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/03/2023  8:49:00 PM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'viva.toelkes@gmail.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Black Weber State University Women''s Hooded Sweatshirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Art Crafters'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/17/2023  10:36:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'dominque.dickerson@dickerson.org')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Volleyball Short Sleeve T-Shirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Linguistic Systems Inc'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/16/2023  1:54:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'latrice.tolfree@hotmail.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Crew Socks'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Circuit Solution Inc'),1);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '02/16/2023  1:54:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'latrice.tolfree@hotmail.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Professionals Unlimited'),4);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/24/2023  2:50:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'stephaine@cox.net')), (SELECT sdProduct_id FROM Product WHERE productName ='Black Weber State University Women''s Hooded Sweatshirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Eagle Software Inc'),1);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/8/2023  10:28:00 PM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'ernie_stenseth@aol.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Jets Cybernetics'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/08/2023  10:28:00 PM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'ernie_stenseth@aol.com')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Volleyball Short Sleeve T-Shirt'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Linguistic Systems Inc'),1);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/20/2023  4:24:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'dominque.dickerson@dickerson.org')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Rain Poncho'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Burton & Davis'),1);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/20/2023  4:24:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'dominque.dickerson@dickerson.org')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Putter Cover'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Price Business Services'),2);
INSERT INTO orderItem(sdOrderTable_id, sdProduct_id, sdVendor_id, quanity) VALUES( (SELECT sdOrderTable_id FROM orderTable WHERE orderDateTime = (SELECT CONVERT(dateTime, '01/20/2023  4:24:00 AM')) AND sdCustomer_id = (SELECT sdCustomer_id FROM customer WHERE customerEmailAddress =  'dominque.dickerson@dickerson.org')), (SELECT sdProduct_id FROM Product WHERE productName ='Weber State University Coaches Hat'), (SELECT sdVendor_id FROM Vendor WHERE vendorName ='Eagle Software Inc'),1);

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

