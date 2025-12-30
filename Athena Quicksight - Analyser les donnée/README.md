# AWS Analytics Masterclass 📊

Cours complet sur **Amazon Athena** et **Amazon QuickSight** - Analyse et visualisation de données.

**Format :** Dashboard AWS (clics) + SQL (requêtes) + CLI (commandes)

---

## 📚 TABLE DES MATIÈRES

### Concepts Fondamentaux
- **[Athena Basics](./01-Athena-Basics.md)** - Qu'est-ce que Athena? (SQL sur S3)
- **[QuickSight Basics](./02-QuickSight-Basics.md)** - Qu'est-ce que QuickSight? (Dashboards)
- **[S3 & Data Organization](./03-S3-Data-Organization.md)** - Préparer les données

### Athena en Détail
- **[Databases & Tables](./04-Athena-Databases.md)** - Créer et gérer tables
- **[SQL Queries](./05-Athena-SQL.md)** - Requêtes SQL (SELECT, JOIN, agrégations)
- **[Partitioning](./06-Athena-Partitioning.md)** - Optimiser les requêtes
- **[Data Formats](./07-Athena-Formats.md)** - CSV, Parquet, JSON, ORC

### QuickSight en Détail
- **[Setup & Users](./08-QuickSight-Setup.md)** - Créer et configurer
- **[Data Sources](./09-QuickSight-Data.md)** - Connecter Athena
- **[Visualizations](./10-QuickSight-Viz.md)** - Graphiques, tableaux, cartes
- **[Dashboards](./11-QuickSight-Dashboards.md)** - Créer et partager

### Avancé
- **[Performance Tuning](./12-Performance.md)** - Optimiser les requêtes
- **[Cost Optimization](./13-Costs.md)** - Réduire la facture
- **[Advanced Analytics](./14-Advanced.md)** - ML, anomalies, forecasting

### Référence
- **[SQL Reference](./SQL-Reference.md)** - Toutes les requêtes utiles
- **[CLI Commands](./CLI-Reference.md)** - Athena via AWS CLI
- **[Troubleshooting](./Troubleshooting.md)** - Erreurs courantes
- **[FAQ](./FAQ.md)** - Questions fréquentes

---

## 🎯 FLUX D'APPRENTISSAGE

### Parcours Débutant (4-6 heures)
```
1. Athena Basics (30 min)
   ├─ Qu'est-ce que Athena?
   ├─ Comment ça marche?
   └─ Cas d'usage

2. S3 & Data Organization (30 min)
   ├─ Préparer les données
   ├─ Formats supportés
   └─ Structure dossiers

3. Créer une table Athena (45 min)
   ├─ Créer base de données
   ├─ CREATE TABLE
   └─ Tester la table

4. Requêtes SQL (1 heure)
   ├─ SELECT basique
   ├─ Filtres
   └─ Agrégations

5. QuickSight Basics (1 heure)
   ├─ Setup
   ├─ Créer source Athena
   ├─ Visualisations simples
   └─ Partager tableau de bord
```

### Parcours Intermédiaire (8-12 heures)
```
1. Débutant (ci-dessus)

2. SQL Avancé (2 heures)
   ├─ JOINs
   ├─ Sous-requêtes
   ├─ Window functions
   └─ Agrégations complexes

3. Partitioning (1 heure)
   ├─ Partitionner par date/région
   └─ Optimiser les requêtes

4. Data Formats (1 heure)
   ├─ CSV vs Parquet
   ├─ Compression
   └─ Quand utiliser quoi?

5. QuickSight Avancé (2 heures)
   ├─ Visualisations complexes
   ├─ Parameters
   ├─ Calculated fields
   └─ Partager & permissions

6. Performance (1 heure)
   ├─ Query optimization
   ├─ Caching
   └─ Partitioning
```

### Parcours Avancé (15+ heures)
```
1. Tous les parcours ci-dessus

2. Architecture (2 heures)
   ├─ Data lakes
   ├─ ETL pipelines
   └─ Multi-source analytics

3. Cost Optimization (1 heure)
   ├─ Partitioning strategy
   ├─ Data compression
   └─ Query optimization

4. Advanced Analytics (2 heures)
   ├─ Machine learning
   ├─ Anomaly detection
   ├─ Forecasting
   └─ Custom metrics

5. Automation (2 heures)
   ├─ Scheduled queries
   ├─ Lambda triggers
   ├─ EventBridge
   └─ Dashboards auto-refresh

6. Governance (1 heure)
   ├─ Access control
   ├─ Data cataloging
   ├─ Compliance
   └─ Auditing
```

---

## 💡 CONCEPTS CLÉS

| Concept | Explication | Utilité |
|---------|-------------|---------|
| **Athena** | SQL sur S3 sans serveur | Requêtes ad-hoc sur données |
| **Query** | Requête SQL | Récupérer/analyser les données |
| **Table** | Ensemble de données | Structure des données |
| **Partition** | Sous-ensemble de données | Optimiser les requêtes |
| **Database** | Collection de tables | Organiser les données |
| **QuickSight** | Dashboard & visualisations | Voir les données graphiquement |
| **Dataset** | Source de données QuickSight | Connexion Athena/S3 |
| **Analysis** | Ensemble de visualisations | Créer dashboards |
| **Dashboard** | Version partagée | Montrer aux autres |
| **Parameter** | Variable dans dashboard | Filtrer dynamiquement |
| **S3** | Stockage des données | Où vivent les fichiers |
| **Parquet** | Format optimisé | Requêtes rapides |
| **CSV** | Format texte | Simple mais lent |

---

## 🏗️ ARCHITECTURE

```
┌─────────────┐
│  Data (S3)  │
│ CSV/Parquet │
└──────┬──────┘
       │
┌──────▼──────────────┐
│  Athena             │
│  (SQL Engine)       │
│  ├─ Queries         │
│  ├─ Tables          │
│  ├─ Partitions      │
│  └─ Metadata        │
└──────┬──────────────┘
       │
       ├─────────────────────┐
       │                     │
┌──────▼─────────┐   ┌───────▼──────────┐
│  Results (S3)  │   │  QuickSight      │
│  ├─ CSV        │   │  ├─ Datasets     │
│  ├─ JSON       │   │  ├─ Analyses     │
│  └─ Parquet    │   │  ├─ Dashboards   │
└────────────────┘   │  └─ Visualizations
                     └──────────────────┘
```

---

## 📊 COMPARAISON: Athena vs Alternatives

| Aspect | Athena | RDS | Redshift | BigQuery |
|--------|--------|-----|----------|----------|
| **Données** | S3 | DB managed | Data warehouse | Google Cloud |
| **Setup** | Seconds | Hours | Days | Google |
| **Coûts** | Pay-per-query | Fixed | Reserved | Pay-per-query |
| **Volume** | Petabytes | Gigabytes | Terabytes | Petabytes |
| **Latency** | Seconds | Milliseconds | Seconds | Seconds |
| **Idéal pour** | Ad-hoc | OLTP | Analytics | Analytics |

---

## 💰 COÛTS APPROXIMATIFS

```
Athena:
  ├─ $5 par TB scanné
  ├─ Gratuit: 1M requêtes/mois (free tier)
  └─ Exemple: 100 GB/mois = $0.50

QuickSight:
  ├─ $12/mois par utilisateur
  ├─ Essai gratuit: 1 mois
  └─ Ou payant à l'utilisation ($0.30/session)

S3:
  ├─ $0.023 par GB/mois (standard)
  └─ Exemple: 1 TB/mois = $23

────────────────────────────────
TOTAL: ~$35/mois (petit usage)
TOTAL: ~$150-500/mois (entreprise)
```

---

## 🚀 BESOIN D'AIDE RAPIDE?

### "Je viens de commencer"
- → **Athena Basics** (01-Athena-Basics.md)
- → **QuickSight Basics** (02-QuickSight-Basics.md)
- → **Setup guide** (08-QuickSight-Setup.md)

### "Je veux analyser mes données"
- → **S3 Organization** (03-S3-Data-Organization.md)
- → **Créer tables Athena** (04-Athena-Databases.md)
- → **Écrire requêtes SQL** (05-Athena-SQL.md)

### "Je veux créer des dashboards"
- → **Setup QuickSight** (08-QuickSight-Setup.md)
- → **Connecter Athena** (09-QuickSight-Data.md)
- → **Visualisations** (10-QuickSight-Viz.md)
- → **Dashboards** (11-QuickSight-Dashboards.md)

### "Je veux optimiser"
- → **Partitioning** (06-Athena-Partitioning.md)
- → **Data Formats** (07-Athena-Formats.md)
- → **Performance** (12-Performance.md)
- → **Costs** (13-Costs.md)

### "Je veux du SQL avancé"
- → **SQL Queries** (05-Athena-SQL.md)
- → **SQL Reference** (SQL-Reference.md)

### "J'ai une erreur"
- → **Troubleshooting** (Troubleshooting.md)
- → **FAQ** (FAQ.md)

---

## 📌 NOTES IMPORTANTES

- **Région:** `eu-west-3` (Paris)
- **Free Tier:** 1M requêtes Athena/mois
- **QuickSight Trial:** 1 mois gratuit
- **Data Format:** Parquet > CSV (plus rapide)
- **Partitioning:** Essentiel pour gros volumes
- **S3 Cost:** Peut être dominant avec gros données
- **Query Timeout:** 30 min par défaut
- **Concurrent Queries:** Illimité (mais peut être limité)

---

## ✅ CHECKLIST D'APPRENTISSAGE

```
Athena:
☐ Comprendre Athena basics
☐ Créer une database
☐ Uploader données S3
☐ Créer une table
☐ Écrire requête SELECT
☐ Filtrer avec WHERE
☐ Agréger avec COUNT/SUM
☐ Utiliser JOINs
☐ Partitionner les données
☐ Optimiser requêtes

QuickSight:
☐ Créer compte QuickSight
☐ Créer utilisateurs
☐ Connecter Athena
☐ Créer Dataset
☐ Créer Analysis
☐ Ajouter visualisations
☐ Publier Dashboard
☐ Partager avec d'autres

Advanced:
☐ Scheduled queries
☐ Parameters dans dashboards
☐ Machine learning
☐ Cost optimization
☐ Access control
```

---

## 🎁 CAS D'USAGE COURANTS

| Cas | Solution | Fichier |
|-----|----------|---------|
| **Analyser logs** | Athena + CloudWatch Logs | 03-S3-Data-Organization.md |
| **Dashboard KPIs** | Athena + QuickSight | 11-QuickSight-Dashboards.md |
| **Data Exploration** | Athena SQL | 05-Athena-SQL.md |
| **Rapports mensuels** | Scheduled queries | 12-Performance.md |
| **Anomaly detection** | QuickSight ML | 14-Advanced.md |
| **Coût AWS** | Cost Explorer | 13-Costs.md |
| **Data Warehouse** | Data Lake S3 + Athena | 03-S3-Data-Organization.md |

---

## 📚 RESSOURCES OFFICIELLES

- [Athena Documentation](https://docs.aws.amazon.com/athena/)
- [QuickSight Documentation](https://docs.aws.amazon.com/quicksight/)
- [Presto SQL Documentation](https://prestodb.io/docs/current/)
- [S3 Best Practices](https://docs.aws.amazon.com/s3/latest/dev/BestPractices.html)

---

## 📖 STRUCTURE DU COURS

```
Analytics-Masterclass/
│
├── README.md (ce fichier)
│
├── CONCEPTS FONDAMENTAUX
│   ├── 01-Athena-Basics.md
│   ├── 02-QuickSight-Basics.md
│   └── 03-S3-Data-Organization.md
│
├── ATHENA EN DÉTAIL
│   ├── 04-Athena-Databases.md
│   ├── 05-Athena-SQL.md
│   ├── 06-Athena-Partitioning.md
│   └── 07-Athena-Formats.md
│
├── QUICKSIGHT EN DÉTAIL
│   ├── 08-QuickSight-Setup.md
│   ├── 09-QuickSight-Data.md
│   ├── 10-QuickSight-Viz.md
│   └── 11-QuickSight-Dashboards.md
│
├── AVANCÉ
│   ├── 12-Performance.md
│   ├── 13-Costs.md
│   └── 14-Advanced.md
│
└── RÉFÉRENCE
    ├── SQL-Reference.md
    ├── CLI-Reference.md
    ├── Troubleshooting.md
    └── FAQ.md
```

---

## 🎓 APRÈS AVOIR TERMINÉ

**Sujets avancés à explorer:**
- Glue Data Catalog (metadata)
- EMR (cluster computing)
- Redshift (data warehouse)
- Lake Formation (data lake)
- SageMaker (machine learning)
- EventBridge (automation)

**Certifications:**
- AWS Certified Data Analytics
- AWS Solutions Architect
- AWS Data Engineer

---

**AWS Analytics Masterclass - Cours Complet 📚**

Commence avec [Athena Basics](./01-Athena-Basics.md) ou [QuickSight Basics](./02-QuickSight-Basics.md)!
