# Triggers & Scheduling Glue ⏰

Automatiser exécution crawlers et jobs.

---

## Trigger Types

### Crawler Complete

```
Déclenche job quand crawler finit:

Crawler runs → (success)
             → Trigger
             → Job starts
             → Transform data
             → Done
```

### Scheduled

```
Cron expressions:

Daily 00:00:
cron(0 0 * * ? *)

Daily 14:30:
cron(30 14 * * ? *)

Every hour:
cron(0 * * * ? *)

Every Monday 08:00:
cron(0 8 ? * MON *)
```

### On-Demand

```
Manual trigger:
aws glue start-job-run --job-name customers-transform
```

---

## Typical Pipeline

```
1. S3 receives data (08:00)
2. Crawler starts (08:05) - cron scheduled
3. Crawler finishes (08:15)
4. Trigger activates
5. Job starts (08:20)
6. Job finishes (08:35)
7. Data ready for analytics
```

---

## Costs

```
Triggers: GRATUIT
Crawlers: Gratuit (1M DPU-sec/mois)
Jobs: $0.44/DPU-hour (after free tier)

Example pipeline (daily):
├─ Crawler: 5 min = ~$0
├─ Job: 30 min (10 DPUs) = $2.20
└─ Monthly: $66 (après free tier)
```

---

