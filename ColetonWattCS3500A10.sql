/* Coleton Watt*/

/*1. Show the first and last name
, address
, city and state
, email address
, phone number 
and phone type of people from the following cities
Yakima Washington, Birmingham England, Columbus Ohio, Cambridge England and Burbank California. 
Arrange the list alphabetically by city then last name then first name (351 rows returned)*/

SELECT pp.FirstName, pp.LastName, pa.AddressLine1, pa.City, psp.Name AS 'State',  EmailAddress, PhoneNumber , ppnt.Name AS 'Phone Type'
FROM Person.Person pp 
INNER JOIN Person.BusinessEntity pbe
ON pp.BusinessEntityID = pbe.BusinessEntityID
INNER JOIN Person.BusinessEntityAddress pbea
ON pbea.BusinessEntityID = pbe.BusinessEntityID
INNER JOIN Person.[Address] pa
ON pa.AddressID = pbea.AddressID
INNER JOIN Person.StateProvince psp
ON psp.StateProvinceID = pa.StateProvinceID
INNER JOIN Person.EmailAddress pea
ON pea.BusinessEntityID = pp.BusinessEntityID
INNER JOIN Person.PersonPhone ppp
ON ppp.BusinessEntityID = pp.BusinessEntityID
INNER JOIN Person.PhoneNumberType ppnt
ON ppnt.PhoneNumberTypeID = ppp.PhoneNumberTypeID


WHERE (pa.city = 'Yakima' and psp.Name = 'Washington')
OR	(pa.city = 'Birmingham' and psp.Name = 'England')
OR	(pa.city = 'Columbus' and psp.Name = 'Ohio')
OR	(pa.city = 'Cambridge' and psp.Name = 'England')
OR	(pa.city = 'Burbank' and psp.Name = 'California')

ORDER BY pa.City, pp.LastName, pp.FirstName ;

 --2. Show the first and last names of the employees, their job title, 
 --their birth date formatted as three character month two digit day four digit year 
 --and shift name. 
 --Arrange the list by job title, last name then first name (296 rows returned)
SELECT pp.FirstName, pp.LastName, pp.PersonType, FORMAT(hre.BirthDate, 'MMM dd yyyy') AS BirthDate, Shift.Name AS 'Shift Type'
FROM Person.Person pp
INNER JOIN HumanResources.Employee hre
ON hre.BusinessEntityID = pp.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.Shift
ON HumanResources.EmployeeDepartmentHistory.ShiftID = HumanResources.Shift.ShiftID

ORDER BY pp.PersonType, LastName, FirstName;


--3. Show the names of the vendors 
--and the products that they manufacture 
--for those vendors who manufacture pedals. 
--Order the list by vendors then by product name (11 rows returned)

SELECT Vendor.Name AS 'Vendor Name', Product.Name AS 'Products Name'
FROM Purchasing.Vendor
INNER JOIN Purchasing.ProductVendor
ON Purchasing.ProductVendor.BusinessEntityID = Purchasing.Vendor.BusinessEntityID
INNER JOIN Production.Product
ON Purchasing.ProductVendor.ProductID = Production.Product.ProductID
INNER JOIN Production.ProductSubcategory
ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID

WHERE ProductSubcategory.Name = 'Pedals'

ORDER BY Vendor.Name, Product.Name;

/* 4. Show the product name, 
standard cost, 
list price, 
quantity and 
location name 
for products whose list price is greater than zero
and located in Final Assembly
where the quantity is between 200 and 500. 
Arrange the list by standard cost then quantity(13 rows returned)
*/
SELECT Product.Name AS 'Product Name', Product.StandardCost, Product.ListPrice, ProductInventory.Quantity, Location.Name AS 'Location Name'
FROM Production.Product
INNER JOIN Production.ProductInventory
ON Production.ProductInventory.ProductID = Production.Product.ProductID
INNER JOIN Production.Location
ON 	Production.ProductInventory.LocationID = Production.Location.LocationID	

WHERE Product.ListPrice > 0
AND ProductInventory.Quantity BETWEEN 200 AND 500
AND Location.Name = 'Final Assembly'

ORDER BY StandardCost, Quantity;

/*
 5. Show the products that have been scrapped 
 and the reason they were 
 scrapped problem with the drill size. 

 Arrange the list by product then reason (86 rows returned)
*/

SELECT Product.Name AS 'Product Name', ScrapReason.Name AS 'Scrap Reason'
FROM Production.Product
INNER JOIN Production.WorkOrder
ON Production.WorkOrder.ProductID = Production.Product.ProductID
INNER JOIN Production.ScrapReason 
ON Production.WorkOrder.ScrapReasonID = Production.ScrapReason.ScrapReasonID

WHERE ScrapReason.Name LIKE '%drill size%'

ORDER BY Product.Name, ScrapReason.Name;

/*
 6.  Show the vendor name
 , the product name
 , the ship date
 , the difference between the order quantity and the received quantity for those products where the received quantity was at least 50 less than the order quantity. 
 Show the difference. 
 Arrange the list by the greatest difference. (209 rows returned)
*/
SELECT 
	Vendor.Name As 'Vendor Name'
	, Product.Name AS 'Product Name'
	, PurchaseOrderHeader.ShipDate
	--, PurchaseOrderDetail.OrderQty
	--, PurchaseOrderDetail.ReceivedQty
	, PurchaseOrderDetail.OrderQty-PurchaseOrderDetail.ReceivedQty AS 'Quantity Difference'
FROM Production.Product
INNER JOIN Purchasing.PurchaseOrderDetail
ON Purchasing.PurchaseOrderDetail.ProductID = Production.Product.ProductID
INNER JOIN Purchasing.PurchaseOrderHeader
ON Purchasing.PurchaseOrderDetail.PurchaseOrderID = Purchasing.PurchaseOrderHeader.PurchaseOrderID
INNER JOIN Purchasing.Vendor
ON Purchasing.PurchaseOrderHeader.VendorID = Purchasing.Vendor.BusinessEntityID	

WHERE PurchaseOrderDetail.OrderQty-PurchaseOrderDetail.ReceivedQty >=50

ORDER BY 'Quantity Difference';


/*
 7. Show the product name
 , the product subcategory name
 , the product category name
 , the product model name for subcategories of Road Bikes or Mountain Bikes.
 Order the list by product name, the category, then the subcategory. (75 rows returned)
*/
SELECT
	Product.Name AS 'Product Name'
	, ProductSubcategory.Name As 'SubCategory Name'
	, ProductCategory.Name AS 'Category Name'
	
FROM Production.Product
INNER JOIN 	Production.ProductSubcategory
ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
INNER JOIN Production.ProductCategory
ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID

WHERE ProductSubcategory.Name = 'Mountain Bikes'
OR ProductSubcategory.Name = 'Road Bikes'

ORDER BY Product.Name, ProductCategory.Name, ProductSubcategory.Name;

/*
 8.  Show the name of the product
 , the sales order quantity
 , the sales order date
 , the sales due date and 
 whether the product was ordered online (Show as Yes) 
 for any Tire products 
 and were ordered in June of 2011 
 or August of 2013 
 Arrange the list by order date. (1145 rows returned)
*/

SELECT 
	Product.Name
	, SalesOrderDetail.OrderQty
	, FORMAT(SalesOrderHeader.OrderDate, 'yyyy-dd-MM') AS 'Order Date'
	--, SalesOrderHeader.OnlineOrderFlag
	, Case When SalesOrderHeader.OnlineOrderFlag = 1 THEN 'Yes' Else 'No' END AS 'Online?'
	--, FORMAT(OrderDate, 'MMMM yyyy')
	
FROM Production.Product
INNER JOIN Sales.SalesOrderDetail
ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID


WHERE (FORMAT(OrderDate, 'MMMM yyyy') = 'June 2011'
OR FORMAT(OrderDate, 'MMMM yyyy') = 'August 2013')
AND Product.Name LIKE '%Tire%'

ORDER BY OrderDate;


/*
 9. Show the name of the sales person 
 who had orders in the month of January 
 of any year. Show the name only once (16 rows returned)
*/

SELECT  DISTINCT
 CONCAT(Person.FirstName, ' ', Person.LastName) AS 'Name Of Sales Person'
FROM Person.Person
INNER JOIN HumanResources.Employee
ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
INNER JOIN Sales.SalesPerson
ON Sales.SalesPerson.BusinessEntityID = HumanResources.Employee.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderHeader.SalesPersonID = Sales.SalesPerson.BusinessEntityID

WHERE FORMAT(SalesOrderHeader.OrderDate, 'MMMM') = 'January'

ORDER BY 'Name Of Sales Person';


/*
 10. Show the name of the sales people.
 their sales territory name
 , the sales year to date
 , their bonus
 , commission percentage
 and sales last year. 

 Order the list by sales territory name, then sales person last and first name. (14 rows returned)
*/
SELECT 
	CONCAT(Person.FirstName, ' ', Person.LastName) AS 'Name Of Sales Person'
	, SalesTerritory.Name AS 'Territory Name'
	, SalesPerson.SalesYTD
	, SalesPerson.Bonus
	, SalesPerson.CommissionPct
	, SalesPerson.SalesLastYear
FROM Person.Person
INNER JOIN HumanResources.Employee
ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
INNER JOIN Sales.SalesPerson
ON Sales.SalesPerson.BusinessEntityID = HumanResources.Employee.BusinessEntityID
INNER JOIN Sales.SalesTerritory
ON Sales.SalesPerson.TerritoryID = Sales.SalesTerritory.TerritoryID

ORDER BY SalesTerritory.Name, Person.LastName, Person.FirstName;
