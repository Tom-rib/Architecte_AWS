# Job 6 : Automatiser les Pipelines de Données avec AWS Glue 📊

Guide complet pour ingérer, transformer et automatiser vos données avec AWS Glue.

---

## TABLE DES MATIÈRES

### Concepts de base
- **[Glue Basics](./01-AWS-Glue-Concepts-Complets.md)** - Qu'est-ce que AWS Glue ?
- **[Crawlers](./02-Crawlers-Concepts-Complets.md)** - Détecter les schémas automatiquement
- **[Data Formats](./06-Data-Formats.md)** - CSV, JSON, Parquet

### Transformation et Jobs
- **[Jobs Glue Avancés](./03-Jobs-Glue-Avances.md)** - Créer et exécuter des jobs
- **[PySpark pour Glue](./07-PySpark-Glue.md)** - Écrire du code de transformation
- **[S3 Integration](./04-S3-Integration-Avances.md)** - Lire/écrire dans S3

### Automatisation et Sécurité
- **[Triggers & Scheduling](./08-Triggers-Scheduling.md)** - Automatiser les pipelines
- **[IAM & Security](./05-IAM-Glue-Security.md)** - Permissions et sécurité
- **[CLI Commands](./CLI-Commands.md)** - Toutes les commandes AWS CLI

### Référence
- **[Troubleshooting](./Troubleshooting.md)** - Problèmes courants

---

## 🎯 FLUX RAPIDE

```
BASES (30 min) :
1. Lire 01-AWS-Glue-Concepts-Complets.md
2. Lire 02-Crawlers-Concepts-Complets.md
3. Suivre GUIDE-SETUP-JOB6.md

INTERMÉDIAIRE (2h) :
4. 03-Jobs-Glue-Avances.md
5. 06-Data-Formats.md
6. 07-PySpark-Glue.md

AVANCÉ (3h) :
7. 04-S3-Integration-Avances.md
8. 08-Triggers-Scheduling.md
9. 05-IAM-Glue-Security.md
10. CLI-Commands.md
```

---

## 💡 CONCEPTS CLÉS

| Concept | Utilité | Coût |
|---------|---------|------|
| **Crawler** | Détecter schéma dans S3 | Gratuit (1M requêtes) |
| **Job Glue** | Transformer données | 0.44$ / DPU-heure |
| **Catalog** | Stocker métadonnées | Gratuit |
| **Trigger** | Automatiser exécution | Gratuit |
| **S3** | Source et destination | Stockage + transferts |

---

## 📊 PIPELINE TYPIQUE

```
S3 (Données brutes)
    ↓
Crawler Glue
    ↓ (détecte schéma)
Glue Catalog
    ↓
Job Glue (transformation PySpark)
    ↓ (nettoie, transforme)
S3 (Données propres)
    ↓
Trigger (automatisation)
    ↓
Répète tous les jours/heures
```

---

## 🚀 EXEMPLE COMPLET

### Données brutes (customers.csv)
```
id,name,email,age
1,John Doe,john@example.com,30
2,Jane Smith,jane@example.com,25
3,Bob,invalid_email,35
,Empty Name,,40
```

### Transformation (Job Glue)
```python
# Charger données
customers = glueContext.create_dynamic_frame.from_catalog(
    database="default", 
    table_name="customers"
)

# Nettoyer (supprimer vides, invalides)
clean_customers = Filter.apply(
    customers,
    lambda x: x is not None and x["email"] is not None
)

# Sauvegarder propres
glueContext.write_dynamic_frame.from_options(
    frame=clean_customers,
    connection_type="s3",
    connection_options={"path": "s3://output-bucket/clean/"},
    format="parquet"
)
```

### Résultat (Parquet optimisé)
```
id,name,email,age
1,John Doe,john@example.com,30
2,Jane Smith,jane@example.com,25
```

---

## 🔄 ARCHITECTURE RECOMMANDÉE

```
Landing Zone (S3)
├─ Raw Data
│  └─ customers.csv
│  └─ orders.json
│  └─ products.parquet
│
Glue Processing
├─ Crawler (détect schéma)
├─ Job (transformation)
└─ Catalog (métadonnées)
│
Processed Zone (S3)
├─ Clean Data
│  └─ customers_clean.parquet
│  └─ orders_clean.parquet
│  └─ products_clean.parquet
│
Analytics (Athena, Redshift)
└─ Requêtes SQL
```

---

## 🔒 SÉCURITÉ

```
IAM Role pour Glue
├─ S3 Read (source data)
├─ S3 Write (output)
├─ Glue Service Role
└─ CloudWatch Logs

Encryption
├─ S3 encryption
├─ Glue job encryption
└─ Data in transit
```

---

## 💰 COÛTS

```
Free Tier:
├─ Crawlers: 1M requêtes gratuites/mois
├─ Catalog: Gratuit
├─ Triggers: Gratuit
└─ Job: 1M DPU-secondes gratuites/mois

Payant:
├─ Job: 0.44$ / DPU-heure (après free)
├─ S3 storage: 0.023$ / GB / mois
└─ S3 transfer: 0.02$ / GB
```

---

## 🎁 BONUS: Patterns Courants

| Use Case | Solution |
|----------|----------|
| Détecter schéma | Crawler Glue |
| Nettoyer données | Filter + ApplyMapping |
| Convertir format | Format conversion dans Job |
| Merger tables | Join en PySpark |
| Deduplicate | Distinct en PySpark |
| Enrichir données | Lookup table join |
| Partitionner | Partition keys en S3 |
| Incremental load | Avec dates/timestamps |

---

## 📚 RESSOURCES

- Voir GUIDE-SETUP-JOB6.md : Configuration rapide
- AWS Glue Documentation : https://docs.aws.amazon.com/glue/
- PySpark Documentation : https://spark.apache.org/docs/latest/

---

**Créé pour maîtriser AWS Glue rapidement** 📚
