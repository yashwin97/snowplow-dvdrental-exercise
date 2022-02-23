select title, category
from (
SELECT f.title, c.name as category, row_number () over (partition by c.name order by COUNT(r.rental_id) desc) as r_num
FROM film_category fc
JOIN category c
USING(category_id)
JOIN film f
USING(film_id)
JOIN inventory i
USING(film_id)
JOIN rental r 
USING(inventory_id)
where EXTRACT(year from r.rental_date) = 2005
GROUP BY 1, 2
) t 
where r_num <= 10
order by 2, 1