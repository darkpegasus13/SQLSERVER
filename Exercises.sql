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

--22 



