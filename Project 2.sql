-- Project 2
-- SQL Data Analyst
-- 26/May/2023

-- Efrat Elazar

-- Ex 1:
-- Expected Result: 238 Rows --> WELL DONE!!!.

/* Tables in use:
select * from production.product
select * from sales.salesorderDetail sod
*/

select distinct(p.productID), p.Name, p.Color, p.ListPrice, p.Size 
from production.product p
left Join -- 'Left Join': Reducig 'sold' from 'total products list'
sales.salesorderDetail sod
on p.productID = sod.productID
Where sod.productID is null -- 'Where' in context of 'left join': Reducig 'sold' from 'total products list'
order By p.productID

----*******************************************************

-- Ex 2: 
-- Expected result: 701 Rows --> Well Done!!!
-- CustomerID, LastName, FirstName

-- Do no do it again. it shold be run only once!!!
/*
update sales.customer set personid=customerid     
where customerid <=290  update sales.customer 
set personid=customerid+1700     
where customerid >= 300 and customerid<=350  
update sales.customer 
set personid=customerid+1700     
where customerid >= 352 and customerid<=701
*/

-- My Answer for Ex 2: 

/* Tables in use:
select * from Person.person p
select * from sales.customer c
*/

Select c.CustomerID, ISNULL(p.LastName, 'Unknown') as 'Last Name', ISNULL(p.FirstName, 'Unknown') as 'First Name'
from sales.customer c
Left join 
Person.person p
on c.PersonID = p.BusinessEntityID
-- Above: 'Left Join' - we want to include customers (only in 'Customer' table) that do not have names
left Join 
 sales.salesorderHeader soh
on c.CustomerID = soh.CustomerID
Where soh.CustomerID is null
-- 'Where' (in 'Join' context -  because we want to ignore customers that did made orders (from 'salesorderHeader' table)
order by c.CustomerID 

----*******************************************************

-- Ex 3: 
-- Expected result: 10 Rows, with correct names --> Well Done!!!
-- Tables in use: 
/*
select * sales.salesorderHeader soh
select * from sales.customer c
select * from Person.person p
select * from sales.salesorderHeader soh
*/

With CTE as
(select soh.CustomerID as 'custID', count(SalesOrderNumber)over(partition by CustomerID) as 'NumOrdPerCust'  
from sales.salesorderHeader soh) 
select distinct top 10 cte.custID, p.FirstName as 'First Name', p.LastName as 'Last Name', cte.NumOrdPerCust --, DENSE_Rank() over (order by cte.NumOrdPerCust ) as 'NumOrdRank'
from cte
join 
sales.customer c
on c.CustomerID = cte.custID
Left join 
Person.person p
on c.PersonID = p.BusinessEntityID
inner Join 
 sales.salesorderHeader soh
on c.CustomerID = soh.CustomerID
order by cte.NumOrdPerCust desc

----*******************************************************


-- Ex 4: 
-- Expected results: 290 Rows -- DONE!!
  -- HireDate, JobTitle: Employee ([HumanResources][Employee])
  -- LastNAme, FirstName: Person
  -- In This order: First Name, LastName, JobTitle, HireDate, CountOfTitle

  /* Tables in use:
  select * from  HumanResources.Employee
  select * from  Person.Person
  */

  Select p.FirstName, p.LastName,  e.JobTitle, e.HireDate, count (e.BusinessEntityID)over(partition by JobTitle) as 'Num Of Emps in this Title'
  from HumanResources.Employee e
  join Person.Person p
  on p.BusinessEntityID = e.BusinessEntityID


  ----*******************************************************

-- Ex 5: 
-- Expected results: 19,127 Rows -- DONE !!!

/* Tables in use: 
Select * from sales.customer c
select * from sales.salesorderHeader soh
select * from  Person.Person
*/

select CustOrd.SalesOrderID, CustOrd.customerID, CustOrd.LastName, CustOrd.FirstName, CustOrd.LastOrder, CustOrd.PreviousOrder from 
(Select soh.SalesOrderID, c.CustomerID, p.LastName, p.FirstName , soh.orderDate as LastOrder
,Rank()over(partition by soh.customerID order By soh.orderDate Desc) as OredresRank
,LAG(soh.orderDate,1) over(partition by soh.customerID order By soh.orderDate ) as PreviousOrder
from sales.customer c
join sales.salesorderHeader soh
on c.customerID = soh.CustomerID
join Person.Person p
on p.BusinessEntityID = c.PersonID) as CustOrd
where CustOrd.OredresRank Like '1' 
order By CustOrd.LastName --Results in table presented in the project page - are sorted differently

 ----*******************************************************

-- Ex 6: SumLineTotal, SalesOrderID Per Year are as expected.

/* Tables in use:
Select * from sales.customer c --CustomerID, PersonID
select * from sales.salesorderHeader soh  -- OrderDate, customerID
select * from sales.salesorderDetail sod --- UnitPrice*(1-UnitPriceDiscount)*OrderQty OR LineTotal 
select * from  Person.Person -- LastName, FirstName, BusinessEntityID
*/

Select xxx.Year, xxx.SalesOrderID, xxx.LastName, xxx.FirstName, xxx.SumLineTotal 
from (
select Distinct Year(ExpenYear.orderDate) as Year, ExpenYear.SumLineTotal, ExpenYear.SalesOrderID,  ExpenYear.LastName, ExpenYear.FirstName
, Dense_Rank() over( partition by Year(ExpenYear.orderDate)order by ExpenYear.SumLineTotal desc) as OrderPriceRank
from 
(select  sod.productID, sod.SalesOrderID, sod.lineTotal, soh.orderDate, p.FirstName, p.LastName, sum(sod.lineTotal) over (partition by sod.SalesOrderID ) as SumLineTotal
  from sales.salesorderDetail sod --- SalesOrderID, UnitPrice*(1-UnitPriceDiscount)*OrderQty OR LineTotal 
  join sales.salesorderHeader soh
  on soh.SalesOrderID = sod.SalesOrderID
  join sales.customer c 
  on c.customerID = soh.customerID
  join Person.Person p
  on p.BusinessEntityID = c.PersonID
  group by sod.productID, sod.SalesOrderID,sod.lineTotal, soh.orderDate, p.FirstName, p.LastName
 
) as ExpenYear
) as XXX
 Where xxx.OrderPriceRank like 1



----*******************************************************
 -- Ex 7: 
 -- Expexted Results: 12 Rows -- DONE !!

 /* Tables in Use:
 select * from sales.salesOrderHeader
 select * from sales.salesOrderDetail
   */
  
  select * From
  (Select Year(soh.OrderDate) as Year, Month(soh.OrderDate) as Month, soh.SalesOrderID
  from sales.salesOrderHeader soh) x pivot (count (x.SalesOrderID) for Year in 
  ([2011], [2012], [2013],[2014])) as AA
  order by AA.Month

  ----******************************************************* 

 -- Ex 8: ** Add Summarize line for each Year*** Use ROLLUP 
/* I could not have a solution to the conflict between 'Order by Year, month'
 and the 'Sum Total' of all months in each year.
 It was either : wrong 'SumTotal'   or wrong 'order' of yesar/month
 as a result - I did not set to the 'RollUp' stage..  :(
 I had endless trials...
 */
 -- Tables in use:
 /*
 select * from sales.salesOrderHeader
  select * from sales.salesOrderDetail
  */
 ---------------------- Below: So Far The Best, BUT 'Sum Total' **Order** is wrong, RollUp is not applied.
  WITH CTE as (
  Select distinct top 1000 YEAR(soh.orderdate) as YEAR1,  MONTH(soh.orderdate) AS MONTH1
   , Sum(sod.LineTotal) over (partition by MONTH(soh.orderdate) order By YEAR(soh.orderdate)) as 'MonthSum'
    from sales.salesOrderHeader soh
  Join sales.salesOrderDetail sod
  on soh.SalesOrderID = sod.SalesOrderID)
  --order by Year(soh.orderdate), month(soh.orderdate)) 
  select xx.Year1, XX.Month1, xx.MonthSum, 
  SUM(xx.MonthSum)over(order by xx.MonthSUM Rows between unbounded preceding and Current row ) sumTotal
  from CTE xx
  --group by ROLLUP ((xx.Year1) , (xx.MONTH1))
  
  order by xx.year1, xx.month1
  --------------------------------------


  -- Ex 9: DONE!!!!!! 290 Rows
  
  /* Tables in Use: 
     Select * from HumanResources.employee e --BusinessEntityID, HireDate
     Select * from HumanResources.Department d --DepartmentID, Department Name
     Select * from HumanResources.EmployeeDepartmentHistory edh -- BusinessEntityID, DepartmentID
*/
	
	 Select /*d.DepartmentID,*/ d.Name as 'DepartmentName' , e.BusinessEntityID  'EmployeeID' , concat(p.FirstName, ' ', p.LastName) as 'Full Name'
	 ,e.HireDate --, edh.EndDate
	 , DateDiff(mm, e.HireDate, getDate()) as '#Months-Vetek (Till May 2023)' /*- Different values from the table in project page)'*/
	 , LAG (p.FirstName + ' '+  p.LastName) over (partition by d.departmentID order by e.HireDate ) as 'PrevPersonHired'
	, LAG (e.HireDate) over (partition by d.departmentID order by e.HireDate ) as 'PrevHireDate'
	, DateDiff (dd, (LAG (e.HireDate) over (partition by d.departmentID order by e.HireDate )), e.Hiredate) as 'DiffDays'
		from HumanResources.employee e
		join HumanResources.EmployeeDepartmentHistory edh
	on e.BusinessEntityID = edh.BusinessEntityID
		join
	HumanResources.Department d
	on edh.DepartmentID = d.DepartmentID
		join person.person p
	on p.BusinessEntityID = e.BusinessEntityID
	Where edh.EndDate is null -- Means The Employee is still working  
	order by 1,4 desc
	
	 
			


-- Ex 10 -- DONE!!! Perfect 219 lines!!:

/* Tables in Use:
Select * from HumanResources.employee --BusinessEntityID, HireDate, 
 Select * from HumanResources.employeeDepartmentHistory --BusinessEntityID, DepartmentID, EndDate(Null --> Current DeptID)
 select * from person.person -- BusinessEntityID, LastName, FirstName
*/

Select distinct e.HireDate, edh.DepartmentID, string_agg((concat(p.FirstName, ' ',p.LastName, ' ', e.BusinessEntityID, ' ', edh.EndDate))  , ',') as 'NAMES'
 from 
 HumanResources.employee e
 Join 
 HumanResources.employeeDepartmentHistory edh
 on e.BusinessEntityID = edh.BusinessEntityID
  join person.person p
 on p.BusinessEntityID = e.BusinessEntityID
Where edh.EndDate is null  -- 'EndDate Null' means the employee is still hired, not Fired :)
  --order by e.HireDate
  group by e.HireDate, edh.DepartmentID
  order by e.HireDate



