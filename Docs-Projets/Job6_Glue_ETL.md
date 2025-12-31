# Job 6 : AWS Glue - Pipeline ETL 🔄

> Automatiser l'ingestion et la transformation de données

---

## 🎯 Objectif

Automatiser l'ingestion et la transformation de données avec AWS Glue. Le pipeline extrait des données brutes d'un bucket S3, les nettoie, et génère des fichiers Parquet optimisés.

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| AWS Glue | ETL serverless |
| S3 | Stockage input/output |
| Glue Crawler | Détection de schéma |
| Glue Data Catalog | Métadonnées |
| IAM | Permissions |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| Glue Crawler | 1M runs gratuits |
| Glue ETL | ~$0.44/DPU-heure |

⚠️ **Attention** : Glue peut coûter si vous laissez des jobs tourner !

---

## 🏗️ Architecture

```
S3 (CSV) → Crawler → Glue Catalog → ETL Job → S3 (Parquet)
```

---

# Étape 1 : Préparer les données dans S3

## Créer la structure S3

```
s3://mon-bucket-glue/
├── input/
│   └── customers.csv
├── output/
│   └── (fichiers Parquet générés)
└── scripts/
    └── (scripts PySpark)
```

## Fichier de données : customers.csv

```csv
id,name,email,created_at
1,Alice Dupont,alice@example.com,2024-01-01
2,Bob Martin,bob@example.com,2024-01-05
3,Charlie Durand,charlie@example.com,2024-01-10
4,Diana Petit,,2024-01-15
5,Eve Bernard,eve@example.com,2024-01-20
6,,frank@example.com,2024-01-25
7,Grace Moreau,grace@example.com,2024-01-30
```

## 🖥️ Dashboard

```
1. S3 → Create bucket
   - Bucket name : mon-bucket-glue-VOTREPRENOM
   - Region : eu-west-3
   - Create bucket ✓

2. Créer les dossiers :
   - Create folder → input
   - Create folder → output
   - Create folder → scripts

3. Uploader le CSV :
   - input/ → Upload → customers.csv
```

## 💻 CLI

```bash
# Créer le bucket
aws s3 mb s3://mon-bucket-glue-tom --region eu-west-3

# Créer le fichier CSV
cat > customers.csv << 'EOF'
id,name,email,created_at
1,Alice Dupont,alice@example.com,2024-01-01
2,Bob Martin,bob@example.com,2024-01-05
3,Charlie Durand,charlie@example.com,2024-01-10
4,Diana Petit,,2024-01-15
5,Eve Bernard,eve@example.com,2024-01-20
6,,frank@example.com,2024-01-25
7,Grace Moreau,grace@example.com,2024-01-30
EOF

# Uploader
aws s3 cp customers.csv s3://mon-bucket-glue-tom/input/
```

---

# Étape 2 : Créer le rôle IAM pour Glue

## 🖥️ Dashboard

```
1. IAM → Roles → Create role

2. Trusted entity : AWS service
   Use case : Glue

3. Next

4. Permissions :
   - ☑ AWSGlueServiceRole
   - ☑ AmazonS3FullAccess

5. Next

6. Role name : GlueServiceRole

7. Create role ✓
```

## 💻 CLI

```bash
# Créer le rôle
aws iam create-role \
  --role-name GlueServiceRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "glue.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attacher les policies
aws iam attach-role-policy \
  --role-name GlueServiceRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole

aws iam attach-role-policy \
  --role-name GlueServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

---

# Étape 3 : Créer la base de données Glue

## 🖥️ Dashboard

```
1. AWS Glue → Databases → Add database

2. Name : glue_demo_db

3. Create database ✓
```

## 💻 CLI

```bash
aws glue create-database \
  --database-input '{"Name": "glue_demo_db"}' \
  --region eu-west-3
```

---

# Étape 4 : Créer un Crawler

## 🖥️ Dashboard

```
1. AWS Glue → Crawlers → Create crawler

2. Name : customers-crawler

3. Next

4. Data sources → Add a data source :
   - Data source : S3
   - S3 path : s3://mon-bucket-glue-tom/input/
   - Add an S3 data source ✓

5. Next

6. IAM role : GlueServiceRole

7. Next

8. Target database : glue_demo_db

9. Crawler schedule : On demand

10. Next → Create crawler ✓
```

## 💻 CLI

```bash
aws glue create-crawler \
  --name customers-crawler \
  --role GlueServiceRole \
  --database-name glue_demo_db \
  --targets '{
    "S3Targets": [{
      "Path": "s3://mon-bucket-glue-tom/input/"
    }]
  }' \
  --region eu-west-3
```

---

# Étape 5 : Exécuter le Crawler

## 🖥️ Dashboard

```
1. AWS Glue → Crawlers → customers-crawler

2. Run crawler ✓

3. Attendez que le status soit "Ready" (2-3 minutes)

4. Vérifiez la table créée :
   AWS Glue → Tables → input (ou customers)
```

## 💻 CLI

```bash
# Lancer le crawler
aws glue start-crawler \
  --name customers-crawler \
  --region eu-west-3

# Vérifier le status
aws glue get-crawler \
  --name customers-crawler \
  --query 'Crawler.State' \
  --region eu-west-3

# Voir la table créée
aws glue get-tables \
  --database-name glue_demo_db \
  --query 'TableList[*].Name' \
  --region eu-west-3
```

---

# Étape 6 : Créer le Job ETL

## Script PySpark : transform_customers.py

```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

# Initialisation
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Lire les données depuis le catalogue
datasource = glueContext.create_dynamic_frame.from_catalog(
    database="glue_demo_db",
    table_name="input"
)

# Convertir en DataFrame pour les transformations
df = datasource.toDF()

# Afficher le schéma
print("Schéma original:")
df.printSchema()

# Transformation : Supprimer les lignes avec des valeurs NULL
df_cleaned = df.filter(
    (df["id"].isNotNull()) & 
    (df["email"].isNotNull())
)

# Afficher les stats
print(f"Lignes avant nettoyage: {df.count()}")
print(f"Lignes après nettoyage: {df_cleaned.count()}")

# Reconvertir en DynamicFrame
cleaned_dynamic_frame = DynamicFrame.fromDF(df_cleaned, glueContext, "cleaned")

# Écrire en Parquet dans S3
glueContext.write_dynamic_frame.from_options(
    frame=cleaned_dynamic_frame,
    connection_type="s3",
    connection_options={
        "path": "s3://mon-bucket-glue-tom/output/"
    },
    format="parquet"
)

job.commit()
print("Job terminé avec succès!")
```

## 🖥️ Dashboard

```
1. Uploader le script :
   S3 → mon-bucket-glue-tom → scripts → Upload → transform_customers.py

2. AWS Glue → ETL jobs → Create job

3. Name : customers-transform

4. IAM Role : GlueServiceRole

5. Type : Spark

6. Glue version : Glue 4.0

7. Language : Python 3

8. Script path : s3://mon-bucket-glue-tom/scripts/transform_customers.py

9. Worker type : G.1X
   Number of workers : 2

10. Job parameters (optionnel) :
    --enable-metrics true
    --enable-continuous-cloudwatch-log true

11. Save ✓
```

## 💻 CLI

```bash
# Uploader le script
aws s3 cp transform_customers.py s3://mon-bucket-glue-tom/scripts/

# Créer le job
aws glue create-job \
  --name customers-transform \
  --role GlueServiceRole \
  --command '{
    "Name": "glueetl",
    "ScriptLocation": "s3://mon-bucket-glue-tom/scripts/transform_customers.py",
    "PythonVersion": "3"
  }' \
  --default-arguments '{
    "--enable-metrics": "true",
    "--enable-continuous-cloudwatch-log": "true"
  }' \
  --glue-version "4.0" \
  --number-of-workers 2 \
  --worker-type G.1X \
  --region eu-west-3
```

---

# Étape 7 : Exécuter le Job

## 🖥️ Dashboard

```
1. AWS Glue → ETL jobs → customers-transform

2. Run ✓

3. Suivez l'exécution dans "Runs"

4. Attendez que le status soit "Succeeded" (5-10 minutes)
```

## 💻 CLI

```bash
# Lancer le job
RUN_ID=$(aws glue start-job-run \
  --job-name customers-transform \
  --query 'JobRunId' \
  --output text \
  --region eu-west-3)

echo "Run ID: $RUN_ID"

# Vérifier le status
aws glue get-job-run \
  --job-name customers-transform \
  --run-id $RUN_ID \
  --query 'JobRun.JobRunState' \
  --region eu-west-3
```

---

# Étape 8 : Vérifier les résultats

## 🖥️ Dashboard

```
1. S3 → mon-bucket-glue-tom → output/

2. Vous devriez voir des fichiers .parquet

3. Vérifiez le nombre de lignes :
   - Input : 7 lignes
   - Output : 5 lignes (2 supprimées car NULL)
```

## 💻 CLI

```bash
# Lister les fichiers output
aws s3 ls s3://mon-bucket-glue-tom/output/ --recursive

# Télécharger et vérifier (optionnel)
aws s3 cp s3://mon-bucket-glue-tom/output/ ./output/ --recursive
```

---

# Étape 9 : Créer un Trigger (Optionnel)

## 🖥️ Dashboard

```
1. AWS Glue → Triggers → Create trigger

2. Name : daily-transform

3. Trigger type : Schedule

4. Frequency : Daily
   Start hour : 03:00

5. Jobs to trigger : customers-transform

6. Create trigger ✓

7. Actions → Activate trigger
```

## 💻 CLI

```bash
# Créer un trigger schedulé
aws glue create-trigger \
  --name daily-transform \
  --type SCHEDULED \
  --schedule "cron(0 3 * * ? *)" \
  --actions '[{"JobName": "customers-transform"}]' \
  --start-on-creation \
  --region eu-west-3
```

---

# 🔧 Troubleshooting

## ❌ Crawler ne trouve pas de données

```
1. Vérifiez le chemin S3 (avec / à la fin)
2. Vérifiez que le fichier CSV existe
3. Vérifiez les permissions du rôle IAM
```

## ❌ Job échoue

```
1. Vérifiez les logs CloudWatch :
   CloudWatch → Log groups → /aws-glue/jobs/error
   
2. Vérifiez le script (syntaxe Python)

3. Vérifiez que le nom de la table correspond
```

## ❌ Pas de fichiers output

```
1. Vérifiez que le job a le status "Succeeded"
2. Vérifiez le chemin S3 de sortie
3. Vérifiez les logs pour voir si des lignes ont été traitées
```

---

# 🧹 Nettoyage

```bash
# 1. Supprimer le trigger
aws glue delete-trigger --name daily-transform --region eu-west-3

# 2. Supprimer le job
aws glue delete-job --job-name customers-transform --region eu-west-3

# 3. Supprimer le crawler
aws glue delete-crawler --name customers-crawler --region eu-west-3

# 4. Supprimer la table
aws glue delete-table \
  --database-name glue_demo_db \
  --name input \
  --region eu-west-3

# 5. Supprimer la database
aws glue delete-database --name glue_demo_db --region eu-west-3

# 6. Vider et supprimer le bucket S3
aws s3 rm s3://mon-bucket-glue-tom --recursive
aws s3 rb s3://mon-bucket-glue-tom

# 7. Supprimer le rôle IAM
aws iam detach-role-policy --role-name GlueServiceRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole
aws iam detach-role-policy --role-name GlueServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam delete-role --role-name GlueServiceRole
```

---

## 📊 Résumé du Pipeline

| Étape | Composant | Résultat |
|-------|-----------|----------|
| 1 | S3 Input | 7 lignes CSV |
| 2 | Crawler | Table créée dans Catalog |
| 3 | ETL Job | Nettoyage des NULL |
| 4 | S3 Output | 5 lignes Parquet |

---

## ✅ Checklist Finale

- [ ] Bucket S3 créé avec structure input/output/scripts
- [ ] Fichier CSV uploadé
- [ ] Rôle IAM GlueServiceRole créé
- [ ] Database Glue créée
- [ ] Crawler créé et exécuté
- [ ] Table visible dans le Data Catalog
- [ ] Job ETL créé
- [ ] Job exécuté avec succès
- [ ] Fichiers Parquet générés dans output/

---

[⬅️ Retour : Job5](./Job5_CloudWatch_SNS.md) | [➡️ Suite : Job7_Athena_QuickSight.md](./Job7_Athena_QuickSight.md)
