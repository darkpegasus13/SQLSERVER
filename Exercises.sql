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
