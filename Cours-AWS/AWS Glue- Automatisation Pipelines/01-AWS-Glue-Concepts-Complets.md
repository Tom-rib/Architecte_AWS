# AWS Glue - Guide Complet & Référence 🔧

Service AWS pour découvrir, préparer et transformer les données à grande échelle.

---

## TABLE DES MATIÈRES

1. [Qu'est-ce que AWS Glue ?](#qu-est-ce-que-aws-glue-)
2. [Composants Principaux](#composants-principaux)
3. [Glue Catalog](#glue-catalog)
4. [Crawlers](#crawlers)
5. [Jobs](#jobs)
6. [Architecture](#architecture)
7. [Pricing](#pricing)
8. [Best Practices](#best-practices)

---

## Qu'est-ce que AWS Glue ?

Service **ETL (Extract, Transform, Load)** entièrement géré qui facilite :

```
Extract (Extraire)
├─ Lire données depuis S3, RDS, Redshift, DynamoDB
└─ Détecter schémas automatiquement

Transform (Transformer)
├─ Nettoyer données (supprimer nulls, valeurs invalides)
├─ Convertir formats (CSV → Parquet)
├─ Joindre tables
└─ Enrichir avec lookups

Load (Charger)
├─ Écrire dans S3
├─ Envoyer vers Redshift
├─ Ou autre destination
└─ Partitionné et optimisé
```

### Comparaison avec alternatives

| Outil | Glue | Lambda | EC2 | DataPipeline |
|---|---|---|---|---|
| **Type** | ETL Managed | Serverless | On-premise | Orchestration |
| **Scaling** | Auto | Auto | Manual | Auto |
| **Coût** | Pay per DPU | Pay per exec | Pay per hour | Moins cher |
| **Idéal pour** | Gros volumes | Petit jobs | Full control | Workflow |
| **Langage** | PySpark, Scala | Python, Node | Tous | Shell script |

---

## Composants Principaux

### 1. CRAWLER (Explorateur)

**Rôle** : Parcourir S3 et détecter les schémas automatiquement

```
Crawler
│
├─ Lit fichiers S3
├─ Détecte colonnes
├─ Détecte types (int, string, date)
├─ Crée table dans Catalog
└─ Planifiable (hourly, daily, on-demand)
```

**Exemple** :
```
Input: s3://mybucket/customers/
├─ customers.csv
│  └─ id, name, email, age
└─ customers_new.csv
   └─ id, name, email, age, phone

Crawler crée/met à jour:
Table: customers
Schéma: id (int), name (string), email (string), age (int), phone (string)
```

**Coût** : Gratuit (1M requêtes/mois incluses)

---

### 2. CATALOG (Métadonnées)

**Rôle** : Stocker métadonnées (schémas, types, partitions)

```
Glue Catalog
│
├─ Database (container)
│  └─ Tables (schémas)
│     ├─ Colonnes
│     ├─ Types
│     ├─ Partitions
│     ├─ Location S3
│     └─ Format
│
└─ Accessible par:
   ├─ Glue Jobs
   ├─ Athena (requêtes SQL)
   ├─ Redshift Spectrum
   └─ EMR
```

**Avantages** :
- Schema once, use everywhere
- Pas de duplication de metadata
- Centralisé et versionné
- Searchable

---

### 3. JOB (Transformation)

**Rôle** : Exécuter code PySpark/Scala pour transformer données

```
Job Glue
│
├─ Lit depuis Catalog
├─ Exécute code PySpark
├─ Transforme données
└─ Écrit vers S3/Redshift/etc

Architecture:
Job → Spark cluster (auto-scaled)
     → DPU allocation (1-100 DPUs)
     → Parallélisation auto
     → Coûts basés sur temps exec
```

**Langage** : PySpark (Python) ou Scala

**Execution** :
- On-demand (manual trigger)
- Scheduled (cron)
- Event-based (S3 upload)

---

### 4. TRIGGER (Orchestration)

**Rôle** : Automatiser exécution de jobs/crawlers

```
Trigger
│
├─ Types:
│  ├─ Crawler complete (après crawler fini)
│  ├─ Scheduled (cron: daily, hourly, etc)
│  ├─ On-demand (manual)
│  └─ CloudWatch Events
│
└─ Actions:
   ├─ Lancer crawler
   ├─ Lancer job
   └─ Notification SNS
```

---

## Glue Catalog

### Database

Container pour organiser tables

```
database: sales_data
├─ Table: customers
├─ Table: orders
└─ Table: products

database: logs
├─ Table: app_logs
└─ Table: error_logs
```

### Table

Schéma + métadonnées

```
Table: customers
├─ Location: s3://mybucket/customers/
├─ Format: parquet
├─ Partitions: year, month
│
├─ Colonnes:
│  ├─ id (bigint) - primary
│  ├─ name (string)
│  ├─ email (string)
│  ├─ phone (string)
│  ├─ created_at (timestamp)
│  └─ year (int) - partition
│
└─ Properties:
   ├─ Classification: parquet
   ├─ Compression: snappy
   └─ Stored as Parquet
```

### Partitions

Optimiser requêtes par division données

```
Sans partition:
s3://mybucket/customers/
├─ customer_1.parquet
├─ customer_2.parquet
└─ ... (tout dans un endroit)

Avec partition (year/month):
s3://mybucket/customers/
├─ year=2024/month=01/
│  ├─ part_01.parquet
│  └─ part_02.parquet
├─ year=2024/month=02/
│  └─ part_01.parquet
└─ year=2025/month=01/
   └─ part_01.parquet

Avantage: Requête year=2024 ne lit que 2024 (10x plus rapide)
```

---

## Crawlers

### Fonctionnement

```
1. Lancer Crawler
   │
2. Connecter à S3
   │
3. Scanner fichiers
   ├─ Lire sample rows
   ├─ Détecter types
   ├─ Grouper partitions
   │
4. Créer/mettre à jour table Catalog
   │
5. Enregistrer metadonnées
   ├─ Schema
   ├─ Partitions
   ├─ Format
   └─ Classification
```

### Configuration

```
Crawler Config:
├─ Name: data-crawler
├─ Source: S3 path (s3://mybucket/data/)
├─ Include patterns: *.csv, *.parquet
├─ Exclude patterns: _temp, .logs
├─ Database output: default
├─ Table name prefix: raw_
├─ Partitions: year, month
├─ Data format: auto-detect
└─ Schedule: daily at 00:00
```

### Coûts

```
Free tier: 1M DPU-seconds/mois GRATUIT

Calculation:
Crawler run time = 5 minutes
Cost = (1 DPU × 5 min / 60 min) = 0.083 DPU-hours
Monthly: 30 runs × 0.083 = 2.5 DPU-hours = 1.1$ (après free tier)
```

---

## Jobs

### Anatomy of a Glue Job

```python
import sys
from awsglue.transforms import *
from awsglue.context import GlueContext
from pyspark.context import SparkContext

# Context (Spark + Glue)
sc = SparkContext()
glueContext = GlueContext(sc)

# 1. EXTRACT - Read from Catalog
input_data = glueContext.create_dynamic_frame.from_catalog(
    database="default",
    table_name="customers"
)

# 2. TRANSFORM - Clean/Process
clean_data = Filter.apply(
    input_data,
    lambda row: row is not None and row["email"] is not None
)

# 3. LOAD - Write to S3
glueContext.write_dynamic_frame.from_options(
    frame=clean_data,
    connection_type="s3",
    connection_options={"path": "s3://output/customers_clean/"},
    format="parquet"
)
```

### Job Types

```
Standard Job
├─ PySpark (Python + Spark)
├─ Scala (Scala + Spark)
└─ Idéal pour ETL volumétrique

Streaming Job
├─ Kafka input
├─ Real-time processing
└─ Idéal pour streaming data

Python Shell
├─ Python sans Spark
├─ Light-weight tasks
└─ Moins cher
```

### DPU (Data Processing Units)

```
DPU = unité compute pour jobs

1 DPU = 4 vCPU + 16 GB RAM

Allocation:
├─ G.1X: 1 DPU standard (défault)
├─ G.2X: 2 DPU (2x puissance)
└─ G.025X: 0.25 DPU (workers)

Job config:
├─ Worker type: G.1X (default)
├─ Number of workers: 10 (10 DPUs)
├─ Max concurrent runs: 1
└─ Timeout: 2880 minutes (48h)

Coût:
10 DPUs × 1 hour = $4.40 (0.44$/DPU-hour)
```

---

## Architecture

### Glue ETL Pipeline

```
┌─────────────────────────────────────┐
│        Data Sources                  │
├──────────┬──────────┬──────────┐
│   S3     │   RDS    │ Redshift │
└──────────┴──────────┴──────────┘
           │
           ↓
┌─────────────────────────────────────┐
│    AWS Glue Crawler                 │
│ (Detect schema & create Catalog)    │
└─────────────────────────────────────┘
           │
           ↓
┌─────────────────────────────────────┐
│    Glue Catalog                     │
│ (Store metadata)                    │
└─────────────────────────────────────┘
           │
           ↓
┌─────────────────────────────────────┐
│    AWS Glue Job (PySpark)           │
│ (Transform/Clean/Enrich)            │
└─────────────────────────────────────┘
           │
           ↓
┌──────────┬──────────┬──────────┐
│   S3     │ Redshift │ Athena   │
│ (clean)  │(warehouse)│(queries) │
└──────────┴──────────┴──────────┘
```

---

## Pricing

### Free Tier

```
✅ Crawlers: 1M DPU-seconds/mois
✅ Catalog: Unlimited metadata
✅ Triggers: Unlimited
✅ Data Catalog: 100 tables free

Calculation:
1M DPU-seconds = ~278 DPU-hours
= ~278 crawler runs × 1h each
```

### Payant

```
Jobs: $0.44 / DPU-hour (après free tier)

Examples:
├─ 10 DPU × 2 hours = $8.80
├─ 50 DPU × 1 hour = $22
└─ 100 DPU × 30 min = $22

S3 Costs (separate):
├─ Storage: $0.023 / GB / month
├─ PUT/POST: $0.005 per 1000
└─ GET: $0.0004 per 1000
```

---

## Best Practices

### 1. Partitions

```
❌ BAD
s3://bucket/data/
└─ 1GB file (slow queries)

✅ GOOD
s3://bucket/data/
├─ year=2024/month=01/
│  └─ part_001.parquet
├─ year=2024/month=02/
│  └─ part_001.parquet
└─ year=2025/month=01/
   └─ part_001.parquet

Benefits:
- Faster queries (scan only needed partition)
- Better scalability
- Lower costs
```

### 2. Formats

```
❌ CSV (bad for Glue)
├─ Verbose
├─ Schema lost
└─ Slow parsing

✅ Parquet (best)
├─ Compressed
├─ Schema preserved
├─ Columnar (fast queries)
└─ Compatible with everything
```

### 3. DPU Allocation

```
❌ BAD
- Always use 100 DPU
- Oversized for small jobs
- Wasting money

✅ GOOD
- Use right-sizing
- Monitor execution time
- Scale based on data volume
- Use G.025X for small jobs
```

### 4. Error Handling

```
✅ Log errors
glueContext.getLogger().info("Processing...")

✅ Add try-except
try:
    data = transform(input_data)
except Exception as e:
    glueContext.getLogger().error(f"Error: {e}")

✅ Monitor in CloudWatch
See Job logs for debugging
```

---

**SUITE**: Voir 02-Crawlers-Concepts-Complets.md pour crawlers avancés
