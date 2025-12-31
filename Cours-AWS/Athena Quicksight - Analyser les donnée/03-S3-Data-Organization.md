# S3 & Data Organization 📁

Comment préparer et organiser vos données dans S3 pour Athena.

---

## Pourquoi l'organisation compte?

Bien organiser vos données = **Requêtes rapides + Coûts bas**.

```
Mauvaise organisation:
├─ Tous les fichiers dans /
└─ Athena scan TOUT → Coûteux & lent

Bonne organisation:
├─ Par date (year=2024/month=01/)
├─ Par type (type=sales/, type=logs/)
└─ Athena scan SEULEMENT ce qui est nécessaire → Rapide & bon marché
```

---

## Structure recommandée

### Par date (recommandé)
```
s3://mon-bucket/data/
├── year=2024/
│   ├── month=01/
│   │   ├── day=01/
│   │   │   ├── data_001.parquet
│   │   │   └── data_002.parquet
│   │   └── day=02/
│   │       └── data_001.parquet
│   └── month=02/
│       └── ...
├── year=2023/
│   └── ...
```

**Avantage:** Facile à filtrer par date avec Athena.

```sql
SELECT * FROM table
WHERE year=2024 AND month=01;  -- Rapide! Scan que 1 mois
```

### Par région/catégorie
```
s3://mon-bucket/data/
├── region=US/
│   ├── state=NY/
│   ├── state=CA/
│   └── state=TX/
├── region=EU/
│   ├── country=FR/
│   ├── country=DE/
│   └── country=UK/
└── region=ASIA/
    ├── country=JP/
    └── country=SG/
```

### Par type de données
```
s3://mon-bucket/
├── raw/           (données brutes, comme uploadées)
├── processed/     (données nettoyées)
├── analytics/     (données pour analyses)
└── archive/       (anciennes données)
```

### Mixte (recommandé)
```
s3://mon-bucket/
├── raw/customers/
│   ├── year=2024/month=01/
│   └── year=2024/month=02/
├── raw/orders/
│   ├── year=2024/month=01/
│   └── year=2024/month=02/
├── processed/
│   ├── customers_clean/
│   └── orders_clean/
└── analytics/
    ├── sales_by_region/
    └── customer_metrics/
```

---

## Formats de fichiers

### CSV (Comma-Separated Values)

```
customer_id,name,email,age
1,John,john@example.com,30
2,Jane,jane@example.com,25
3,Bob,bob@example.com,35
```

**Avantage:**
✅ Simple
✅ Lisible
✅ Universel

**Inconvénient:**
❌ Gros fichiers
❌ Requêtes lentes
❌ Pas de schéma

**Quand utiliser:** Petits fichiers, données simples.

---

### Parquet (Columnar)

Format binaire optimisé pour analytics.

```
Header: [schema]
Column 1 (id): [1, 2, 3]
Column 2 (name): [John, Jane, Bob]
Column 3 (email): [john@..., jane@..., bob@...]
```

**Avantage:**
✅ Compressé (5-10x)
✅ Requêtes rapides
✅ Schéma typé
✅ Colonaire (scan 1 col = rapide)

**Inconvénient:**
❌ Moins lisible
❌ Besoin de convertir depuis CSV

**Quand utiliser:** Données volumineuses, requêtes analytiques.

**Comparaison:**
```
1M rows, 10 colonnes:

CSV:        50 MB  → Athena query: 5 secondes
Parquet:    5 MB   → Athena query: 0.5 secondes
(10x plus rapide, 10x moins grand!)
```

---

### JSON (JavaScript Object Notation)

```json
{
  "customer_id": 1,
  "name": "John",
  "email": "john@example.com",
  "age": 30
}
{
  "customer_id": 2,
  "name": "Jane",
  "email": "jane@example.com",
  "age": 25
}
```

**Avantage:**
✅ Flexible (structuré ou pas)
✅ Imbriqué (nested data OK)
✅ Lisible

**Inconvénient:**
❌ Gros fichiers
❌ Requêtes lentes
❌ Pas typé strictement

**Quand utiliser:** Données semi-structurées, logs, APIs.

---

### ORC (Optimized Row Columnar)

Format optimisé similaire à Parquet.

**Avantage:**
✅ Très compressé
✅ Requêtes très rapides
✅ Bon pour Athena

**Inconvénient:**
❌ Moins supporté que Parquet
❌ Moins compatible

**Quand utiliser:** Gros volumes, performance critique.

---

## Compression

Réduire la taille des fichiers = économiser sur les coûts S3 + requêtes rapides.

### Formats de compression

| Format | Compression | Avantage |
|--------|------------|----------|
| **None** | Aucune | Rapide à écrire |
| **GZIP** | Moyen (5-10x) | Lisible en texte |
| **SNAPPY** | Bon (3-5x) | Rapide à décompresser |
| **LZO** | Bon (3-5x) | Très rapide |
| **Parquet (built-in)** | Excellent (10-20x) | Compression native |

**Recommandation:** Parquet with SNAPPY = meilleur ratio.

---

## Naming Conventions

Nommez vos fichiers intelligemment.

```
❌ Mauvais:
file.csv
data.csv
export_1.parquet

✅ Bon:
customers_2024_01_01.csv
orders_2024_01_02_part_001.parquet
sales_regions_eu_2024.parquet

Structure:
<type>_<date>_<region>_<version>.<format>
```

---

## Partitioning pour Athena

**Partitioning** = Organiser par dossiers pour optimiser requêtes.

### Exemple: Partitionner par date

```
s3://bucket/data/
├── year=2024/month=01/day=01/
│   └── data_001.parquet
├── year=2024/month=01/day=02/
│   └── data_001.parquet
└── year=2024/month=02/day=01/
    └── data_001.parquet
```

**Athena reconnaît automatiquement!**

```sql
-- Requête smart (scan seulement month=01):
SELECT * FROM table
WHERE year=2024 AND month=01;

-- Requête naive (scan tout):
SELECT * FROM table
WHERE date >= '2024-01-01' AND date < '2024-02-01';
```

### Comment créer des partitions

**Option 1: Créer dossiers manuellement**

```bash
aws s3 cp data_jan.parquet s3://bucket/data/year=2024/month=01/
aws s3 cp data_feb.parquet s3://bucket/data/year=2024/month=02/
```

**Option 2: Glue Crawler (automatique)**

```
AWS Glue → Crawlers → Create crawler
  → Détecte automatiquement les partitions
  → Crée la table avec partitions
```

---

## Permissions S3

Athena a besoin d'accéder à S3.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::mon-bucket/data/*",
        "arn:aws:s3:::mon-bucket"
      ]
    }
  ]
}
```

---

## Checklist: Préparer vos données

```
☐ Décider format (Parquet recommandé)
☐ Décider structure dossiers (par date?)
☐ Créer bucket S3
☐ Créer dossiers
☐ Uploader fichiers
☐ Configurer partitions (si applicable)
☐ Tester accès Athena
☐ Vérifier permissions
☐ Optimiser avec compression
```

---

## Coûts S3

```
Standard Storage:
  └─ $0.023 par GB/mois

Requête GET:
  └─ $0.0004 par 1000 requêtes

Athena read:
  └─ $5 par TB scanné

Exemple 1 TB/mois:
├─ S3 storage: $23
├─ Athena queries (1 TB scanné): $5
└─ TOTAL: $28
```

---

## Prochains pas

→ **[Athena Databases](./04-Athena-Databases.md)** - Créer tables

→ **[Athena Partitioning](./06-Athena-Partitioning.md)** - Optimiser requêtes

---

**S3 Organization Terminé! ✅**
