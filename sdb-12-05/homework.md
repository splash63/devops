# Домашнее задание к занятию "`Индексы`" - `Гайченков Евгений`

## Задание 1

![alt text](https://github.com/splash63/devops/blob/main/sdb-12-05/img/1.png)

## Задание 2

```bash
SELECT
    c.last_name || ' ' || c.first_name AS customer_name,
    f.title AS film_title,
    SUM(p.amount) AS total_amount
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
    AND p.payment_date = r.rental_date
JOIN customer c ON r.customer_id = c.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE p.payment_date >= '2005-07-30'
  AND p.payment_date < '2005-07-31'
GROUP BY c.customer_id, c.last_name, c.first_name, f.title;
```
