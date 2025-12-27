# Data Formats pour Glue 📄

CSV, JSON, Parquet - Comparaison et usage.

---

## CSV

```
Format:
id,name,email
1,Alice,alice@example.com
2,Bob,bob@example.com

Pros:
✅ Humainement lisible
✅ Universal support
✅ Excel compatible

Cons:
❌ Volumineux
❌ Pas de schéma
❌ Lent pour requêtes
❌ Problèmes: quoting, délimiteurs
```

---

## JSON

```
Format:
{"id": 1, "name": "Alice", "email": "alice@example.com"}
{"id": 2, "name": "Bob", "email": "bob@example.com"}

Pros:
✅ Structuré
✅ Imbriqué possible
✅ Schéma flexible

Cons:
❌ Volumineux
❌ Lent parsing
❌ Moins efficace que Parquet
```

---

## Parquet

```
Format: Binaire columnar
(not human readable - optimal pour machine)

Pros:
✅ Compressé (10x smaller)
✅ Rapide requêtes (columnar)
✅ Schéma préservé
✅ Predicate pushdown
✅ Athena/Redshift compatible

Cons:
❌ Pas humainement lisible
❌ Moins support que CSV

IDÉAL POUR GLUE ✅
```

---

## Conversion

### CSV → Parquet

```python
df = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    format="csv",
    connection_options={"path": "s3://input/data.csv"}
)

glueContext.write_dynamic_frame.from_options(
    frame=df,
    connection_type="s3",
    format="parquet",
    connection_options={"path": "s3://output/data.parquet/"}
)
```

---

## Recommandations

```
Use CSV:
├─ Petit fichiers
├─ Data interchange
└─ Excel/manual edit

Use JSON:
├─ Nested data
├─ API responses
└─ Flexible schema

Use Parquet:
├─ Glue jobs
├─ Data lakes
├─ Analytics queries
└─ **RECOMMANDÉ POUR JOB 6**
```

---

