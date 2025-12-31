# Athena: SQL Queries 📝

Requêtes SQL complètes pour Athena (Presto SQL).

---

## SELECT Basique

```sql
-- Tout
SELECT * FROM customers;

-- Colonnes spécifiques
SELECT customer_id, name, email FROM customers;

-- Avec alias
SELECT customer_id AS id, name AS customer_name FROM customers;

-- DISTINCT
SELECT DISTINCT country FROM customers;

-- LIMIT
SELECT * FROM customers LIMIT 10;
```

---

## WHERE (Filtres)

```sql
-- Égal
SELECT * FROM customers WHERE country = 'France';

-- Numérique
SELECT * FROM customers WHERE age > 30;
SELECT * FROM customers WHERE age >= 30 AND age <= 65;

-- Texte
SELECT * FROM customers WHERE name LIKE 'A%';
SELECT * FROM customers WHERE name LIKE '%john%';

-- IN
SELECT * FROM customers WHERE country IN ('France', 'Germany', 'Spain');

-- NOT NULL
SELECT * FROM customers WHERE email IS NOT NULL;

-- Combinaisons
SELECT * FROM customers 
WHERE (country = 'France' OR country = 'Germany')
AND age > 25;
```

---

## ORDER BY & LIMIT

```sql
-- Trier croissant
SELECT * FROM customers ORDER BY name ASC;

-- Trier décroissant
SELECT * FROM customers ORDER BY age DESC;

-- Multi-colonnes
SELECT * FROM customers ORDER BY country, name;

-- Avec LIMIT
SELECT * FROM customers ORDER BY age DESC LIMIT 10;
```

---

## Agrégations

```sql
-- Compter
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(DISTINCT country) FROM customers;

-- Somme
SELECT SUM(purchase_amount) AS total_spent FROM orders;

-- Moyenne
SELECT AVG(age) AS average_age FROM customers;

-- Min/Max
SELECT MIN(age), MAX(age) FROM customers;
SELECT MIN(purchase_date), MAX(purchase_date) FROM orders;

-- GROUP BY
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC;

-- HAVING (filter après GROUP BY)
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country
HAVING COUNT(*) > 100
ORDER BY customer_count DESC;
```

---

## JOINs

```sql
-- INNER JOIN (intersection)
SELECT c.name, o.amount, o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- LEFT JOIN (tout du left, match du right)
SELECT c.name, COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- Multiple JOINs
SELECT c.name, o.amount, p.product_name
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN products p ON o.product_id = p.product_id;
```

---

## Fonctions String

```sql
-- Majuscules/minuscules
SELECT UPPER(name), LOWER(email) FROM customers;

-- Longueur
SELECT name, LENGTH(name) FROM customers;

-- Sous-chaîne
SELECT SUBSTRING(email, 1, 5) FROM customers;

-- Remplacer
SELECT REPLACE(name, 'John', 'Jean') FROM customers;

-- Trim (enlever espaces)
SELECT TRIM(name) FROM customers;

-- Concat
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM customers;
```

---

## Fonctions Date

```sql
-- Date actuelle
SELECT CURRENT_DATE;
SELECT CURRENT_TIMESTAMP;

-- Extraire partie
SELECT DATE(creation_date) FROM customers;
SELECT YEAR(creation_date) FROM customers;
SELECT MONTH(creation_date) FROM customers;
SELECT DAY(creation_date) FROM customers;

-- Ajouter/soustraire
SELECT DATE_ADD('day', 7, creation_date) FROM customers;
SELECT DATE_FORMAT(creation_date, '%Y-%m') FROM customers;

-- Différence
SELECT DATE_DIFF('day', creation_date, CURRENT_DATE) AS days_since FROM customers;
```

---

## Fonctions Math

```sql
-- Arrondissement
SELECT ROUND(price, 2) FROM products;

-- Valeur absolue
SELECT ABS(amount) FROM transactions;

-- Puissance
SELECT POWER(2, 10) FROM table;  -- 1024

-- Racine carrée
SELECT SQRT(amount) FROM table;
```

---

## CTE (WITH)

```sql
WITH customer_purchases AS (
    SELECT customer_id, COUNT(*) AS purchase_count, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT c.name, cp.purchase_count, cp.total_spent
FROM customers c
INNER JOIN customer_purchases cp ON c.customer_id = cp.customer_id
WHERE cp.total_spent > 1000;
```

---

## Sous-requêtes

```sql
-- Dans WHERE
SELECT * FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM orders WHERE amount > 500
);

-- Dans FROM
SELECT high_spenders.customer_id, high_spenders.total_spent
FROM (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM orders
    GROUP BY customer_id
    HAVING SUM(amount) > 1000
) AS high_spenders;
```

---

## Window Functions

```sql
-- Row number
SELECT 
    name, 
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS rank
FROM employees;

-- Partitioned
SELECT 
    department, 
    name, 
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
FROM employees;

-- Running total
SELECT 
    order_date, 
    amount,
    SUM(amount) OVER (ORDER BY order_date) AS running_total
FROM orders;
```

---

**SQL Queries Terminé! ✅**
