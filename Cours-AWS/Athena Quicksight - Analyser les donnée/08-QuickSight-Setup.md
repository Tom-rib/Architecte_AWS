# QuickSight: Setup & Configuration 🎯

Comment créer et configurer Amazon QuickSight.

---

## S'inscrire à QuickSight

### Step 1: Aller à AWS Console
```
1. AWS Console → QuickSight
2. Cliquer "Sign up for QuickSight"
```

### Step 2: Choisir édition
```
Standard Edition:
  └─ $12/mois par utilisateur (recommandé)

Enterprise Edition:
  └─ $24/mois par utilisateur (features avancées)

Essai gratuit:
  └─ 1 mois gratuit (pas besoin de carte crédit)
```

### Step 3: Créer compte
```
1. Email d'administration
2. S3 access (choisir buckets)
3. Créer
```

---

## Créer des utilisateurs

### Admin User
```
QuickSight → Manage groups → Administrators
  → Ajouter administrateur (you)
  → Accès complet
```

### Analystes (Users)
```
QuickSight → Manage groups → Analysts
  → Add users
  → Peuvent créer analyses/dashboards
  → $12/mois chacun
```

### Readers (Viewers)
```
QuickSight → Readers
  → Peuvent voir dashboards
  → $0.30 par session (session = 30 min)
  → Pas d'accès création
```

---

## Activer Athena Access

QuickSight doit pouvoir accéder à Athena.

```
QuickSight → Manage QuickSight → Account Settings
  → Scroll down "Data and storage access"
  → Ajouter S3 buckets
  → Ajouter Athena access
```

---

## Connecter Athena

### Créer data source

```
1. QuickSight → Data Sources → New data source
2. Sélectionner "Athena"
3. Nommer: "Athena-Prod"
4. Choisir workgroup: "primary" (ou votre)
5. Create data source
```

### Tester la connexion

```
QuickSight → Data Sources → Athena-Prod
  → Test connection
  → Doit afficher: ✅ Connection successful
```

---

## Créer des datasets

### Dataset = Connexion Athena + Configuration

```
1. QuickSight → Datasets → New dataset
2. Sélectionner "Athena-Prod"
3. Choisir table (ex: customers)
4. Créer dataset

Options:
├─ Direct import (recommended)
│  └─ Importe directement Athena
├─ Query
│  └─ Requête SQL personnalisée
└─ Spreadsheet
   └─ Upload CSV
```

---

## Paramètres importants

### Refresh Settings
```
QuickSight → Datasets → Select dataset → Refresh
  ├─ Fréquence auto-refresh
  ├─ Heure (UTC)
  └─ Joua de la semaine
```

### Row Level Security (RLS)
```
Limiter les données par utilisateur

Exemple:
├─ Utilisateur "Alice" → voit que région "US"
├─ Utilisateur "Bob" → voit que région "EU"
└─ Administrateur → voit tout
```

### Spice (Caching)
```
Importez données en cache pour requêtes rapides

Sans Spice:
├─ Requête chaque fois → Plus lent

Avec Spice:
├─ Données cachées → Plus rapide
├─ Nécessite import → Moins de flexibilité
```

---

## Checklist Setup

```
☐ Créer compte QuickSight
☐ Choisir édition
☐ Créer admin user
☐ Activer Athena access
☐ Ajouter S3 buckets
☐ Créer data source Athena
☐ Tester connexion
☐ Créer datasets
☐ Configurer refresh
☐ Ajouter utilisateurs
```

---

**QuickSight Setup Terminé! ✅**
