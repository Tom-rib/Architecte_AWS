# AWS Glue CLI Commands 🔧

Toutes les commandes CLI pour gérer Glue.

---

## Crawlers

### Créer Crawler

```bash
aws glue create-crawler \
  --name customers-crawler \
  --database-name default \
  --description "Crawl customer CSV files" \
  --targets S3Targets=[{Path=s3://mybucket/customers/,Exclusions=[_temp/*]}] \
  --role arn:aws:iam::ACCOUNT_ID:role/GlueServiceRole \
  --schedule-expression "cron(0 0 * * ? *)" \
  --table-prefix raw_ \
  --region eu-west-3
```

### Démarrer Crawler

```bash
aws glue start-crawler --name customers-crawler --region eu-west-3
```

### Lister Crawlers

```bash
aws glue get-crawlers --region eu-west-3
```

### Obtenir Status Crawler

```bash
aws glue get-crawler \
  --name customers-crawler \
  --region eu-west-3
```

### Supprimer Crawler

```bash
aws glue delete-crawler \
  --name customers-crawler \
  --region eu-west-3
```

---

## Catalog

### Lister Databases

```bash
aws glue get-databases --region eu-west-3
```

### Lister Tables

```bash
aws glue get-tables \
  --database-name default \
  --region eu-west-3
```

### Obtenir Table Schema

```bash
aws glue get-table \
  --database-name default \
  --name customers \
  --region eu-west-3
```

### Obtenir Partitions

```bash
aws glue get-partitions \
  --database-name default \
  --table-name customers \
  --region eu-west-3
```

---

## Jobs

### Créer Job

```bash
aws glue create-job \
  --name customers-transform \
  --role arn:aws:iam::ACCOUNT_ID:role/GlueServiceRole \
  --command Name=glueetl,ScriptLocation=s3://mybucket/scripts/transform.py \
  --max-retries 1 \
  --timeout 2880 \
  --glue-version 4.0 \
  --worker-type G.1X \
  --number-of-workers 10 \
  --region eu-west-3
```

### Exécuter Job

```bash
aws glue start-job-run \
  --job-name customers-transform \
  --arguments '--database=default,--table=customers' \
  --region eu-west-3
```

### Voir Job Run Status

```bash
aws glue get-job-run \
  --job-name customers-transform \
  --run-id jr_XXXX \
  --region eu-west-3
```

### Lister Jobs

```bash
aws glue get-jobs --region eu-west-3
```

### Supprimer Job

```bash
aws glue delete-job \
  --job-name customers-transform \
  --region eu-west-3
```

---

## Triggers

### Créer Trigger (Crawler Complete)

```bash
aws glue create-trigger \
  --name crawl-to-transform-trigger \
  --type CRAWLER \
  --crawler-details CrawlerName=customers-crawler \
  --actions JobName=customers-transform \
  --region eu-west-3
```

### Créer Trigger Scheduled

```bash
aws glue create-trigger \
  --name daily-transform-trigger \
  --type SCHEDULED \
  --schedule-expression "cron(0 0 * * ? *)" \
  --actions JobName=customers-transform \
  --region eu-west-3
```

### Lister Triggers

```bash
aws glue get-triggers --region eu-west-3
```

### Supprimer Trigger

```bash
aws glue delete-trigger \
  --name crawl-to-transform-trigger \
  --region eu-west-3
```

---

## Logs

### Voir Crawler Logs

```bash
aws logs tail /aws-glue/crawlers/customers-crawler --follow
```

### Voir Job Logs

```bash
aws logs tail /aws-glue/jobs/customers-transform --follow
```

---

