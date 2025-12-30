# QuickSight: Visualizations 📊

Comment créer des graphiques et visualisations.

---

## Créer une analyse

```
1. QuickSight → Analyses → Create analysis
2. Sélectionner dataset (ex: customers)
3. Create analysis
```

---

## Ajouter une visualisation

```
Analysis → Add visual
  → Choisir type de graphique
  → Configure les champs
  → Ajouter à l'analysis
```

---

## Types de graphiques courants

### Bar Chart (comparaison)

```
Utilité: Comparer des catégories

Exemple: Clients par pays
├─ X-axis: country
├─ Y-axis: COUNT(customer_id)
└─ Resultat: Barres par pays
```

### Line Chart (tendance)

```
Utilité: Voir évolution dans le temps

Exemple: Ventes par mois
├─ X-axis: month
├─ Y-axis: SUM(amount)
└─ Resultat: Courbe montante/descendante
```

### Pie Chart (parts)

```
Utilité: Montrer % du total

Exemple: Clients par région
├─ Slices: country
├─ Value: COUNT(customer_id)
└─ Resultat: Cercle divisé
```

### Table (détails)

```
Utilité: Voir données brutes

Exemple: Liste de clients
├─ Colonnes: name, email, country
├─ Rows: Tous les clients
└─ Resultat: Tableau lisible
```

### KPI (nombre clé)

```
Utilité: Afficher un nombre important

Exemple: Total clients
├─ Primary value: COUNT(*)
├─ Trend: Croissance %
└─ Resultat: "12,345 ↑ +5%"
```

### Map (géographique)

```
Utilité: Visualiser par localisation

Exemple: Ventes par région
├─ Geo field: country/state
├─ Value: SUM(amount)
└─ Resultat: Heatmap du monde
```

---

## Configurer une visualisation

### Fields

```
Drag & drop champs:
├─ Dimensions (texte, date)
│  └─ Utiliser comme catégories (X-axis, colors, etc)
├─ Measures (nombres)
│  └─ Utiliser comme valeurs (Y-axis, sizes, etc)
```

### Filters

```
Ajouter filtres:
├─ Visual-level filter (affecte juste ce graphique)
├─ Page-level filter (affecte tous graphiques)
└─ Dataset-level filter (permanent dans dataset)
```

### Aggregations

```
QuickSight agrège automatiquement:
├─ COUNT(*) pour comptage
├─ SUM() pour totaux
├─ AVG() pour moyennes
├─ MIN/MAX pour extrêmes
```

---

## Calculated Fields

Créer des colonnes calculées.

```
Example: Région d'une adresse

1. Analyses → Add → Calculated field
2. Formule: IF(country IN ('FR', 'DE', 'ES'), 'EU', 'Other')
3. Utiliser dans graphiques
```

---

## Parameters (Filtres dynamiques)

Créer des variables pour filtrer.

```
Example: Filtrer par pays

1. Analysis → Add parameter
   Name: Country
   Type: Single select
   Values: {USA, France, Germany, Spain}
2. Ajouter à graphiques
3. Dashboard users peuvent changer la valeur
```

---

## Checklist Visualisations

```
☐ Créer analyse
☐ Ajouter au moins 3 graphiques
├─ 1 Bar chart
├─ 1 Line chart
├─ 1 Table ou KPI
☐ Configurer filtres
☐ Ajouter calculated fields (si besoin)
☐ Tester interactions
☐ Nommer les visualisations
```

---

**Visualizations Terminé! ✅**
