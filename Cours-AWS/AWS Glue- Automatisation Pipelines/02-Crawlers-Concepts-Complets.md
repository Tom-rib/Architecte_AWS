# AWS Glue Crawlers - Guide Complet 🔍

Tout sur les crawlers Glue pour détecter et cataloguer vos données.

---

## TABLE DES MATIÈRES

1. [Qu'est-ce qu'un Crawler ?](#qu-est-ce-quun-crawler-)
2. [Fonctionnement](#fonctionnement)
3. [Configuration](#configuration)
4. [Sources Supportées](#sources-supportées)
5. [Schéma Detection](#schéma-detection)
6. [Partitions](#partitions)
7. [Scheduling](#scheduling)
8. [Best Practices](#best-practices)

---

## Qu'est-ce qu'un Crawler ?

Service qui :
- Scanne vos données
- Détecte schémas automatiquement
- Crée/met à jour table Catalog
- Aucun code à écrire

```
Crawler
│
├─ Entrée: S3 path (ou RDS, Redshift, etc)
├─ Opération: Lire sample + détecter
├─ Sortie: Table dans Glue Catalog
└─ Trigger: Schedule ou manual
```

---

## Fonctionnement

### Étapes d'Exécution

```
1. Lancer Crawler
2. Connecter à source (S3, RDS, etc)
3. Scanner fichiers/tables
4. Lire sample rows
5. Inférer types:
   ├─ "123" → integer
   ├─ "hello" → string
   ├─ "2024-01-01" → date
   └─ "45.67" → double
6. Créer schéma
7. Créer/mettre à jour table Catalog
8. Enregistrer partitions (si existent)
```

### Détection Smart

```
CSV File:
id,name,created_at
1,Alice,2024-01-01
2,Bob,2024-01-02
3,Charlie,2024-01-03

Crawler detects:
┌────────────┬──────┬───────────┐
│ Column     │ Type │ Nullable  │
├────────────┼──────┼───────────┤
│ id         │ int  │ false     │
│ name       │ str  │ false     │
│ created_at │ date │ false     │
└────────────┴──────┴───────────┘
```

---

## Configuration

### Créer un Crawler (Console)

```
1. AWS Glue > Crawlers
2. "Create crawler"
3. Remplir:
   ├─ Name: customers-crawler
   ├─ Source:
   │  ├─ Type: S3
   │  ├─ Path: s3://mybucket/customers/
   │  └─ Include patterns: *.csv
   ├─ Output:
   │  ├─ Database: default
   │  └─ Table prefix: raw_
   ├─ Schedule: Daily 00:00
   └─ "Create"
```

### Via CLI

```bash
aws glue create-crawler \
  --name customers-crawler \
  --database-name default \
  --description "Crawl customer data" \
  --targets S3Targets=[{Path=s3://mybucket/customers/}] \
  --role arn:aws:iam::ACCOUNT_ID:role/GlueServiceRole \
  --schedule-expression "cron(0 0 * * ? *)" \
  --region eu-west-3
```

---

## Sources Supportées

```
Crawler peut lire:
├─ S3 (fichiers)
├─ RDS (tables)
├─ Redshift (tables)
├─ DynamoDB (tables)
├─ JDBC (database)
├─ MongoDB (collections)
└─ Kafka (topics)
```

---

## Schéma Detection

### Type Inference

```
Glue essaie de détecter le type correct

Exemples:
"2024-01-01" → timestamp (avec context)
"2024" → int (sans context)
"45.67" → double
"true" / "false" → boolean
"123" → int

Problèmes:
"NA" → string (not double)
"" → string (empty)
NULL → inferred from other rows
```

### Partition Detection

```
Crawler détecte partitions auto

Exemple S3:
s3://bucket/data/
├─ year=2024/month=01/customers.csv
├─ year=2024/month=02/customers.csv
└─ year=2025/month=01/customers.csv

Crawler crée:
Table: data
Partitions: year (int), month (int)

Avantage: Requête année=2024 scanne seulement 2024
```

---

## Partitions

### Partition Keys

```
Définir partitions pour optimiser requêtes:

Avant:
s3://bucket/customers/ (1GB → 5 sec query)

Après (partitionné):
s3://bucket/customers/year=2024/month=01/ (100MB → 0.5 sec)

Crawler peut auto-détecter structure S3:
year=2024/month=01/ → partitions year, month
```

---

## Scheduling

### Options

```
On-demand:
├─ Crawler runs manuellement
├─ Quand: aws glue start-crawler
└─ Use: Testing, debug

Scheduled:
├─ Crawler runs automatiquement
├─ Options:
│  ├─ Hourly: cron(0 * * * ? *)
│  ├─ Daily: cron(0 0 * * ? *)
│  ├─ Weekly: cron(0 0 ? * MON *)
│  └─ Custom: cron(15 12 * * ? *)
└─ Use: Production daily crawls

CloudWatch Events:
├─ Trigger sur événement
├─ Ex: S3 object created
└─ Use: Real-time updates
```

---

## Best Practices

### 1. Naming

```
❌ crawler1, c1, data_crawler_v2

✅ customers-raw-crawler
✅ orders-raw-crawler
✅ logs-archive-crawler
```

### 2. Database Organization

```
❌ Tout dans "default" database

✅ Separate databases:
├─ database: raw_data
│  ├─ table: customers
│  └─ table: orders
└─ database: clean_data
   ├─ table: customers_clean
   └─ table: orders_clean
```

### 3. Include/Exclude Patterns

```
Include patterns:
├─ *.csv (tous CSV)
├─ *.parquet (tous Parquet)
└─ data_*.json (data files seulement)

Exclude patterns:
├─ _temp/* (temp files)
├─ .logs/* (logs)
└─ *.tmp (temporary)
```

### 4. Schedule Optimization

```
❌ Crawler toutes les heures (si data changes daily)
├─ Coûteux
├─ Inutile

✅ Crawler une fois par jour (après bulk load)
├─ Efficace
├─ Suffit pour metadata
```

---

## Dépannage

### Crawler runs mais aucune table créée

```
Causes:
1. Source vide (no files)
2. Wrong path (typo)
3. Include patterns trop restrictif
4. IAM permissions manquantes

Solutions:
1. Vérifier chemin S3
2. Vérifier fichiers existent
3. Élargir patterns
4. Ajouter S3 read permissions
```

### Types détectés incorrectement

```
Cause: Sample rows ambigus

Solution:
1. Vérifier données source
2. Augmenter sample size (crawler settings)
3. Editer schéma manuellement après crawl
4. Utiliser Glue jobs pour fix
```

---

**Coût**: 1M DPU-seconds/mois GRATUIT (puis $0.44/DPU-hour)
