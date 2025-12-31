# CloudWatch Basics 📊

CloudWatch = service de monitoring AWS pour Lambda et API Gateway.

---

## 🎯 QU'EST-CE QUE CLOUDWATCH ?

CloudWatch = tableau de bord centralisé pour surveiller :

- **Logs** : Voir logs d'exécution Lambda en temps réel
- **Metrics** : Graphiques de performance (invocations, erreurs, durée)
- **Alarms** : Alertes automatiques si problèmes
- **Dashboards** : Vue d'ensemble personnalisée

---

## 📊 COMPOSANTS PRINCIPAUX

| Composant | Utilité | Accès |
|-----------|---------|-------|
| **Logs** | Déboguer + voir output | CloudWatch > Logs |
| **Metrics** | Performance graphiques | CloudWatch > Metrics |
| **Alarms** | Notifications | CloudWatch > Alarms |
| **Dashboards** | Vue globale | CloudWatch > Dashboards |

---

## 🎯 UTILISATIONS COURANTES

### 1. Voir les logs Lambda (déboguer)

```
CloudWatch > Logs > /aws/lambda/my-api-function
→ [09-Lambda-Logs.md](./09-Lambda-Logs.md)
```

### 2. Monitorer performance

```
CloudWatch > Metrics > AWS/Lambda
→ [10-Metrics.md](./10-Metrics.md)
```

### 3. Créer alertes (notifications)

```
CloudWatch > Alarms > Create alarm
→ [11-Alarms.md](./11-Alarms.md)
```

---

## 🖼️ ACCÉDER À CLOUDWATCH

```
1. AWS Console > CloudWatch
2. Dans menu gauche:
   - Logs > Log groups
   - Metrics > AWS Services
   - Alarms > All alarms
   - Dashboards > All dashboards
```

---

## 📌 NOTES

- **Logs** : Gratuit (5 GB/mois free tier)
- **Metrics** : Gratuit (historique 15 mois)
- **Alarms** : 10 gratuit/mois (free tier)
- **Dashboards** : Gratuit illimité

---

## 🚀 NEXT STEPS

1. **Déboguer :** [09-Lambda-Logs.md](./09-Lambda-Logs.md)
2. **Monitorer :** [10-Metrics.md](./10-Metrics.md)
3. **Alertes :** [11-Alarms.md](./11-Alarms.md)

---

[⬅️ Retour](./README.md) | [➡️ Logs](./09-Lambda-Logs.md)

