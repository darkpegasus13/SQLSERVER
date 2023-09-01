--8
SELECT * FROM order_items WHERE order_id=6 AND quantity*unit_price>30;

--9
SELECT * FROM products WHERE quantity_in_stock IN (49,38,72);

--10 BETWEEN operator is inclusive
SELECT * FROM customers WHERE birth_date BETWEEN '1990-1-1' AND '2000-1-1'

--11 we can use NOT as well with LIKE
Select * FROM customers WHERE (address LIKE '%TRIAL%' OR address LIKE '%AVENUE%')
Select * FROM customers WHERE phone LIKE '%9';

--12 regex not available without c# code we can use like  for this purpose
Select * FROM customers WHERE first_name like 'elka' OR first_name LIKE 'ambur';
Select * FROM customers WHERE last_name like '%EY' OR last_name LIKE '%ON';
Select * FROM customers WHERE last_name like 'MY%' OR last_name LIKE '%SE%';
Select * FROM customers WHERE last_name like '%B[RU]%';

--13 "=" or "<>" wont work because they compare value and null represents lack of value
Select  * From orders where shipped_date is null

--14 In RDBMS one primary key mandatory in every table so it is sorted according to primary key
Select *,quantity*unit_price as 'total price' from order_items
where order_id=2 order by 'total price' desc;

--15
Select top 5 * From customers;  --either use top
Select * From customers order by first_name OFFSET 5 ROWS 
FETCH NEXT 5 ROWS ONLY; --or use offset with fetch
Select top 3 * from customers order by points desc;

--16 if column with same name use table_name.column_name
select O.order_id,O.product_id,P.name,O.quantity,O.unit_price from order_items
O join products P on O.product_id = P.product_id;

--17 for using from another db use [db_name].[schema_name].[table_name]
select O.order_id,O.product_id,P.name,O.quantity,O.unit_price from order_items
O join [sql_inventory].[dbo].[products] P on O.product_id = P.product_id;

--18 Self Join
select emp.employee_id,emp.first_name,mngr.first_name as manager from [sql_hr].[dbo].[employees] emp 
join [sql_hr].[dbo].[employees] mngr on emp.reports_to = mngr.employee_id;

--19 Joining multiple tables
use sql_invoicing
select date,invoice_id,amount,C.name,PM.name from payments P join
clients C on P.client_id = C.client_id
join payment_methods PM on P.payment_method = PM.payment_method_id;

--20 Compound join (in case of composite primary keys)
use sql_store
select * from order_items OI
join order_item_notes N on OI.order_id = N.order_Id 
and OI.product_id = N.product_id;

--21 Implicit join syntax(always better to use Join or explicit syntax)
select * from order_items OI,order_item_notes N 
where OI.order_id = N.order_Id and OI.product_id = N.product_id;

--22 join is inner join and left and right join are outer join
select P.product_id,name,quantity from products P left join order_items OI 
on  P.product_id = OI.product_id

--23 nesting two outer joins(best practise to use left join)
select order_date,order_id,first_name,SH.name,OS.name from orders O join customers C
on O.customer_id = C.customer_id left join shippers SH on SH.shipper_id = O.shipper_id
join order_statuses OS on OS.order_status_id = O.status;

--24 Self Outer joins
select emp.employee_id,emp.first_name,mngr.first_name as manager from [sql_hr].[dbo].[employees] emp 
left join [sql_hr].[dbo].[employees] mngr on emp.reports_to = mngr.employee_id;

--25 cross joins produces M x N products
--Implicit
select * from customers C cross join products P;
--Explicit
select * from customers C, products P;

--26 Union(does not contain duplicates) and union all
select first_name,points,'Elite' as type from customers where points <= 1000
union
-- order, type and number of columns should be same name of first sun query taken
select first_name,points,'Elite Pro' as sfdf from customers where points >1000
order by first_name;

--27 Insert here we can change order of fields
insert into customers (first_name,last_name) values ('jayesh','bhushan')
--here orders needs to be same
insert into customers values('jayesh','bhushan')

--28 Multiple Insert
insert into products values('d',2,3)
insert into shippers values('shipper 1')

--29 Gets Last insert id but if insert happen at another table it will be different
-- better use output clause to get the id
select SCOPE_IDENTITY();
select @@Identity;
select ident_current('products');
INSERT INTO shippers OUTPUT INSERTED.shipper_id VALUES ('Shipper 2');

--30 Copying a table only copies structure and data no constraints
SELECT * INTO product_archived FROM products;
--Conditional creation
Select *
into invoice_archived from 
(Select invoice_id, number, name as client,invoice_total,payment_total,invoice_date,payment_date,due_date
from sql_invoicing.dbo.invoices i join sql_invoicing.dbo.clients c 
on i.client_id = c.client_id where payment_date is not null) temp;

--31 update multi rows
update customers set points = points+50 where birth_date<'1990-01-01'

--32 update with subquery query in () is executed first
update orders set comments = 'Gold Customer' where customer_id IN
(select customer_id from customers where points>3000);

--33 aggregate functions count does not include null column use count(*) to do that
select 'First half of 2019' as duration,sum(invoice_total) as total_sales,sum(payment_total) as total_payment,
sum(invoice_total-payment_total) as expected
from sql_invoicing.dbo.invoices where due_date between '2019-01-01' and '2019-06-30'
union
select 'Second half of 2019' as duration,sum(invoice_total) as total_sales,sum(payment_total) as total_payment,
sum(invoice_total-payment_total) as expected
from sql_invoicing.dbo.invoices where due_date between '2019-07-01' and '2019-12-31'
union 
select 'Total' as duration,sum(invoice_total) as total_sales,sum(payment_total) as total_payment,
sum(invoice_total-payment_total) as expected
from sql_invoicing.dbo.invoices where due_date between '2019-01-01' and '2019-12-31'

--34 order and group by (check why not working correctly)
select date,payment_methods.name,temp.amt from payment_methods right join 
(select date,payment_id,SUM(amount) as amt from payments 
group by date,payment_id) temp
on temp.payment_id = payment_methods.payment_method_id
order by date;

--35 having clause (with having clause we filter after the rows are grouped 
--whereas in where rows are used before grouping)
select C.customer_id,SUM(quantity*unit_price) as total from customers C
join orders O on O.customer_id = C.customer_id
join order_items OI on O.order_id = OI.order_id
where state = 'VA'
group by C.customer_id
having SUM(quantity*unit_price) >100

--36 Rollup
select name,SUM(amount) from payments P
join payment_methods PM on PM.payment_method_id = P.payment_method
group by name with rollup

--37 subqueries
select * from employees where salary > (Select avg(salary) from employees);

--38 In operator
select * from clients where client_id not in (select distinct client_id from invoices)

--39 join vs subquery depends on performance and use case
select customer_id,first_name,last_name from customers where customer_id in (
select O.customer_id from order_items OI join orders O on OI.order_id = O.order_id
where OI.product_id = 3);

--40 All and Any keyword
select * from invoices where invoice_total > (select max(invoice_total) from invoices where
client_id = 3);
--Or using All operator
select * from invoices where invoice_total > All (select invoice_total from invoices where
client_id = 3);
--take min  as above or use the Any keyword with same syntax it works as a IN operator

--41 Correlated queries executes for each for in a table
select * from invoices i where invoice_total > (
select avg(invoice_total) from invoices where client_id = i.client_id);

--42 Exists operator checks whether a row matching criteria present
select * from products p where not exists(
	select * from order_items o where o.product_id=p.product_id 
);

--43 subqueries in select
select *,total_sales-average as diff from
(select c.client_id,name,sum(invoice_total) as total_sales,(select avg(invoice_total) from invoices) as
average
from clients c left join invoices i 
on c.client_id = i.client_id group by c.client_id,name) tmp;

--44 Subqueries in from 
select *,total_sales-average as diff from
(select c.client_id,name,sum(invoice_total) as total_sales,(select avg(invoice_total) from invoices) as
average
from clients c left join invoices i 
on c.client_id = i.client_id group by c.client_id,name) tmp;

--45 SQL Functions Maths
select round(2.334,2);
select ceiling(2.33);
select floor(2.33);
select ABS(-2.33);
select rand(1);
--removing a digit from number (0 here)
select (CAST(REPLACE(CAST(Salary AS VARCHAR(10)), '0', '') AS INT));

--string functions
select LOWER('hello');
select Upper('hello');
select Trim('   hello  ');
select LTrim('   hello  ');
select RTrim('   hello  ');
select left('hello',2);
select right('hello',3);
select substring('hello',2,4);
--returns index of first occurence and 0 if not found
SELECT CHARINDEX('H', 'hello',1); 
select replace('hello','e','o');
select concat('hello','world');

--date and time functions
SELECT SYSDATETIME()
    ,SYSDATETIMEOFFSET()
    ,SYSUTCDATETIME()
    ,CURRENT_TIMESTAMP
    ,GETDATE()
    ,GETUTCDATE();

declare @date DateTime;
set @date = CURRENT_TIMESTAMP;
select year(@date),month(@date),day(@date),
CONVERT(VARCHAR(10), @date, 108);

SELECT
DATENAME(WEEKDAY, @date) as DayName,
DATEPART(WEEKDAY, @date) as DayOfTheWeek,
DATENAME(MONTH, @date) As MonthName;

--formatting date and time
SELECT FORMAT(CURRENT_TIMESTAMP, 'dd-MM-yyyy hh:mm:ss tt')

--calculation in date and time
select dateadd(year,2,getdate()); 
select dateadd(year,-2,getdate()); --for subtracting date 
select dateadd(hour,2,getdate());
select datediff(day,getdate(),dateadd(day,2,getdate()));

--Isnull and colescce
use sql_store
--here datatype should be same
select isnull(shipper_id,-1) from orders;
select coalesce(shipper_id,order_id,-1) from orders;

--If Condition
IF (select order_date from orders where order_id=1)>='2019-01-01' 
       SELECT order_id,'Active' as category from orders where order_id=1
ELSE 
       SELECT order_id,'Old' as category from orders temp where order_id=1

--case condition
--we use else for default
select order_id, case when order_date>='2019-01-01' then 'new' 
when order_date<'2019-01-01' then 'old' else 'unknown' end as status from orders; 

--Views they do not store data they pickup from underlying table
-- using create or alter to create else alter if present
--The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, 
--and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
create or alter view client_balance as
select c.client_id, name, SUM(invoice_total-payment_total) as balance from invoices i join
clients c on i.client_id = c.client_id group by c.client_id,name;

select * from client_balance;

--updating records using view
--views can be update data only when distinct,aggregate,group by,union are not there
--the view also need to have all the same columns as well
--Any modifications, including UPDATE, INSERT, and DELETE statements, must reference columns 
--from only one base table.
update client_balance set balance=0 where client_id=1;
delete from client_balance where client_id=1;

--if you update or modify a view some rows may get excluded due to conditions in view
--to prevent this with check options is used

create or alter view client_balance as
select c.client_id, name, SUM(invoice_total-payment_total) as balance from invoices i join
clients c on i.client_id = c.client_id group by c.client_id,name with check option;

--Stored Procs
--organised and structured code 
--adds layer of security
--faster executions(optimisation by sql server its execution flow is stored)
create or alter procedure get_invoices_with_balance
as
select * from client_balance where balance>0;

--add if exists to avoid error if not present
drop procedure if exists get_invoices_with_balance;

create or alter procedure get_invoices_by_clientid(
@clientId int = 0,
@message int output)
as
if @clientId is null
--use begin and end to group a set of statements
Begin
	select * from clients
	return; 
end
if not exists (select * from clients where client_id = @clientId)
begin
	throw 50001,'client not found',1;
end
else
begin
set @message = 1;
select * from clients where client_id = @clientId;
end
--parameters - @clientId and argument will be its values here null
declare @msg int;
exec get_invoices_by_clientid 3, @msg output;
select @msg as message;

--Variables

--user/session variables
EXEC [sys].[sp_set_session_context] @key = 'SecurityObjectUserID'
                                   ,@value = @SecurityObjectUserID
                                   ,@read_only = 1;  
SELECT @SecurityObjectUserID = CONVERT(BIGINT,SESSION_CONTEXT(N'SecurityObjectUserID'));

--local variables inside a sp or function
Declare @af int = 0;
--to set a variable value use output

--Functions

--two types scalar and table valued

--scalar
create or alter function udf_Get_Client_Invoice_Number(
	@clientId int
)
returns int
as
begin
	declare @n int;
	Set @n = (select count(*) from invoices where client_id = @clientId);
	return @n;
end

select dbo.udf_Get_Client_Invoice_Number(2);

--Table Valued
create or alter function udf_Get_Client_Invoice_Number2(
	@clientId int
)
returns table
as
	return select * from invoices where client_id = @clientId;


select * from dbo.udf_Get_Client_Invoice_Number2(2);





