# CloudWatch - Guide Complet & Référence 🔍

Service AWS pour monitorer, enregistrer et analyser **tous vos services** en temps réel.

---

## TABLE DES MATIÈRES

1. [Qu'est-ce que CloudWatch ?](#qu-est-ce-que-cloudwatch-)
2. [Types de Données](#types-de-données)
3. [Logs CloudWatch](#logs-cloudwatch)
4. [Metrics CloudWatch](#metrics-cloudwatch)
5. [Alarms CloudWatch](#alarms-cloudwatch)
6. [Dashboards](#dashboards)
7. [Log Insights](#log-insights)
8. [Rétention & Coûts](#rétention--coûts)
9. [Best Practices](#best-practices)

---

## Qu'est-ce que CloudWatch ?

CloudWatch est le **système de monitoring centralisé d'AWS**. Il collecte :

- **Logs** : Tous les messages d'exécution (Lambda, EC2, RDS, etc)
- **Metrics** : Données quantifiables (CPU, RAM, erreurs, durée)
- **Alarms** : Alertes automatiques basées sur des seuils
- **Dashboards** : Visualisations personnalisées

### Comparaison avec d'autres outils

| Outil | CloudWatch | DataDog | NewRelic | Prometheus |
|---|---|---|---|---|
| **Coût** | Gratuit (basic) | 15$/mois | 40$/mois | Gratuit |
| **Intégration AWS** | Native | Plugin | Plugin | Plugin |
| **Logs** | ✅ Oui | ✅ Oui | ✅ Oui | ❌ Non |
| **Metrics** | ✅ Oui | ✅ Oui | ✅ Oui | ✅ Oui |
| **Alarms** | ✅ Oui | ✅ Oui | ✅ Oui | ✅ Oui |
| **Setup** | Minimal | Facile | Facile | Complexe |
| **Idéal pour** | AWS seulement | Multi-cloud | Multi-cloud | Open source |

---

## Types de Données

### 1. LOGS

**Définition** : Messages texte produits par vos applications

**Sources** :
- Lambda (print, logger.info, logger.error)
- EC2 (logs système, applications)
- RDS (logs database)
- API Gateway (requêtes HTTP)
- CloudTrail (actions AWS)
- Applications custom

**Exemple** :
```
2025-12-27T15:30:45.123Z  [INFO]  Requete: GET /api/users
2025-12-27T15:30:46.456Z  [ERROR] Database connection failed
2025-12-27T15:30:47.789Z  [INFO]  Response sent: 200 OK
```

**Avantages** :
- Détails complets
- Debugging facile
- Historique complet

**Inconvénients** :
- Stockage lourd
- Moins facile à analyser (besoin Log Insights)
- Coûteux si volume énorme

---

### 2. METRICS

**Définition** : Données numériques mesurables sur le temps

**Sources Automatiques** :
- **EC2** : CPU, Réseau entrant/sortant, Disque
- **Lambda** : Durée (ms), Erreurs (count), Invocations (count)
- **RDS** : Connexions actives, Read/Write Latency, CPU
- **API Gateway** : Erreurs 4xx, 5xx, Latence
- **S3** : Requêtes (count), Bytes
- **DynamoDB** : Read/Write Capacity, Throttles
- **ELB** : Requêtes, Latence, Target Health

**Sources Personnalisées** :
- Envoyer vos propres métriques depuis code
- Exemple : "nombre d'utilisateurs connectés", "transactions par seconde"

**Format** :
```
Métrique = Nom + Timestamp + Valeur + Dimensions

Exemple:
- Nom: CPUUtilization
- Valeur: 45.2 (%)
- Timestamp: 2025-12-27T15:30:45Z
- Dimensions: InstanceId=i-1234567890abcdef0, ImageId=ami-0123456789
```

**Granularité** :
- Standard : 1 minute (automatique)
- Détaillée : 10 ou 30 secondes (payant, 0.30€/mois par métrique)

**Avantages** :
- Léger et rapide
- Facile à représenter graphiquement
- Peu cher

**Inconvénients** :
- Moins de détails
- Impossible de retracer exactement quand un événement s'est produit

---

### 3. ALARMS

**Définition** : Actions automatiques quand une métrique dépasse un seuil

**Types** :
1. **Metric Alarm** : Basée sur 1 métrique
2. **Composite Alarm** : Basée sur plusieurs alarms
3. **Anomaly Detection Alarm** : Basée sur patterns anormaux

**Exemple** :
```
Alarme: "CPU EC2 > 80%"
│
├─ SI TRUE pendant 2 minutes
│  └─ ALORS envoyer email
│
└─ SI FALSE pendant 5 minutes
   └─ ALORS envoyer "OK" email
```

**Actions possibles** :
- SNS (envoyer notification)
- Auto Scaling (augmenter/diminuer instances)
- EC2 (rebooter instance)
- Lambda (exécuter fonction)
- OpsCenter (ticket)
- CodePipeline (déclencher pipeline)

**Avantages** :
- Automation complète
- Notification instantanée
- Actions automatiques

---

### 4. DASHBOARDS

**Définition** : Visualisations personnalisées de vos métriques

**Contenu possible** :
- Graphiques linéaires (évolution CPU dans le temps)
- Graphiques en barres (comparaison)
- Nombres (valeur actuelle)
- Texte (notes)
- Tables (derniers logs)

**Exemple** :
```
Dashboard "Production Monitoring"
├─ [Graphique] CPU EC2: 45%
├─ [Graphique] Lambda Errors: 0.5%
├─ [Nombre] RDS Connexions: 120 / 200
├─ [Graphique] API Latency: 250ms
└─ [Table] Dernières erreurs
```

**Avantages** :
- Vue d'ensemble rapide
- Partageable avec l'équipe
- Personnalisable

**Coût** :
- 3 premiers dashboards GRATUIT
- Après : 3€/mois par dashboard

---

## Logs CloudWatch

### Comment fonctionnent les Logs

```
EC2 / Lambda / RDS
    ↓ (envoie logs)
CloudWatch Logs
    ├─ Log Group (application)
    │   └─ Log Stream (instance/exécution)
    │       └─ Log Event (message)
    │
    ├─ Stockage: S3 (archivage)
    ├─ Analyse: CloudWatch Logs Insights (requêtes)
    └─ Alarms: Metric Filters (créer alarmes)
```

### Log Groups

**Qu'est-ce ?** : Conteneur pour tous les logs d'une application

**Exemples** :
- `/aws/lambda/hello-api` → Logs de fonction Lambda
- `/aws/ec2/production` → Logs d'instance EC2
- `/aws/rds/database-1` → Logs de RDS
- `/custom/myapp` → Logs custom

**Propriétés** :
- **Rétention** : 1 jour à never (par défaut : never)
- **KMS Encryption** : Chiffrer les logs
- **Retention Policy** : Supprimer anciens logs automatiquement

### Log Streams

**Qu'est-ce ?** : Séquence de logs d'une source spécifique

**Exemples** :
- Lambda : 1 stream par exécution (ID de request)
- EC2 : 1 stream par instance
- RDS : 1 stream par type d'erreur

### Rétention

```
Options:
- Never expire (jamais supprimer)
- 1 day
- 3 days
- 1 week
- 2 weeks
- 1 month
- 45 days
- 60 days
- 90 days
- 6 months
- 1 year
- 5 years (max)

Coût:
- 0.50€ par GB stocké / mois
- Après 5 ans, considérer archivage S3
```

---

## Metrics CloudWatch

### Métriques Standard (Gratuites)

**EC2** :
- CPUUtilization (%)
- NetworkIn / NetworkOut (bytes)
- DiskReadOps / DiskWriteOps
- CPUCreditBalance (T-instances)

**Lambda** :
- Duration (ms)
- Errors (count)
- Invocations (count)
- Throttles (count)
- ConcurrentExecutions (count)
- OffthePeakTimeSeconds (if on-demand)

**RDS** :
- DatabaseConnections (count)
- CPUUtilization (%)
- DatabaseConnections (count)
- ReadLatency / WriteLatency (ms)
- ReadThroughput / WriteThroughput (bytes/sec)

**API Gateway** :
- 4XXError / 5XXError (count)
- Latency (ms)
- Count (requêtes totales)
- IntegrationLatency (ms)

### Métriques Personnalisées

**Comment envoyer** :

```python
import boto3

cloudwatch = boto3.client('cloudwatch')

cloudwatch.put_metric_data(
    Namespace='MyApp',
    MetricData=[
        {
            'MetricName': 'ActiveUsers',
            'Value': 150,
            'Unit': 'Count',
            'Timestamp': datetime.now()
        }
    ]
)
```

**Exemples d'utilisation** :
- Nombre d'utilisateurs connectés
- Transactions par seconde
- Longueur de queue
- Score de satisfaction client
- Coût par requête

**Coût** :
- 50 premières métriques/mois : GRATUIT
- Après : 0.30€ par métrique/mois

---

## Alarms CloudWatch

### Types d'Alarms

#### 1. Metric Alarms

```
Basée sur 1 métrique
│
Exemple:
  Alarme: "CPU > 80%"
  │
  ├─ Condition: CPUUtilization >= 80
  ├─ Durée: 2 minutes (pour éviter faux positif)
  ├─ Statistic: Average (ou Max, Min, Sum, SampleCount)
  │
  ├─ SI TRUE
  │  └─ Action: Envoyer SNS
  │
  └─ SI FALSE (OK)
     └─ Action: Envoyer "OK" SNS
```

#### 2. Composite Alarms

```
Basée sur plusieurs alarms
│
Exemple:
  Alarme: "Plusieurs erreurs"
  │
  └─ IF (Lambda Errors > 1%) AND (API Latency > 1s)
     THEN Send Alert
```

#### 3. Anomaly Detection Alarms

```
Basée sur patterns anormaux
│
Exemple:
  Alarme: "CPU anormal"
  │
  └─ ML détecte pattern normal
     │
     SI deviation > 2 sigma
     THEN Send Alert
```

### Statistiques

```
Stat: Average
- Exemple: CPU moyen sur 5 minutes

Stat: Maximum
- Exemple: Pic CPU sur 5 minutes

Stat: Minimum
- Exemple: CPU min sur 5 minutes

Stat: Sum
- Exemple: Total d'erreurs sur 5 minutes

Stat: SampleCount
- Nombre de points de données
```

### États de l'Alarme

```
OK (vert) : Condition FALSE
│
├─ CPU < 80%
├─ Erreurs < 1%
└─ Tout normal

ALARM (rouge) : Condition TRUE
│
├─ CPU >= 80%
├─ Erreurs >= 1%
└─ Action déclenchée

INSUFFICIENT_DATA (gris) : Pas assez de données
│
├─ Juste créée
├─ Pas de historique
└─ Attendre 5 min
```

---

## Dashboards

### Créer un Dashboard

1. CloudWatch Console > Dashboards > Create Dashboard
2. Ajouter widgets
3. Choisir métriques
4. Personnaliser (titre, couleur, etc)

### Types de Widgets

| Widget | Usage |
|---|---|
| Line Chart | Tendance dans le temps |
| Stacked Area | Comparaison cumulée |
| Number | Valeur actuelle |
| Bar Chart | Comparaison |
| Gauge | Indicateur (0-100) |
| Log | Voir logs |
| Metric Math | Calcul personnalisé |

---

## Log Insights

### Requêtes CloudWatch Logs Insights

**Langage** : Spécial CloudWatch (pas SQL)

**Exemples** :

```
# Tous les logs
fields @timestamp, @message

# Logs avec erreur
fields @timestamp, @message | filter @message like /ERROR/

# Compter erreurs par minute
stats count() as ErrorCount by bin(5m)

# Top 10 erreurs
stats count() as count by @message | sort count desc | limit 10

# Latency percentile
stats pct(@duration, 95) as p95_latency

# Erreurs dans les 5 dernières minutes
fields @timestamp, @message | filter @timestamp > ago(5m) and level = "ERROR"
```

**Coût** :
- 0.55€ par GB analysé
- Requête gratuite 1x/jour (premier 1GB)

---

## Rétention & Coûts

### Coûts CloudWatch

```
Logs
├─ 0.50€ / GB stocké / mois
├─ 0.05€ / GB ingéré
└─ 0.55€ / GB analysé (Logs Insights)

Metrics
├─ Custom Metrics: 0.30€ / métrique / mois (après 50 free)
└─ API Requests: 0.01€ / 1000 requêtes

Alarms
├─ 0.10€ / alarm / mois (après 10 free)
└─ Composite Alarms: 0.50€ / mois (après 1 free)

Dashboards
├─ 3€ / dashboard / mois (après 3 free)

Log Groups
├─ Free Tier: 5GB logs / 1000 metric filters
```

### Optimisation Coûts

```
1. Réduire rétention logs
   - Default: never (TRÈS cher)
   - Meilleur: 7-30 jours

2. Archiver en S3
   - Subscription Filter → S3
   - Garder 1 semaine CloudWatch
   - Historique 1 an en S3 (moins cher)

3. Filtrer logs au source
   - Ne logger que l'essentiel
   - Moins d'envoi = moins cher

4. Limiter custom metrics
   - 50 free/mois
   - Au delà: très cher
   - Choisir bien lesquelles

5. Désactiver unused dashboards
   - 3€/mois par dashboard
   - Supprimer les anciennes
```

---

## Best Practices

### 1. Nommage

```
❌ MAUVAIS
/logs
/app-logs
/production

✅ BON
/aws/lambda/hello-api
/aws/ec2/production-web-servers
/custom/myapp/payment-service
```

### 2. Rétention

```
Données sensibles
├─ 30 jours (garder assez pour debugging)

Production
├─ 7-14 jours (balance coûts/historique)

Development
├─ 1-3 jours (moins important)

Archive long-term
├─ S3 Glacier (très pas cher)
```

### 3. Alarms

```
❌ MAUVAIS
- Alarme pour chaque métrique
- Threshold trop strict
- Pas d'état INSUFFICIENT_DATA

✅ BON
- Alarmes pour seuils critiques
- Threshold basé sur historique
- Gestion état INSUFFICIENT_DATA
- Composite alarms pour logique complexe
```

### 4. Logs

```
❌ MAUVAIS
- Log tout (chaque ligne de code)
- Logs sans timestamp
- Mélanger erreurs et info

✅ BON
- Log structure (JSON)
- Niveaux: DEBUG, INFO, WARN, ERROR
- Include contexte (user ID, request ID)
- Correlation ID entre services
```

### 5. Monitoring Multi-Service

```
✅ Créer 1 Dashboard Central
├─ Vue d'ensemble production
├─ Toutes les métriques clés
└─ Update en temps réel

✅ Créer Alarms Interconnectées
├─ 1 Topic SNS principal
├─ Toutes les alarms → ce topic
└─ Facile à gérer
```

---

## Foire aux Questions

**Q: Logs gratuits combien ?**
A: 5GB/mois inclus dans free tier

**Q: Métriques gratuites combien ?**
A: Illimitées (standard), 50 custom metrics/mois

**Q: Alarms gratuites combien ?**
A: 10 alarms/mois

**Q: Combien de logs garder ?**
A: Dépend, 7-30 jours est bon balance

**Q: Peut-on filtrer logs avant stockage ?**
A: Oui, avec Subscription Filters

**Q: Archived logs en S3 combien coûte ?**
A: 0.024€ / GB / mois (vs 0.50€ CloudWatch)

---

**SUITE** : Voir 02-SNS-Concepts-Complets.md pour notifications
