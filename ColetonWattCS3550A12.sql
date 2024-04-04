/*
	1. Display the name of the department
	, day of the month the employee was hired 
	and the total number of employees hired per department for each day of the month. 
	The days of the month should appear along the left hand side and the department names should appear across the headers
	(Complete both Static and Dynamic Pivot Query)
*/

--1A)
SELECT HireDateDay,
			[Document Control]
		,	[Engineering]
		,	[Executive]
		,	[Facilities and Maintenance]
		,	[Finance]
		,	[Human Resource]
		,	[Information Services]
		,	[Marketing]
		,	[Production]
		,	[Production Control]
		,	[Purchasing]
		,	[Quality Assurance]	
		,	[Research and Development]
		,	[Sales]
		,	[Shipping and Receiving]
		,	[Tool Design]

FROM
(
	SELECT Department.Name AS DepartmentName, DATEPART(dd, Employee.HireDate) AS HireDateDay, Employee.BusinessEntityID
	FROM HumanResources.Employee
	INNER JOIN HumanResources.EmployeeDepartmentHistory
	ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID
	INNER JOIN HumanResources.Department
	ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID
) TableData

PIVOT
(
	COUNT(BusinessEntityID) FOR DepartmentName IN
	(
		[Document Control]
		,	[Engineering]
		,	[Executive]
		,	[Facilities and Maintenance]
		,	[Finance]
		,	[Human Resource]
		,	[Information Services]
		,	[Marketing]
		,	[Production]
		,	[Production Control]
		,	[Purchasing]
		,	[Quality Assurance]	
		,	[Research and Development]
		,	[Sales]
		,	[Shipping and Receiving]
		,	[Tool Design]
	)

) AS pivotTable
ORDER BY HireDateDay;



--1B)

DECLARE @columns1 NVARCHAR(MAX), @sql1 NVARCHAR(MAX)
SET @columns1 = N'';
SELECT @columns1 += N', ' + QUOTENAME(name) FROM HumanResources.Department AS t1;
SET @columns1 = STUFF(@columns1, 1, 2, '');
SET @sql1 = N'SELECT HireDateDay,'+ @columns1 + N'
		
FROM
(
	SELECT Department.Name AS DepartmentName, DATEPART(dd, Employee.HireDate) AS HireDateDay, Employee.BusinessEntityID
	FROM HumanResources.Employee
	INNER JOIN HumanResources.EmployeeDepartmentHistory
	ON HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.Employee.BusinessEntityID
	INNER JOIN HumanResources.Department
	ON HumanResources.EmployeeDepartmentHistory.DepartmentID = HumanResources.Department.DepartmentID
) TableData

PIVOT
(
	COUNT(BusinessEntityID) FOR DepartmentName IN
	(' + @columns1 + N'
	)

) AS pivotTable
ORDER BY HireDateDay;';

EXECUTE sp_executeSQL @sql1;

/*
	2. List the Scrap Reason Name
	, the day of the week for the Product Work Order Start Date 
	
	and the total of the Scrapped Quantity per Scrap Reason and Day of the Week
	. The Day of the Week should appear across the top in order with the Scrap Reason name on the left hand side of the table.
	(Complete both Static and Dynamic Pivot Query)
*/

-- 2A)
SELECT ScrapReason, [Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday]
FROM
(
	SELECT ScrapReason.Name AS ScrapReason, DATENAME(dw, WorkOrder.StartDate) AS StartDay, WorkOrder.ScrappedQty
	FROM Production.WorkOrder
	INNER JOIN Production.ScrapReason
	ON Production.WorkOrder.ScrapReasonID = Production.ScrapReason.ScrapReasonID
) scrapped

PIVOT
(
	SUM(scrapped.ScrappedQty) FOR scrapped.StartDay IN  
	( 
		[Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday]
	) 
)AS PivotTable
ORDER BY ScrapReason;


-- 2B)

DECLARE @columns2 NVARCHAR(MAX), @sql2 NVARCHAR(MAX)
SET @columns2 = N'';
SELECT @columns2 += N', ' 
	+ QUOTENAME(DayOftheWeek) 
	FROM 
	(
		SELECT DISTINCT DATENAME(dw, WorkOrder.StartDate) AS DayOftheWeek, DATEPART(dw, WorkOrder.StartDate) AS DayOftheWeekNum 
		FROM Production.WorkOrder
	) AS t1
	ORDER BY DayOftheWeekNum;
	
SET @columns2 = STUFF(@columns2, 1, 2, '');


SET @sql2 = N'SELECT ScrapReason,' + @columns2 + N'
FROM
(
	SELECT ScrapReason.Name AS ScrapReason, DATENAME(dw, WorkOrder.StartDate) AS StartDay, WorkOrder.ScrappedQty
	FROM Production.WorkOrder
	INNER JOIN Production.ScrapReason
	ON Production.WorkOrder.ScrapReasonID = Production.ScrapReason.ScrapReasonID
) scrapped

PIVOT
(
	SUM(scrapped.ScrappedQty) FOR scrapped.StartDay IN  
	(' + @columns2 + '
	) 
)AS PivotTable
ORDER BY ScrapReason;';

EXECUTE sp_executeSQL @sql2;

