
select*from fact_sales
select sum(Total_Amount)from fact_sales
select*from [Order Details]
select ProductID,Quantity from [Order Details]where Quantity>10
declare @var1 varchar(100)
set @var1 = 'Rob,Tom,White'
select substring(empname,6,16) from emp_div
select*from fact_sales
select*from Suppliers
select*from Products
select*from Categories
select * from[Orders]
select*from [Order Details Extended]
select*from Customers
select*from Employees

--1.	Display the product names along with their supplier name
select a.CompanyName,b.ProductName from 
Suppliers a inner join Products b on a.SupplierID=b.SupplierID

--2.	Display the product names and the category which the products fall under. Also display the supplier’s name
select a.CompanyName,b.ProductName,b.CategoryID from 
Suppliers a inner join Products b on a.SupplierID=b.SupplierID

--3.	Display the Order_id, Contact name and the number of products purchased by the customer
DECLARE @A VARCHAR(1000)
SELECT @A=COUNT(PRODUCTID) FROM [Order Details Extended]
GROUP BY OrderID  

SELECT O.OrderID,C.ContactName,@A AS PRODUCTS
FROM Customers C
JOIN Orders O  ON
O.CustomerID=C.CustomerID  JOIN [Order Details Extended] ODE
ON O.OrderID=ODE.OrderID 

--4.	Display the Order_Id, Contact name and the shipping company name having Brazil as the ship country
select a.OrderID, b.ContactName,b.CompanyName ,a.ShipCountry  
from Customers b
inner join Orders a  on  a.CustomerID=b.CustomerID where a.ShipCountry like '%brazil%'

--5.	Display the Order_Id, contact name along with the employee’s name who handled that sale. Also display the total amount of that particular order 
SELECT*FROM Orders
SELECT*FROM Employees
select a.OrderID,ContactName,FirstName ,b.Title ,sum(d.ExtendedPrice)Totalamount from Orders a inner join Employees b on a.EmployeeID=b.EmployeeID 
inner join Customers c on a.CustomerID=c.CustomerID 
inner join [Order Details Extended] d on d.OrderID=a.OrderID where b.Title like '%sale%' group by a.OrderID,c.ContactName,b.FirstName,b.Title

-- 6.	Display the product names that were sold by the sales manager 

select a.ProductName,c.Title from Products a 
inner join fact_sales b on a.ProductID=b.Product_ID
inner join Employees c on b.Employee_ID=c.EmployeeID where Title='Sales Manager';

--7.	Fetch all the columns from suppliers with the corresponding product id and product name. If the Region is Null concatenate the first letters of country and city, should be in Upper case.
select *, 
case when Region is null then (left(country,1)+left(city,1))
else Region
end as region2
from Products a
inner join Suppliers b on a.SupplierID=b.SupplierID 

--8.	Display the company name, contact name, city along with the Unit price from products. 
--Fetch all the records from suppliers. Handle the null values
select CompanyName,ContactName,City,UnitPrice from Products inner join Suppliers on Products.SupplierID=Suppliers.SupplierID 

-
--9.	Select customer id, ship name, ship city, territory description, unit price and discount where in the territory id should not exceed four characters and the ship via should be 1 or 2..
select a.TerritoryDescription,a.TerritoryID,a.RegionID,c.CustomerID,c.ShipName,c.ShipCity,c.ShipVia,d.UnitPrice,d.Discount from Territories a 
inner join EmployeeTerritories b on a.TerritoryID=b.TerritoryID
inner join Orders c on b.EmployeeID=c.EmployeeID
inner join [Order Details Extended] d on c.OrderID=d.OrderID
inner join Customers e on c.CustomerID=e.CustomerID where a.TerritoryID<=9999 and c.ShipVia<=2;


--10.	Display the order id, customer id, Unit price, quantity where the discount should be greater than zero.
select a.CustomerID,a.OrderID,b.Discount,b.Quantity,b.UnitPrice from Orders a 
inner join [Order Details Extended] b on a.OrderID=b.OrderID
 where b.Discount>0;

 --11.	Select the category id, category name, description, product name, and supplier id and unit price.
 --Where the description should not exceed two subcategories
 ;with CTE
 AS
 (
 SELECT CategoryID,CAST(DESCRIPTION AS VARCHAR(100)) AS NEW FROM Categories
 ),
 CTE2
 AS
 (
 SELECT CategoryID,REPLACE(NEW, 'and ',',') AS DES2 FROM CTE
 ),
 CTE3
 AS
 (
 SELECT *,LEN(DES2)-LEN(REPLACE(DES2,',',''))AS COUNT FROM CTE2
 )

 select  C.CategoryID,CategoryName,ProductName,UnitPrice,s.SupplierID,c.Description from
 Products P INNER JOIN  Suppliers S on p.SupplierID=s.SupplierID
 inner join Categories c on c.CategoryID=p.CategoryID
  inner join CTE3 ct  on ct.CategoryID=c.CategoryID
 WHERE COUNT<2
 
 --12.	Write a query to select only the first letter in each word present in the column 'Contact Name'.
 --(E.g.: A Beautiful Mind-ABM) and name this column as 'Short Name'. Do order by ‘Short Form' (use Suppliers table)
 ;with CTI
 as(
 select  LEFT(ContactName, CHARINDEX(' ', ContactName)) as firstname,
 substring(ContactName,CHARINDEX(' ', ContactName)+1,len(ContactName)-(CHARINDEX(' ', ContactName)-1)) as lastname
 from Suppliers
 )select left(CTI.firstname,1)+left(CTI.lastname,1)AS SHORTNAME
 FROM CTI ORDER BY SHORTNAME
 
 

 --13.	Display the Delivery time (in days) for each order and sort it by delivery day.
select *, DATEdiff(DD,OrderDate,ShippedDate)as deliverydates  from Orders 
 ORDER BY OrderID
 
 --14.	Display the order id along with its delivery status.
--Delivery status: If order Delivered within 7 days, then status will be ‘ON-TME’ 
--Delivered after 7 days, then status will be ‘Delayed’
-- Delivered before 4 days, then status will be ‘Delivered Early’.
select OrderID, case when  DATEdiff(DD,OrderDate,ShippedDate)=7 then 'on time'
            when datediff(DD,OrderDate,ShippedDate)>7 then 'delay'
			when datediff(DD,OrderDate,ShippedDate)<=4 then 'delivered early'
			end as deliverystatus from Orders
 
--15.	Display the employee name along with their appraisal date (Add 6 months to hire date)
      
	  select EmployeeID,HireDate, DATEADD(MM,6,HireDate) AppraisalDate from Employees