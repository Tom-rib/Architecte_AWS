# Athena Basics 🔍

Qu'est-ce que Amazon Athena et comment l'utiliser?

---

## Qu'est-ce que Athena?

**Athena** = Service AWS pour faire des **requêtes SQL sur des données dans S3** - Sans serveur.

```
Traditionnel:
Données → Base de données → Requête SQL

Athena:
Données (S3) → Athena (SQL Engine) → Résultats
            (directement, pas de DB)
```

**Avantage:** Pas besoin de créer/maintenir une base de données. Juste du SQL sur vos fichiers!

---

## Comment ça marche?

### 1. Vous mettez les données dans S3
```
s3://mon-bucket/data/customers.csv
s3://mon-bucket/data/orders.parquet
```

### 2. Vous créez une table Athena
```sql
CREATE TABLE customers (
    id INT,
    name STRING,
    email STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES ('field.delim' = ',')
LOCATION 's3://mon-bucket/data/';
```

### 3. Vous écrivez des requêtes SQL
```sql
SELECT COUNT(*) as total
FROM customers
WHERE name LIKE 'A%';
```

### 4. Athena scanne les fichiers S3
```
Athena lit directement depuis S3
Aucune copie des données
```

### 5. Vous obtenez les résultats
```
total
─────
1,234
```

---

## Pourquoi Athena?

✅ **Sans serveur** - AWS gère tout
✅ **Pas de setup** - Quelques secondes pour commencer
✅ **Serverless SQL** - Pas de database à maintenir
✅ **Coûts bas** - Pay-per-query
✅ **Scalable** - Fonctionne sur petits et gros fichiers
✅ **Intégré** - Fonctionne directement avec S3
✅ **Standard SQL** - Syntaxe SQL classique

---

## Limitations

❌ **Pas temps réel** - Requêtes en secondes/minutes, pas millisecondes
❌ **Pas de transactions** - Pas d'ACID guarantees
❌ **Requêtes limitées** - 30 min max (configurable)
❌ **Pas idéal pour modif** - Pas d'UPDATE/DELETE natif
❌ **Coûts S3** - Scanner tout = coûts S3

---

## Pricing

### Modèle de coûts

```
Athena:
  └─ $5 par TB scanné

Exemple:
├─ Query scanne 100 GB → $0.50
├─ Query scanne 1 TB → $5
└─ Query scanne 10 TB → $50

Free Tier:
  └─ 1M requêtes/mois (gratuit premier mois)
```

---

## Architecture Athena

```
┌────────────────────┐
│   Athena Console   │
│  (Query Editor)    │
└────────┬───────────┘
         │ Requête SQL
┌────────▼──────────────────────┐
│  Athena Query Engine           │
│  1. Parse SQL                  │
│  2. Plan execution             │
│  3. Scan S3                    │
│  4. Compute résultats          │
└────────┬──────────────────────┘
         │
┌────────▼──────────────────────┐
│  S3 (Data Source)              │
│  ├─ customers.csv             │
│  ├─ orders.parquet            │
│  └─ products.json             │
└────────┬──────────────────────┘
         │
┌────────▼──────────────────────┐
│  S3 (Results)                  │
│  ├─ query-results/123/...     │
│  ├─ results.csv               │
│  └─ results.json              │
└────────────────────────────────┘
```

---

## Concepts Clés

### Database
Collection de tables. Organise vos données.

```sql
CREATE DATABASE ma_base;
USE ma_base;
```

### Table
Structure avec colonnes et types.

```sql
CREATE TABLE customers (
    id INT,
    name STRING,
    email STRING
)
LOCATION 's3://bucket/data/';
```

### Query
Requête SQL pour récupérer des données.

```sql
SELECT * FROM customers WHERE id > 100;
```

### Result
Fichier CSV/Parquet avec les résultats.

```
s3://query-results-bucket/query-123/results.csv
```

### Partition
Groupement de données pour optimiser les requêtes.

```
s3://bucket/data/year=2024/month=01/
s3://bucket/data/year=2024/month=02/
```

---

## SQL dans Athena

Athena supporte **Presto SQL** - Très similaire à SQL classique.

### Basiques

```sql
-- Sélectionner tout
SELECT * FROM customers;

-- Colonnes spécifiques
SELECT id, name FROM customers;

-- Avec WHERE
SELECT * FROM customers WHERE age > 30;

-- Trier
SELECT * FROM customers ORDER BY name;

-- Limiter
SELECT * FROM customers LIMIT 10;
```

### Agrégations

```sql
-- Compter
SELECT COUNT(*) FROM customers;

-- Moyenne
SELECT AVG(age) FROM customers;

-- Somme
SELECT SUM(amount) FROM orders;

-- Grouper
SELECT country, COUNT(*) as count 
FROM customers 
GROUP BY country;
```

### JOINs

```sql
-- Inner join
SELECT c.name, o.amount
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id;

-- Left join
SELECT c.name, COUNT(o.id) as order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.name;
```

### Fonctions

```sql
-- String functions
SELECT UPPER(name), LOWER(email) FROM customers;
SELECT LENGTH(name) FROM customers;
SELECT SUBSTRING(email, 1, 5) FROM customers;

-- Date functions
SELECT DATE(creation_date) FROM customers;
SELECT YEAR(creation_date) FROM customers;
SELECT MONTH(creation_date) FROM customers;

-- Math
SELECT ROUND(price, 2) FROM products;
SELECT ABS(-100) FROM table;
```

---

## Cas d'usage

### ✅ BON CAS
- Analyser logs S3
- Explorer des données historiques
- Ad-hoc queries
- Data exploration
- Rapports une fois/jour
- Data warehouse queries
- Machine learning prep

### ❌ MAUVAIS CAS
- Applications en temps réel (< 100ms)
- Mises à jour fréquentes (UPDATE/DELETE)
- Gros volumes (> 100 TB par requête)
- Transactions ACID nécessaires
- Requêtes très fréquentes (1000x/sec)

---

## Quand utiliser Athena vs alternatives?

```
Athena:
├─ Données déjà dans S3
├─ Ad-hoc queries
├─ Analyse historique
└─ Coûts variables OK

RDS/MySQL:
├─ Besoin temps réel
├─ Transactions ACID
├─ Updates fréquentes
└─ Petits volumes

Redshift:
├─ Data warehouse complet
├─ Gros volumes (> 100 GB)
├─ Requêtes complexes
└─ BI avancée

Elasticsearch:
├─ Recherche full-text
├─ Analyse logs real-time
├─ Faceting/aggregations
└─ APIs avancées
```

---

## Prochains pas

→ **[S3 & Data Organization](./03-S3-Data-Organization.md)** - Préparer vos données

→ **[Athena Databases & Tables](./04-Athena-Databases.md)** - Créer des tables

→ **[Athena SQL Queries](./05-Athena-SQL.md)** - Écrire requêtes

---

**Athena Basics Terminé! ✅**
