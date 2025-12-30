# Athena: Databases & Tables 🗄️

Comment créer et gérer bases de données et tables dans Athena.

---

## Databases

Une database = Container pour vos tables.

### Créer une database

```sql
CREATE DATABASE IF NOT EXISTS ma_base;
```

### Lister les databases

```sql
SHOW DATABASES;
```

### Supprimer une database

```sql
DROP DATABASE IF EXISTS ma_base;
```

---

## Tables

Une table = Structure pour vos données.

### Créer une table simple (CSV)

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS customers (
    customer_id INT,
    name STRING,
    email STRING,
    age INT,
    country STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES ('field.delim' = ',')
LOCATION 's3://mon-bucket/data/customers/';
```

### Créer une table Parquet

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS customers_parquet (
    customer_id INT,
    name STRING,
    email STRING,
    age INT,
    country STRING
)
STORED AS PARQUET
LOCATION 's3://mon-bucket/data/customers_parquet/';
```

### Avec partitions

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS customers (
    customer_id INT,
    name STRING,
    email STRING
)
PARTITIONED BY (year INT, month INT)
STORED AS PARQUET
LOCATION 's3://mon-bucket/data/customers/';

-- Ajouter partitions
ALTER TABLE customers ADD PARTITION (year=2024, month=01);
ALTER TABLE customers ADD PARTITION (year=2024, month=02);
```

---

## Colonne Types

```
STRING          → Texte
INT             → Entier
BIGINT          → Grand entier
DOUBLE          → Nombre décimal
BOOLEAN         → True/False
DATE            → Date (2024-01-01)
TIMESTAMP       → Date + temps (2024-01-01 10:30:00)
ARRAY           → Liste
MAP             → Clé-valeur
STRUCT          → Objet imbriqué
```

---

## Opérations courantes

### Voir tables

```sql
SHOW TABLES;
SHOW TABLES IN ma_base;
```

### Voir structure

```sql
DESCRIBE customers;
DESCRIBE FORMATTED customers;
```

### Renommer

```sql
ALTER TABLE customers RENAME TO customers_old;
```

### Ajouter colonne

```sql
ALTER TABLE customers ADD COLUMN phone_number STRING;
```

### Supprimer table

```sql
DROP TABLE IF EXISTS customers;
```

---

## Test SELECT

```sql
-- Récupérer quelques lignes pour tester
SELECT * FROM customers LIMIT 5;

-- Compter lignes
SELECT COUNT(*) FROM customers;

-- Vérifier données
SELECT * FROM customers WHERE customer_id = 1;
```

---

**Databases & Tables Terminé! ✅**
