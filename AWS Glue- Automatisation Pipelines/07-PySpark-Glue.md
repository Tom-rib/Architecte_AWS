# PySpark pour AWS Glue 🔥

Transformer données avec PySpark dans Glue.

---

## DynamicFrame vs DataFrame

```
DynamicFrame:
├─ Glue-specific
├─ Schema-flexible
└─ Handle messy data

DataFrame:
├─ Standard Spark
├─ Schema-rigid
└─ Better performance

Conversion:
df = glueContext.convert_to_spark(dynamic_frame)
```

---

## Common Transformations

### Filter (Supprimer lignes)

```python
clean_data = Filter.apply(
    frame=input_data,
    f=lambda x: x["email"] is not None
)
```

### ApplyMapping (Rename/Type)

```python
mapped = ApplyMapping.apply(
    frame=clean_data,
    mappings=[
        ("old_name", "string", "new_name", "string"),
        ("id", "int", "customer_id", "bigint"),
    ]
)
```

### Join (Merge tables)

```python
joined = Join.apply(
    frame1=customers,
    frame2=orders,
    keys1=["id"],
    keys2=["customer_id"]
)
```

---

## Raw PySpark

```python
# Convert to RDD for more control
customers_rdd = customers_df.rdd

# Map transformation
mapped = customers_rdd.map(lambda row: (
    row["id"],
    row["name"].upper(),
    row["email"]
))

# Filter
filtered = mapped.filter(lambda x: x[2] is not None)

# Back to Spark
result_df = filtered.toDF(["id", "name", "email"])
```

---

## Error Handling

```python
try:
    df = glueContext.create_dynamic_frame.from_catalog(
        database="default",
        table_name="customers"
    )
except Exception as e:
    glueContext.getLogger().error(f"Failed: {e}")
    sys.exit(1)
```

---

## Performance Tips

```
✅ Use Parquet
✅ Partition data
✅ Filter early (before expensive ops)
✅ Use native Spark functions (not Python UDFs)
❌ Avoid shuffle if possible
```

---

