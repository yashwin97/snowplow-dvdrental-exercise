create table if not exists film_recommendations
as 
--Creates a table with a genre unique for each customer
with customer_selection as (
select distinct customer,movie_genre
from (
SELECT customer.customer_id AS customer, category.name AS movie_genre,SUM(rental_duration) as duration,language_id, COUNT(category.name) AS num_rented,rating,row_number () over (partition by customer.customer_id order by COUNT(category.name)desc,SUM(rental_duration) ) as rn
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
JOIN rental ON payment.rental_id = rental.rental_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
join film ON  film_category.film_id = film.film_id 
GROUP BY customer, movie_genre,film.rating,language_id 
ORDER BY customer, num_rented DESC) t  
where rn= 1
),movie_list as (
select title as film_title, name as movie_genre 
from film f
join film_category fc 
USING(film_id)
join category c
USING(category_id)
), customer_watched as (
select customer_id, title as film_title, name as movie_genre 
from rental r
join inventory i 
USING(inventory_id)
join film
USING(film_id)
join film_category fc 
USING(film_id)
join category c
USING(category_id)
order by 1
),
--Aggregating the results and excluding movies already watched by customer
final_table as (
select customer,title, row_number () over (partition by customer order by title ) as rn
from (
select customer,cs.movie_genre,ml.film_title as title
from customer_selection cs
join movie_list ml
on cs.movie_genre = ml.movie_genre 
except 
select customer_id, name as movie_genre, title as film_title 
from rental r
join inventory i 
USING(inventory_id)
join film
USING(film_id)
join film_category fc 
USING(film_id)
join category c
USING(category_id)
) t
order by 1,3 )
select customer as customer_id, title
from final_table 
where rn <= 10;