with initial_table as (
select EXTRACT(month from r.rental_date) as month,r.customer_id as cid,SUM(amount) as rental_amount
from payment p 
join rental r 
USING(rental_id)
where EXTRACT(year from r.rental_date) = 2005
group by 1,2
order by 3 desc
),bottom as (
select * 
from initial_table
order by 3 asc
limit (SELECT (count(*) / 10) AS selnum FROM initial_table)
), top as (
select * 
from initial_table
order by 3 desc
limit (SELECT (count(*) / 10) AS selnum FROM initial_table)
)
select store_id, month, AVG(rental_amount)
from (
select store_id,EXTRACT(month from r.rental_date) as month,r.customer_id as cust_id,SUM(amount) as rental_amount
from store s
join staff s2 
USING(store_id)
join payment p 
USING(staff_id)
join rental r 
USING(rental_id)
where EXTRACT(year from r.rental_date) = 2005 
group by 1,2,3
order by 1,2,3,4 desc 
) t
where cust_id not in (select cid from top) and cust_id not in (select cid from bottom)
group by 1,2