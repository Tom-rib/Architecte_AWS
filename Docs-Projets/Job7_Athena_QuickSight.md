# Job 7 : Athena + QuickSight - Analyse de données 📈

> Requêtes SQL sur S3 et visualisation avec dashboards

---

## 🎯 Objectif

Effectuer des requêtes SQL sur des données stockées dans S3 avec Athena et visualiser les résultats avec QuickSight pour créer des dashboards interactifs.

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| S3 | Stockage des données |
| Athena | Requêtes SQL serverless |
| QuickSight | Visualisation et dashboards |
| Glue Data Catalog | Métadonnées |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| S3 | 5 GB gratuit |
| Athena | $5/TB de données scannées |
| QuickSight | 1 mois d'essai gratuit |

⚠️ **Attention** : QuickSight coûte ~$12/mois après l'essai gratuit

---

## 🏗️ Architecture

```
S3 (CSV) → Athena (SQL) → QuickSight (Dashboards)
```

---

# Étape 1 : Préparer les données S3

## Fichiers de données

### customers.csv

```csv
customer_id,name,email,country,signup_date
1,John Smith,john@example.com,USA,2024-01-15
2,Marie Dupont,marie@example.com,France,2024-01-20
3,Anna Mueller,anna@example.com,Germany,2024-01-22
4,Carlos Garcia,carlos@example.com,Spain,2024-02-01
5,Yuki Tanaka,yuki@example.com,Japan,2024-02-05
6,Emma Wilson,emma@example.com,UK,2024-02-10
7,Lucas Martin,lucas@example.com,France,2024-02-15
8,Sofia Rossi,sofia@example.com,Italy,2024-02-20
9,Hans Schmidt,hans@example.com,Germany,2024-02-25
10,Li Wei,li@example.com,China,2024-03-01
```

### orders.csv

```csv
order_id,customer_id,amount,order_date,product
101,1,150.00,2024-02-01,Laptop
102,2,75.50,2024-02-05,Mouse
103,1,200.00,2024-02-10,Monitor
104,3,50.00,2024-02-15,Keyboard
105,2,300.00,2024-02-20,Tablet
106,4,125.00,2024-02-25,Headphones
107,5,450.00,2024-03-01,Phone
108,1,80.00,2024-03-05,Webcam
109,6,175.00,2024-03-10,Speaker
110,7,95.00,2024-03-15,Mouse
```

## 🖥️ Dashboard

```
1. S3 → Créer bucket : athena-data-VOTREPRENOM

2. Créer dossiers :
   - customers/
   - orders/
   - athena-results/

3. Uploader :
   - customers/customers.csv
   - orders/orders.csv
```

## 💻 CLI

```bash
# Créer le bucket
aws s3 mb s3://athena-data-tom --region eu-west-3

# Créer et uploader les fichiers
aws s3 cp customers.csv s3://athena-data-tom/customers/
aws s3 cp orders.csv s3://athena-data-tom/orders/
```

---

# Étape 2 : Configurer Athena

## 🖥️ Dashboard

```
1. Athena → Query editor

2. Settings → Manage

3. Query result location :
   s3://athena-data-tom/athena-results/

4. Save ✓
```

## 💻 CLI

```bash
# Créer un workgroup avec location de résultats
aws athena create-work-group \
  --name primary \
  --configuration '{
    "ResultConfiguration": {
      "OutputLocation": "s3://athena-data-tom/athena-results/"
    }
  }' \
  --region eu-west-3
```

---

# Étape 3 : Créer la Database et les Tables

## 🖥️ Athena Query Editor

### Créer la Database

```sql
CREATE DATABASE IF NOT EXISTS analytics_db;
```

### Créer la table customers

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS analytics_db.customers (
    customer_id INT,
    name STRING,
    email STRING,
    country STRING,
    signup_date STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://athena-data-tom/customers/'
TBLPROPERTIES ('skip.header.line.count'='1');
```

### Créer la table orders

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS analytics_db.orders (
    order_id INT,
    customer_id INT,
    amount DOUBLE,
    order_date STRING,
    product STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://athena-data-tom/orders/'
TBLPROPERTIES ('skip.header.line.count'='1');
```

## 💻 CLI

```bash
# Exécuter une requête via CLI
aws athena start-query-execution \
  --query-string "CREATE DATABASE IF NOT EXISTS analytics_db" \
  --result-configuration "OutputLocation=s3://athena-data-tom/athena-results/" \
  --region eu-west-3
```

---

# Étape 4 : Tester les requêtes SQL

## Requête 1 : Voir les données

```sql
SELECT * FROM analytics_db.customers LIMIT 10;
```

## Requête 2 : Compter les clients

```sql
SELECT COUNT(*) as total_customers 
FROM analytics_db.customers;
```

## Requête 3 : Clients par pays

```sql
SELECT 
    country, 
    COUNT(*) as count
FROM analytics_db.customers
GROUP BY country
ORDER BY count DESC;
```

## Requête 4 : Total des ventes

```sql
SELECT 
    ROUND(SUM(amount), 2) as total_sales,
    COUNT(*) as order_count,
    ROUND(AVG(amount), 2) as avg_order
FROM analytics_db.orders;
```

## Requête 5 : Ventes par produit

```sql
SELECT 
    product,
    COUNT(*) as quantity,
    ROUND(SUM(amount), 2) as total
FROM analytics_db.orders
GROUP BY product
ORDER BY total DESC;
```

## Requête 6 : JOIN - Clients avec leurs commandes

```sql
SELECT 
    c.name,
    c.country,
    COUNT(o.order_id) as order_count,
    ROUND(SUM(o.amount), 2) as total_spent
FROM analytics_db.customers c
LEFT JOIN analytics_db.orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.country
ORDER BY total_spent DESC;
```

## Requête 7 : Ventes par mois

```sql
SELECT 
    SUBSTRING(order_date, 1, 7) as month,
    COUNT(*) as order_count,
    ROUND(SUM(amount), 2) as total_sales
FROM analytics_db.orders
GROUP BY SUBSTRING(order_date, 1, 7)
ORDER BY month;
```

---

# Étape 5 : Configurer QuickSight

## 🖥️ Dashboard

```
1. QuickSight → Sign up for QuickSight
   (ou accédez si déjà inscrit)

2. Edition : Standard ($12/mois, 1 mois gratuit)

3. QuickSight account name : votreprenom-analytics

4. Notification email : votre-email@example.com

5. QuickSight access to AWS services :
   ☑ Amazon Athena
   ☑ Amazon S3
     - Sélectionnez : athena-data-tom

6. Finish ✓
```

---

# Étape 6 : Créer un Dataset Athena

## 🖥️ Dashboard

```
1. QuickSight → Datasets → New dataset

2. Sélectionnez : Athena

3. Data source name : Athena-Analytics

4. Athena workgroup : primary

5. Create data source ✓

6. Database : analytics_db

7. Tables : customers

8. Select ✓

9. Import to SPICE (recommandé pour performance)

10. Visualize ✓
```

---

# Étape 7 : Créer un Dashboard

## 🖥️ Dashboard

### Analyse 1 : Clients par pays

```
1. QuickSight → Analyses → New analysis

2. Dataset : customers

3. Drag & Drop :
   - Field : country → Y axis
   - Aggregation : Count → Values

4. Visual type : Horizontal bar chart

5. Title : "Clients par Pays"
```

### Analyse 2 : KPI - Total Clients

```
1. Add visual → KPI

2. Value : customer_id (Count)

3. Title : "Total Clients"
```

### Analyse 3 : Évolution des inscriptions

```
1. Add visual → Line chart

2. X axis : signup_date

3. Value : customer_id (Count)

4. Title : "Inscriptions par Date"
```

### Analyse 4 : Ventes par produit

```
1. Créer un nouveau dataset avec : orders

2. Add visual → Pie chart

3. Group/Color : product

4. Value : amount (Sum)

5. Title : "Ventes par Produit"
```

---

# Étape 8 : Publier le Dashboard

## 🖥️ Dashboard

```
1. Analysis → Share → Publish dashboard

2. Dashboard name : Analytics Dashboard

3. Publish ✓

4. Share with users (optionnel) :
   - Add users or groups
   - Set permissions (Viewer, Author)
```

---

# Étape 9 : Créer une requête custom dans QuickSight

## 🖥️ Dashboard

```
1. QuickSight → Datasets → New dataset → Athena

2. Use custom SQL

3. Collez cette requête :
```

```sql
SELECT 
    c.name,
    c.country,
    COUNT(o.order_id) as orders,
    COALESCE(SUM(o.amount), 0) as total_spent
FROM analytics_db.customers c
LEFT JOIN analytics_db.orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.country
```

```
4. Confirm query ✓

5. Dataset name : customer_orders_summary

6. Create & Visualize
```

---

# 🔧 Troubleshooting

## ❌ Athena : "No output location provided"

```
1. Settings → Manage
2. Configurez s3://bucket/athena-results/
3. Save
```

## ❌ Athena : "Table not found"

```
1. Vérifiez que la database est sélectionnée
2. Vérifiez le nom de la table
3. Re-exécutez CREATE TABLE
```

## ❌ QuickSight : "Access Denied to S3"

```
1. QuickSight → Manage QuickSight
2. Security & permissions → QuickSight access to AWS services
3. ☑ Cochez votre bucket S3
```

## ❌ Données vides dans QuickSight

```
1. Vérifiez que SPICE a importé les données
2. Dataset → Refresh SPICE
3. Vérifiez la requête Athena directement
```

---

# 🧹 Nettoyage

```bash
# 1. Supprimer les tables Athena
aws athena start-query-execution \
  --query-string "DROP TABLE analytics_db.customers" \
  --result-configuration "OutputLocation=s3://athena-data-tom/athena-results/"

aws athena start-query-execution \
  --query-string "DROP TABLE analytics_db.orders" \
  --result-configuration "OutputLocation=s3://athena-data-tom/athena-results/"

aws athena start-query-execution \
  --query-string "DROP DATABASE analytics_db" \
  --result-configuration "OutputLocation=s3://athena-data-tom/athena-results/"

# 2. Vider et supprimer le bucket S3
aws s3 rm s3://athena-data-tom --recursive
aws s3 rb s3://athena-data-tom

# 3. QuickSight (Dashboard) :
# Manuellement : QuickSight → Account settings → Unsubscribe
```

---

## ✅ Checklist Finale

- [ ] Bucket S3 créé avec données CSV
- [ ] Athena configuré (output location)
- [ ] Database et tables créées
- [ ] Requêtes SQL testées (7 requêtes)
- [ ] QuickSight inscrit
- [ ] Dataset Athena créé
- [ ] Dashboard avec visualisations
- [ ] Dashboard publié

---

[⬅️ Retour : Job6](./Job6_Glue_ETL.md) | [➡️ Suite : Job8_ECS_Fargate.md](./Job8_ECS_Fargate.md)
