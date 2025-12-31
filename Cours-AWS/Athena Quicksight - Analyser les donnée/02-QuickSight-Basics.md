# QuickSight Basics 📈

Qu'est-ce que Amazon QuickSight et comment créer des dashboards?

---

## Qu'est-ce que QuickSight?

**QuickSight** = Service AWS pour créer des **dashboards et visualisations** - Sans code.

```
Données (Athena) → QuickSight → Dashboards visuels
                             ├─ Graphiques
                             ├─ Tableaux
                             ├─ Cartes
                             └─ KPIs
```

**Avantage:** Visualisez vos données facilement - Pas besoin de programmer.

---

## Comment ça marche?

### 1. Créer un compte QuickSight
```
AWS Console → QuickSight → Sign up
(Essai gratuit 1 mois)
```

### 2. Créer une source de données
```
QuickSight → Data Sources → New data source
  ├─ Athena
  ├─ S3
  ├─ RDS
  ├─ Redshift
  └─ + 20 autres
```

### 3. Créer une analyse
```
QuickSight → Analyses → New analysis
  ├─ Sélectionner source de données
  ├─ Ajouter champs
  └─ Créer visualisations
```

### 4. Ajouter des visualisations
```
Analysi → Ajouter vis → Choisir type
  ├─ Bar chart
  ├─ Line chart
  ├─ Pie chart
  ├─ Table
  ├─ Heatmap
  └─ etc
```

### 5. Publier un dashboard
```
Analysis → Publish → Share → Dashboard publié
(Partageable avec d'autres utilisateurs)
```

---

## Types de visualisations

### Graphiques (Charts)

| Type | Utilité | Données |
|------|---------|---------|
| **Bar Chart** | Comparer catégories | Catégorique + Numérique |
| **Line Chart** | Tendance dans le temps | Temps + Numérique |
| **Pie Chart** | Parts du total | Catégorique + Numérique |
| **Scatter Plot** | Relation 2 variables | Numérique + Numérique |
| **Area Chart** | Accumulation dans le temps | Temps + Numérique |
| **Combo Chart** | Mix bar + line | Catégorique + 2x Numérique |

### Tableaux & Listes

| Type | Utilité |
|------|---------|
| **Table** | Données détaillées |
| **Pivot Table** | Croiser 2 dimensions |
| **KPI** | Nombre clé (ex: 1,234 clients) |

### Géométriques

| Type | Utilité |
|------|---------|
| **Map** | Données géographiques |
| **Heatmap** | Intensité par région |
| **Scatter (Geo)** | Points sur carte |

---

## Architecture QuickSight

```
┌──────────────────────────┐
│  Data Source             │
│  ├─ Athena               │
│  ├─ S3                   │
│  ├─ RDS                  │
│  └─ Redshift             │
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│  Dataset                 │
│  (Copy of data)          │
│  ├─ Calculated fields    │
│  ├─ Joins                │
│  └─ Filters              │
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│  Analysis                │
│  (Interactive view)      │
│  ├─ Visualizations       │
│  ├─ Parameters           │
│  └─ Filters              │
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│  Dashboard               │
│  (Published view)        │
│  ├─ Read-only           │
│  ├─ Shareable           │
│  └─ Auto-refresh        │
└──────────────────────────┘
```

---

## Dataset vs Analysis vs Dashboard

### Dataset
Connexion à vos données + transformations.

```
Données brutes → Dataset
├─ Join tables
├─ Filter rows
├─ Add calculations
└─ Aggregate data
```

### Analysis
Version interactive où vous créez/expérimentez.

```
Dataset → Analysis
├─ Add visualizations
├─ Change filters
├─ Adjust parameters
└─ Test things out
```

### Dashboard
Version publiée pour partager avec d'autres.

```
Analysis → Dashboard
├─ Read-only (pour viewers)
├─ Scheduled refresh
├─ Sharing permissions
└─ Public ou privé
```

---

## Concepts Clés

### Field (Champ)
Une colonne dans vos données.

```
Exemple:
├─ customer_id (numérique)
├─ customer_name (texte)
├─ purchase_amount (numérique)
└─ purchase_date (date)
```

### Dimension
Champ catégorique (texte, date, catégorie).

```
Exemple:
├─ Country (USA, France, Germany)
├─ Product (A, B, C)
└─ Date (2024-01-01, 2024-01-02)
```

### Measure
Champ numérique (nombre).

```
Exemple:
├─ Sales amount ($)
├─ Quantity (pièces)
└─ Count (nombre)
```

### Visual (Visualisation)
Un graphique ou tableau.

```
Types:
├─ Bar chart
├─ Line chart
├─ Pie chart
├─ Table
└─ Map
```

### Parameter
Variable pour filtrer dynamiquement.

```
Exemple:
├─ Date range (De / À)
├─ Country (dropdown)
└─ Product (multi-select)
```

---

## Pricing

### Modèle de coûts

```
Édition Standard:
  └─ $12 par utilisateur/mois

Édition Enterprise:
  └─ $24 par utilisateur/mois

Par Session:
  └─ $0.30 par session (session = 30 min)

Free Trial:
  └─ 1 mois gratuit
```

**Exemple:**
```
Équipe de 5 analystes:
├─ 5 × $12/mois = $60/mois
└─ Plus partage (readers): $0.30/session
```

---

## Avantages vs Limitations

### Avantages
✅ **Sans code** - Drag & drop
✅ **Rapide** - Dashboards en minutes
✅ **Beau** - Visuels professionnels
✅ **Collaboratif** - Partage facile
✅ **Intégré** - Fonctionne avec Athena/RDS/Redshift
✅ **ML** - Anomalies, forecasting automatique
✅ **Mobile** - Apps mobile iOS/Android

### Limitations
❌ **Limite visuelle** - Pas pour programmation avancée
❌ **Coûts utilisateurs** - $12 par personne/mois
❌ **Pas temps réel** - 1-2 sec latency minimum
❌ **Limite requêtes** - 10,000 rows max par visual

---

## Quand utiliser QuickSight vs alternatives?

```
QuickSight:
├─ Dashboards AWS
├─ Équipes techniques
├─ Setup rapide
└─ Intégration Athena

Tableau:
├─ Visuals très avancées
├─ Équipes data analysts
├─ Plus flexible
└─ Plus cher

Power BI:
├─ Microsoft environment
├─ Office 365 users
├─ Less coûteux
└─ Moins de features

Grafana:
├─ Temps réel
├─ Monitoring
├─ Infrastructure
└─ Self-hosted
```

---

## Cas d'usage

### ✅ BON CAS
- KPIs dashboards
- Sales analytics
- Customer analysis
- Operational metrics
- Executive reports
- Real-time monitoring (+ 1sec)
- Budget tracking

### ❌ MAUVAIS CAS
- Programmation avancée
- Custom visualizations
- Vraiment temps réel (< 100ms)
- Très gros datasets (> 1M rows)
- Self-hosted/on-premise

---

## Prochains pas

→ **[QuickSight Setup](./08-QuickSight-Setup.md)** - Créer et configurer

→ **[Connecter Athena](./09-QuickSight-Data.md)** - Data sources

→ **[Visualisations](./10-QuickSight-Viz.md)** - Créer des graphiques

→ **[Dashboards](./11-QuickSight-Dashboards.md)** - Publier et partager

---

**QuickSight Basics Terminé! ✅**
