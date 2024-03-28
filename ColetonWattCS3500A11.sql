/*1. List the first name
, last name
, gender
, age (in days)
, and job title of the oldest age (as calculated by number of days) employee. 
Note that you should calculate the age in days.*/

SELECT Person.FirstName, Person.LastName, Employee.Gender, DATEDIFF(day, Employee.BirthDate, GETDATE()) AS 'Age in Days', Employee.JobTitle
FROM Person.Person
INNER JOIN HumanResources.Employee
ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
WHERE Employee.BirthDate =
(
		SELECT MIN(Employee.BirthDate)
		FROM HumanResources.Employee
		--ORDER BY BirthDate
);


/*2. Display the employee male to female ratio of employees in Production. 
(Note that ratio is male/female). Show the single value up to two digits after the decimal (i.e. 5.43). Use CAST to convert the number 
of each gender to a FLOAT. User ROUND to get the value down to 2 digits after decimal*/


SELECT WomenEmpolyees.Name, ROUND(CAST(MaleEmployess.numberOfEmp AS float) /  CAST(WomenEmpolyees.numberOfEmp AS float), 2) AS 'Ratio male/female'
FROM
(
	SELECT Employee.Gender, Department.Name, COUNT(*) AS numberOfEmp
	FROM HumanResources.Employee
	INNER JOIN HumanResources.EmployeeDepartmentHistory
	ON 	HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID
	INNER JOIN HumanResources.Department
	ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID	
	WHERE Employee.Gender = 'F'
	GROUP BY Gender, Department.Name
) WomenEmpolyees
INNER JOIN
(
	SELECT Employee.Gender, Department.Name, COUNT(*) AS numberOfEmp
	FROM HumanResources.Employee
	INNER JOIN HumanResources.EmployeeDepartmentHistory
	ON 	HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID
	INNER JOIN HumanResources.Department
	ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID	
	WHERE Employee.Gender = 'M'
	GROUP BY Gender, Department.Name
) MaleEmployess
ON WomenEmpolyees.Name = MaleEmployess.Name

WHERE WomenEmpolyees.Name = 'Production';




/*3. Show the 
	name
	, quantity 
	and product ID 
	of the highest total quantity ordered item SOLD to customers. 
To clarify, show the highest total order quantity per item. Remember the double join*/
SELECT Product.Name, SUM(orderQty) AS OrderQty, Product.ProductID
FROM Production.Product
INNER JOIN Sales.SpecialOfferProduct
ON Sales.SpecialOfferProduct.ProductID = Production.Product.ProductID
INNER JOIN Sales.SalesOrderDetail
ON Sales.SalesOrderDetail.SpecialOfferID = Sales.SpecialOfferProduct.SpecialOfferID
AND Sales.SalesOrderDetail.ProductID = Sales.SpecialOfferProduct.ProductID

GROUP BY Product.ProductID, Product.Name
HAVING SUM(orderQty) =
(
	SELECT MAX(OrderQty)
	FROM 
	(
		SELECT ProductID, SUM(orderQty) AS OrderQty
		FROM Sales.SalesOrderDetail
		
		GROUP BY ProductID
		--ORDER BY OrderQty DESC;
	) producttable
)



/*4. Show the state/provinces(s) with the most online orders. Show the number of online orders as well (hint: it is over 5000)*/


SELECT StateProvince.Name, COUNT(*) AS onlineOrders
FROM Sales.SalesOrderHeader
INNER JOIN Sales.Customer
ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID	
INNER JOIN Person.Person
ON 	Sales.Customer.PersonID = Person.Person.BusinessEntityID	
INNER JOIN Person.BusinessEntity
ON Person.Person.BusinessEntityID = Person.BusinessEntity.BusinessEntityID	
INNER JOIN Person.BusinessEntityAddress
ON Person.BusinessEntityAddress.BusinessEntityID = Person.BusinessEntity.BusinessEntityID	
INNER JOIN Person.Address
ON Person.BusinessEntityAddress.AddressID = Person.Address.AddressID
INNER JOIN Person.StateProvince
ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID	

WHERE SalesOrderHeader.OnlineOrderFlag = 1

GROUP BY StateProvince.Name
HAVING COUNT(*) = 
(
	SELECT MAX(onlineOrders)
	FROM
	(
		SELECT StateProvince.Name, COUNT(*) AS onlineOrders
		FROM Sales.SalesOrderHeader
		INNER JOIN Sales.Customer
		ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID	
		INNER JOIN Person.Person
		ON 	Sales.Customer.PersonID = Person.Person.BusinessEntityID	
		INNER JOIN Person.BusinessEntity
		ON Person.Person.BusinessEntityID = Person.BusinessEntity.BusinessEntityID	
		INNER JOIN Person.BusinessEntityAddress
		ON Person.BusinessEntityAddress.BusinessEntityID = Person.BusinessEntity.BusinessEntityID	
		INNER JOIN Person.Address
		ON Person.BusinessEntityAddress.AddressID = Person.Address.AddressID
		INNER JOIN Person.StateProvince
		ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID	
		
		WHERE SalesOrderHeader.OnlineOrderFlag = 1
		
		GROUP BY StateProvince.Name
		--ORDER BY onlineOrders DESC
	) t1
	
);

/*5. Display the vendor name, credit rating and address (street address, city, state) for vendors 
that have a credit rating less than or equal to 2. Sort the list be Vendor Name.( Hint: 93 rows)*/

SELECT Vendor.Name AS 'Vendor Name', Vendor.CreditRating, Address.AddressLine1, Address.City, StateProvince.Name AS [State]
FROM Purchasing.Vendor
INNER JOIN Person.BusinessEntity
ON Purchasing.Vendor.BusinessEntityID = Person.BusinessEntity.BusinessEntityID	
INNER JOIN Person.BusinessEntityAddress
ON Person.BusinessEntityAddress.BusinessEntityID = Person.BusinessEntity.BusinessEntityID
INNER JOIN Person.Address
ON Person.BusinessEntityAddress.AddressID = Person.Address.AddressID	
INNER JOIN Person.StateProvince
ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID	

WHERE CreditRating <= 2

ORDER BY Vendor.Name;


/*6. Display the territory (Territory ID, Name, CountryRegionCode, Group and Number of Customers) of the 
sales territory that has the most customers. (Hint: Number of customers is over 4000*/
SELECT SalesTerritory.TerritoryID, SalesTerritory.Name, CountryRegion.Name, SalesTerritory.[Group], COUNT(*) AS 'Number of Customers'

FROM Sales.Customer
INNER JOIN Sales.SalesTerritory
ON Sales.Customer.TerritoryID = Sales.SalesTerritory.TerritoryID	
INNER JOIN Person.CountryRegion
ON Sales.SalesTerritory.CountryRegionCode = Person.CountryRegion.CountryRegionCode	

GROUP BY SalesTerritory.TerritoryID, SalesTerritory.Name, CountryRegion.Name, SalesTerritory.[Group]
HAVING COUNT(*) =
(
	SELECT MAX(CustomerCount)
	FROM
	(
		SELECT COUNT(*) AS CustomerCount
		FROM Sales.Customer
		INNER JOIN Sales.SalesTerritory
		ON Sales.Customer.TerritoryID = Sales.SalesTerritory.TerritoryID	
		INNER JOIN Person.CountryRegion
		ON Sales.SalesTerritory.CountryRegionCode = Person.CountryRegion.CountryRegionCode	
		
		GROUP BY SalesTerritory.TerritoryID, SalesTerritory.Name, CountryRegion.Name, SalesTerritory.[Group]
	) t1
);


/*7. List the employee (still with the company) last hired in each department, 
in alphabetical order by department. The employee must still be in the department. (End date is blank) (Hint: 17 rows returned)*/

SELECT Department.Name AS 'Department Name', Person.FirstName, Person.LastName
FROM HumanResources.Employee
LEFT OUTER JOIN HumanResources.EmployeeDepartmentHistory
ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID	
INNER JOIN
(
	SELECT DepartmentID, MAX(HireDate) AS hirdateMin
	FROM HumanResources.Employee
	LEFT OUTER JOIN HumanResources.EmployeeDepartmentHistory
	ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID	
	
	
	WHERE CurrentFlag = 1
	AND EmployeeDepartmentHistory.EndDate IS NULL
	
	GROUP BY DepartmentID
)  t1
ON t1.DepartmentID = EmployeeDepartmentHistory.DepartmentID
AND t1.hirdateMin = Employee.HireDate
INNER JOIN HumanResources.Department
ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID	
INNER JOIN Person.Person
ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID	

WHERE CurrentFlag = 1
AND EmployeeDepartmentHistory.EndDate IS NULL

ORDER BY Department.Name;

/*8. List the first and last name, current pay rate and year to date sales of sales employees who have above average YTD sales. 
Sort by last name then first name (Hint: 8 rows)*/

SELECT Person.FirstName, Person.LastName, EmployeePayHistory.Rate, SalesPerson.SalesYTD
FROM Sales.SalesPerson
INNER JOIN HumanResources.Employee
ON Sales.SalesPerson.BusinessEntityID = HumanResources.Employee.BusinessEntityID	
INNER JOIN Person.Person
ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
INNER JOIN  HumanResources.EmployeePayHistory
ON HumanResources.EmployeePayHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID	

WHERE SalesYTD > 
(
	SELECT AVG(SalesYTD)
	FROM Sales.SalesPerson
);


/*9. Identify the currency of the foreign country (not the US) with the highest total number of orders.
(Hint: Number of orders is over 6000*/
SELECT CurrencyRate.ToCurrencyCode, COUNT(*) AS 'Order Count'
FROM Sales.SalesOrderHeader
INNER JOIN Sales.CurrencyRate
ON Sales.SalesOrderHeader.CurrencyRateID = Sales.CurrencyRate.CurrencyRateID	

WHERE CurrencyRate.ToCurrencyCode != 'USD'

GROUP BY CurrencyRate.ToCurrencyCode
HAVING COUNT(*) = 
(
	SELECT MAX(OrderCount) 
	FROM 
	(
		SELECT CurrencyRate.ToCurrencyCode, COUNT(*) AS OrderCount
		FROM Sales.SalesOrderHeader
		INNER JOIN Sales.CurrencyRate
		ON Sales.SalesOrderHeader.CurrencyRateID = Sales.CurrencyRate.CurrencyRateID	
		
		WHERE CurrencyRate.ToCurrencyCode != 'USD'
		
		GROUP BY CurrencyRate.ToCurrencyCode
	) t1
);


/*10.  Show the unique 
Sale Reason Name
, Sales Unit Price
, Product Name
, Special Offer Description
, Special Offer Discount Percent, and the 
discounted price of the item (unit price minus the discount applied against the unit price) 
for this items On Promotion where the Special Offer Description begins with Touring. (Hint: 33 rows)*/

SELECT SalesReason.Name, SalesOrderDetail.UnitPrice, Product.Name, SpecialOffer.Description, SpecialOffer.DiscountPct, ROUND((SalesOrderDetail.UnitPrice * (1 - SpecialOffer.DiscountPct)), 2) AS 'Discounted Price'
FROM Production.Product
INNER JOIN Sales.SpecialOfferProduct
ON Sales.SpecialOfferProduct.ProductID = Production.Product.ProductID	
INNER JOIN Sales.SalesOrderDetail
ON 	Sales.SalesOrderDetail.SpecialOfferID = Sales.SpecialOfferProduct.SpecialOfferID
AND Sales.SalesOrderDetail.ProductID = Sales.SpecialOfferProduct.ProductID
INNER JOIN Sales.SpecialOffer
ON Sales.SpecialOfferProduct.SpecialOfferID = Sales.SpecialOffer.SpecialOfferID
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID	
INNER JOIN Sales.SalesOrderHeaderSalesReason
ON Sales.SalesOrderHeaderSalesReason.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID	
INNER JOIN Sales.SalesReason
ON Sales.SalesOrderHeaderSalesReason.SalesReasonID = Sales.SalesReason.SalesReasonID	

WHERE SpecialOffer.Description LIKE 'Touring%'
AND SalesReason.Name = 'On Promotion'

ORDER BY Product.Name;

