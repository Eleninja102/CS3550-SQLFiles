
SELECT t1.DepartmentName, ROUND(CAST(NumberOfMale AS float) / CAST(NumberOfFemale AS float), 2) AS EmpolyeeMaleToFemaleRatio, NumberOfFemale, NumberOfMale
FROM(
	SELECT hrd.Name AS DepartmentName, COUNT(*) AS NumberOfFemale
	FROM HumanResources.Employee hre
	INNER JOIN HumanResources.EmployeeDepartmentHistory hredh
	ON hre.BusinessEntityID = hredh.BusinessEntityID
	INNER JOIN HumanResources.Department hrd
	ON hrd.DepartmentID = hredh.DepartmentID

	WHERE hre.Gender = 'F'
	GROUP BY hrd.Name
)t1

INNER JOIN
(
	SELECT hrd.Name AS DepartmentName, COUNT(*) AS NumberOfMale
	FROM HumanResources.Employee hre
	INNER JOIN HumanResources.EmployeeDepartmentHistory hredh
	ON hre.BusinessEntityID = hredh.BusinessEntityID
	INNER JOIN HumanResources.Department hrd
	ON hrd.DepartmentID = hredh.DepartmentID

	WHERE hre.Gender = 'M'
	GROUP BY hrd.Name
)t2


ON t1.DepartmentName = t2.DepartmentName

Where t1.DepartmentName = 'Production'
SELECT pp.Name AS productName, pp.ProductID AS productId, SUM(ssod.OrderQty) AS totalOrderQty
FROM Sales.SalesOrderDetail ssod
INNER JOIN Sales.SpecialOfferProduct ssop
ON ssod.ProductID = ssop.ProductID
AND ssop.SpecialOfferID = ssod.SpecialOfferID
INNER JOIN Production.Product pp
ON pp.ProductID = ssop.ProductID

GROUP BY pp.Name, pp.ProductID
HAVING SUM(ssod.OrderQty) =(
	SELECT MAX(totalOrderQty)
	FROM 
	(SELECT pp.Name AS productName, pp.ProductID AS productId, SUM(ssod.OrderQty) AS totalOrderQty
	FROM Sales.SalesOrderDetail ssod
	INNER JOIN Sales.SpecialOfferProduct ssop
	ON ssod.ProductID = ssop.ProductID
	AND ssop.SpecialOfferID = ssod.SpecialOfferID
	INNER JOIN Production.Product pp
	ON pp.ProductID = ssop.ProductID
		
	GROUP BY pp.Name, pp.ProductID) t1
)
