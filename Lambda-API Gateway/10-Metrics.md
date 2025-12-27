# Metrics - Monitorer Performance 📈

CloudWatch Metrics = graphiques automatiques pour surveiller votre Lambda.

---

## 🎯 OBJECTIF

Voir performance en temps réel et détecter problèmes (lenteur, erreurs, etc).

---

## 📊 DASHBOARD AUTOMATIQUE (Lambda)

Lambda crée automatiquement des graphiques :

### Accéder aux métriques

```
1. AWS Console > Lambda > my-api-function
2. Monitor (onglet)
3. Voir les 6 graphiques automatiques
```

---

## 📈 MÉTRIQUES PRINCIPALES

### 1. Invocations

```
┌─ Invocations (dernières 24h) ────────┐
│                                      │
│     █                                │
│     █ █     █ █                      │
│     █ █ █   █ █ █                    │
│ ────────────────────────────────────│
│ 0   6h  12h  18h  24h               │
│                                      │
│ Total: 1,523 requêtes                │
└──────────────────────────────────────┘
```

**Interprétation :**
- ✅ Montée = plus de demandes (bien pour API)
- ⚠️ Pics réguliers = traffic pattern
- ❌ Zéro = pas d'utilisation

---

### 2. Errors

```
┌─ Errors (dernières 24h) ─────────────┐
│                                      │
│ 3                                    │
│       █                              │
│ 2    █ █                             │
│ 1    █ █ █                           │
│ ────────────────────────────────────│
│ 0   6h  12h  18h  24h               │
│                                      │
│ Total: 15 erreurs (1% du total)      │
└──────────────────────────────────────┘
```

**Interprétation :**
- ✅ Zéro = aucune erreur (idéal)
- ⚠️ < 1% = acceptable
- ❌ > 5% = problème code

---

### 3. Duration (Temps exécution)

```
┌─ Duration (Average) ─────────────────┐
│                                      │
│ 100ms                                │
│  50ms  █                             │
│  40ms  █ █                           │
│  30ms  █ █ █                         │
│ ────────────────────────────────────│
│ 0   6h  12h  18h  24h               │
│                                      │
│ Average: 45 ms                       │
│ Min: 10 ms                           │
│ Max: 250 ms                          │
└──────────────────────────────────────┘
```

**Interprétation :**
- ✅ < 100ms = très rapide
- ⚠️ 100-500ms = acceptable
- ❌ > 1 sec = lent, optimiser

---

### 4. Memory Used

```
┌─ Memory Used (Average) ──────────────┐
│                                      │
│ 128 MB                               │
│  80 MB  █                            │
│  60 MB  █ █                          │
│  50 MB  █ █ █                        │
│ ────────────────────────────────────│
│ 0   6h  12h  18h  24h               │
│                                      │
│ Average: 65 MB / 128 MB (51%)        │
│ Peak: 95 MB                          │
└──────────────────────────────────────┘
```

**Interprétation :**
- ✅ < 60% = bonne marge
- ⚠️ 60-90% = acceptable
- ❌ > 90% = augmenter mémoire

---

### 5. Throttles

```
┌─ Throttles (dernières 24h) ──────────┐
│                                      │
│ (vide = bien !)                      │
│                                      │
│                                      │
│ ────────────────────────────────────│
│ 0   6h  12h  18h  24h               │
│                                      │
│ Total: 0 throttles                   │
└──────────────────────────────────────┘
```

**Interprétation :**
- ✅ Zéro = pas de problème
- ❌ > 0 = trop de requêtes concurrentes

---

### 6. Duration (percentiles)

```
┌─ Duration (p99, p95) ────────────────┐
│                                      │
│ 100ms                                │
│  50ms          p99 ─────             │
│  40ms    p95 ─────                   │
│  30ms ─────                          │
│ ────────────────────────────────────│
│ 0   6h  12h  18h  24h               │
│                                      │
│ p99: 120 ms (99% < 120 ms)           │
│ p95: 85 ms  (95% < 85 ms)            │
│ p50: 45 ms  (50% < 45 ms)            │
└──────────────────────────────────────┘
```

**Interprétation :**
- p99 = 99% des requêtes < 120ms
- p95 = 95% des requêtes < 85ms
- p50 = médiane 45ms

---

## 🎯 SIGNAUX D'ALERTE

### ❌ Erreurs > 1%

```
Cause probable:
- Code bug
- DB connection error
- Timeout
- Permission IAM

Solution:
1. Voir CloudWatch Logs
2. Chercher message d'erreur
3. Réparer code
```

### ❌ Duration > 5 sec

```
Cause probable:
- Code lent
- API call lent
- DB query lent

Solution:
1. Augmenter mémoire (boost CPU)
2. Optimiser code
3. Ajouter caching
4. Augmenter timeout
```

### ❌ Memory > 90%

```
Cause probable:
- Données trop grandes en mémoire
- Memory leak

Solution:
1. Augmenter mémoire
   Lambda > Configuration > Memory Size
2. Optimiser code
```

### ❌ Throttles > 0

```
Cause probable:
- Trop de requêtes concurrentes
- Limite dépassée (1000 par défaut)

Solution:
1. Augmenter concurrency limit
   Lambda > Configuration > Concurrency
2. Ajouter queue (SQS)
3. Réduire chaque requête
```

---

## 💻 VIA CLI

### Voir metrics

```bash
# Invocations dernières 24h
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=my-api-function \
  --statistics Sum \
  --start-time 2024-12-25T00:00:00Z \
  --end-time 2024-12-26T00:00:00Z \
  --period 3600 \
  --region eu-west-3
```

### Erreurs

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=my-api-function \
  --statistics Sum \
  --start-time 2024-12-25T00:00:00Z \
  --end-time 2024-12-26T00:00:00Z \
  --period 3600 \
  --region eu-west-3
```

### Duration moyenne

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=my-api-function \
  --statistics Average,Maximum \
  --start-time 2024-12-25T00:00:00Z \
  --end-time 2024-12-26T00:00:00Z \
  --period 3600 \
  --region eu-west-3
```

---

## 📊 DASHBOARD PERSONNALISÉ

Créer dashboard pour voir toutes les métriques ensemble :

```
1. CloudWatch > Dashboards > Create dashboard
2. Dashboard name: Lambda-Monitoring
3. Add widgets
4. Ajouter chaque métrique
5. Save
```

---

## 📌 NOTES

- **Metrics historiques** : 15 mois gratuit (CloudWatch)
- **Granularité** : 1 min default, 5 min pour custom metrics
- **Cost** : Metrics gratuit (free tier)
- **Alarms** : 10 gratuit/mois

---

[⬅️ Retour](./README.md) | [➡️ Alarms](./11-Alarms.md)

