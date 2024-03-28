/*
1) List the name of each sales person 
and the sum total due of their sales orders (17 rows) 
*/
SELECT 
	CONCAT(Person.FirstName, ' ', Person.LastName) AS 'Name Of Sales Person'
	, SUM(SalesOrderHeader.TotalDue) AS 'Sum of Total Due'
FROM Person.Person
INNER JOIN HumanResources.Employee
ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
INNER JOIN Sales.SalesPerson
On Sales.SalesPerson.BusinessEntityID = HumanResources.Employee.BusinessEntityID	
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderHeader.SalesPersonID = Sales.SalesPerson.BusinessEntityID

GROUP BY Person.FirstName, Person.LastName

ORDER BY 'Name Of Sales Person';

/*
2) What is the average standard cost of all products 
that are wheels or handlebars
and the culture is listed as "English" for both products. 
Show the Product Name, Culture Name and Average Standard Cost.
Order by Product Name (22 rows returned)
*/

SELECT 
	Product.Name AS 'Product Name'
	, Culture.Name 'Culture'
	, AVG(Product.StandardCost) AS 'Average Standard Cost'
FROM Production.Product
INNER JOIN Production.ProductSubcategory
ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
INNER JOIN Production.ProductModel
ON Production.Product.ProductModelID = Production.ProductModel.ProductModelID
INNER JOIN Production.ProductModelProductDescriptionCulture
ON 	Production.ProductModelProductDescriptionCulture.ProductModelID = Production.ProductModel.ProductModelID
INNER JOIN Production.Culture
ON Production.ProductModelProductDescriptionCulture.CultureID = Production.Culture.CultureID

WHERE (ProductSubcategory.Name = 'Wheels'
OR ProductSubcategory.Name = 'Handlebars')
AND Culture.Name = 'English'

GROUP BY  
	Product.Name
	, Culture.Name
	
ORDER BY Product.Name;

/* 
 3) List the name of each department 
 and how many current workers are in each department. 
 Order by number of employees in descending order (16 rows) 
*/

SELECT 
	Department.Name AS 'Department Name'
	, COUNT(*) AS 'Number of Workers'
FROM HumanResources.Employee
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID
INNER JOIN HumanResources.Department
ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID

GROUP BY Department.Name

ORDER BY 'Number of Workers' DESC;

/* 
 4) Show the average pay rate for each department. 
 Order the list by Average Pay Rate in descending order (16 rows)  
*/
SELECT 
	Department.Name AS 'Department Name'
	, AVG(EmployeePayHistory.Rate) AS 'Average Pay Rate'
FROM HumanResources.Employee
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID
INNER JOIN HumanResources.Department
ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID
INNER JOIN HumanResources.EmployeePayHistory
ON HumanResources.EmployeePayHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID


GROUP BY Department.Name

ORDER BY 'Average Pay Rate' DESC;

/*
5) Show the number of people who live in each postal code 
for those zip codes that have 50 or more people. 
Arrange the list by number of people in descending order then zip code (163 rows) 
*/

SELECT 
 Address.PostalCode
 , Count(*) AS 'People Count'
FROM Person.Person
INNER JOIN Person.BusinessEntity
ON Person.Person.BusinessEntityID = Person.BusinessEntity.BusinessEntityID
INNER JOIN Person.BusinessEntityAddress
ON Person.BusinessEntityAddress.BusinessEntityID = Person.BusinessEntity.BusinessEntityID
INNER JOIN Person.Address
ON Person.BusinessEntityAddress.AddressID = Person.Address.AddressID

GROUP BY Address.PostalCode
HAVING COUNT(*) >= 50

ORDER BY 'People Count' DESC, PostalCode;


/*
 6) What is the name of the person(s) who have the 
 below average Sales Year to Date
 and what is the amount of sales (9 row) 
*/

SELECT
	CONCAT(Person.FirstName, ' ', Person.LastName) AS 'Name Of Sales Person'
	, AVG(SalesPerson.SalesYTD)
FROM Person.Person
INNER JOIN HumanResources.Employee
ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
INNER JOIN Sales.SalesPerson
ON Sales.SalesPerson.BusinessEntityID = HumanResources.Employee.BusinessEntityID

GROUP BY Person.FirstName, Person.LastName
HAVING AVG(SalesPerson.SalesYTD) < ( SELECT AVG(SalesPerson.SalesYTD) FROM Sales.SalesPerson )

ORDER BY 'Name Of Sales Person';

/*
	7) List the product name 
	and scrap reason name 
	and the total scrap quantity per product name and scrap reason name 
	for those products that have more than 100 total items scrapped. 
	Arrange the list from highest to lowest quantity (25 rows) 
*/

SELECT 
	Product.Name AS 'Product Name'
	, ScrapReason.Name AS 'Scrap Reason'
	, SUM(WorkOrder.ScrappedQty) AS 'Total Scrap Quantity'
FROM Production.Product
INNER JOIN Production.WorkOrder
ON Production.WorkOrder.ProductID = Production.Product.ProductID
INNER JOIN Production.ScrapReason
ON Production.WorkOrder.ScrapReasonID = Production.ScrapReason.ScrapReasonID

GROUP BY 
	Product.Name
	, ScrapReason.Name
HAVING SUM(WorkOrder.ScrappedQty) > 100
ORDER BY 'Total Scrap Quantity' DESC;


/*
 8) Show the number of employees per state province. 
 Arrange the list by highest number of employees then by state province name (14 rows) 
*/

SELECT 
	StateProvince.Name AS 'State Province'
	, COUNT(*) AS 'Number of Employees'
FROM Person.Person
INNER JOIN Person.BusinessEntity
ON Person.Person.BusinessEntityID = Person.BusinessEntity.BusinessEntityID
INNER JOIN Person.BusinessEntityAddress
ON Person.BusinessEntityAddress.BusinessEntityID = Person.BusinessEntity.BusinessEntityID
INNER JOIN Person.Address
ON Person.BusinessEntityAddress.AddressID = Person.Address.AddressID
INNER JOIN Person.StateProvince
ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID
INNER JOIN HumanResources.Employee
ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID

GROUP BY
	StateProvince.Name
	
ORDER BY 'Number of Employees' DESC, StateProvince.Name;

/*
 9) Per department, 
 how many employees have over 25 hours of vacation. 
 Arrange the list by Department name (16 row) 
*/

SELECT 
	Department.Name AS 'Department Name',
	COUNT(*) AS 'Number Of Employees'
FROM HumanResources.Employee
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID
INNER JOIN HumanResources.Department
ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID

WHERE Employee.VacationHours > 25

GROUP BY Department.Name

ORDER BY Department.Name;

/*
 10) Show the location name 
 and the total of the product inventory quantity. 
 Show only those that had 5000 or more total quantity.

 Order by total quantity highest to lowest, then by  location (9 row) 
*/
SELECT 
	Location.Name AS 'Location Name'
	, SUM(ProductInventory.Quantity) AS 'Total Inventory Quantity'
FROM Production.Product
INNER JOIN Production.ProductInventory
ON Production.ProductInventory.ProductID = Production.Product.ProductID
INNER JOIN Production.Location
ON Production.ProductInventory.LocationID = Production.Location.LocationID

GROUP BY Location.Name
HAVING SUM(ProductInventory.Quantity) >= 5000


ORDER BY 'Total Inventory Quantity' DESC, Location.Name;