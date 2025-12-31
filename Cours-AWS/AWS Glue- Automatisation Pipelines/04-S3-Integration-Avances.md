# S3 Integration avec AWS Glue 📦

Lire et écrire dans S3 depuis Glue.

---

## Lire depuis S3

### Depuis Catalog (Recommandé)

```python
# Simple - crawler a détecté le schéma
df = glueContext.create_dynamic_frame.from_catalog(
    database="default",
    table_name="customers"
)
```

### Depuis Path Directement

```python
# Pas besoin de crawler
df = glueContext.create_dynamic_frame.from_options(
    format_options={"multiline": False},
    connection_type="s3",
    format="csv",
    connection_options={"path": "s3://mybucket/customers/"},
    transformation_ctx="datasource"
)
```

---

## Écrire vers S3

### Simple

```python
glueContext.write_dynamic_frame.from_options(
    frame=df,
    connection_type="s3",
    connection_options={"path": "s3://output/clean/"},
    format="parquet"
)
```

### Avec Partitions

```python
glueContext.write_dynamic_frame.from_options(
    frame=df,
    connection_type="s3",
    connection_options={
        "path": "s3://output/customers/",
        "partitionKeys": ["year", "month"]  # Partition by year/month
    },
    format="parquet"
)
```

---

## Formats

```
CSV:
├─ Lisible
├─ Volumineux
└─ Lent pour requêtes

JSON:
├─ Structuré
├─ Compressé
└─ Bon pour API

Parquet:
├─ Compressé
├─ Rapide requêtes
└─ Excellent pour Glue/Athena
```

---

## Best Practices

```
✅ Partitionner par time
├─ year=2024/month=01/
├─ year=2024/month=02/
└─ Queries scannent seulement needed partitions

✅ Utiliser Parquet
├─ Compression native
├─ Schema preserved
└─ Compatible Athena, Redshift Spectrum

✅ Nettoyer path
├─ Pas de fichiers temporaires
├─ Pas de _logs ou .tmp
└─ Structures claires
```

---

**Coût**: S3 storage + requêtes Glue
