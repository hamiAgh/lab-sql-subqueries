#1. How many copies of the film Hunchback Impossible exist in the inventory system?
USE sakila;
SELECT * FROM film WHERE title='Hunchback Impossible';


SELECT COUNT(inventory_id) FROM inventory 
WHERE film_id = (SELECT film_id 
			FROM film
            WHERE title='Hunchback Impossible');


#2. List all films whose length is longer than the average of all the films.
SELECT AVG(length) FROM film; #so averagw length is 115

SELECT film_id, title,length FROM film
WHERE length > (SELECT AVG(length) 
                FROM film)
ORDER BY length ASC;

#3. Use subqueries to display all actors who appear in the film Alone Trip.

#if we don't want the actor name
SELECT actor_id FROM film_actor 
WHERE film_id = (SELECT film_id
                 FROM film
                 WHERE title= 'Alone Trip');

#if we want the actor name

SELECT fa.actor_id, a.first_name, a.last_name FROM film_actor AS fa
JOIN actor AS a
USING (actor_id)
WHERE film_id = (SELECT film_id
                 FROM film
                 WHERE title= 'Alone Trip');


#4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT * FROM category; #name of category is Family 

#if we don't want the film title
SELECT film_id FROM film_category
WHERE category_id= (SELECT category_id
					FROM category
                    WHERE name='Family');

#if we want the film title
SELECT fc.film_id, f.title FROM film_category AS fc
JOIN film AS f
USING (film_id)
WHERE category_id= (SELECT category_id
					FROM category
                    WHERE name='Family');
                    
#5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
#Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.


SELECT first_name, last_name, email FROM customer
									WHERE address_id IN 
                                    (SELECT address_id FROM address 
                                    WHERE city_id IN 
                                    (SELECT city_id FROM city 
                                    WHERE country_id = 
                                    (SELECT country_id FROM country 
                                    WHERE country='Canada')));

SELECT c.first_name, c.last_name, c.email, co.country FROM customer AS c
JOIN address AS a
USING (address_id)
JOIN city as ci
USING (city_id)
JOIN country as co
USING (country_id)
WHERE country='Canada';

#6.Which are films starred by the most prolific actor? 
#Most prolific actor is defined as the actor that has acted in the most number of films. 
#First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

FROM film
WHERE film_id IN 
    (SELECT film_id
    FROM film_actor
    WHERE actor_id IN 
        (SELECT actor_id
        FROM 
            (SELECT actor_id, COUNT(film_id) AS num_films
            FROM film_actor
            GROUP BY actor_id
            ORDER BY num_films DESC
            LIMIT 1) 
		AS prolific_actor));
        
#7. Films rented by most profitable customer. 
#You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments


SELECT title
FROM film
WHERE film_id IN 
    (SELECT film_id
    FROM rental
    WHERE customer_id IN 
        (SELECT customer_id FROM 
		(SELECT customer_id, SUM(amount) AS total_payments FROM payment
		GROUP BY customer_id
		ORDER BY total_payments DESC LIMIT 1) 
        AS most_profitable_customer));
        
#8.Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

SELECT customer_id, SUM(amount) AS total_amount_spent FROM payment
GROUP BY customer_id 
HAVING total_amount_spent > (SELECT AVG(total_amount) 
							FROM (SELECT customer_id, SUM(amount) AS total_amount
                            FROM payment
                            ORDER BY total_amount_spent ASC));