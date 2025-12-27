# AWS Glue Jobs - Guide Avancé 🚀

Tout sur la création et exécution de jobs de transformation.

---

## Créer un Job Glue

### Minimal Job

```python
import sys
from awsglue.transforms import *
from awsglue.context import GlueContext
from pyspark.context import SparkContext

sc = SparkContext()
glueContext = GlueContext(sc)

# Lire depuis S3
df = glueContext.create_dynamic_frame.from_catalog(
    database="default",
    table_name="customers"
)

# Écrire vers S3
glueContext.write_dynamic_frame.from_options(
    frame=df,
    connection_type="s3",
    connection_options={"path": "s3://output/customers/"},
    format="parquet"
)
```

### Avec Transformation

```python
from awsglue.transforms import Filter, ApplyMapping

# Charger
customers = glueContext.create_dynamic_frame.from_catalog(
    database="default",
    table_name="customers"
)

# Filtrer (supprimer nulls)
clean_customers = Filter.apply(
    customers,
    lambda row: row["email"] is not None
)

# Mapper colonnes (rename/reorder)
mapped = ApplyMapping.apply(
    frame=clean_customers,
    mappings=[
        ("id", "bigint", "customer_id", "bigint"),
        ("name", "string", "full_name", "string"),
        ("email", "string", "email_address", "string"),
        ("created_at", "timestamp", "created_date", "string"),
    ]
)

# Sauvegarder
glueContext.write_dynamic_frame.from_options(
    frame=mapped,
    connection_type="s3",
    connection_options={"path": "s3://output/customers_clean/"},
    format="parquet"
)
```

---

## Job Parameters

```
Command-line args:

--database: source database
--table: source table
--output_path: destination S3

Usage:
aws glue start-job-run \
  --job-name customers-transform \
  --arguments '--database=default,--table=customers,--output_path=s3://out/'
```

---

## Job Monitoring

```
CloudWatch Logs:
├─ /aws-glue/jobs/customers-transform
├─ stdout (print statements)
└─ stderr (errors)

Metrics:
├─ Execution time
├─ DPU hours consumed
└─ Success/failure
```

---

## DPU Allocation

```
Worker Types:

G.1X (Default):
├─ 4 vCPU + 16 GB RAM
├─ Cost: $0.44/hour
└─ Good for: most jobs

G.2X (2x power):
├─ 8 vCPU + 32 GB RAM
├─ Cost: $0.88/hour
└─ Good for: heavy compute

G.025X (lightweight):
├─ 0.25 vCPU + 1 GB RAM
├─ Cost: $0.055/hour
└─ Good for: Python shell
```

---

## Coûts

```
Job de 10 DPUs pendant 2 heures:
10 DPUs × 2 hours × $0.44/DPU-hour = $8.80

Optimizations:
├─ Use right-sizing (avoid over-allocation)
├─ Cache data between runs
├─ Use efficient formats (Parquet)
└─ Partition source data
```

---

## Erreurs Courantes

```
❌ OOM (Out of Memory)
└─ Augmenter DPUs ou optimiser code

❌ Timeout
└─ Augmenter job timeout (par défaut 2880 min)

❌ Schema mismatch
└─ Vérifier crawler a détecté correct schéma
```

---

**SUITE**: Voir 07-PySpark-Glue.md pour code avancé
